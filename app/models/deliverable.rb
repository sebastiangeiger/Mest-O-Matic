# == Schema Information
# Schema version: 20110508021842
#
# Table name: deliverables
#
#  id          :integer         not null, primary key
#  title       :string(255)
#  description :string(255)
#  start_date  :date
#  end_date    :date
#  projects_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Deliverable < ActiveRecord::Base
  belongs_to :projects
end
