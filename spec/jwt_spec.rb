require 'spec_helper'

describe Rack::JWT do
  include_context :test_data

  it "adds the JWT payload to the environment with a valid token" do
    code, env = middleware.call Rack::MockRequest.env_for 'http://example.com', { "HTTP_AUTHORIZATION" => "Bearer: #{token}" }
    
    expect(code).to eq(200)
    expect(env['jwt.payload']).to_not be_nil
    
    payload = env['jwt.payload']
    expect(payload).to have_key("user_id")
  end
  
  it "returns a 401 status code without a token" do
    code, env, body = middleware.call Rack::MockRequest.env_for 'http://example.com'
    
    expect(code).to eq(401)
    expect(body).to include("No Authentication Token provided.")
  end
  
  it "raises a JWT::DecodeError with an invalid token" do
    expect { middleware.call Rack::MockRequest.env_for 'http://example.com', { "HTTP_AUTHORIZATION" => "Bearer: #{invalid_token}" } }.to raise_error(JWT::DecodeError)
  end
  
  it "raises a Rack::JWT::BadHeaderFormatError when the Authorization header is invalid" do
    expect { middleware.call Rack::MockRequest.env_for 'http://example.com', { "HTTP_AUTHORIZATION" => "Foo Bar" } }.to raise_error(Rack::JWT::BadHeaderFormatError)
  end
  
  context "excluded URL" do
  
    it "allows a request without a token" do
      code, env = excluded_middleware.call Rack::MockRequest.env_for 'http://example.com/public/foo'
    
      expect(code).to eq(200)
      expect(env['jwt.payload']).to be_nil
    end
  
    it "does not set the JWT payload" do
      code, env = excluded_middleware.call Rack::MockRequest.env_for 'http://example.com/public/foo', { "HTTP_AUTHORIZATION" => "Bearer: #{token}" }
    
      expect(code).to eq(200)
      expect(env['jwt.payload']).to be_nil
    end
    
    it "requires a token on other URLs" do
      code, env, body = excluded_middleware.call Rack::MockRequest.env_for 'http://example.com/foo'
    
      expect(code).to eq(401)
      expect(body).to include("No Authentication Token provided.")
    end
    
  end
  
  context "URL prefix" do 
    
    it "returns success outside the prefix" do
      code, env = prefixed_middleware.call Rack::MockRequest.env_for 'http://example.com/foo'
    
      expect(code).to eq(200)
      expect(env['jwt.payload']).to be_nil
    end
    
    it "returns a 401 status without a token" do
      code, env, body = prefixed_middleware.call Rack::MockRequest.env_for 'http://example.com/api/foo'
    
      expect(code).to eq(401)
      expect(body).to include("No Authentication Token provided.")
    end
    
    it "returns success inside the prefix" do
      code, env = middleware.call Rack::MockRequest.env_for 'http://example.com/api/foo', { "HTTP_AUTHORIZATION" => "Bearer: #{token}" }
    
      expect(code).to eq(200)
      expect(env['jwt.payload']).to_not be_nil
    
      payload = env['jwt.payload']
      expect(payload).to have_key("user_id")
      
    end
    
  end
end