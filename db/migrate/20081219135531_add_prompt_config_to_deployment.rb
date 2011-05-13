class AddPromptConfigToDeployment < ActiveRecord::Migration
  def self.up
    add_column :deployments, :prompt_config, :text
  end

  def self.down
    remove_column :deployments, :prompt_config
  end
end
