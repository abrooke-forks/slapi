# frozen_string_literal: true
# require 'sinatra'
# Handles a POST request for '/reload'
module Sinatra
  module SlapiRoutes
    module Routing
      module Plugin
        def self.registered(slapi)
          slapi.post '/reload' do
            #puts "I am a reload"
            slapi.reload_plugins
          end
        end
      end
    end
  end
end
