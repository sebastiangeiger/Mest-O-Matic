# == Schema Information
# Schema version: 20110516195657
#
# Table name: solutions
#
#  id             :integer         not null, primary key
#  eit_id         :integer
#  deliverable_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class Solution < ActiveRecord::Base
  belongs_to :deliverable
end
