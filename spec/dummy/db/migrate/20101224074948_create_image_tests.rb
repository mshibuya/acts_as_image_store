class CreateImageTests < ActiveRecord::Migration
  def self.up
    create_table :image_tests do |t|
      t.string :name, :limit => 32
      t.integer :confirm_id
      t.string :image, :limit => 36
      t.string :image2, :limit => 36

      t.timestamps
    end
  end

  def self.down
    drop_table :image_tests
  end
end
