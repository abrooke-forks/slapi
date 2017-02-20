# frozen_string_literal: true
require 'sinatra'

module Sinatra
  module SlapiRoutes
    # Brain Routes
    # Its main functions are to:
    #  1. Allow quering of Redis Database
    #     - Query by Hash (aka Redis Key)
    #     - Query by Key (aka Redis Field)
    #  2. Enables saving data to Brain
    #  3. Enables delete data from Brain
    module Brain
      def self.registered(slapi)
        slapi.post '/v1/save' do
          raise 'missing plugin name' unless params[:plugin]
          raise 'missing key' unless params[:key]
          raise 'missing value' unless params[:value]

          # Saves into brain as Plugin: key, value
          slapi.save(params[:plugin], params[:key], params[:value])
          status 200
        end

        slapi.post '/v1/delete' do
          raise 'missing plugin name' unless params[:plugin]
          raise 'missing key' unless params[:key]

          # Saves into brain as Plugin: key, value
          slapi.delete(params[:plugin], params[:key])
          status 200
        end

        slapi.get '/v1/key_query' do
          raise 'missing plugin name' unless env['HTTP_PLUGIN']
          raise 'missing key' unless env['HTTP_KEY']

          # Searches brain via Plugin: key
          data_return = slapi.query_key(env['HTTP_PLUGIN'], env['HTTP_KEY'])
          status 200
          return data_return
        end

        slapi.get '/v1/hash_query' do
          raise 'missing plugin name' unless env['HTTP_PLUGIN']

          # Searches brain via Plugin: key
          data_return = slapi.query_hash(env['HTTP_PLUGIN'])
          status 200
          return data_return
        end
      end
    end
  end
end
