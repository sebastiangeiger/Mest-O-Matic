class ReviewsController < ApplicationController
  def index
    @deliverable = Deliverable.find(params[:deliverable_id])
    @deliverable.latest_version.each do |sub|
      sub.review ||= Review.new
    end
    @submissions = @deliverable.latest_version
  end
  
  def mass_create
    @deliverable = Deliverable.find(params[:deliverable_id])
    Submission.update(params[:submissions].keys, params[:submissions].values)
    redirect_to project_deliverable_reviews_path(@deliverable.project, @deliverable)
  end
end
