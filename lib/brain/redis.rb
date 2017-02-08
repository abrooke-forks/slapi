# frozen_string_literal: true

require 'redis'

# Extend Slapi Class
# Load Brain and Create Container in DIND Host
class Brain < Slapi
  def initialize
    super()
    @container = nil
    @container_info = {}
    @brain_url = nil
    @brain_name = 'slapi_brain'

    load if settings.bot['brain']
  end

  def load
    # TODO: Function check for existing brain or delete existing?
    check_brain = brain_check(@brain_name)
    if check_brain
      @image = Docker::Image.create(fromImage: 'redis:3-alpine')
      @container_hash = {
        'name' => 'slapi_brain',
        'Image' => 'redis:3-alpine',
        'Cmd' => ['redis-server', '--appendonly', 'yes'],
        'ExposedPorts' => { '6379/tcp' => {} },
        'HostConfig' => {
          'PortBindings' => {
            '6379/tcp' => [{ 'HostPort' => '6379', 'HostIp' => '0.0.0.0' }]
          },
          'Binds' => ["#{Dir.pwd}/brain/:/data"]
        }
      }
      @container_hash['Entrypoint'] = @image.info['Config']['Entrypoint']
      @container_hash['WorkingDir'] = @image.info['Config']['WorkingDir']
      @container_hash['Labels'] = @image.info['Config']['Labels']
      @container = Docker::Container.create(@container_hash)
      @container.tap(&:start)
    end
    @redis = Redis.new
    puts @redis
  end

  def brain_check(name)
    @container = Docker::Container.get(name)
  rescue StandardError => _error
    return false
  end

  def query(plugin, key)
    if @brain_url
      @redis.hmget(plugin, key)
    else
      puts 'Brain not configured'
    end
  end

  def save(plugin, key, value)
    if @brain_url
      @redis.hmset(plugin, key, value)
    else
      puts 'Brain not configured'
    end
  end
end
