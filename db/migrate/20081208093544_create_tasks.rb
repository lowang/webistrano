class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string :name
      t.integer :stage_id
      t.string :role, :limit => 32
    end
  end

  def self.down
    drop_table :tasks
  end
end
