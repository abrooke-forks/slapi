require_relative '../lib/core/realtime.rb'
require 'spec_helper'


RSpec.describe RealTimeClient, vcr: { cassette_name: 'web/rtm_start' } do

  let(:ws) { double(Slack::RealTime::Concurrency::Mock::WebSocket, on: true) }
  let(:url) { 'wss://ms173.slack-msgs.com/websocket/lqcUiAvrKTP-uuid=' }

  before do
    @token = ENV.delete('SLACK_API_TOKEN')
    Slack::Config.reset
    Slack::RealTime::Config.reset
    Slack::RealTime.configure do |config|
      config.concurrency = Slack::RealTime::Concurrency::Mock
    end
  end
  after do
    ENV['SLACK_API_TOKEN'] = @token if @token
  end

  context 'client' do
    context 'started' do
      let(:client) { Slack::RealTime::Client.new(store_class: Slack::RealTime::Stores::Store) }
      describe '#start!' do
        let(:socket) { double(Slack::RealTime::Socket, connected?: true) }
        before do
          allow(Slack::RealTime::Socket).to receive(:new).with(url, ping: 30, logger: Slack::Logger.default).and_return(socket)
          allow(socket).to receive(:connect!)
          allow(socket).to receive(:start_sync)
          client.start!
        end

        context 'properties provided upon connection' do
          it 'sets url' do
            expect(client.url).to eq url
          end
        end
       
      end
    end
  end

  context "bot name" do
    it "configures and returns successfully" do
      settings = MockSettings.new({:adapter => {'token' => 'abc123'}})
      real_time = RealTimeClient.new(settings)
      expect(real_time.bot_name).to eq("headroom")
    end
  end

  context "update plugin cache" do
    it "configures and returns successfully" do
      settings = MockSettings.new({:adapter => {'token' => 'abc123'}})
      real_time = RealTimeClient.new(settings)
      expect(real_time.update_plugin_cache).to be_a_kind_of(Array)
    end
  end

        # TODO: invalid_auth
        # NEED to work out valid auth or mocking service
        context "run bot" do
          it "configures and returns successfully" do
            settings = MockSettings.new({:adapter => {'token' => ENV['SLACK_API_TOKEN2']}})
            real_time = RealTimeClient.new(settings)
            expect(real_time.run_bot).to be_a_kind_of(Array)
          end
        end 

end
