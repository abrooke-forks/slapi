# frozen_string_literal: true

# Slapi Plugin Helper for Sinatra Extension Access
class Slapi

  # Allows reloads from
  def self.reload_plugins
    @plugins.load
  end

  # Pulls help list of Plugins Object
  def self.help_list(data)
    @plugins.help_list(@help_options, requested_plugin(data)) if requested_plugin(data)
  end

  # Routes the execution to the correct plugin if it exists.
  def self.exec(data)
    @plugins.exec(data, requested_plugin(data))
  end

  def self.requested_plugin(data)
    if data.text.include? ' '
      # Create array based on spaces
      data_array = data.text.split(' ')
      if data.text.include? 'help'
        data.channel[0] == 'D' ? data_array[1] : data_array[2]
      else
        data.channel[0] == 'D' ? data_array[0] : data_array[1]
      end
    elsif data.text.exclude? @client.self.id
      data.text
    else
      null
    end
  end
end
