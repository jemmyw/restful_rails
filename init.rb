require 'restful/restful'

config_file = File.join(RAILS_ROOT, 'config', 'restful.rb')

if File.exists?(config_file)
  RR::Configuration.config(File.read(config_file))
end