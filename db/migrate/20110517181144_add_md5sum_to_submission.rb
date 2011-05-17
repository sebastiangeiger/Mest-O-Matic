class AddMd5sumToSubmission < ActiveRecord::Migration
  def self.up
    change_table :submissions do |t|
      t.string :md5_checksum
    end
  end

  def self.down
    change_table :submissions do |t|
      t.remove :md5_checksum
    end
  end
end
