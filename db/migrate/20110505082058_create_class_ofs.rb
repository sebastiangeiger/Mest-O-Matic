class CreateClassOfs < ActiveRecord::Migration
  def self.up
    create_table :class_ofs, :id => false do |t|
      t.integer :year

      t.timestamps
    end
  end

  def self.down
    drop_table :class_ofs
  end
end
