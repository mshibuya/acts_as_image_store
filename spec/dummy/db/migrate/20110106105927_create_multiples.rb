class CreateMultiples < ActiveRecord::Migration
  def self.up
    create_table :multiples do |t|
      t.string :title
      t.integer :confirm_id

      t.timestamps
    end
  end

  def self.down
    drop_table :multiples
  end
end
