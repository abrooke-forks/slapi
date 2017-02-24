# frozen_string_literal: true
require 'sinatra'

module Sinatra
  module SlapiRoutes
    # Sinatra Extension for Chat Access
    # Its main functions are to:
    #  1. Route Messages to Client
    #     - Standard Text Chat
    #     - Emote Chat
    #     - Attachment Chat
    module Chat
      def self.registered(slapi)
        # Handles a POST request for '/v1/attachment'
        # @see https://api.slack.com/docs/message-attachments Slack Documentation
        # @see https://api.slack.com/docs/messages/builder
        #
        # @param [Hash] params the parameters sent on the request
        # @option params [String] :channel The Slack Channel ID (Name may work in some instances)
        # @option params [String] :text The text that will be posted in the channel
        # @option params [String] :as_user ('true')
        # @option params [Hash] attachments the information about the attachments
        # @option attachments [String] :fallback
        # @option attachments [String] :pretext
        # @option attachments [String] :title
        # @option attachments [String] :title_link
        # @option attachments [String] :text
        # @option attachments [String] :color ('#229954') defaults to GREEN(constant) if not specified
        # @return [String] the resulting webpage
        slapi.post '/v1/attachment' do
          raise 'missing channel' unless params[:channel]
          raise 'missing text' unless params[:text]
          raise 'missing fallback' unless params[:attachments][:fallback]
          raise 'missing title' unless params[:attachments][:title]
          channel = params[:channel]
          slapi.chat_attachment(
            nil,
            channel,
            pretext: params[:attachments][:pretext],
            fallback: params[:attachments][:fallback],
            title: params[:attachments][:title],
            title_link: params[:attachments][:title_link],
            text: params[:attachments][:text],
            color: params[:attachments][:color] ? params[:attachments][:color] : GREEN
          )
          status 200
          { 'message' => 'yes, it worked' }.to_json
        end

        # Handles a POST request for '/v1/speak'
        # @see https://api.slack.com/docs/message-formatting Slack Documentation
        # @see https://api.slack.com/docs/messages/builder
        #
        # @param [Hash] params the parameters sent on the request
        # @option params [String] :channel The Slack Channel ID (Name may work in some instances)
        # @option params [String] :text The text that will be posted in the channel, supports formatting
        # @return [String] the resulting webpage
        slapi.post '/v1/emote' do
          raise 'missing channel' unless params[:channel]
          raise 'missing text' unless params[:text]

          channel = params[:channel]
          text = params[:attachments][:text]
          slapi.chat_me(
            nil,
            channel,
            text
          )
          status 200
          { 'message' => 'yes, it worked' }.to_json
        end

        # Handles a POST request for '/v1/speak'
        # @see https://api.slack.com/docs/message-formatting Slack Documentation
        # @see https://api.slack.com/docs/messages/builder
        #
        # @param [Hash] params the parameters sent on the request
        # @option params [String] :channel The Slack Channel ID (Name may work in some instances)
        # @option params [String] :text The text that will be posted in the channel, supports formatting
        # @option params [String] :as_user ('true')
        # @return [String] the resulting webpage
        slapi.post '/v1/speak' do
          raise 'missing channel' unless params[:channel]
          raise 'missing text' unless params[:text]

          channel = params[:channel]
          text = params[:attachments][:text]
          slapi.chat(
            nil,
            channel,
            text
          )
          status 200
          { 'message' => 'yes, it worked' }.to_json
        end
      end
    end
  end
end
