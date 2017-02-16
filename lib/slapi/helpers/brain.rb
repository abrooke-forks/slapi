# frozen_string_literal: true

# Slapi Brain Helper for Sinatra Extension Access
class Slapi
  def self.query_key(hash_name, key)
    query = @redis.hmget(hash_name, key)
    debug_logger("Key retrieved for #{hash_name}")
    query
  end

  def self.query_hash(hash_name)
    @redis.hkeys(hash_name)
    debug_logger("Hash retrieved for #{hash_name}")
  end

  def self.delete(hash_name, key)
    @redis.hdel(hash_name, key)
    debug_logger("Data deleted for #{hash_name}")
  end

  def self.save(hash_name, key, value)
    @redis.hmset(hash_name, key, value)
    debug_logger("Data saved for #{hash_name}")
  end

  def self.set_url
    @brain_url = File.readlines('/etc/hosts').grep(/brain/).any? ? 'redis://brain:6379' : 'redis://127.0.0.1:6379'
  end
end
