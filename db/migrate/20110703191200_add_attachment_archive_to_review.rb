class AddAttachmentArchiveToReview < ActiveRecord::Migration
  def self.up
    add_column :reviews, :archive_file_name, :string
    add_column :reviews, :archive_content_type, :string
    add_column :reviews, :archive_file_size, :integer
    add_column :reviews, :archive_updated_at, :datetime
  end

  def self.down
    remove_column :reviews, :archive_file_name
    remove_column :reviews, :archive_content_type
    remove_column :reviews, :archive_file_size
    remove_column :reviews, :archive_updated_at
  end
end
