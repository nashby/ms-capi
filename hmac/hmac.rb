require 'java'
require_relative '../JCAPI.jar'

module Java
  import 'java.security'
  import 'java.security.MessageDigest'
  import 'com.pheox.jcapi'
  
  Security.add_provider JCAPIProvider.new

  class HMAC
    BLOCK_SIZE = 64

    def initialize(message, password)
      @message = message
      @password = password
    end

    def hmac
      if @password.length > BLOCK_SIZE
        @password = String.from_java_bytes(hash(@password))
      end

      @password += "\0" * (BLOCK_SIZE - @password.length)
      akey = @password.unpack("C*")

      key_xor_ipad = ("\x36" * BLOCK_SIZE).unpack("C*")
      key_xor_opad = ("\x5C" * BLOCK_SIZE).unpack("C*")
      
      (akey.size - 1).times do |i|
        key_xor_ipad[i] ^= akey[i]      
        key_xor_opad[i] ^= akey[i]     
      end

      key_xor_ipad = key_xor_ipad.pack("C*")
      key_xor_opad = key_xor_opad.pack("C*")

      String.from_java_bytes(hash(key_xor_opad + String.from_java_bytes(hash(key_xor_ipad + @message))))
    end

    def hash(data)
      @hash ||= begin
        md = MessageDigest.get_instance("MD5", "JCAPI")
        md.digest(data.to_java_bytes)
      end
    end
  end
end

# I thought I'd never use it...
if __FILE__ == $0
  hmac = Java::HMAC.new(ARGV[0], ARGV[1])
  p hmac.hmac
end
