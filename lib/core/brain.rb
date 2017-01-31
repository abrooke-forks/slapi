# frozen_string_literal: true
require 'yaml'
require 'docker'
# require 'logger'
require 'redis'

# Load Brain and Create Container in DIND Host
class Brain
  def initialize(settings)
    @container = nil
    @container_info = {}
    @container_hash = { 'name' => 'slapi_brain' }
    @brain_url = nil

    load if settings.bot[:brain]
    puts settings.bot[:brain]
    # logger.debug('Brain Loaded: If you do not want to use the bot brain please set to false in config') if settings.bot[:brain]
    # logger.debug('Brain Not Loaded: If you want to use the bot brain please set to true in config') unless settings.bot[:brain]
  end

  def load
    @image = Docker::Image.create(fromImage: 'redis:3-alpine')
    @container_hash['Entrypoint'] = @image.info['Config']['Entrypoint']
    @container_hash['WorkingDir'] = @image.info['Config']['WorkingDir']
    @container_hash['Labels'] = @image.info['Config']['Labels']
    @container_hash = {
      'Image' => 'redis:3-alpine',
      'Cmd' => 'redis-server --appendonly yes',
      'ExposedPorts' => { '6379/tcp' => {} },
      'HostConfig' => {
        '6379/tcp' => [{ 'HostPort' => '6379' }],
        'Binds' => ["#{Dir.pwd}/brain/:/data"]
      }
    }
    @container = Docker::Container.create(@container_hash)
    @container.start
    puts @container
    @redis = Redis.new(host: 'docker', port: '6379')
    puts @redis
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
