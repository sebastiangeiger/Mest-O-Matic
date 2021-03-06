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

class User < ActiveRecord::Base
  include ActiveModel::Validations
  SUBTYPES = %w[Eit Staff] 
  
  has_many :solutions
  belongs_to :class_of
  
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
  validates :type,         :allow_nil => true, :inclusion => SUBTYPES
  validates_presence_of :class_of, :if => :eit?
  
  def identifier_name 
    email.split("@").first
  end

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
    type == nil
  end
  
  def name 
    "#{first_name} #{last_name}"
  end
  
  def User.types
    SUBTYPES
  end
  
  def User.all_unassigned
    User.all.select{|user| user.unassigned?}
  end
  
  def role=(role_name)
    if role_name and matchdata = role_name.match(/Eit \(Class of (\d{4})\)/) then
      self.type = "Eit"
      self.class_of = ClassOf.find_by_year(matchdata[1].to_i)
    else
      self.type = role_name
    end
  end
  
  def role
    if type.eql?("Eit") then
      "Eit (Class of #{class_of.year})"
    else
      type
    end
  end
  
  def User.all_roles
    ts = SUBTYPES.reject{|t| t.eql?("Eit")}
    ClassOf.all.each do |c|
      ts << "Eit (Class of #{c.year})"
    end
    return ts.sort
  end
end
