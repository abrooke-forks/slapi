# frozen_string_literal: true

# Extend Slapi Module
# module Slapi
# Basic Client setup
class Bot
  def self.run
    @client.on :hello do
      @logger.info "Client: Successfully connected, welcome '#{@client.self.name}' to the '#{@client.team.name}' team at https://#{@client.team.domain}.slack.com."
    end

    @client.on :message do |data|
      # Clean up listners and don't require @bot if in a DM
      # Spaces are included here and not in case statement for DM help (i.e.; "help" vs "@bot help")
      bot_prefix = "(^#{@bot_name} |^@#{@bot_name} |^\<@#{@client.self.id}\> )" unless data.channel[0] == 'D'
      bot_prefix = "(^#{@bot_name} |^@#{@bot_name} |^\<@#{@client.self.id}\> |^)" if data.channel[0] == 'D'

      case data.text
      when data.user == @client.self.id then
        null
      when /#{bot_prefix}ping/ then
        ping(data)
      when /#{bot_prefix}help/ then
        get_help(data)
      when /#{bot_prefix}reload/ then
        reload(data)
      when /#{bot_prefix}/ then
        plugin(data)
      end
    end
    @client.start_async
  end

  def self.chat(data, attachment)
    @client.web_client.chat_postMessage(
      channel: channel(data),
      as_user: true,
      attachments: [attachment]
    )
  end

  def self.channel(data)
    # Set channel to post based on dm_user option
    if data.text.include? "#{@bot_prefix}help"
      dm_info = @client.web_client.im_open user: data.user
      @help_options['dm_user'] ? dm_info['channel']['id'] : data.channel
    else
      data.channel
    end
  end

  def self.requested_plugin(data)
    if data.text.include? ' '
      # Create array based on spaces
      data_array = data.text.split(' ')
      data.channel[0] == 'D' ? data_array[0] : data_array[1]
    elsif data.text.exclude? @client.self.id
      data.text
    end
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
    help_return = @plugins.help data

    # Remove when doing level 2 help or responding with specific plugin help
    unless (data.text.include? "#{@bot_prefix}help ") || (@help_options['level'] == 2)
      help_text = "Please use `@#{@bot_name} help plugin_name` for specific info"
    end
    if help_return && !help_return.empty?
      chat(
        data,
        pretext: help_text,
        fallback: 'Your help has arrived!',
        title: 'Help List',
        text: help_return,
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
    @plugins.load
    chat(
      data,
      title: 'Plugin Reloader',
      text: 'Plugins Reloaded Successfully',
      color: '#229954'
    )
  end

  def self.plugin(data)
    plugin_return = @plugins.exec(requested_plugin(data), data) if requested_plugin(data)
    if plugin_return && !plugin_return.empty?
      chat(
        data,
        title: "Plugin: #{requested_plugin(data)}",
        fallback: 'Plugin Responded',
        text: plugin_return,
        color: '#229954'
      )
    # If configured, will mute failure response. Good for API Plugins that don't provide responses
    elsif !@bot_options['mute_fail']
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
