# frozen_string_literal: true
require 'sinatra'
require 'sinatra/base'
require 'sinatra/config_file'
require 'json'
require 'logger'
require 'yaml'
require 'docker'
require 'slack-ruby-client'

# SLAPI Init
class Slapi < Sinatra::Application
  register Sinatra::ConfigFile
  # enable :sessions
  config_file 'config/environments.yml'

  # Enable local configs to be ignored
  # Adds Exception for missing config
  botfile = File.file?('config/bot.yml')
  botlocalfile = File.file?('config/bot.yml')

  config_file 'config/bot.yml' if botfile

  config_file 'config/bot.local.yml' if botlocalfile

  raise 'No bot config found' unless botfile | botlocalfile

  configure :production, :development, :test do
    enable :logging
  end

  # Environment should be set outside of application be either:
  # RACK_ENV=production
  # sending in the -E flag as in: unicorn -c path/to/unicorn.rb -E development -D
  set :environment, :production

  # Logging outside of requests is not available in Sinatra unless you do something like this:
  # http://stackoverflow.com/questions/14463512/how-do-i-access-sinatras-logger-outside-the-request-scope
  # TODO: set up Rack Logger
  # logger.debug "current environment is set to: #{settings.environment}"
  # TODO: also set up log to write to log fil
  puts "Current environment is set to: #{settings.environment}"

  Slack.configure do |config|
    config.token = settings.adapter['token']
    raise 'Missing Slack Token configuration!' unless config.token
  end

  @bot_name = settings.bot['name']
  @bot_options = settings.bot || {}
  @help_options = settings.help || {}
  @admin_options = settings.admin || {}

  # Create
  @client = Slack::RealTime::Client.new

  # Load rest of bot
  require_relative 'lib/init'

  # Set botname based on settings or client name
  def bot_name
    @bot_name = @bot_options['name'] || @client.self.name
  end

  # Setup brain connection
  @brain = Brain.new

  # Setup Realtime Listener
  @realtime = ClientBase.new
  @realtime.run_bot
end
