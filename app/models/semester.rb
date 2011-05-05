class Semester < ActiveRecord::Base
  has_many :projects
  belongs_to :class_of
end
