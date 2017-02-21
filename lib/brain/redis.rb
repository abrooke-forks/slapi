# frozen_string_literal: true
require 'socket'
require 'logger'
require 'json'
require 'yaml'
require 'docker'
require 'redis'

# Brain Class
# Its main functions are to:
#  1. Create Redis Container
#     - Local Docker Install or DIND depending on Setup
#     - Validates if a previous container is running and replaces it
#     - Mounts Path to DIND Host or Localhost for Redis AOF file (Data Persistance)
#  2. Create Redis Client Access
#     - URL For Redis determined by IP Comparison (Checking for Compose Environment)
#  3. Enables Access to Brain
#     - Query brain for specific key (i.e. Plugin User)
#     - Query brain for specific hash (i.e. Plugin)
#     - Delete Key from Brain (i.e. Plugin User)
#     - Save Key/Value to Brain (i.e. Plugin User Bob )
class Brain
  def initialize(settings)
    @logger = Logger.new(STDOUT)
    @logger.level = settings.logger_level
  end

  def brain
    brain_check('slapi_brain')
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
    set_url
    @redis = Redis.new(url: @brain_url)
  end

  def brain_check(name)
    container = Docker::Container.get(name)
    container&.delete(force: true) if container
  rescue StandardError => _error
    false
  end

  def query_key(hash_name, key)
    query = @redis.hmget(hash_name, key)
    @logger.debug("Key retrieved for #{hash_name}")
    query
  end

  def query_hash(hash_name)
    @redis.hkeys(hash_name)
    @logger.debug("Hash retrieved for #{hash_name}")
  end

  def delete(hash_name, key)
    @redis.hdel(hash_name, key)
    @logger.debug("Data deleted for #{hash_name}")
  end

  def save(hash_name, key, value)
    @redis.hmset(hash_name, key, value)
    @logger.debug("Data saved for #{hash_name}")
  end

  def set_url
    # Pull local IP and Brain Contianer IP
    ip = Socket.ip_address_list.detect(&:ipv4_private?).ip_address
    container_ip = @container.info['NetworkSettings']['IPAddress']

    # Determine if running via DIND/Compose Config or if running local
    compose_bot = false unless ip.rpartition('.')[0] == container_ip.rpartition('.')[0]
    # If Compose, set docker network ip. If, local use localhost
    @brain_url = compose_bot ? "redis://#{ip}:6379" : 'redis://127.0.0.1:6379'
  end
end
