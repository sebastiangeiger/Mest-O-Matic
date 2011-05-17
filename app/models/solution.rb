# == Schema Information
# Schema version: 20110516210728
#
# Table name: solutions
#
#  id             :integer         not null, primary key
#  user_id        :integer
#  deliverable_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class Solution < ActiveRecord::Base
  belongs_to :deliverable
  belongs_to :user
  has_many :submissions
  
  validates :user, :presence => true 
  validates :deliverable, :presence => true
  validates_uniqueness_of :user_id, :scope => :deliverable_id
end
