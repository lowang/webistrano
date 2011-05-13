class AlterDeployment < ActiveRecord::Migration
  def self.up
    execute 'ALTER TABLE `deployments` CHANGE `log` `log` MEDIUMTEXT CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL'
  end

  def self.down
    execute 'ALTER TABLE `deployments` CHANGE `log` `log` TEXT CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL'
  end
end
