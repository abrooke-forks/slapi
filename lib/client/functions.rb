# frozen_string_literal: true

# Extend Slapi class
# Basic Client setup
class ClientFunctions < Slapi
  def initialize
    super()
  end

  def ping
    @client.web_client.chat_postMessage channel: data.channel,
                                        as_user: true,
                                        attachments:
                                        [
                                          {
                                            title: 'Bot Check',
                                            text: 'PONG',
                                            color: '#229954'
                                          }
                                        ]
  end

  def help(data)
    help_return = @plugins.help data
    # Remove when doing level 2 help or responding with specific plugin help
    unless (data.text.include? "#{@bot_prefix}help ") || (@help_options['level'] == 2)
      help_text = "Please use `@#{@bot_name} help plugin_name` for specific info"
    end
    # Set channel to post based on dm_user option
    help_channel = data.channel unless @help_options['dm_user']

    # if doing dm_user under help, create DM and set channel ID for chat post
    dm_info = @client.web_client.im_open user: data.user if @help_options['dm_user']
    help_channel = dm_info['channel']['id'] if @help_options['dm_user']
    if help_return && !help_return.empty?
      @client.web_client.chat_postMessage channel: help_channel,
                                          as_user: true,
                                          attachments:
                                          [
                                            {
                                              pretext: help_text,
                                              fallback: 'Your help has arrived!',
                                              title: 'Help List',
                                              text: help_return,
                                              color: '#F7DC6F'
                                            }
                                          ]
    else
      @client.web_client.chat_postMessage channel: help_channel,
                                          as_user: true,
                                          attachments:
                                          [
                                            {
                                              title: 'Help Error',
                                              fallback: 'Plugins or Commands not Found!',
                                              text: "Sorry <@#{data.user}>, I did not find any help commands or plugins to list",
                                              color: '#A93226'
                                            }
                                          ]
    end
  end

  def reload
    @client.web_client.chat_postMessage channel: data.channel,
                                        as_user: true,
                                        attachments:
                                        [
                                          {
                                            title: 'Plugin Reloader',
                                            text: 'Plugins are being reloaded, please wait',
                                            color: '#F7DC6F'
                                          }
                                        ]
    @plugins.load
    @client.web_client.chat_postMessage channel: data.channel,
                                        as_user: true,
                                        attachments:
                                        [
                                          {
                                            title: 'Plugin Reloader',
                                            text: 'Plugins Reloaded Successfully',
                                            color: '#229954'
                                          }
                                        ]
  end
end
