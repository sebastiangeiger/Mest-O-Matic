class Project < ActiveRecord::Base
  belongs_to :semester
  belongs_to :subject
  
  validates :semester, :presence => true
end
