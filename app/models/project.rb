# == Schema Information
# Schema version: 20110518121401
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

class Project < ActiveRecord::Base
  SUBTYPES = %w[Assignment Quiz TeamProject]
  has_many :deliverables
  
  belongs_to :semester
  belongs_to :subject
  
  validates :title, :presence => true
  validates :start, :presence => true
  validates :semester, :presence => true
  validates :type, :presence => true, :inclusion => SUBTYPES
  
  def Project.types
    SUBTYPES
  end
end
