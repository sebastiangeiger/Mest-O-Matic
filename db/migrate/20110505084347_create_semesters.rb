class CreateSemesters < ActiveRecord::Migration
  def self.up
    create_table :semesters do |t|
      t.integer :nr
      t.date :start
      t.date :end
      t.references :class_of
      
      t.timestamps
    end
  end

  def self.down
    drop_table :semesters
  end
end
