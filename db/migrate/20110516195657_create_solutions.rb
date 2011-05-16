class CreateSolutions < ActiveRecord::Migration
  def self.up
    create_table :solutions do |t|
      t.references :eit
      t.references :deliverable 
      t.timestamps
    end
  end

  def self.down
    drop_table :solutions
  end
end