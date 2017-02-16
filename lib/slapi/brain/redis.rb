# frozen_string_literal: true

# Slapi Brain
class Slapi

  def self.brain
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

  def self.brain_check(name)
    container = Docker::Container.get(name)
    container&.delete(force: true) if container
  rescue StandardError => _error
    false
  end
end
