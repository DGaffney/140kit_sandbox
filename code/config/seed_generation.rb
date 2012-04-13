seed = ""
Setting.all(:name => ["user_role_tweet_limit", "max_track_ids", "batch_size", "check_for_new_datasets_interval", "rsync_interval", "statuses", "unflippable_statuses", "sleep_constant", "drop_interval", "hide_interval", "clean_orphan_interval", "roles", "maximum_user_search", "maximum_user_search", "maximum_user_search"]).each do |setting|
  seed += "Setting.create(:name => '#{setting.name}', :var_type => '#{setting.var_type}', :var_class => '#{setting.var_class}', :value => #{setting.value})\n"
end
AnalyticalOffering.all.each do |ao|
  seed += "#{ao.function} = AnalyticalOffering.create(:title => #{ao.title.inspect}, :description => #{ao.description.inspect}, :function => #{ao.function.inspect}, :rest => #{ao.rest}, :created_by => #{ao.created_by.inspect}, :created_by_link => #{ao.created_by_link.inspect}, :enabled => #{ao.enabled}, :language => #{ao.language.inspect}, :access_level => #{ao.access_level.inspect}, :source_code_link => #{ao.source_code_link.inspect})\n"
  ao.variables.each do |var|
    seed += "AnalyticalOfferingVariableDescriptor.create(:name => #{var.name.inspect}, :description => #{var.description.inspect}, :user_modifiable => #{var.user_modifiable}, :position => #{var.position}, :kind => #{var.kind.inspect}, :analytical_offering_id => #{ao.function}.id, :values => #{var.values.inspect})\n"
  end
  ao.requirements.each do |reqs|
    seed += "AnalyticalOfferingRequirement.create(:position => #{reqs.position}, :analytical_offering_requirement_id => #{reqs.analytical_offering_requirement_id}, :analytical_offering_id => #{reqs.analytical_offering_id})\n"
  end
end
Post.all.each do |post|
  seed+= "Post.create(:id => #{post.id}, :title => #{post.title.inspect}, :slug => #{post.slug.inspect}, :text => #{post.text.inspect}, :created_at => Time.parse(#{post.created_at.to_s.inspect}), :status => #{post.status.inspect}, :researcher_id => 1)\n"
end