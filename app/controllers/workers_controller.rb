# frozen_string_literal: true

# Manage workers list.
class WorkersController < ApplicationController
  before_action :init_object, only: %i[create new]
  before_action :find_object, only: %i[destroy show update]
  before_action :set_attributes_from_params, only: %i[create update]
  before_action :set_attributes_from_session, only: %i[new show]

  # Create record for worker.
  def create
    return redirect_to(worker_path(@worker)) if @worker.save

    store_errors_and_params
    redirect_to(new_worker_path)
  end

  # Delete record for worker.
  def destroy
    flash[:alert] = "Error(s) occured: #{@worker.errors.to_hash.to_json}" unless @worker.destroy

    redirect_to(workers_path)
  end

  # List records of workers.
  def index
    @workers = Work::Worker.order(:position)
  end

  # Show form for new worker.
  def new
    # nothing
  end

  # Show form for existing worker and also show information related to the worker.
  def show
    # nothing
  end

  # Change record for worker.
  def update
    store_errors_and_params unless @worker.save

    redirect_to(worker_path(@worker))
  end

  private

  SESSION_KEY = {"new" => :create, "show" => :update}.freeze

  private_constant :SESSION_KEY

  # Find record in table.
  def find_object
    @worker = Work::Worker.find(params[:id])
  end

  # Initialize empty object
  def init_object
    @worker = Work::Worker.new
  end

  # Set attributes in object (from params hash).
  def set_attributes_from_params
    @worker.attributes =
      params.require(:work_worker).permit(:payment_info, :position, :rate, :title)
  end

  # Set attributes in object (from session hash).
  def set_attributes_from_session
    values = session.delete("#{controller_path}##{SESSION_KEY.fetch(action_name)}")
    @worker.attributes = values&.slice("payment_info", "position", "rate", "title") || {}
  end

  # Store received data & object errors into session.
  def store_errors_and_params
    flash[:alert] = "Error(s) occured: #{@worker.errors.to_hash.to_json}"
    session["#{controller_path}##{action_name}"] = params.permit!.to_h
  end
end
