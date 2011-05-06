class DefaultValuesForYearAndSemester < ActiveRecord::Migration
  def self.up
    c11 = ClassOf.find_or_create_by_year("2011")
    c12 = ClassOf.find_or_create_by_year("2012")
    c13 = ClassOf.find_or_create_by_year("2013")
    Semester.create(:class_of => c11, :nr => 4, :start => Date.parse("2011-01-01"), :end => Date.parse("2011-07-31"))
    Semester.create(:class_of => c12, :nr => 2, :start => Date.parse("2011-01-01"), :end => Date.parse("2011-07-31"))
  end

  def self.down
    #TODO
  end
end
