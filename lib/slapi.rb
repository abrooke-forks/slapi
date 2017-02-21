# frozen_string_literal: true
require 'sinatra'
require 'sinatra/base'
require 'sinatra/config_file'
require 'logger'
require 'json'
require 'yaml'
require 'docker'
require 'httparty'
require 'slack-ruby-client'

# Routes
require_relative 'routes/plugin'
require_relative 'routes/chat'
require_relative 'routes/brain'

# Slapi Class - Primary Class
# Its main functions are to:
#  1. Set Sinatra Environment/Config
#     - configs loaded from ./config folder
#     - bot config has bot.local.yml then bot.yml preference
#  2. Set Slack Client Configuration
#     - Token is read in bot.local.yml/bot.yml
#  3. Creates Brain Instance
#     - lib/brain/redis.rb
#  4. Create Plugins Instance
#     - lib/plugins/plugins.rb
#  5. Starts Bot
#     - lib/slapi/client/base.rb
class Slapi < Sinatra::Base

  # Load Extended Class items
  require_relative 'slapi/init'

  set :root, File.dirname(__FILE__)
  register Sinatra::ConfigFile

  config_file '../config/environments.yml'

  if File.file?('config/bot.local.yml')
    config_file '../config/bot.local.yml'
  elsif File.file?('config/bot.yml')
    config_file '../config/bot.yml'
  else
    raise 'No bot config found'
  end

  configure :production, :development, :test do
    enable :logging
  end

  register Sinatra::SlapiRoutes::Plugin
  register Sinatra::SlapiRoutes::Chat
  register Sinatra::SlapiRoutes::Brain

  @logger = Logger.new(STDOUT)
  @logger.level = settings.logger_level

  # Logging outside of requests is not available in Sinatra unless you do something like this:
  # http://stackoverflow.com/questions/14463512/how-do-i-access-sinatras-logger-outside-the-request-scope

  # set :environment, :production

  @logger.debug("Slapi: Current environment is set to: #{settings.environment}")

  @help_options = settings.help || {}
  @admin_options = settings.admin || {}
  @bot_options = settings.bot || {}

  # Setup Realtime Client
  Slack.configure do |config|
    config.token = settings.adapter['token']
    raise 'Missing Slack Token configuration!' unless config.token
  end

  @client = Slack::RealTime::Client.new
  @bot_name = settings.bot['name'] || @client.self.name

  # Load Brain
  # Utilizes helper from brain/brain
  @brain = Brain.new(settings)

  # Load Plugins
  # Utilizes Library from plugins/plugins
  @plugins = Plugins.new(settings)

  # Run Slapi Bot/Slack Client
  # Utilizes Library from client/base
  run
end
