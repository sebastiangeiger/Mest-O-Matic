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
require_relative "capitalized_validator"

class User < ActiveRecord::Base
  include ActiveModel::Validations
  
  validates :identifier_url, :presence => true
  validates_uniqueness_of :identifier_url
  validates :email, :presence => true
  validates_uniqueness_of :email
  validates :first_name, :presence => true, :capitalized => true
  validates :last_name, :presence => true, :capitalized => true
  validates :middle_names, :capitalized => true, :allow_nil => true
  
  def suggested_first_name
    first_name || email.split("@").first.split(".").first.capitalize
  end

  def suggested_last_name
    last_name || email.split("@").first.split(".").last.capitalize
  end
end
