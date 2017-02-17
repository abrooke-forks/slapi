# frozen_string_literal: true
require 'sinatra'
require 'sinatra/base'
require 'sinatra/config_file'
require 'logger'
require 'json'
require 'yaml'
require 'docker'
require 'redis'
require 'httparty'
require 'slack-ruby-client'

# Routes
require_relative 'routes/plugin'
require_relative 'routes/chat'
require_relative 'routes/brain'

# Initial Bot Config
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

  # TODO: Log to files?
  @logger = Logger.new(STDOUT)
  @logger.level = settings.logger_level

  # Logging outside of requests is not available in Sinatra unless you do something like this:
  # http://stackoverflow.com/questions/14463512/how-do-i-access-sinatras-logger-outside-the-request-scope

  # set :environment, :production

  debug_logger("current environment is set to: #{settings.environment}")

  @help_options = settings.help || {}
  @admin_options = settings.admin || {}

  # Setup Realtime Client
  Slack.configure do |config|
    config.token = settings.adapter['token']
    raise 'Missing Slack Token configuration!' unless config.token
  end

  @client = Slack::RealTime::Client.new
  @bot_name = settings.bot['name'] || @client.self.name

  # Load Brain
  # Utilizes helper from brain/brain
  @brain = Brain.new

  # Load Plugins
  # Utilizes Library from plugins/plugins
  @plugins = Plugins.new

  # Run Slapi Bot/Slack Client
  # Utilizes Library from client/base
  run
end
