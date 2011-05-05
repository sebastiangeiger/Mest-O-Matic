class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.date :start
      t.date :end
      t.string :title
      t.text :description
      t.references :semester
      
      t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end
