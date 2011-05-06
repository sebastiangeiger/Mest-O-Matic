class Semester < ActiveRecord::Base
  has_many :projects
  belongs_to :class_of
  
  validates_uniqueness_of :class_of_id, :nr
end
