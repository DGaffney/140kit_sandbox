class Tweets < Application
  # provides :xml, :yaml, :js

  def index(limit=100, offset=0)
    @tweets = []
    if params[:dataset_id]
      @tweets = Tweet.all(:dataset_id => params[:dataset_id], :limit => limit, :offset => offset)
    elsif params[:curation_id]
      @tweets = Tweet.all(:dataset_id => Curation.first(:id => params[:curation_id]).datasets.collect(&:id), :limit => limit, :offset => offset)
    elsif params[:user_id]
      @tweets = Tweet.all(:user_id => params[:user_id], :limit => limit, :offset => offset)
    else
      @tweets = Tweet.all(:limit => limit, :offset => offset)
    end
    display @tweets
  end

  def show(id)
    @tweet = Tweet.get(id)
    raise NotFound unless @tweet
    display @tweet
  end

  def new
    only_provides :html
    @tweet = Tweet.new
    display @tweet
  end

  def edit(id)
    only_provides :html
    @tweet = Tweet.get(id)
    raise NotFound unless @tweet
    display @tweet
  end

  def create(tweet)
    @tweet = Tweet.new(tweet)
    if @tweet.save
      redirect resource(@tweet), :message => {:notice => "Tweet was successfully created"}
    else
      message[:error] = "Tweet failed to be created"
      render :new
    end
  end

  def update(id, tweet)
    @tweet = Tweet.get(id)
    raise NotFound unless @tweet
    if @tweet.update(tweet)
       redirect resource(@tweet), :message => {:notice => "Tweet was successfully updated"}
    else
      message[:error] = "Tweet failed to be updated"
      display @tweet, :edit
    end
  end

  def destroy(id)
    @tweet = Tweet.get(id)
    raise NotFound unless @tweet
    if @tweet.destroy
      redirect resource(:tweet), :message => {:notice => "Tweet was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # Tweet
