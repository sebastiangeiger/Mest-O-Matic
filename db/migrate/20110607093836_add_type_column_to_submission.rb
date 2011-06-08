class AddTypeColumnToSubmission < ActiveRecord::Migration
  def self.up
    change_table :submissions do |t|
      t.string :type
    end
  end

  def self.down
    change_table :submissions do |t|
      t.remove :type
    end
  end
end
