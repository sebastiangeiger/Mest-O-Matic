class CreateVersionDownloads < ActiveRecord::Migration
  def self.up
    create_table :version_downloads do |t|
      t.integer :version_nr 
      t.references :deliverable
      t.references :downloader

      t.timestamps
    end
  end

  def self.down
    drop_table :version_downloads
  end
end
