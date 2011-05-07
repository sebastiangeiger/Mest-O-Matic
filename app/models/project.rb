class Project < ActiveRecord::Base
  belongs_to :semester
  belongs_to :subject
  
  validates :title, :presence => true
  validates :start, :presence => true
  validates :semester, :presence => true
end
