# frozen_string_literal: true
require 'sinatra'

# Extend Slapi Module
module Sinatra
  module SlapiRoutes
    # Sinatra Extension that adds routes to accces Slapi Brain
    module Brain
      def self.registered(slapi)
        slapi.post '/v1/save' do
          raise 'missing plugin name' unless params[:plugin]
          raise 'missing key' unless params[:key]
          raise 'missing value' unless params[:value]

          logger.debug('Saving data to brain')
          # Saves into brain as Plugin: key, value
          slapi.brain_save(params[:plugin], params[:key], params[:value])
          logger.debug('Data saved to brain')
        end

        slapi.get '/v1/query' do
          raise 'missing plugin name' unless env['HTTP_PLUGIN']
          raise 'missing key' unless env['HTTP_KEY']

          logger.debug('Getting data from brain')
          # Searches brain via Plugin: key
          data_return = slapi.brain_query(env['HTTP_PLUGIN'], env['HTTP_KEY'])
          logger.debug('Data retrieved from brain')
          return data_return
        end
      end
    end
  end
end
