class Instance < ActiveRecord::Base
  def machine_image
    return Machine.find_by_user(self.hostname).image_url
  end

  def machine
    return Machine.find_by_user(self.hostname)
  end
end
