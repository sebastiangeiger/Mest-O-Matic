# == Schema Information
# Schema version: 20110505105605
#
# Table name: semesters
#
#  id          :integer         not null, primary key
#  nr          :integer
#  start       :date
#  end         :date
#  class_of_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Semester < ActiveRecord::Base
  has_many :projects
  belongs_to :class_of
  
  validates_uniqueness_of :nr, :scope => :class_of_id
  validates :class_of, :presence => true
  validates :nr, :presence => true

  def title
    "#{class_of.year} / #{nr}"
  end
end
