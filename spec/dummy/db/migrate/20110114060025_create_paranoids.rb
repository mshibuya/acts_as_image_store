class CreateParanoids < ActiveRecord::Migration
  def self.up
    create_table :paranoids do |t|
      t.string :name
      t.string :image
      t.datetime :deleted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :paranoids
  end
end
