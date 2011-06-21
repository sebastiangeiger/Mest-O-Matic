class AddedGradedColumnToDeliverable < ActiveRecord::Migration
  def self.up
    change_table :deliverables do |t|
      t.boolean :graded, :default => false
      t.date :last_graded_at
    end 
  end

  def self.down
    change_table :deliverables do |t|
      t.remove :graded
      t.remove :last_graded_at
    end
  end
end
