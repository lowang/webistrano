class Task < ActiveRecord::Base
  belongs_to :stage
  serialize :roles, Array
end
