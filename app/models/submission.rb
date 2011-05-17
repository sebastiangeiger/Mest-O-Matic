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
  
  has_attached_file :archive
  
  before_validation :generate_md5_checksum, :on => :create
  validates_attachment_presence :archive
  validates :solution, :presence => true 
  validates_attachment_content_type :archive, :content_type => "application/zip"
  validates :md5_checksum, :presence => true
  validate :unique_archive
  
  def generate_md5_checksum
    self.md5_checksum = Digest::MD5.hexdigest(archive.to_file.read) if archive and archive.to_file
  end
  
  def unique_archive
    if solution then
      archive_checksum = self.md5_checksum
      errors.add(:archive, 'has already been uploaded (A file with the same md5 checksum already exists)') unless solution.submissions.select{|sub| sub.md5_checksum.eql?(archive_checksum)}.empty?
    end
  end
end
