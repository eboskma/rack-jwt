require "jwt"
require "rack/jwt/version"
require "rack/jwt/bad_header_format_error"
require "rack/jwt/invalid_token_error"

module Rack
  class JWT
    @@secret = nil
    
    class << self
      
      def secret=(secret)
        @@secret = secret
      end
      
    end
    
    def initialize(app, options = {})
      default_options = {
        algorithm: 'HS256'
      }
      
      @app, @options = app, default_options.merge(options)
    end
    
    def call(env)
      raise Rack::JWT::SecretMissingError("The secret has not been configured") if @@secret.nil?
      
      authorization = env['HTTP_AUTHORIZATION']
      if authorization.nil?
        return [401, { "Content-Type" => "text/plain", "Content-Length" => "0", "WWW-Authenticate" => "None"}, []]
      else
        if header_valid? authorization
          _, token = authorization.split ' '
          env['jwt.payload'] = decode(token)
        else
          raise Rack::JWT::BadHeaderFormatError.new "Format is Authorization: Bearer <token>"
        end
      end
      
      @app.call env
    end
    
    private
    
    def header_valid?(authorization_data)
      authorization_data.start_with? 'Bearer'
    end
    
    def decode(token)
      ::JWT.decode token, @@secret
    end
  end
end
