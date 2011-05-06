class Project < ActiveRecord::Base
  belongs_to :semester
  belongs_to :subject
end
