# == Schema Information
# Schema version: 20110517132702
#
# Table name: deliverables
#
#  id          :integer         not null, primary key
#  title       :string(255)
#  description :string(255)
#  start_date  :datetime
#  end_date    :datetime
#  project_id  :integer
#  created_at  :datetime
#  updated_at  :datetime
#  author_id   :integer
#

class Deliverable < ActiveRecord::Base
  belongs_to :project
  
  has_many :solutions
  has_many :submissions, :through => :solutions
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"
  
  validates :title, :presence => true
  validates_uniqueness_of :title, :scope => :project_id, :case_sensitive => false
  validates :project, :presence => true
  validates :start_date, :presence => true
  validates :end_date, :presence => true
  validates :author, :presence => true
  validate :start_date_must_be_before_end_date
  
  def start_date_must_be_before_end_date
    errors.add(:end_date, 'must be after start date') if start_date and end_date and start_date >= end_date
  end
  
  def current?
    end_date > DateTime.now
  end
  
  def ended?
    not current?
  end
  
  def graded?
    false
  end
  
  def not_graded_yet?
    not graded?
  end
  
  def submissions_for(by_user)
    user_solution = solutions.select{|sol| sol.user.eql?(by_user)}.first
    if user_solution
      user_solution.submissions 
    else
      []
    end
  end
  
  def not_submitted?(by_user)
    submissions_for(by_user).empty?
  end
  
  def submitted?(by_user)
    submissions_for(by_user).size > 0
  end

  def latest_submission(by_user)
    submissions_for(by_user).sort{|a,b| a.created_at <=> b.created_at}.first
  end
  
  def submitted_on_time?(by_user)
    latest_submission(by_user).created_at <= end_date
  end
  
  def submitted_too_late?(by_user)
    submitted?(by_user) and not submitted_on_time?(by_user)
  end

  def versions 
    versions = {0 => []}
    current_submissions = []
    submissions.sort{|a,b| a.created_at <=> b.created_at}.each_with_index do |sub, i|
      current_submissions = Array.new(current_submissions).reject{|s| sub.solution == s.solution}
      current_submissions << sub
      versions[i+1] = current_submissions
    end
    return versions
  end
  
end
