# frozen_string_literal: true

# Typical implementation for actions: create, destroy, new, show, update.
module Crud
  ALL_ACTIONS = %i[create destroy new show update].freeze

  DEFAULT_ACTIONS_FOR_FILTERS = {
    init_object: %i[create new],
    find_object: %i[destroy show update],
    set_attributes_from_params: %i[create update],
    set_attributes_from_session: %i[new show],
  }.freeze

  # :no_doc:
  # @param controller_class [ActionController::Base]
  # @param actions [Array<Symbol>]
  # @return [void]
  def self.add_filters(controller_class, actions)
    controller_class.class_eval do
      DEFAULT_ACTIONS_FOR_FILTERS.each do |mth, default_actions|
        only = actions & default_actions
        before_action(mth, only:) if only.present?
      end
    end
  end

  # :no_doc:
  # @param controller_class [ActionController::Base]
  # @param actions [Array<Symbol>]
  # @return [void]
  def self.add_methods(controller_class, actions)
    InstanceMethods::MODULES_FOR_ACTIONS.slice(*actions).each_value do |modules|
      modules.each { |mod| controller_class.include(mod) }
    end
  end

  # Method for DSL.
  def crud(&)
    configurator = Configurator.new
    configurator.instance_eval(&)

    singleton_class.attr_reader(:crud_options)
    singleton_class.instance_variable_set(:@crud_options, configurator.config.freeze)

    actions = configurator.config[:actions] || ALL_ACTIONS

    Crud.add_filters(self, actions)
    Crud.add_methods(self, actions)
  end

  # Helper class for initialization of CRUD options.
  class Configurator
    attr_reader :config

    def initialize
      @config = {attributes: {}, paths: {}}
    end

    # @param array [Array<String>]
    # @param hash [Hash<String, Array | Hash | String>]
    def attributes(array, hash = {})
      @config[:attributes][:permit] = array + [hash]
      @config[:attributes][:slice] = array + hash.keys
    end

    %i[actions class_name item_name].each do |mth|
      define_method(mth) { |value| @config[mth] = value }
    end

    %i[index new show].each do |mth|
      define_method(:"#{mth}_path") { |&block| @config[:paths][mth] = block }
    end
  end

  # Methods for instance of controller class.
  module InstanceMethods
    # Methods for all supported actions.
    module AllActions
      private

      # @see Configurator
      def crud_options
        @crud_options ||= self.class.singleton_class.instance_variable_get(:@crud_options)
      end

      # Helper method for accessing model instance.
      def object
        instance_variable_get(:"@#{crud_options[:item_name]}")
      end

      # Helper method for changing model instance.
      def object=(value)
        instance_variable_set(:"@#{crud_options[:item_name]}", value)
      end
    end

    # Methods for `create` action.
    module Create
      # Create record.
      def create
        return redirect_to(object_path(:show)) if object.save

        store_errors_and_params
        redirect_to(object_path(:new))
      end
    end

    # Methods for `create`, `destroy` & `update` actions.
    module CreateDestroyUpdate
      private

      # Helper method for accessing application path for model instance.
      def object_path(key)
        block = crud_options[:paths][key]
        instance_eval(&block)
      end
    end

    # Methods for `create` & `new` actions.
    module CreateNew
      private

      # Initialize empty object.
      def init_object
        self.object = crud_options[:class_name].constantize.new
      end
    end

    # Methods for `create` & `update` actions.
    module CreateUpdate
      private

      # @return [Hash-like]
      def permitted_params
        param_key = crud_options[:class_name].underscore.gsub("/", "_")
        params.require(param_key).permit(*crud_options[:attributes][:permit])
      end

      # Set attributes in object (from params hash).
      def set_attributes_from_params
        object.attributes = permitted_params
      end

      # Store received data & object errors into session.
      def store_errors_and_params
        flash[:alert] = "Error(s) occured: #{object.errors.to_hash.to_json}"
        session["#{controller_path}##{action_name}"] = permitted_params.to_h
      end
    end

    # Methods for `destroy` action.
    module Destroy
      # Delete record.
      def destroy
        flash[:alert] = "Error(s) occured: #{object.errors.to_hash.to_json}" unless object.destroy

        redirect_to(object_path(:index))
      end
    end

    # Methods for `destroy`, `show` & `update` actions.
    module DestroyShowUpdate
      private

      # Find record in table.
      def find_object
        self.object = crud_options[:class_name].constantize.find(params[:id])
      end
    end

    # Methods for `new` action.
    module New
      # Show form for new record.
      def new
        # nothing
      end
    end

    # Methods for `new` & `show` actions.
    module NewShow
      private

      SESSION_KEY = {"new" => :create, "show" => :update}.freeze

      private_constant :SESSION_KEY

      # Set attributes in object (from session hash).
      def set_attributes_from_session
        values = session.delete("#{controller_path}##{SESSION_KEY.fetch(action_name)}")
        object.attributes = values&.slice(*crud_options[:attributes][:slice]) || {}
      end
    end

    # Methods for `show` action.
    module Show
      # Show form for existing record.
      def show
        # nothing
      end
    end

    # Methods for `update` action.
    module Update
      # Change record.
      def update
        store_errors_and_params unless object.save

        redirect_to(object_path(:show))
      end
    end

    MODULES_FOR_ACTIONS = {
      create: [AllActions, Create, CreateDestroyUpdate, CreateNew, CreateUpdate],
      destroy: [AllActions, CreateDestroyUpdate, Destroy, DestroyShowUpdate],
      new: [AllActions, CreateNew, New, NewShow],
      show: [AllActions, DestroyShowUpdate, NewShow, Show],
      update: [AllActions, CreateDestroyUpdate, CreateUpdate, DestroyShowUpdate, Update],
    }.freeze
  end
end
