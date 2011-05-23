# == Schema Information
# Schema version: 20110518175912
#
# Table name: team_memberships
#
#  id         :integer         not null, primary key
#  team_id    :integer
#  eit_id     :integer
#  role       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class TeamMembership < ActiveRecord::Base
  include ActiveModel::Validations
  
  belongs_to :team
  belongs_to :eit

  validates :eit, :presence => true 
  validates :team, :presence => true
  
  validates_uniqueness_of :eit_id, :scope => :team_id
  validates_with OnlyOneMembershipPerProjectValidator
    
end
