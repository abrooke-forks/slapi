# frozen_string_literal: true

# Extend Slapi class
# Basic Client setup
class ClientBase < Slapi
  def initialize
    super()
  end

  def run_bot
    # Ensure there is a bot name to be referenced
    bot_name
    @client.on :hello do
      puts "Successfully connected, welcome '#{@client.self.name}' to the '#{@client.team.name}' team at https://#{@client.team.domain}.slack.com."
    end

    @client.on :message do |data|
      # Clean up listners and don't require @bot if in a DM
      @bot_prefix = "(^#{@bot_name} |^@#{@bot_name} |^\<@#{@client.self.id}\> )" unless data.channel[0] == 'D'
      @bot_prefix = "(^#{@bot_name} |^@#{@bot_name} |^\<@#{@client.self.id}\> |^)" if data.channel[0] == 'D'

      case data.text
      when data.user == @client.self.id then
        null
      when /#{@bot_prefix}ping/ then
        ClientFunctions.ping
      when /#{@bot_prefix}help/ then
        ClientFunctions.help(data)
      when /#{@bot_prefix}reload/ then
        ClientFunctions.reload
      when /#{@bot_prefix}/ then
        ClientPlugin.run(data)
      end
    end
  end
end
