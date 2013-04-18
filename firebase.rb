require 'firebase_token_generator'
require 'httparty'

module Firebase
  def self.create_token(auth_data, options={})
    secret = ENV['FIREBASE_SECRET'] || raise("FIREBASE_SECRET is not defined")
    generator = Firebase::FirebaseTokenGenerator.new(secret)
    return generator.create_token(auth_data, options)
  end

  def self.set(path, data)
    token = self.create_token({}, :admin => true)
    response = HTTParty.put('https://backbinder.firebaseio.com/' + path + '.json', {
      :query => {:auth => token},
      :body => MultiJson.encode(data)
      })
    raise response.body unless response.success?
  end
end

if __FILE__ == $0
  require 'dotenv'
  Dotenv.load
  Firebase.set("users/1/folders", %w[a b c d])
end
