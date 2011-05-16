# == Schema Information
# Schema version: 20110511191306
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
#

class User < ActiveRecord::Base
  include ActiveModel::Validations
  
  has_many :solutions
  
  def self.attributes_protected_by_default # default is ["id","type"] 
    ["id"] 
  end
  
  validates :identifier_url, :presence => true, :uniqueness => true
  validates :email,          :presence => true, :uniqueness => true
  validates :first_name,     :presence => true, :on => :update
  validates :last_name,      :presence => true, :on => :update 
  validates :first_name,   :allow_nil => true, :capitalized => true
  validates :last_name,    :allow_nil => true, :capitalized => true
  validates :middle_names, :allow_nil => true, :capitalized => true
  # validates :type,         :allow_nil => true, :valid_user_subtype => true

  def suggested_first_name
    first_name || email.split("@").first.split(".").first.capitalize
  end

  def suggested_last_name
    last_name || email.split("@").first.split(".").last.capitalize
  end
  
  def complete?
    !!self.valid?
  end
  
  def eit?
    type.eql?("Eit")
  end
  
  def staff?
    type.eql?("Staff")
  end
  
  def unassigned?
    type.eql?("Unassigned")
  end
  
  def name 
    "#{first_name} #{last_name}"
  end
  
  def User.types
    %w[Eit Staff Unassigned] 
  end
  
  def User.all_unassigned
    User.all.select{|user| user.unassigned?}
  end
  
  def type
    return super if super and User.types.include?(super)
    return "Unassigned"
  end
  
end
