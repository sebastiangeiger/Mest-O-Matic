class OnlyOneMembershipPerProjectValidator < ActiveModel::Validator
  def validate(teammembership)
    if teammembership and teammembership.team and teammembership.team.team_project then
      eit = teammembership.eit
      team = teammembership.team
      team_project = team.team_project
      teammembership.errors[:eit] << "Only one team membership per project is allowed" unless team_project.teams_for_eit(eit).reject{|t| t==team}.empty?
    end
  end
end
