# == Schema Information
# Schema version: 20110518175912
#
# Table name: teams
#
#  id              :integer         not null, primary key
#  team_project_id :integer
#  name            :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class Team < ActiveRecord::Base
  belongs_to :team_project
  has_many :team_memberships
  has_many :eits, :through => :team_memberships
  
  validates :team_project, :presence => true
  # validates_length_of :team_memberships, :minimum => 1
end
