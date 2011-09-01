class AddIndexesToRelationships < ActiveRecord::Migration
  def self.up
  end
  
  add_index :relationships, :debtor_id
  add_index :relationships, :creditor_id
  

  def self.down
  end
end
