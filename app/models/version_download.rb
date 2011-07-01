# == Schema Information
# Schema version: 20110701140102
#
# Table name: version_downloads
#
#  id             :integer         not null, primary key
#  version_nr     :integer
#  deliverable_id :integer
#  downloader_id  :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class VersionDownload < ActiveRecord::Base
  belongs_to :downloader, :class_name => "Staff", :foreign_key => "downloader_id"
  belongs_to :deliverable
end
