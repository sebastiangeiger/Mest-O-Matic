class ReviewsController < ApplicationController
  before_filter :ensure_signed_in
  before_filter :require_staff

  def index
    @deliverable = Deliverable.find(params[:deliverable_id])
    @submissions = @deliverable.latest_version
    @submissions.each do |sub|
      sub.review ||= Review.new
    end
  end
  
  def mass_create
    @deliverable = Deliverable.find(params[:deliverable_id])
    keys = params[:submissions].keys
    values = params[:submissions].values
    params[:submissions].each_pair do |k,v|
      v["review_attributes"]["reviewer_id"] ||= current_user.id.to_s
      review = Review.where(:submission_id => k).first #TODO: Could probably be done better (in form)
      v["review_attributes"]["id"] ||= review.id if review and review.id
    end
    Submission.update(params[:submissions].keys, values)
    redirect_to project_deliverable_reviews_path(@deliverable.project, @deliverable)
  end
end
