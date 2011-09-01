class Domain < ActiveRecord::Base
  has_many :nads
  
  has_many :relationships, :foreign_key => "creditor_id"
  
  has_many :reverse_relationships, :foreign_key => "debtor_id",
                                   :class_name => "Relationship"
  
  has_many :debtors, :through => :relationships, :source => :debtor
  has_many :creditors, :through => :reverse_relationships, :source => :creditor
end
