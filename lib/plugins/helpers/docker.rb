# frozen_string_literal: true

# Docker Helpers for Plugin Class
# Its main functions are to:
#  1. Set Items to be binded/mounted to Plugin Container
#     - Include script if script type
#     - Include plugin config if configured with path to mount/bind
#  2. Set Script Language based on plugin config
#     - Language determines which image is pulled for script exec
class Plugin
  def bind_set(type = nil)
    if type == 'script'
      if @config['plugin']['mount_config'].nil?
        @container_hash['HostConfig']['Binds'] =
          [
            "#{Dir.pwd}/scripts/#{filename}:/scripts/#{filename}"
          ]
        @logger.debug("Plugin: #{@name}: Script Type Plugin; No Config Bind")
      else
        # Will mount the plugins yml file into the container at specified path.
        # This enable configing the plugin with a single file at both level (SLAPI and Self)
        @container_hash['HostConfig']['Binds'] =
          [
            "#{Dir.pwd}/scripts/#{filename}:/scripts/#{filename}",
            "#{Dir.pwd}/config/plugins/#{@name}.yml:#{@config['plugin']['mount_config']}"
          ]
        @logger.debug("Plugin: #{@name}: Script Type Plugin; Config being binded to container at location: #{@config['plugin']['mount_config']}")
      end
    elsif !@config['plugin']['mount_config'].nil?
      # Will mount the plugins yml file into the container at specified path.
      # This enable configing the plugin with a single file at both level (SLAPI and Self)
      @container_hash['HostConfig']['Binds'] =
        [
          "#{Dir.pwd}/config/plugins/#{@name}.yml:#{@config['plugin']['mount_config']}"
        ]
      @logger.debug("Plugin: #{@name}: Container Type Plugin; Config being binded to container at location: #{@config['plugin']['mount_config']}")
    else
      @logger.debug("Plugin: #{@name}: Container Type Plugin; No Config Bind")
    end
  end

  def lang_settings
    lang = {}
    case @config['plugin']['language']
    when 'ruby', 'rb'
      lang[:file_type] = '.rb'
      lang[:image] = 'slapi/ruby:latest'
    when 'python', 'py'
      lang[:file_type] = '.py'
      lang[:image] = 'slapi/python:latest'
    when 'node', 'nodejs', 'javascript', 'js'
      lang[:file_type] = '.js'
      lang[:image] = 'slapi/nodejs:latest'
    when 'bash', 'shell'
      lang[:file_type] = '.sh'
      lang[:image] = 'slapi/base:latest'
    else
      lang[:file_type] = '.sh'
      lang[:image] = 'slapi/base:latest'
      @logger.info("Plugin: #{@name}: Language not set in config, defaulting to shell/bash")
    end
    lang
  end
end
