class ReviewsController < ApplicationController
  def index
    @deliverable = Deliverable.find(params[:deliverable_id])
    @submissions = @deliverable.latest_version
    #@deliverable.solutions.each do |sol|
    #  if sol.submissions.empty? then
    #    @submissions << Submission.new(:solution => sol)
    #  end
    #end
    @submissions.each do |sub|
      sub.review ||= Review.new
    end
  end
  
  def mass_create
    @deliverable = Deliverable.find(params[:deliverable_id])
    Submission.update(params[:submissions].keys, params[:submissions].values)
    redirect_to project_deliverable_reviews_path(@deliverable.project, @deliverable)
  end
end
