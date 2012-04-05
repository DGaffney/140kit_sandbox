class PostsController < ApplicationController
  before_filter :login_required, except: [:index, :show]
  before_filter :admin_required, only: [:update, :create, :edit, :destroy, :panel]
  caches_page :index, :show
  
  def index
    @posts = Post.where(:status => "regular").paginate(:page => params[:page], :per_page => 10, :order => "created_at desc")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @posts }
    end
  end

  def show
    @post = Post.find_by_id_and_slug(params[:id], params[:slug])
  end
  
  def new
    @post = Post.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(params[:post])
    expire_page :action => :index
    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render json: @post, status: :created, location: @post }
      else
        format.html { render action: "new" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.json
  def update
    @post = Post.find(params[:id])
    expire_page :action => :index
    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to post_path(@post.id, @post.slug), notice: 'Post was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    expire_page :action => :index
    respond_to do |format|
      format.html { redirect_to posts_url }
      format.json { head :no_content }
    end
  end
end
