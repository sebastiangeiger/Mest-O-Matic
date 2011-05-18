# == Schema Information
# Schema version: 20110505105605
#
# Table name: class_ofs
#
#  id         :integer         not null, primary key
#  year       :integer
#  created_at :datetime
#  updated_at :datetime
#

class ClassOf < ActiveRecord::Base
  has_many :semesters
  has_many :eits
  
  validates :year, :uniqueness => true
  validates :year, :presence => true
  validates :year, :numericality => true
end
