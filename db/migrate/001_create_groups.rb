class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string  :name
      t.text    :short_description
      t.text    :long_description
      t.boolean :public, :default => true
      t.integer :owner_id
      t.timestamps
    end
  end

  def self.down
    drop_table :groups
  end
end
