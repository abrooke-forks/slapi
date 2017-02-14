# frozen_string_literal: true

# External
require 'json'
require 'logger'
require 'yaml'
require 'docker'
require 'httparty'
require 'slack-ruby-client'

# Internal

## Client
require_relative 'client/base'
# require_relative 'client/functions'
# require_relative 'client/plugin'

## Brain
require_relative 'brain/redis'

## Plugins
require_relative 'plugin/plugins'
