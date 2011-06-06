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
  
  accepts_nested_attributes_for :submissions
  validates :user, :presence => true 
  validates :deliverable, :presence => true
  validates_uniqueness_of :user_id, :scope => :deliverable_id
  
  def Solution.find_or_create(options = {})
    deliverable = options[:deliverable]
    user = options[:user]
    solution = Solution.all.select{|s| s.deliverable_id == deliverable.id and s.user_id == user.id}
    if solution.empty? then
      solution = Solution.create(:deliverable => deliverable, :user => user)
    else
      solution = solution.first
    end
    return solution
  end
end
