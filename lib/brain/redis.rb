# frozen_string_literal: true

# Slapi Brain
class Brain

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
    debug_logger("Key retrieved for #{hash_name}")
    query
  end

  def query_hash(hash_name)
    @redis.hkeys(hash_name)
    debug_logger("Hash retrieved for #{hash_name}")
  end

  def delete(hash_name, key)
    @redis.hdel(hash_name, key)
    debug_logger("Data deleted for #{hash_name}")
  end

  def save(hash_name, key, value)
    @redis.hmset(hash_name, key, value)
    debug_logger("Data saved for #{hash_name}")
  end

  def set_url
    @brain_url = File.readlines('/etc/hosts').grep(/brain/).any? ? 'redis://brain:6379' : 'redis://127.0.0.1:6379'
  end

end
