require File.dirname(__FILE__) + '/test_helper'

class ActsAsFilestoreTest < Test::Unit::TestCase
	load_schema

	class Log < ActiveRecord::Base
		acts_as_filestore :data, :title, :dir => File.join(File.dirname(__FILE__), 'plugintest')
	end

	def setup
		# remove test directory
		FileUtils::remove_dir(File.join(File.dirname(__FILE__), 'plugintest'), true)
	end

  def test_this_plugin
    l = Log.new
		assert_nil(l.data,  "data should be empty")
		assert_nil(l.title, "title should be empty")

		l.data = 'testing data...'
		assert_equal('testing data...', l.data, "data should be set")
		assert(l.save, "Log should save OK")

		l = Log.find(:first)
		assert_equal('testing data...', l.data, "data should be set after reload")

		l.title = 'testing title'
		l = Log.find(:first)
		assert(l.title.blank?, "title should be empty, was: #{l.title.inspect}")
		l.title = 'testing title'
		assert(l.save, "Log should save OK")


		assert_equal('testing data...', File.new(File.join(l.send(:act_as_filestore_dir),'data.store')).read, "data value should be stored in file")

		dir = l.send(:act_as_filestore_dir)

		l2 = Log.new
		assert_nil(l2.data, "should not be able to read value from other model")

		assert(l.destroy)
		assert(!File.directory?(dir), "store directory should be removed")
  end
end
