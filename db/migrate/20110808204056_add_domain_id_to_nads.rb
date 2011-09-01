class AddDomainIdToNads < ActiveRecord::Migration
  def self.up
    add_column :nads, :domain_id, :integer
  end

  def self.down
    remove_column :nads, :domain_id
  end
end
