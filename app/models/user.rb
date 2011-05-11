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
  
  validates :identifier_url, :presence => true, :uniqueness => true
  validates :email,          :presence => true, :uniqueness => true
  validates :first_name,     :presence => true, :on => :update
  validates :last_name,      :presence => true, :on => :update 
  validates :first_name,   :allow_nil => true, :capitalized => true
  validates :last_name,    :allow_nil => true, :capitalized => true
  validates :middle_names, :allow_nil => true, :capitalized => true
  
  def suggested_first_name
    first_name || email.split("@").first.split(".").first.capitalize
  end

  def suggested_last_name
    last_name || email.split("@").first.split(".").last.capitalize
  end
  
  def complete?
    self.valid?
  end
end
