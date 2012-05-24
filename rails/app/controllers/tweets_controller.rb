class TweetsController < ApplicationController
  before_filter :login_required, except: [:index, :show]
  
  def index
    @curation = Curation.find(params[:curation_id])
    @dataset_ids = @curation.datasets.collect(&:id)
    @tweets = Tweet.where(:dataset_id => @dataset_ids).paginate(:page => params[:tweets_page], :per_page => 10, :order => "created_at desc")
    @page_title = "Tweets for #{@curation.name}"
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tweets }
    end
  end

  def show
    @tweet = Tweet.find(params[:id])
    @page_title = "Tweet from #{@tweet.screen_name} (##{@tweet.twitter_id})"
  end
  
end
