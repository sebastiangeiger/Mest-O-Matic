# == Schema Information
# Schema version: 20110518183857
#
# Table name: users
#
#  id             :integer         not null, primary key
#  first_name     :string(255)
#  middle_names   :string(255)
#  last_name      :string(255)
#  identifier_url :string(255)
#  email          :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  type           :string(255)
#  class_of_id    :integer
#

class Eit < User
  has_many :team_memberships
  has_many :teams, :through => :team_memberships 
  belongs_to :class_of
  validates :class_of, :presence => true
  
end
