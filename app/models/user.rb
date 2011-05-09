# == Schema Information
# Schema version: 20110509114008
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
#

class User < ActiveRecord::Base
end
