module ResearchersHelper
  def link_to_twitter(researcher, opts={})
    opts[:target] ||= '_blank'
    link_to "@#{researcher.user_name}", researcher.twitter_url, opts
  end
end
