# == Schema Information
# Schema version: 20110505105605
#
# Table name: subjects
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Subject < ActiveRecord::Base
  has_many :projects
end
