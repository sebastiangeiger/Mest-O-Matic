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
        haml_tag :img, :src => "/icons/document-tick.png", :alt => "You submitted a version."
      else
        haml_tag :img, :src => "/icons/document-cross.png", :alt => "You did not submit a version yet."
      end
    elsif deliverable.ended? and deliverable.not_graded_yet? then
      if deliverable.submitted?(user) then
        haml_tag :img, :src => "/icons/clock.png", :alt => "Grading in progress."
      else
        haml_tag :img, :src => "/icons/document-cross.png", :alt => "You did not submit a version yet."
      end
    elsif deliverable.graded?
      haml_tag "div", "11 %"
    end
  end

  def on_time_icon(deliverable, user)
    if deliverable.submitted_too_late?(user) or deliverable.not_submitted?(user) and deliverable.ended? then
      haml_tag :img, :src => "/icons/exclamation.png", :alt => "You submitted too late."
    end
  end
end
