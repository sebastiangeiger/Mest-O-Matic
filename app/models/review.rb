# == Schema Information
# Schema version: 20110601194807
#
# Table name: reviews
#
#  id            :integer         not null, primary key
#  percentage    :integer
#  submission_id :integer
#  remarks       :text
#  reviewer_id   :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class Review < ActiveRecord::Base
  belongs_to :submission
  belongs_to :reviewer, :class_name => "Staff", :foreign_key => "reviewer_id"

  validates :submission, :presence => true
  validates :reviewer, :presence => true
  validates_uniqueness_of :submission_id
end
