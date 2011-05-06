class ClassOf < ActiveRecord::Base
  has_many :semesters
  
  validates_uniqueness_of :year
end
