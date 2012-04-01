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
      if current_user
        if current_user.id == curation.researcher_id
          return "Your dataset is currently streaming. Take this opportunity to review available analytics, and add the ones you think may be useful for your research. When the data stream is complete, you will be able to import the dataset, at which point analysis can be run."
        else
          return "This dataset is currently streaming. Take this opportunity to review available analytics, and add the ones you think may be useful for your research. When the data stream is complete, you will be able to import the dataset, at which point analysis can be run."
        end
      else
        return "This dataset is currently streaming."
      end
    when "tsv_stored"
      if current_user
        if current_user.id == curation.researcher_id
          return "Your dataset has now been stored! At this point, you may add any analytical process you want. After you're done, go ahead and import the dataset, and we will begin processing analytics."
        else
          return "This dataset has now been stored! At this point, you may add any analytical process you want. After you're done, go ahead and import the dataset, and we will begin processing analytics."
        end
      else
        return "This dataset has now been stored! At this point, you can add any analytical process you want if you log in."
      end
    when "needs_import"
      if current_user
        if current_user.id == curation.researcher_id
          return "Your dataset has been queued for import. Please come back when the data import is complete."
        else
          return "This dataset has been queued for import. Please come back when the data import is complete."
        end
      else
        return "This dataset has been queued for import. Please come back when the data import is complete."
      end
    when "imported"
      if current_user
        if current_user.id == curation.researcher_id
          return "Your dataset is live! You can add, edit, and alter any and all analytics you want, and we'll keep this dataset online so long as people actively use it (If this dataset goes one week without any activity, including someone looking at it, we will archive it automatically)."
        else
          return "This dataset is live! We'll keep this dataset online so long as people actively use it."
        end
      else
        return ""
      end
    when "needs_drop"
      if current_user
        if current_user.id == curation.researcher_id
          return "Your dataset is in the process of being archived. At this point, you can't take any actions. To re-import the dataset and bring it live again, just select that option."
        else
          return "This dataset is in the process of being archived. At this point, you can't take any actions. To re-import the dataset and bring it live again, just select that option."
        end
      else
        return "This dataset is in the process of being archived. At this point, you can't take any actions. To re-import the dataset and bring it live again, just select that option."
      end      
    when "dropped"
      if current_user
        if current_user.id == curation.researcher_id
          return "Your dataset has been archived. At this point, you can't take any actions. To re-import the dataset and bring it live again, just select that option."
        else
          return "This dataset has been archived. At this point, you can't take any actions. To re-import the dataset and bring it live again, just select that option."
        end
      else
        return "This dataset has been archived. At this point, you can't take any actions. To re-import the dataset and bring it live again, just select that option."
      end      
    when "zero_data"
      if current_user
        if current_user.id == curation.researcher_id
          return "Unfortunately, no tweets were found for the time period you selected."
        else
          return "Unfortunately, no tweets were found for the time period the researcher selected."
        end
      else
        return "Unfortunately, no tweets were found for the time period the researcher selected."
      end
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
      return "Have Fun!"
    when "needs_drop"
      return "Hold on"
    when "dropped"
      return "Bring it live"
    when "zero_data"
      return "Remove"
    end
  end

  def next_step_badge(curation)
    case curation.status
    when "tsv_storing"
      return link_to next_step_badge_text(curation), analyze_dataset_url(curation), {:class => "btn btn-primary btn-large"}
    when "tsv_stored"
      return link_to next_step_badge_text(curation), import_dataset_url(curation), {:class => "btn btn-primary btn-large"}
    when "needs_import"
      return link_to next_step_badge_text(curation), analyze_dataset_url(curation), {:class => "btn btn-primary btn-large"}
    when "imported"
      return link_to next_step_badge_text(curation), "#", {:class => "btn btn-primary btn-large"}
    when "needs_drop"
      return link_to next_step_badge_text(curation), "#", {:class => "btn btn-primary btn-large"}
    when "dropped"
      return link_to next_step_badge_text(curation), import_dataset_url(curation), {:class => "btn btn-primary btn-large"}
    when "zero_data"
      return link_to next_step_badge_text(curation), dataset_path(curation), {:method => :delete, :class => "btn btn-primary btn-large"}
    end
  end
end
