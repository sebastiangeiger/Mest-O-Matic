class CreateReviews < ActiveRecord::Migration
  def self.up
    create_table :reviews do |t|
      t.integer :percentage
      t.references :submission
      t.text :remarks
      t.references :reviewer

      t.timestamps
    end
  end

  def self.down
    drop_table :reviews
  end
end
