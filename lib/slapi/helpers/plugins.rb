# frozen_string_literal: true

# Plugin Helpers for Slapi Class
# Its main functions are to:
#  1. Allow Reloading of Plugins
#  2. Get Help items from Plugins (Command List)
#  3. Pass commands to exec to plugins
#  4. Verify plugin exec requested is available or configured
#  5. Verify plugin help requested is available or configured
#     - Determine is requesting a Command List or Help for specific command
#  6. Sort data from chat for Requested Plugin
#     - Determines if data is coming from Chat Room, DM, or has Bot Name included/excluded
class Slapi

  # Allows reloads from
  def self.reload_plugins
    @logger.debug('Loading plugins')
    @plugins.load
  end

  # Pulls help list of Plugins Object
  def self.help_list(data)
    @logger.debug('Slapi: Getting help list')
    @plugins.help_list(requested_plugin(data))
  end

  # Routes the execution to the correct plugin if it exists.
  def self.exec(data)
    request = requested_plugin(data)
    @logger.debug("Slapi: Running plugin execution against #{request}")
    @plugins.exec(data, request)
  end

  # Validate plugin exists
  def self.verify(data)
    request = requested_plugin(data)
    @logger.debug("Slapi: Validating plugin request #{request}")
    @plugins.verify(request)
  end

  def self.help_verify(data)
    request = requested_plugin(data)
    if request
      @logger.debug("Slapi: Verifying requested plugin - #{request}")
      @plugins.verify(request)
    elsif !request
      @logger.debug('Slapi: No specific plugin help requested')
      true
    end
  end

  def self.requested_plugin(data)
    if data.text.include? ' '
      requested_plugin = chat_data_sort(data)
    elsif data.text.exclude? @client.self.id
      @logger.debug('Slapi: Plugin called without args from DM')
      requested_plugin = data.text
    else
      @logger.debug('Slapi: No matches found, no plugin requested')
      requested_plugin = null
    end
    requested_plugin
  end

  def self.chat_data_sort(data)
    # Create array based on spaces
    data_array = data.text.split(' ')
    if data.text.include? 'help'
      @logger.debug('Slapi: Checking if help request includes a plugin')
      requested_plugin = data.channel[0] == 'D' ? data_array[1] : data_array[2]
      @logger.debug("Slapi: Help requested for #{requested_plugin}") if requested_plugin
    else
      @logger.debug('Slapi: Checking if bot call has a requested plugin')
      requested_plugin = data.channel[0] == 'D' ? data_array[0] : data_array[1]
      @logger.debug("Slapi: Requested #{requested_plugin}") if requested_plugin
    end
    requested_plugin
  end
end
