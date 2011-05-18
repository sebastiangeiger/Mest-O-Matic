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
  belongs_to :team
  belongs_to :eit
end
