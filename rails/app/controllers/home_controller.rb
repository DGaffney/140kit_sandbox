class HomeController < ApplicationController
  def index
    @featured_post = Post.latest_featured
    @tweets_count = Dataset.sum(:tweets_count)
    @users_count = Dataset.sum(:users_count)
    @count = Dataset.count
    @researchers_count = Researcher.count
  end
end
