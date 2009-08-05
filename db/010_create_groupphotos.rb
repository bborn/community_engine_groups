class CreateGroupphotos < ActiveRecord::Migration
  def self.up
    create_table :groupphotos do |t|
      t.column "name", :string
      t.column "description", :text
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
      t.column "group_id", :integer
      t.column "content_type", :string
      t.column "filename", :string     
      t.column "size", :integer
      t.column "parent_id",  :integer 
      t.column "thumbnail", :string      
      t.column "width", :integer  
      t.column "height", :integer      
    end
  end

  def self.down
    drop_table :groupphotos
  end
end
