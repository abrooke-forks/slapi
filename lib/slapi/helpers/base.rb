# frozen_string_literal: true

# Slapi Base Client Helper for Sinatra Extension Access
class Slapi
  def self.chat(data, attachment)
    @client.web_client.chat_postMessage(
      channel: channel(data),
      as_user: true,
      attachments: [attachment]
    )
  end

  def self.channel(data)
    # Set channel to post based on dm_user option
    if data.text.include? "#{bot_prefix(data)}help"
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

  def self.debug_logger(message)
    @logger.debug(message)
  end

  def self.info_logger(message)
    @logger.info(message)
  end

  def self.warn_logger(message)
    @logger.warn(message)
  end

  def self.error_logger(message)
    @logger.error(message)
  end

  def self.fatal_logger(message)
    @logger.fatal(message)
  end

end
