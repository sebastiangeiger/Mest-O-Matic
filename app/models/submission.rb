# == Schema Information
# Schema version: 20110516210728
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
#

class Submission < ActiveRecord::Base
  belongs_to :solution
  
  has_attached_file :archive
  
  validates_attachment_presence :archive
  validates :solution, :presence => true 
  validates_attachment_content_type :archive, :content_type => "application/zip"
end
