# == Schema Information
# Schema version: 20110703191200
#
# Table name: reviews
#
#  id                   :integer         not null, primary key
#  percentage           :integer
#  submission_id        :integer
#  remarks              :text
#  reviewer_id          :integer
#  created_at           :datetime
#  updated_at           :datetime
#  archive_file_name    :string(255)
#  archive_content_type :string(255)
#  archive_file_size    :integer
#  archive_updated_at   :datetime
#

class Review < ActiveRecord::Base
  has_attached_file :archive
  belongs_to :submission
  belongs_to :reviewer, :class_name => "Staff", :foreign_key => "reviewer_id"

  validates :submission, :presence => true
  validates :reviewer, :presence => true
  validates_uniqueness_of :submission_id
end
