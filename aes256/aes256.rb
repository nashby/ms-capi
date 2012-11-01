require 'java'
require_relative '../JCAPI.jar'

module Java
  import 'java.security'
  import 'java.security.SecureRandom'
  import 'javax.crypto.KeyGenerator'
  import 'javax.crypto.SecretKeyFactory'
  import 'javax.crypto.spec.SecretKeySpec'
  import 'javax.crypto.spec.PBEKeySpec'
  import 'javax.crypto.Cipher'
  import 'com.pheox.jcapi'
  
  Security.add_provider JCAPIProvider.new

  class Aes256
    def initialize(file_in, file_out, password)
      @file_in = file_in
      @file_out = file_out
      @password = password
    end

    def crypt
      content = File.read(@file_in)
      cipher.init(Cipher::ENCRYPT_MODE, key)
      File.open(@file_out, 'w+') { |file| file.write(String.from_java_bytes(cipher.do_final(content.to_java_bytes))) }
    end

    def decrypt
      content = File.read(@file_in)
      cipher.init(Cipher::DECRYPT_MODE, key)
      File.open(@file_out, 'w+') { |file| file.write(String.from_java_bytes(cipher.do_final(content.to_java_bytes))) }
    end 

    def key
      @key ||= begin
        factory = SecretKeyFactory.get_instance("PBKDF2WithHmacSHA1")
        spec = PBEKeySpec.new(@password.to_java(:string).to_char_array, 'salt'.to_java_bytes, 65536, 256)
        tmp = factory.generate_secret(spec)
        
        SecretKeySpec.new(tmp.get_encoded, "AES")
      end
    end

    def cipher
      @cipher ||= begin
        Cipher.get_instance("AES/CBC/PKCS5Padding", "JCAPI")
      end
    end

    def params
      p key.getEncoded
      @params ||= cipher.get_parameters
    end
  end
end

# I thought I'd never use it...
if __FILE__ == $0
  aes = Java::Aes256.new(ARGV[0], ARGV[1], ARGV[2])

  if ARGV[3] == 'crypt'  
    aes.crypt  
  elsif ARGV[3] == 'decrypt'
    aes.decrypt
  end
end
