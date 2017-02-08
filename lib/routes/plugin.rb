# frozen_string_literal: true

# Handles a POST request for '/reload'
# Forces a reload of the @plugins configurations
class PluginRoute < Slapi
  def initialize
    super()
  end
  post '/reload' do
    # NOTE: this currently does not work for a running system
    # however breakpoints are not working on server startup.
    # so this helps to test/inspect the load.
    # @realtime = RealTimeClient.new settings
    @realtime.update_plugin_cache
  end
end
