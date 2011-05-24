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
  has_many :team_memberships, :inverse_of => :team
  has_many :eits, :through => :team_memberships
  
  validates :team_project, :presence => true
  validates_length_of :team_memberships, :minimum => 1
  
  accepts_nested_attributes_for :team_memberships, :allow_destroy => true, :reject_if => lambda{|a| a[:eit_id].blank? and a[:team_id].blank?} 
end
