class InstancesController < ApplicationController
  before_filter :login_required
  def index_instance
    @instances = Instance.all
  end

  def index_machine
    @machines = Machine.all
  end
  
  def edit
    @machine = Machine.find(params[:id])
  end
  
  def update
    @machine = Machine.find(params[:id])
    @machine.ip
    @machine.storage_path = params[:storage_path]
    @machine.working_path = params[:working_path]
    @machine.user =         params[:user]
    @machine.image_url =    params[:image_url]
    @machine.can_store =    params[:can_store]
    @machine.save!
    redirect_to instances_url, :notice => "Changes saved."
  end
  
  def kill_instance
    @instance = Instance.find(params[:id])
    @instance.killed = !@instance.killed
    @instance.save!
    redirect_to instances_url, :notice => "Changes saved."
  end
  
  def kill_machine
    @machine = Machine.find(params[:id])
    @instances = Instance.find_all_by_hostname(@machine.user)
    @instances.each do |instance|
      instance.killed = !instance.killed
      instance.save!
    end
    redirect_to machines_url, :notice => "Changes saved."
  end
  
  def show_instance
    @instance = Instance.find(params[:id])
    @locks = Lock.find_all_by_instance_id(@instance.instance_id)
  end

  def show_machine
    @machine = Machine.find(params[:id])
    @instances = Instance.find_all_by_hostname(@machine.user)
  end
  
end
