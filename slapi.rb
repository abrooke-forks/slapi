# frozen_string_literal: true
require 'sinatra'
require 'sinatra/base'
require 'sinatra/config_file'
require 'logger'
require_relative 'lib/routes/plugin'

## Routes
# require_relative 'lib/routes/plugin'
# require_relative 'lib/routes/chat'
# require_relative 'lib/routes/brain'

# Slapi Bot Module
# module Slapi
# Initial Bot Config
class Bot < Sinatra::Base
  def initialize
    super
  end

  require_relative 'lib/init'

  set :root, File.dirname(__FILE__)
  register Sinatra::ConfigFile

  config_file 'config/environments.yml'

  if File.file?('config/bot.local.yml')
    config_file 'config/bot.local.yml'
  elsif File.file?('config/bot.yml')
    config_file 'config/bot.yml'
  else
    raise 'No bot config found'
  end

  configure :production, :development, :test do
    enable :logging
  end

  # TODO: Log to files?
  @logger = Logger.new(STDOUT)
  @logger.level = settings.logger_level

  # Logging outside of requests is not available in Sinatra unless you do something like this:
  # http://stackoverflow.com/questions/14463512/how-do-i-access-sinatras-logger-outside-the-request-scope

  # set :environment, :production

  @logger.debug "current environment is set to: #{settings.environment}"

  # Setup brain connection
  @brain = Brain.new(settings)
  @plugins = Plugins.new(settings)

  def self.reload_plugins
    @plugins.load
  end

  @help_options = settings.help || {}
  @admin_options = settings.admin || {}

  # Setup Realtime Client
  Slack.configure do |config|
    config.token = settings.adapter['token']
    raise 'Missing Slack Token configuration!' unless config.token
  end

  @client = Slack::RealTime::Client.new
  @bot_name = settings.bot['name'] || @client.self.name

  register Sinatra::SlapiRoutes::Routing::Plugin
  # register Sinatra::SlapiRoutes::Routing::Chat
  # register Sinatra::SlapiRoutes::Routing::Brain
  run
  # @bot.run
end
# end
