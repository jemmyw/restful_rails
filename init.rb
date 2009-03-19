$: << File.dirname(__FILE__) + '/vendor/plugins/resources_controller/lib'
ActiveSupport::Dependencies.load_paths << File.dirname(__FILE__) + '/vendor/plugins/resources_controller/lib'
ActiveSupport::Dependencies.load_once_paths << File.dirname(__FILE__) + '/vendor/plugins/resources_controller/lib'
require File.dirname(__FILE__) + '/vendor/plugins/resources_controller/init'
require 'restful/restful'

config_file = File.join(RAILS_ROOT, 'config', 'restful.rb')

if File.exists?(config_file)
  RR::Configuration.config(config_file)
end