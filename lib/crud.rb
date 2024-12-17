# frozen_string_literal: true

# Typical implementation for actions: create, destroy, new, show, update.
module Crud
  # Method for DSL.
  def crud(&)
    configurator = Configurator.new
    configurator.instance_eval(&)

    before_action(:init_object, only: %i[create new])
    before_action(:find_object, only: %i[destroy show update])
    before_action(:set_attributes_from_params, only: %i[create update])
    before_action(:set_attributes_from_session, only: %i[new show])

    singleton_class.attr_reader(:crud_options)
    singleton_class.instance_variable_set(:@crud_options, configurator.config.freeze)

    include(Crud::InstanceMethods)
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

    %i[class_name item_name].each { |mth| define_method(mth) { |value| @config[mth] = value } }

    %i[index new show].each do |mth|
      define_method(:"#{mth}_path") { |&block| @config[:paths][mth] = block }
    end
  end

  # Methods for instance of controller class.
  module InstanceMethods
    # Create record.
    def create
      return redirect_to(object_path(:show)) if object.save

      store_errors_and_params
      redirect_to(object_path(:new))
    end

    # Delete record.
    def destroy
      flash[:alert] = "Error(s) occured: #{object.errors.to_hash.to_json}" unless object.destroy

      redirect_to(object_path(:index))
    end

    # Show form for new record.
    def new
      # nothing
    end

    # Show form for existing record.
    def show
      # nothing
    end

    # Change record.
    def update
      store_errors_and_params unless object.save

      redirect_to(object_path(:show))
    end

    private

    SESSION_KEY = {"new" => :create, "show" => :update}.freeze

    private_constant :SESSION_KEY

    # @see Configurator
    def crud_options
      @crud_options ||= self.class.singleton_class.instance_variable_get(:@crud_options)
    end

    # Find record in table.
    def find_object
      self.object = crud_options[:class_name].constantize.find(params[:id])
    end

    # Initialize empty object.
    def init_object
      self.object = crud_options[:class_name].constantize.new
    end

    # Helper method for accessing model instance.
    def object
      instance_variable_get(:"@#{crud_options[:item_name]}")
    end

    # Helper method for changing model instance.
    def object=(value)
      instance_variable_set(:"@#{crud_options[:item_name]}", value)
    end

    # Helper method for accessing application path for model instance.
    def object_path(key)
      block = crud_options[:paths][key]
      instance_eval(&block)
    end

    # Set attributes in object (from params hash).
    def set_attributes_from_params
      param_key = crud_options[:class_name].parameterize(separator: "_")
      object.attributes = params.require(param_key).permit(*crud_options[:attributes][:permit])
    end

    # Set attributes in object (from session hash).
    def set_attributes_from_session
      values = session.delete("#{controller_path}##{SESSION_KEY.fetch(action_name)}")
      object.attributes = values&.slice(*crud_options[:attributes][:slice]) || {}
    end

    # Store received data & object errors into session.
    def store_errors_and_params
      flash[:alert] = "Error(s) occured: #{object.errors.to_hash.to_json}"
      session["#{controller_path}##{action_name}"] = params.permit!.to_h
    end
  end
end
