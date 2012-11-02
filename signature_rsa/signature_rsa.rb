require 'java'
require_relative '../JCAPI.jar'

module Java
  import 'java.security'
  import 'java.security.MessageDigest'
  import 'java.security.KeyPairGenerator'
  import 'java.security.KeyFactory'
  import 'java.security.spec.X509EncodedKeySpec'
  import 'com.pheox.jcapi'
  import 'com.pheox.jcapi.JCAPICSPAlgorithm'
  import 'com.pheox.jcapi.JCAPIProperties'
  import 'com.pheox.jcapi.JCAPICryptoFactory'
  
  Security.add_provider JCAPIProvider.new

  class SignatureRSA

    def initialize(message, public_key_file, signature_file)
      @message = message
      @public_key_file = public_key_file
      @signature_file = signature_file
      @signature = nil
    end

    def sign
      signature_instance.init_sign(private_key)
      signature_instance.update(@message.to_java_bytes)
      @signature = signature_instance.sign
      write_signature
      write_public_key
    end

    def verify
      load_signature
      load_public_key
      signature_instance.init_verify(public_key)
      signature_instance.update(@message.to_java_bytes)
      signature_instance.verify(@signature)
    end

    def public_key
      @public_key ||= key_pair.get_public
    end

    def private_key
      @private_key ||= key_pair.get_private
    end

    def write_signature
      File.open(@signature_file, 'w+') { |file| file.write(String.from_java_bytes(@signature)) }
    end

    def load_signature
      @signature = File.read(@signature_file).to_java_bytes
    end

    def write_public_key
      File.open(@public_key_file, 'w+') { |file| file.write(String.from_java_bytes(public_key.get_encoded)) }
    end

    def load_public_key
      raw = File.read(@public_key_file)
      @public_key = KeyFactory.get_instance("RSA").generate_public(X509EncodedKeySpec.new(raw.to_java_bytes))
    end

    private

    def csp_name
      @csp_name ||= JCAPIProperties.get_instance.get_rsacsp
    end

    def provider_type
      @provider_type ||= JCAPIProperties.get_instance.get_cached_provider_type_by_csp(csp_name)
    end

    def key_len
      512
    end

    def key_alg_id
      JCAPICSPAlgorithm::CALG_RSA_SIGN
    end

    def key_alg_name
      "RSA"
    end

    def key_alg
      @key_alg ||= JCAPICSPAlgorithm.new(csp_name, provider_type, key_alg_id, key_alg_name)
    end

    def hash_alg_id
      JCAPICSPAlgorithm::CALG_SHA1
    end

    def hash_alg_name
      "SHA-1"
    end

    def hash_alg
      @hash_alg ||= JCAPICSPAlgorithm.new(csp_name, provider_type, hash_alg_id, hash_alg_name)
    end

    def signature_instance
      @signature_instance ||= JCAPICryptoFactory.create_signature_instance(hash_alg, key_alg)
    end

    def key_pair_generator
      @key_pair_generator ||= begin 
        key = KeyPairGenerator.get_instance("RSA")
        key.java_send(:initialize, [::Java::int], key_len)

        key
      end
    end

    def key_pair
      @key_pair ||= key_pair_generator.generate_key_pair
    end
  end
end

# I thought I'd never use it...
if __FILE__ == $0
  signature_rsa = Java::SignatureRSA.new(ARGV[0], ARGV[1], ARGV[2])

  if ARGV[3] == 'sign' 
    signature_rsa.sign
  elsif ARGV[3] == 'verify'
    if signature_rsa.verify
      puts "Yay, it was successfully verified"
    else
      puts "No. Just no."
    end
  end
end
