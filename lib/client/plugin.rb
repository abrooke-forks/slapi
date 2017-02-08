# frozen_string_literal: true

# Extend Slapi class
# Basic Client setup
class ClientPlugin < Slapi
  def initialize
    super()
  end

  def run(data)
    if data.text.include? ' '
      # Create array based on spaces
      data_array = data.text.split(' ')
      requested_plugin = data_array[1] unless data.channel[0] == 'D'
      requested_plugin = data_array[0] if data.channel[0] == 'D'
    elsif data.text.exclude? @client.self.id
      requested_plugin = data.text
    end

    plugin_return = @plugins.exec(requested_plugin, data) if requested_plugin

    # phrase_return = @plugins.phrase_lookup data
    if plugin_return && !plugin_return.empty?
      data_array = data.text.split(' ')
      requested_plugin = data_array[1] unless data.channel[0] == 'D'
      requested_plugin = data_array[0] if data.channel[0] == 'D'
      @client.web_client.chat_postMessage channel: data.channel,
                                          as_user: true,
                                          attachments:
                                          [
                                            {
                                              title: "Plugin: #{requested_plugin}",
                                              fallback: 'Plugin Responded',
                                              text: plugin_return,
                                              color: '#229954'
                                            }
                                          ]
    # elsif phrase_return && !phrase_return.empty?
    #   @client.web_client.chat_postMessage channel: data.channel,
    #                                       text: phrase_return
    # TODO: could simply not respond at all or make configurable.
    elsif !@bot_options['mute_fail']
      @client.web_client.chat_postMessage channel: data.channel,
                                          as_user: true,
                                          attachments:
                                          [
                                            {
                                              title: 'Plugin Error',
                                              fallback: 'No Plugin Found!',
                                              text: "Sorry <@#{data.user}>, I did not understand or find that command.",
                                              color: '#A93226'
                                            }
                                          ]
    end
  end
end
