class CreateViews < ActiveRecord::Migration
  def self.up
    create_table :views do |t|
      t.integer :nad_id
      t.integer :viewedon

      t.timestamps
    end
  end

  def self.down
    drop_table :views
  end
end
