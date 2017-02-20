# frozen_string_literal: true

# Client Helpers for Slapi Class
# Its main functions are to:
#  1. Route Messages to Client
#     - Standard Text Chat
#     - Emote Chat
#     - Attachment Chat
#  2. Set response channel based on where request type
#     - Help request response in DM if set in Bot Config
#     - No channel set for API requests (debug level only message)
#     - Set to same channel as request
#  3. Set Chat listener pre-fix base on channel
#     - Listen for @bot, bot, or bot id as initiator if normal channel
#     - Above plus any line that starts with a listener if direct message
class Slapi
  def self.chat(data = nil, channel = nil, attachment)
    @client.web_client.chat_postMessage(
      channel: channel ? channel : channel_set(data),
      as_user: true,
      attachments: [attachment]
    )
  end

  def self.chat_me(data = nil, channel = nil, attachment)
    @client.web_client.chat_meMessage(
      channel: channel ? channel : channel_set(data),
      attachments: [attachment]
    )
  end

  def self.channel_set(data)
    # Set channel to post based on dm_user option
    if data.empty?
      @logger.debug("Channel request wasn't given any data")
      nil
    elsif data.text.include? "#{bot_prefix(data)}help"
      dm_info = @client.web_client.im_open user: data.user
      @help_options['dm_user'] ? dm_info['channel']['id'] : data.channel
    else
      data.channel
    end
  end

  def self.bot_prefix(data)
    # Clean up listners and don't require @bot if in a DM
    # Spaces are included here and not in case statement for DM help (i.e.; "help" vs "@bot help")
    data.channel[0] == 'D' ? "(^#{@bot_name} |^@#{@bot_name} |^\<@#{@client.self.id}\> )" : "(^#{@bot_name} |^@#{@bot_name} |^\<@#{@client.self.id}\> |^)"
  end

end
