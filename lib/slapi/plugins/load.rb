# frozen_string_literal: true
# require 'yaml'
require_relative 'plugin'

# Extends Slapi Module
# module Slapi
# Plugins class will act as a cache of the plugins currently loaded.
# It's two main functions are to:
#  1. Load the configuration of all plugins
#  2. Route the execution to the right plugin
class Slapi
  # TODO: determine if this hash is needed outside of this class
  attr_reader :plugin_hash

  # Loads the plugin configuration.
  # Intention is that this is called on startup, however can also be called at any time
  # during execution to reload
  #
  # Currently does not take any parameters nor does it return anything.
  # Future iterations should allow for configuration based on commands from chat.
  def self.load

    # TODO: Should this remove all images
    # TODO: Should this remove all untagged images?
    #
    # TODO: play with where we want the plugin configuration to live.
    yaml_files = File.expand_path('../../../config/plugins/*.yml', File.dirname(__FILE__))
    Dir.glob(yaml_files).each do |file|
      @plugin_hash[File.basename(file, '.*')] = Plugin.new(file)
    end
  end



  # Searches for phrased based plugins
  # TODO: Create Phrases for Plugins: Create code to sift through chat data to match specific phrases for plugins
  def self.phrase_lookup
    # search plugin hash and container labels?
  end

  # Creates primary help list
  #
  # Utilizes the bot.yml help hash to determine response level.
  # TODO: Build Help Hash/Response to return after .each


  # TODO: should this be exposed to cleanout any unused docker containers
  def cleanup_docker
    # Loop through the list of containers and plugins matching and remove any not connected
  end
end
# end
