class AddTypeColumnToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :type, :string
  end

  def self.down
    remove_column :projects, :type
  end
end
