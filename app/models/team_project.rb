# == Schema Information
# Schema version: 20110518175912
#
# Table name: projects
#
#  id          :integer         not null, primary key
#  start       :date
#  end         :date
#  title       :string(255)
#  description :text
#  semester_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#  subject_id  :integer
#  type        :string(255)
#

class TeamProject < Project
  has_many :teams
  has_one :class_of, :through => :semester 

  def assigned_eits
    teams.inject([]){|assigned, team| assigned |= team.eits}
   end

  def unassigned_eits
    class_of.eits.reject{|eit| assigned_eits.include?(eit)}
  end
  
  def teams_for_eit(eit)
    teams.select{|team| team.eits.include?(eit)}
  end
  
  def has_empty_teams?
    teams.select{|team| team.eits.empty?}.size > 0
  end
end
