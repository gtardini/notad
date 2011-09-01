class CreateNads < ActiveRecord::Migration
  def self.up
    create_table :nads do |t|
      t.string :outboundlink
      t.string :imgurl
      t.string :head
      t.string :caption
      t.integer :approved

      t.timestamps
    end
  end

  def self.down
    drop_table :nads
  end
end
