# == Schema Information
# Schema version: 20110517132702
#
# Table name: deliverables
#
#  id          :integer         not null, primary key
#  title       :string(255)
#  description :string(255)
#  start_date  :datetime
#  end_date    :datetime
#  project_id  :integer
#  created_at  :datetime
#  updated_at  :datetime
#  author_id   :integer
#

class Deliverable < ActiveRecord::Base
  belongs_to :project
  
  has_many :solutions
  has_many :submissions, :through => :solutions
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"
  
  validates :title, :presence => true
  validates_uniqueness_of :title, :scope => :project_id, :case_sensitive => false
  validates :project, :presence => true
  validates :start_date, :presence => true
  validates :end_date, :presence => true
  validates :author, :presence => true
  validate :start_date_must_be_before_end_date
  
  def safe_title
    title.gsub(/\s/, "_").camelize.gsub(/[^a-zA-Z0-9]/, "")
  end

  def start_date_must_be_before_end_date
    errors.add(:end_date, 'must be after start date') if start_date and end_date and start_date >= end_date
  end
  
  def current?
    end_date > DateTime.now
  end
  
  def ended?
    not current?
  end
  
  def graded?
    false
  end
  
  def not_graded_yet?
    not graded?
  end
  
  def submissions_for(by_user)
    user_solution = solutions.select{|sol| sol.user.eql?(by_user)}.first
    if user_solution
      user_solution.submissions 
    else
      []
    end
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
    versions = {0 => []}
    current_submissions = []
    submissions.sort{|a,b| a.created_at <=> b.created_at}.each_with_index do |sub, i|
      current_submissions = Array.new(current_submissions).reject{|s| sub.solution == s.solution}
      current_submissions << sub
      versions[i+1] = current_submissions
    end
    return versions
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

  def version_unzipped_path(nr)
    File.join(Rails.root, "public/system/unzipped/deliverable_versions", nr.to_s)
  end

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
end
