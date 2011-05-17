class AddAuthorToDeliverables < ActiveRecord::Migration
  def self.up
    change_table :deliverables do |t|
      t.integer :author_id
    end
  end

  def self.down
    change_table :deliverables do |t|
      t.remove :author_id
    end
  end
end
