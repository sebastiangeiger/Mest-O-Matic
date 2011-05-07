class ClassOf < ActiveRecord::Base
  has_many :semesters
  
  validates :year, :uniqueness => true
  validates :year, :presence => true
  validates :year, :numericality => true
end
