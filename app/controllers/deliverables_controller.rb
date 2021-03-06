class DeliverablesController < ApplicationController
  before_filter :load_project
  before_filter :ensure_signed_in
  before_filter :require_staff
  
  def new
    @deliverable = Deliverable.new
  end

  def create
    @deliverable = Deliverable.new(params[:deliverable])
    @deliverable.author_id = current_user.id
    @project.deliverables << @deliverable
    if params[:commit].eql?("cancel") or @deliverable.save
      #@project.eits.each do |eit|
      #  s = Solution.new(:user => eit)
      #  @deliverable.solutions << s
      #end
      flash[:notice] = "Successfully created the deliverable #{@deliverable.title}" if @deliverable.save
      redirect_to project_path(@project) 
    else
      @project.deliverables.delete(@deliverable)
      render :action => "new"
    end
  end

  def download
    deliverable = Deliverable.find(params[:id])
    VersionDownload.create(:deliverable => deliverable, :version_nr => deliverable.latest_version_nr, :downloader => current_user)
    send_file deliverable.download_latest_version
    #redirect_to project_path(@project)
  end

  def upload
    @deliverable = Deliverable.find(params[:id])
  end

  def process_upload
    @deliverable = Deliverable.find(params[:id])
    if @deliverable.process_corrections_archive(params[:archive].tempfile) then
      flash[:notice] = "Successfully distributed your corrections to the students"
      redirect_to project_path(@project)
    else
      flash[:error] = "The archive that you uploaded did not contain a folder for each student that submitted or had additional folders"
      render :action => "upload" 
    end
  end

  private
    def load_project
      @project = Project.find(params[:project_id])
    end
end
