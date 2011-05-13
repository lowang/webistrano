class AddNoActionToRole < ActiveRecord::Migration
  def self.up
    add_column :roles, :no_action, :integer, :default => 0
  end

  def self.down
    remove_column :roles, :no_action
  end
end
