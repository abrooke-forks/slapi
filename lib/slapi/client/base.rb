# frozen_string_literal: true

# Basic Client setup
class Slapi
  def self.run
    @client.on :hello do
      @logger.info("Client: Successfully connected, welcome '#{@client.self.name}' to the '#{@client.team.name}' team at https://#{@client.team.domain}.slack.com.")
    end

    @client.on :message do |data|
      case data.text
      when /#{bot_prefix(data)}ping/ then
        @logger.debug('User requested ping')
        ping(data)
      when /#{bot_prefix(data)}help/ then
        @logger.debug('User requested help')
        get_help(data)
      when /#{bot_prefix(data)}reload/ then
        @logger.debug('User requested plugin reload')
        reload(data)
      when /#{bot_prefix(data)}/ then
        @logger.debug('User request forwarded to check against plugins')
        plugin(data)
      end unless data.user == @client.self.id
    end
    @client.start_async
  end

  def self.ping(data)
    chat(
      data,
      title: 'Bot Check',
      text: 'PONG',
      color: '#229954'
    )
  end

  def self.get_help(data)
    # Remove when doing level 2 help or responding with specific plugin help
    unless (data.text.include? "#{bot_prefix(data)}help ") || (@help_options['level'] == 2)
      help_text = "Please use `@#{@bot_name} help plugin_name` for specific info"
    end
    if help_list(data)
      chat(
        data,
        pretext: help_text,
        fallback: 'Your help has arrived!',
        title: 'Help List',
        text: help_list(data),
        color: '#F7DC6F'
      )
    else
      chat(
        data,
        title: 'Help Error',
        fallback: 'Plugins or Commands not Found!',
        text: "Sorry <@#{data.user}>, I did not find any help commands or plugins to list",
        color: '#A93226'
      )
    end
  end

  def self.reload(data)
    chat(
      data,
      title: 'Plugin Reloader',
      text: 'Plugins are being reloaded, please wait',
      color: '#F7DC6F'
    )
    reload_plugins
    chat(
      data,
      title: 'Plugin Reloader',
      text: 'Plugins Reloaded Successfully',
      color: '#229954'
    )
  end

  def self.plugin(data)
    if exec(data)
      chat(
        data,
        title: "Plugin: #{requested_plugin(data)}",
        fallback: 'Plugin Responded',
        text: exec(data),
        color: '#229954'
      )
    # If configured, will mute failure response. Good for API Plugins that don't provide responses
    elsif !@bot_options['mute_fail']
      @logger.debug('User request did not find a matching plugin')
      chat(
        data,
        title: 'Plugin Error',
        fallback: 'No Plugin Found!',
        text: "Sorry <@#{data.user}>, I did not understand or find that command.",
        color: '#A93226'
      )
    end
  end
end
# end
