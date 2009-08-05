config.after_initialize do
  if RAILS_ENV == 'development'
    ActiveSupport::Dependencies.load_once_paths = ActiveSupport::Dependencies.load_once_paths.select {|path| (path =~ /(community_engine_groups)/).nil? }  
  end
end 

require_plugin 'community_engine'
config.plugin_paths += ["#{RAILS_ROOT}/vendor/plugins/community_engine_groups/plugins"]


I18n.load_path += Dir[ (File.join(RAILS_ROOT, "vendor", "plugins", "community_engine_geolocation", "lang", "ui", '*.{rb,yml}')) ]
I18n.reload!


if File.exists?( File.join(RAILS_ROOT, 'config', 'application.yml') )
  file = File.join(RAILS_ROOT, 'config', 'application.yml')
  users_app_config = YAML.load_file file
end

plugin_app_config = YAML.load_file(File.join(RAILS_ROOT, 'vendor', 'plugins', 'community_engine_groups', 'config', 'application.yml'))

config_hash = (users_app_config||{}).reverse_merge!(plugin_app_config)

orig_hash   = AppConfig.marshal_dump
merged_hash = config_hash.merge(orig_hash)

AppConfig = OpenStruct.new merged_hash
