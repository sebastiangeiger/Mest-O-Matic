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
  
  def newest_submissions_all_graded?
    reviews = solutions.collect{|s| s.submissions.sort{|a,b| a.created_at<=> b.created_at}.last.review}
    return (not reviews.include?(nil))
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
    result = nil
    user_solution = solutions.select{|sol| sol.user.eql?(by_user)}.first
    reviewed_solution = user_solution.submissions.select{|s| s.review}.sort{|a,b| a.updated_at <=> b.updated_at}.first
    result = reviewed_solution.review if reviewed_solution
    return result
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

  def process_corrections_archive(file)
    filename = file.is_a?(String) ? file : file.path
    tmpdir = File.join(Dir.tmpdir, "#{File.basename(filename)}-unzipped")
    unzipped_dir = MyZip.unzip_file(file,tmpdir)
    unzipped_files = Dir.entries(unzipped_dir).reject{|d| %w[. ..].include?d}
    if unzipped_files.size == 1 and File.directory?(File.join(unzipped_dir, unzipped_files.first)) then
      eit_root = File.join(unzipped_dir, unzipped_files.first)
      eit_folders = Dir.entries(eit_root).reject{|d| %w[. ..].include?d}
      if has_a_folder_and_a_review_for_each_student(eit_folders, eits_submitted) then
        extract_eits_and_reviews(eit_folders).each_pair do |eit,review|
          zipfile = File.join(tmpdir, "Review_of_#{project.safe_title}_#{safe_title}_ver#{review.submission.version}.zip")
          folder = File.join(eit_root, "#{eit.identifier_name}_#{review.submission.version}")
          MyZip.zip_file(folder, zipfile)
          review.archive = File.open(zipfile, "rb") if File.exists?(zipfile)
          review.save #need to save to add the zipfile
          #TODO: Delete temp files
        end
        return true
      end
    end
    false
  end

  def has_a_folder_and_a_review_for_each_student(folders, list_of_students)
    extract_eits_and_reviews(folders).keys.collect{|e| e.identifier_name}.sort == list_of_students.collect{|e| e.identifier_name}.sort
  end

  def extract_eits_and_reviews(folders)
    result = {}
    folders.each do |folder|
      if matchdata = folder.match(/(.*)_(\d+)$/) then
        eit = eits_submitted.select{|e| e.identifier_name == matchdata[1]}.first
        version = matchdata[2].to_i
        sol = Solution.find_or_create(:user => eit, :deliverable => self) if eit
        if sol and sol.submissions.size-1>=version then
          review = sol.submissions[version].review 
          result[eit] = review if eit and review
        end
      end
    end
    return result
  end

  private
    def version_unzipped_path(nr)
      File.join(Rails.root, "public/system/unzipped/deliverable_versions", nr.to_s)
    end

    def download_version(nr)
      zip_file_name = "#{id}_#{project.safe_title}_#{safe_title}_ver#{nr}" 
      zip_file_path = File.join(Rails.root, "public/system/deliverables/#{zip_file_name}.zip")
      unless File.exists?(zip_file_path) then
        FileUtils.mkdir_p(File.dirname(zip_file_path))
        temp_folder = version_unzipped_path(nr)
        FileUtils.rm_r(temp_folder) if File.exists?(temp_folder) # Start with a clean slate
        FileUtils.mkdir_p(temp_folder)
        #Copy everything into temp_folder
        versions[nr].each do |submission| 
          user_dest = File.join(temp_folder, "#{submission.user.identifier_name}_#{submission.version}") 
          FileUtils.cp_r(submission.unzipped_path, user_dest) if submission.is_a? Filesubmission and not RAILS_ENV == 'test' #TODO: Find a way to test uploads!
        end 
        #Create zipfile out of temp_folder
        MyZip.zip_file(temp_folder, zip_file_path)
      end
      #send_file t.path, :type => 'application/zip', :disposition => 'attachment', :filename => "some-brilliant-file-name.zip"
      zip_file_path
    end
end
