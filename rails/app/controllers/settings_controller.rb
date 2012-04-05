class SettingsController < ApplicationController
  before_filter :admin_required
  def index
    @page_title = "Settings"
    @settings = Setting.paginate(:page => params[:page], :per_page => 20)
  end

  def show
    @setting = Setting.find(params[:id])
    @page_title = "Settings: #{@setting.name}"
  end

  def new
    @setting = Setting.new
    @page_title = "New Setting"
  end

  def edit
    @setting = Setting.find(params[:id])
    @page_title = "Editing #{@setting.name} Setting"
  end

  def create
    @setting = Setting.new
    @setting.value = params[:setting][:value]
    @setting.var_class = params[:setting][:var_class]
    @setting.var_type = params[:setting][:var_type]
    @setting.name = params[:setting][:name]
    @setting.value = @setting.set_value
    respond_to do |format|
      if @setting.save
        format.html { redirect_to @setting, notice: 'Setting was successfully created.' }
        format.json { render json: @setting, status: :created, location: @setting }
      else
        format.html { render action: "new" }
        format.json { render json: @setting.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @setting = Setting.find(params[:id])
    @setting.value = params[:setting][:value]
    @setting.var_class = params[:setting][:var_class]
    @setting.var_type = params[:setting][:var_type]
    @setting.name = params[:setting][:name]
    @setting.value = @setting.set_value
    respond_to do |format|
      if @setting.save!
        format.html { redirect_to @setting, notice: 'Setting was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @setting.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @setting = Setting.find(params[:id])
    @setting.destroy
    respond_to do |format|
      format.html { redirect_to settings_url }
      format.json { head :no_content }
    end
  end
end
