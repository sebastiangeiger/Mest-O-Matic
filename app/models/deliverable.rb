# == Schema Information
# Schema version: 20110616104908
#
# Table name: deliverables
#
#  id             :integer         not null, primary key
#  title          :string(255)
#  description    :string(255)
#  start_date     :datetime
#  end_date       :datetime
#  project_id     :integer
#  created_at     :datetime
#  updated_at     :datetime
#  author_id      :integer
#  graded         :boolean
#  last_graded_at :date
#

class Deliverable < ActiveRecord::Base
  belongs_to :project
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"
  
  has_many :solutions
  has_many :submissions, :through => :solutions

  accepts_nested_attributes_for :solutions

  validates :title, :presence => true
  validates_uniqueness_of :title, :scope => :project_id, :case_sensitive => false
  validates :project, :presence => true
  validates :start_date, :presence => true
  validates :end_date, :presence => true
  validates :author, :presence => true
  validate :start_date_must_be_before_end_date
  
  after_create do |d|
    eits.each do |eit| 
      s = Solution.create(:deliverable => d, :user => eit)
      Submission.create(:solution => s)
    end
  end   
  
  def eits
    project.class_of.eits
  end

  def eits_submitted
    solutions.select{|sol| sol.submissions.select{|sub| sub.is_a?(FileSubmission)}.size > 0}.collect{|sol| sol.user}
  end

  def safe_title
    title.gsub(/\s/, "_").camelize.gsub(/[^a-zA-Z0-9]/, "")
  end

  def start_date_must_be_before_end_date
    errors.add(:end_date, 'must be after start date') if start_date and end_date and start_date >= end_date
  end

  def invisible?
    start_date >= Time.now
  end

  def visible?(user)
    return true if user.staff?
    not invisible?
  end
  
  def current?
    end_date > DateTime.now
  end
  
  def ended?
    not current?
  end
  
  def not_graded_yet?
    not graded?
  end

  def reviews_missing? 
    latest_version.select{|sub| sub.review.nil?}.size > 0
  end

  def closed?
    graded? and end_date < Time.now - 1.months
  end

  def not_closed_yet?
    not closed?
  end

  def submissions_for(by_user)
    user_solution = solutions.select{|sol| sol.user.eql?(by_user)}.first
    if user_solution
      user_solution.submissions.select{|sub| sub.is_a?(FileSubmission)} 
    else
      [] #TODO: Can I remove this branch?
    end
  end
  
  def review_for(by_user)
    user_solution = solutions.select{|sol| sol.user.eql?(by_user)}.first
    reviewed_solution = user_solution.submissions.select{|s| s.review}.sort{|a,b| a.updated_at <=> b.updated_at}.first
    reviewed_solution.review if reviewed_solution
  end

  def not_submitted?(by_user)
    submissions_for(by_user).empty?
  end
  
  def submitted?(by_user)
    submissions_for(by_user).size > 0
  end

  def latest_submission(by_user)
    submissions_for(by_user).sort{|a,b| a.created_at <=> b.created_at}.first
  end
  
  def submitted_on_time?(by_user)
    latest_submission(by_user).created_at <= end_date
  end
  
  def submitted_too_late?(by_user)
    submitted?(by_user) and not submitted_on_time?(by_user)
  end

  def versions 
    current_submissions = solutions.map{|sol| sol.submissions.first}
    versions = {0 => current_submissions}
    submissions.select{|sub| sub.is_a?(FileSubmission)}.sort{|a,b| a.created_at <=> b.created_at}.each_with_index do |sub, i|
      current_submissions = Array.new(current_submissions).reject{|s| sub.solution == s.solution}
      current_submissions << sub
      versions[i+1] = current_submissions
    end
    return versions
  end

  def download_latest_version
    download_version(latest_version_nr)
  end
  
  def latest_version
    versions[latest_version_nr]
  end

  def latest_version_nr
    versions.keys.max
  end

  private
    def Deliverable.remove_root_path(path, root)
      roots = []
      paths = []
      roots = root.split("/").reject{|p| p.empty?} if root
      paths = path.split("/").reject{|p| p.empty?} if path
      while paths.first.eql?(roots.shift) do
        paths.shift
      end
      return paths.join("/")
    end

    def version_unzipped_path(nr)
      File.join(Rails.root, "public/system/unzipped/deliverable_versions", nr.to_s)
    end

    def download_version(nr)
      zip_root = "#{id}_#{project.safe_title}_#{safe_title}_ver#{nr}" 
      zipped_file = File.join(Rails.root, "public/system/deliverables/#{zip_root}.zip")
      FileUtils.mkdir_p(File.dirname(zipped_file))
      unless File.exists?(zipped_file) then
        dest_folder = version_unzipped_path(nr)
        FileUtils.rm_r(dest_folder) if File.exists?(dest_folder) # Start with a clean slate
        FileUtils.mkdir_p(dest_folder)
        #Copy everything into dest_folder
        versions[nr].each do |sub| 
          user_dest = File.join(dest_folder, "#{sub.user.identifier_name}_#{sub.version}") 
          FileUtils.cp_r(sub.unzipped_path, user_dest)
        end 
        #Create zipfile out of dest_folder
        Zip::Archive.open(zipped_file, Zip::CREATE) do |ar| 
          ar.add_dir(zip_root)
          Dir.glob("#{dest_folder}/**/*").each do |path|
            zip_path = File.join(zip_root, Deliverable.remove_root_path(path, dest_folder)) 
            if File.directory?(path)
              ar.add_dir(zip_path) 
            else
              ar.add_file(zip_path, path) 
            end
          end
        end
      end
      #send_file t.path, :type => 'application/zip', :disposition => 'attachment', :filename => "some-brilliant-file-name.zip"
      zipped_file
    end
end
