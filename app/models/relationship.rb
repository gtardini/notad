class Relationship < ActiveRecord::Base
  belongs_to :debtor, :class_name => "Domain"
  belongs_to :creditor, :class_name => "Domain"
end
