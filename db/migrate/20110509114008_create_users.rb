class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :first_name
      t.string :middle_names
      t.string :last_name
      t.string :identifier_url
      t.string :email

      t.timestamps
    end
    add_index :users, :identifier_url, :unique => true
  end

  def self.down
    drop_table :users
  end
end
