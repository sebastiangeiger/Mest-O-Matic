class ChangeDateFormatForDeliverables < ActiveRecord::Migration
  def self.up
    change_column :deliverables, :start_date, :datetime
    change_column :deliverables, :end_date, :datetime
  end

  def self.down
    change_column :deliverables, :start_date, :date
    change_column :deliverables, :end_date, :date
  end
end
