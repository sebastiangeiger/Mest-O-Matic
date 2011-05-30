# == Schema Information
# Schema version: 20110518121401
#
# Table name: projects
#
#  id          :integer         not null, primary key
#  start       :date
#  end         :date
#  title       :string(255)
#  description :text
#  semester_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#  subject_id  :integer
#  type        :string(255)
#

class Project < ActiveRecord::Base
  SUBTYPES = %w[Assignment Quiz TeamProject]
  has_many :deliverables

  belongs_to :semester
  belongs_to :subject
  
  has_one  :class_of, :through => :semester  

  validates :title, :presence => true
  validates :start, :presence => true
  validates :semester, :presence => true
  validates :type, :presence => true, :inclusion => SUBTYPES
  
  def Project.types
    SUBTYPES
  end

  def Project.for_user(user)
    if user.eit? then
      @projects = Project.by_class(user.class_of)
    elsif user.staff? then
      @projects = Project.all 
    else
      @projects = []
    end
  end
  private
    def Project.by_class(class_of)
      Project.all.select{|p| p.semester.class_of==class_of}
    end


end
