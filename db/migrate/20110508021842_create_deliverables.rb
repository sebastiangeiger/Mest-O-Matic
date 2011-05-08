class CreateDeliverables < ActiveRecord::Migration
  def self.up
    create_table :deliverables do |t|
      t.string :title
      t.string :description
      t.date :start_date
      t.date :end_date
      t.references :project
      t.timestamps
    end
  end

  def self.down
    drop_table :deliverables
  end
end
