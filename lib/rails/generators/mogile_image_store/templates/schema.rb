ActiveRecord::Schema.define(:version => 0) do

    create_table :mogile_images do |t|
      t.string     :name,       :limit => 32
      t.string     :type,       :limit => 3
      t.integer    :size
      t.integer    :width
      t.integer    :height
      t.integer    :refcount
      t.timestamps
    end

    add_index :mogile_images, [:name]

end
