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
        restrict_urls: [],
        exclude_urls: []
      }
      
      @app, @options = app, default_options.merge(options)
    end
    
    def call(env)
      raise Rack::JWT::SecretMissingError("The secret has not been configured") if @@secret.nil?
      
      authorization = env['HTTP_AUTHORIZATION']
      if url_excluded?(env)
        @app.call env
      elsif constraint?(:restrict_urls) && !url_matches?(:restrict_urls, env)
        @app.call env
      elsif authorization.nil?
        unauthorized
      else
        process_request env, authorization
      end
    end
    
    private
    
    def process_request(env, authorization)
      if header_valid? authorization
        _, token = authorization.split ' '
        jwt_payload = env['jwt.payload'] = decode(token)
        @app.call env
      else
        raise Rack::JWT::BadHeaderFormatError.new "Format is Authorization: Bearer <token>"
      end
    end
    
    def unauthorized
      # body = "No Authentication Token provided."
      body = MultiJson.dump({
        status: 401,
        message: "No Authentication Token provided."
      })
      [
        401, 
        { 
          "Content-Type" => "application/json; charset=utf-8", 
          "Content-Length" => "#{body.length}", 
          "WWW-Authenticate" => "None"
        }, 
        [body]
      ]
    end
    
    def url_excluded?(env)
      constraint?(:exclude_urls) && url_matches?(:exclude_urls, env)
    end
    
    def constraint?(key)
      !(@options[key].nil? || @options[key].empty?)
    end
    
    def url_matches?(key, env)
      path = Rack::Request.new(env).fullpath
      patterns = @options[key]
      patterns = [patterns] unless patterns.is_a? Array
      
      !patterns.select { |url_regex| path.match(url_regex) }.empty?
    end
    
    def header_valid?(authorization_data)
      authorization_data.start_with? 'Bearer'
    end
    
    def decode(token)
      ::JWT.decode token, @@secret
    end
  end
end
