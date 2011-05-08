# == Schema Information
# Schema version: 20110508194142
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
#

class Deliverable < ActiveRecord::Base
  belongs_to :project
  
  validates :title, :presence => true
  validates_uniqueness_of :title, :scope => :project_id, :case_sensitive => false
  validates :project, :presence => true
  validates :start_date, :presence => true
  validates :end_date, :presence => true
  validate :start_date_must_be_before_end_date
  
  def start_date_must_be_before_end_date
    errors.add(:end_date, 'must be after start date') if start_date and end_date and start_date >= end_date
  end
end
