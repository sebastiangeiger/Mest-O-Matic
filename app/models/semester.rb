class Semester < ActiveRecord::Base
  has_many :projects
  belongs_to :class_of
  
  validates_uniqueness_of :class_of_id, :nr
  validates :class_of, :presence => true

  def title
    "#{class_of.year} / #{nr}"
  end
end
