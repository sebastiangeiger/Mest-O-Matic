module DeliverablesHelper
  def time_span_to_due_date_in_words(deliverable)
    distance = distance_of_time_in_words_to_now(deliverable.end_date)
    if deliverable.current? then
      "due in #{distance}"
    else
      "was due #{distance} ago"
    end
  end
  
  def status_icon(deliverable, user)
    if deliverable.current? then
      if deliverable.submitted?(user) then
        haml_tag :img, :src => "/icons/submitted.png", :alt => "You submitted a version."
      else
        haml_tag :img, :src => "/icons/notsubmitted.png", :alt => "You did not submit a version yet."
      end
    elsif deliverable.ended? and deliverable.not_graded_yet? then
      if deliverable.submitted?(user) then
        haml_tag :img, :src => "/icons/clock.png", :alt => "Grading in progress."
        haml_tag :img, :src => "/icons/submitted.png", :alt => "You submitted a version." if deliverable.submitted_on_time?(user)
        haml_tag :img, :src => "/icons/submitted-late.png", :alt => "You submitted a version." if deliverable.submitted_too_late?(user)
      else
        haml_tag :img, :src => "/icons/notsubmitted-late.png", :alt => "You did not submit a version yet."
      end
    elsif deliverable.graded? and deliverable.not_closed_yet?
      if deliverable.review_for(user)
        haml_tag :img, :src => "/icons/exclamation.png", :alt => "You submitted too late."
        haml_tag :span, "#{deliverable.review_for(user).percentage}%" 
      else
        haml_tag :img, :src => "/icons/notsubmitted-late.png", :alt => "You did not submit a version yet."
      end
    elsif deliverable.closed?
      if deliverable.review_for(user)
        haml_tag :img, :src => "/icons/exclamation.png", :alt => "You submitted too late."
        haml_tag :span, "#{deliverable.review_for(user).percentage}%" 
      else
        haml_tag :img, :src => "/icons/failed-closed.png", :alt => "You did not submit a version yet."
      end
    end
  end

end
