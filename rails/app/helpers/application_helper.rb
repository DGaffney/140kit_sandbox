module ApplicationHelper
  def current_route
    "#{params[:controller]}##{params[:action]}"
  end
  def current_route?(route)
    current_route == route
  end
end
