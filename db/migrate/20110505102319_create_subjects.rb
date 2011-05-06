class CreateSubjects < ActiveRecord::Migration
  def self.up
    create_table :subjects do |t|
      t.string :title
      t.timestamps
    end
    
    change_table :projects do |t|
      t.references :subject
    end
    
    Subject.create(:title => "Business")
    Subject.create(:title => "Technology")
    Subject.create(:title => "Communication")
  end

  def self.down
    drop_table :subjects
    change_table :projects do |t|
      t.remove_references :subject
    end
  end
end
