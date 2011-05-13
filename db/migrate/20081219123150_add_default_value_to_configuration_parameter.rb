class AddDefaultValueToConfigurationParameter < ActiveRecord::Migration
  def self.up
    add_column :configuration_parameters, :default_value, :string
  end

  def self.down
    remove_column :configuration_parameters, :default_value
  end
end
