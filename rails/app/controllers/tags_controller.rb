class TagsController < ApplicationController
  before_filter :admin_required, except: [:index, :create]
  before_filter :login_required
  def index
    @tags = Tag.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tags }
    end
  end

  # POST /tags
  # POST /tags.json
  def create
    @tag = Tag.where(:value => params[:tag][:value]).first || Tag.new
    @tag.value = params[:tag][:value] if @tag.id == nil
    object = params[:tag][:classname].constantize.find(params[:tag][:with_id])
    respond_to do |format|
      if @tag.save
        object.tags << @tag
        format.html { redirect_to request.referer, notice: 'Tag was successfully created.' }
        format.json { render json: @tag, status: :created, location: @tag }
      else
        format.html { redirect_to request.referer, notice: 'Tag failed to be added.' }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.json
  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy
    respond_to do |format|
      format.html { redirect_to request.referer, notice: 'Tag removed'}
      format.json { head :no_content }
    end
  end

  def drop_relation
    @tag = Tag.find(params[:tag_id])  
    object = params[:classname].constantize.find(params[:with_id])
    object.tags.delete(@tag)
    redirect_to request.referer
  end
end
