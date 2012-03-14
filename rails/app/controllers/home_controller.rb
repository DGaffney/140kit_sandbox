class HomeController < ApplicationController
  def index
    @featured_post = Post.latest_featured
  end
end
