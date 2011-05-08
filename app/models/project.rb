# == Schema Information
# Schema version: 20110505105605
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
#

class Project < ActiveRecord::Base
  has_many :deliverables
  
  belongs_to :semester
  belongs_to :subject
  
  validates :title, :presence => true
  validates :start, :presence => true
  validates :semester, :presence => true
end
