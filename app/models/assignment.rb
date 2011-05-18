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

class Assignment < Project
end
