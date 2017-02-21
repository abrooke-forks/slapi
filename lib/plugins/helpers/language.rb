# frozen_string_literal: true

# Plugin Helpers for Plugin Class
# Its main functions are to:
#  1. Set Script Language based on plugin config
#     - Language determines which image is pulled for script exec
class Plugin
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
