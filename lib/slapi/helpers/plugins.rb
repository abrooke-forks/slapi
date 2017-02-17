# frozen_string_literal: true

# Slapi Plugin Helper for Sinatra Extension Access
class Slapi

  def self.requested_plugin(data)
    if data.text.include? ' '
      # Create array based on spaces
      data_array = data.text.split(' ')
      plugin = data.channel[0] == 'D' ? data_array[0] : data_array[1]
      @plugin_hash[plugin]
    elsif data.text.exclude? @client.self.id
      plugin = data.text
      @plugin_hash[plugin]
    else
      null
    end
  end

  def self.plugins
    yaml_files = File.expand_path('../../../config/plugins/*.yml', File.dirname(__FILE__))
    Dir.glob(yaml_files).each do |file|
      @plugin_hash[File.basename(file, '.*')] = Plugin.new(file)
    end
  end

  def self.help_list(data)
    @help_return = ''
    if requested_plugin(data)
      @help_return += name + ':' + "\n" + @plugin_hash[requested_plugin(data)].help
    else
      @plugin_hash.each do |plugin|
        @help_return += @help_options['level'] == 1 ? plugin + "\n" : name + ':' + "\n" + @plugin_hash[requested_plugin(data)].help
      end
    end
    @help_return
  end

  # Routes the execution to the correct plugin if it exists.
  def self.exec(data)
    @plugin_hash[requested_plugin(data)].exec data if requested_plugin(data)
  end
end
