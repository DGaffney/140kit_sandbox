module CurationsHelper
  def exact_time(seconds)
    statement = ""
    time_set = []
    time_set << seconds/1.week
    seconds = seconds-time_set.last.weeks
    time_set << seconds/1.day
    seconds = seconds-time_set.last.days
    time_set << seconds/1.hour
    seconds = seconds-time_set.last.hours
    time_set << seconds/1.minute
    seconds = seconds-time_set.last.minutes
    time_set << seconds
    ordered_set = ["Weeks", "Days", "Hours", "Minutes", "Seconds"]
    i = 0
    time_set.each do |t|
      if t == 1
        statement << "#{t} #{ordered_set[i].chop}, "
      elsif t != 0
        statement << "#{t} #{ordered_set[i]}, "
      end
      i+=1
    end
    return statement.chop.chop
  end
  
  def current_status(curation)
    case curation.status
    when "tsv_storing"
      return "Your dataset is currently streaming. Take this opportunity to review available analytics, and add the ones you think may be useful for your research. When the data stream is complete, you will be able to import the dataset, at which point analysis can be run."
    when "tsv_stored"
      return "Your dataset has now been stored! At this point, you may add any analytical process you want. After you're done, go ahead and import the dataset, and we will begin processing analytics."
    when "needs_import"
      return "Your dataset has been queued for import. Please come back when the data import is complete."
    when "imported"
      return "Your dataset is now imported!"
    when "live"
      return "Your dataset is live! You can add, edit, and alter any and all analytics you want, and we'll keep this dataset online so long as people actively use it."
    when "needs_drop"
      return "Your dataset is in the process of being archived. At this point, you can't take any actions. To re-import the dataset and bring it live again, just select that option."
    when "dropped"
      return "Your dataset has been archived. At this point, you can't take any actions. To re-import the dataset and bring it live again, just select that option."
    end
  end
  
  def next_step_badge_text(curation)
    case curation.status 
    when "tsv_storing"
      return "Select Analytics"
    when "tsv_stored"
      return "Bring it live"
    when "needs_import"
      return "Select Analytics"
    when "imported"
      return "Review results"
    when "live"
      return "Review results"
    when "needs_drop"
      return "Hold on"
    when "dropped"
      return "Bring it live"
    end
  end

  def next_step_badge_link(curation)
    case curation.status
    when "tsv_storing"
      return analyze_dataset_url(curation)
    when "tsv_stored"
      return import_dataset_url(curation)
    when "needs_import"
      return analyze_dataset_url(curation)
    when "imported"
      return "#"
    when "live"
      return "#"
    when "needs_drop"
      return "#"
    when "dropped"
      return import_dataset_url(curation)
    end
  end
  
  def next_step_badge(curation)
    tag = "a"
    if ["needs_drop"].include?(curation.status)
      tag = "span"
    end
    return "<#{tag} class='btn btn-primary btn-large' href='#{next_step_badge_link(curation)}'>#{next_step_badge_text(curation)}</#{tag}>".html_safe
  end
end
