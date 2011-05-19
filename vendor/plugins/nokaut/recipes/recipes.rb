unless Capistrano::Configuration.respond_to?(:instance)
  abort "nokaut_svn requires Capistrano 2"
end
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require "#{File.dirname(__FILE__)}/nokaut/capistrano_ext.rb"
require "#{File.dirname(__FILE__)}/nokaut/no_servers_patch.rb"