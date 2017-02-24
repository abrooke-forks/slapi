# frozen_string_literal: true

# Docker Helpers for Plugin Class
# Its main functions are to:
#  1. Set Items to be binded/mounted to Plugin Container
#     - Include script if script type
#     - Include plugin config if configured with path to mount/bind
#  2. Set Script Language based on plugin config
#     - Language determines which image is pulled for script exec
class Plugin
  def bind_set(filename = nil, script = nil)
    @binds = []
    @logger.debug("Plugin: #{@name}: Setting Binds")
    if script
      puts "I has binds #{@binds}"
      @binds.push("#{Dir.pwd}/scripts/#{filename}:/scripts/#{filename}")
      puts "I has binds #{@binds}"
      @binds.push("#{Dir.pwd}/config/plugins/#{@name}.yml:#{@config['plugin']['mount_config']}") if @config['plugin']['mount_config']
      puts "I has binds #{@binds}"
    elsif @config['plugin']['mount_config']
      # Will mount the plugins yml file into the container at specified path.
      # This enable configing the plugin with a single file at both level (SLAPI and Self)
      @binds.push("#{Dir.pwd}/config/plugins/#{@name}.yml:#{@config['plugin']['mount_config']}")
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
