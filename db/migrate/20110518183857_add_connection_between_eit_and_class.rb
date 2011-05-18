class AddConnectionBetweenEitAndClass < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.references :class_of
    end
  end

  def self.down
    change_table :users do |t|
      t.remove_references :class_of
    end
  end
end
