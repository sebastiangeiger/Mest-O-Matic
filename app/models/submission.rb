# == Schema Information
# Schema version: 20110607093836
#
# Table name: submissions
#
#  id                   :integer         not null, primary key
#  solution_id          :integer
#  created_at           :datetime
#  updated_at           :datetime
#  archive_file_name    :string(255)
#  archive_content_type :string(255)
#  archive_file_size    :integer
#  archive_updated_at   :datetime
#  md5_checksum         :string(255)
#  type                 :string(255)
#

class Submission < ActiveRecord::Base
  belongs_to :solution
  
  has_one :review

  accepts_nested_attributes_for :review

  validates :solution, :presence => true 

  def user
    solution.user
  end

  def version
    solution.submissions.index(self)
  end

end
