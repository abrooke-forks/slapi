# frozen_string_literal: true

require_relative 'plugin'

# Plugins class will act as a cache of the plugins currently loaded.
# Its two main functions are to:
#  1. Load the configuration of all plugins
#  2. Route the execution to the right plugin
class Plugins

  attr_reader :plugin_hash

  def initialize
    @plugin_hash = {}
    load
  end

  # Loads the plugin configuration.
  # Intention is that this is called on startup, however can also be called at any time
  # during execution to reload
  #
  # Currently does not take any parameters nor does it return anything.
  # Future iterations should allow for configuration based on commands from chat.
  def load
    yaml_files = File.expand_path('../../config/plugins/*.yml', File.dirname(__FILE__))
    Dir.glob(yaml_files).each do |file|
      @plugin_hash[File.basename(file, '.*')] = Plugin.new(file)
    end
  end

  # Routes the execution to the correct plugin if it exists.
  def help_list(help_options, requested_plugin = nil)
    @help_return = ''
    if requested_plugin
      plugin_object = @plugin_hash[requested_plugin]
      puts plugin_object
      @help_return += requested_plugin + ':' + "\n" + plugin_object.help
    else
      @plugin_hash.each do |name, plugin|
        @help_return += help_options['level'] == 1 ? name + "\n" : name + ':' + "\n" + plugin.help
      end
    end
    @help_return
  end

  # Routes the execution to the correct plugin
  def exec(data, requested_plugin = nil)
    plugin_object = verify(requested_plugin)
    plugin_object.exec data if plugin_object
  end

  # Verifies plugin that's eing executed
  def verify(requested_plugin)
    plugin_return = nil
    @plugin_hash.each do |name, plugin|
      plugin_return = plugin if name == requested_plugin
    end
    plugin_return
  end
end
