# frozen_string_literal: true

# Slapi Plugin Helper for Sinatra Extension Access
class Slapi

  def self.requested_plugin(data)
    if data.text.include? ' '
      # Create array based on spaces
      data_array = data.text.split(' ')
      data.channel[0] == 'D' ? data_array[0] : data_array[1]
    elsif data.text.exclude? @client.self.id
      data.text
    else
      null
    end
  end

  def self.plugins
    # TODO: Need to load into redis and still make accessible
    yaml_files = File.expand_path('../../../config/plugins/*.yml', File.dirname(__FILE__))
    Dir.glob(yaml_files).each do |file|
      File.basename(file, '.*') = Plugin.new(file)
      delete('plugins', File.basename(file, '.*'))
      save('plugins', File.basename(file, '.*'), plugin_object)
    end
  end

  def self.help_list(data)
    @help_return = ''
    if requested_plugin(data)
      plugin_object = query_key('plugins', requested_plugin(data))
      @help_return += name + ':' + "\n" + plugin_object.help
    else
      query_hash('plugins').each do |plugin|
        plugin_object = query_key('plugins', plugin)
        @help_return += @help_options['level'] == 1 ? plugin + "\n" : name + ':' + "\n" + plugin_object.help
      end
    end
    help_return
  end

  # Routes the execution to the correct plugin if it exists.
  def self.exec(data)
    requested_plugin(data).exec data if requested_plugin(data)
  end
end
