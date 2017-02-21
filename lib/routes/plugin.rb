# frozen_string_literal: true

module Sinatra
  module SlapiRoutes
    # Sinatra Extension for Plugin Access
    # Its main functions are to:
    #  1. Allow Reloading of Plugins via API
    module Plugin
      def self.registered(slapi)
        slapi.post '/reload' do
          slapi.reload_plugins
        end
      end
    end
  end
end
