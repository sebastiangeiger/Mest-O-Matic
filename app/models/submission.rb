# == Schema Information
# Schema version: 20110517181144
#
# Table name: submissions
#
#  id                   :integer         not null, primary key
#  solution_id          :integer
#  created_at           :datetime
#  updated_at           :datetime
#  archive_file_name    :string(255)
#  archive_content_type :string(255)
#  archive_file_size    :integer
#  archive_updated_at   :datetime
#  md5_checksum         :string(255)
#

class Submission < ActiveRecord::Base
  belongs_to :solution
  
  has_one :review

  has_attached_file :archive
  
  accepts_nested_attributes_for :review

  before_validation :generate_md5_checksum, :on => :create
  validates :solution, :presence => true 
  validates_attachment_presence :archive
  validates_attachment_content_type :archive, :content_type => "application/zip"
  validates :md5_checksum, :presence => true
  validate :unique_archive
  #TODO: Unzip as part of upload?

  def user
    solution.user
  end

  def version
    solution.submissions.index(self)
  end

  def generate_md5_checksum
    self.md5_checksum = Digest::MD5.hexdigest(archive.to_file.read) if archive and archive.to_file
  end
  
  def unique_archive
    if solution then
      archive_checksum = self.md5_checksum
      errors.add(:archive, 'has already been uploaded (A file with the same md5 checksum already exists)') unless solution.submissions.select{|sub| sub.md5_checksum.eql?(archive_checksum)}.empty?
    end
  end

  def unzip
    FileUtils.mkdir_p(unzipped_path) unless File.exists?(unzipped_path)
    unzip_file(archive.path, unzipped_path)
    unzipped_path
  end

  def unzipped_path
    File.join(Rails.root, "public/system/unzipped/submissions/#{folder_number}")  
  end

  private
    def unzip_file (file, destination)
      Zip::Archive.open(file) do |ar| #TODO: Clean up empty folders? Shadrack style
        ar.each do |zf|
          file_name = File.join(destination,zf.name)
          if zf.directory?
            FileUtils.mkdir_p(file_name)
          else
            dirname = File.dirname(file_name)
            FileUtils.mkdir_p(dirname) unless File.exist?(dirname)
            open(file_name, 'wb') {|f| f << zf.read}
          end
        end
      end#close_file
    end
      

    def folder_number
      archive.path.match(/\/system\/archives\/(\d+)\/original\//)[1]
    end

    
end
