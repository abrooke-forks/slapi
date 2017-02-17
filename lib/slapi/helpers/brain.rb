# frozen_string_literal: true

# Slapi Brain Helper for Sinatra Extension Access
class Slapi
  def self.query_key(hash_name, key)
    query = @brain.query_key(hash_name, key)
    debug_logger("Key retrieved for #{hash_name}")
    query
  end

  def self.query_hash(hash_name)
    query = @brain.query_hash(hash_name)
    debug_logger("Hash retrieved for #{hash_name}")
    query
  end

  def self.delete(hash_name, key)
    @brain.delete(hash_name, key)
    debug_logger("Data deleted for #{hash_name}")
  end

  def self.save(hash_name, key, value)
    @brain.save(hash_name, key, value)
    debug_logger("Data saved for #{hash_name}")
  end
end
