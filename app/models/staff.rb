# == Schema Information
# Schema version: 20110518183857
#
# Table name: users
#
#  id             :integer         not null, primary key
#  first_name     :string(255)
#  middle_names   :string(255)
#  last_name      :string(255)
#  identifier_url :string(255)
#  email          :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  type           :string(255)
#  class_of_id    :integer
#

class Staff < User
  has_many :reviews
  has_many :version_downloads

  def latest_version_downloaded(deliverable)
    VersionDownload.where(:downloader_id => self.id, :deliverable_id => deliverable.id, :version_nr => deliverable.latest_version_nr).first
  end
  
  def latest_downloaded_version_nr(deliverable)
    lv = VersionDownload.where(:downloader_id => self.id, :deliverable_id => deliverable.id).all.sort{|a,b| a.version_nr <=> b.version_nr}.last
    return 0 if lv.nil?
    lv.version_nr
  end
end
