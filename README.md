### Random exercises of using Microsoft CryptoAPI from JRuby (using The Pheox JCAPI)

### Crypting ###

* aes256 file crypting

Using:

```
jruby aes256.rb IN_FILE OUT_FILE PASSWORD crypt|decrypt
```

* hamc

Using:

```
jruby hmac.rb TEXT PASSWORD HMAC_FILE sign|verify
```

* signature

Using:

```
jruby signature_rsa.rb TEXT PUBLIC_KEY_FILE SIGNATURE_FILE sign|verify
```

### Steganography ###

* LSB (wav file):

Using:

```
ruby lsb_writer.rb PHRASE IN_WAV_FILE OUT_WAV_FILE
```

```
ruby lsb_reader.rb PHRASE_LENGTH WAV_FILE
```
