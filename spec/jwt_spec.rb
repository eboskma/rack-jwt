require 'spec_helper'

describe Rack::JWT do
  let(:app) { ->(env) { [200, env, "app"] } }
  
  let(:secret) { "SomeSecret" }
  
  let :middleware do
    Rack::JWT.secret = secret
    Rack::JWT.new app
  end
  
  let :token do
    data = { "user_id" => 1, "full_name" => "John Doe" }
    JWT.encode data, secret
  end
  
  let :invalid_token do
    "SomeRandomDataWhichIsInvalid"
  end
  
  it "adds the JWT payload to the environment with a valid token" do
    code, env = middleware.call Rack::MockRequest.env_for 'http://example.com', { "HTTP_AUTHORIZATION" => "Bearer: #{token}" }
    
    expect(env['jwt.payload']).to_not be_nil
    
    payload = env['jwt.payload']
    expect(payload).to have_key("user_id")
  end
  
  it "returns a 401 status code without a token" do
    code, env = middleware.call Rack::MockRequest.env_for 'http://example.com'
    
    expect(code).to eq(401)
  end
  
  it "raises a JWT::DecodeError with an invalid token" do
    expect { middleware.call Rack::MockRequest.env_for 'http://example.com', { "HTTP_AUTHORIZATION" => "Bearer: #{invalid_token}" } }.to raise_error(JWT::DecodeError)
  end
  
  it "raises a Rack::JWT::BadHeaderFormatError when the Authorization header is invalid" do
    expect { middleware.call Rack::MockRequest.env_for 'http://example.com', { "HTTP_AUTHORIZATION" => "Foo Bar" } }.to raise_error(Rack::JWT::BadHeaderFormatError)
  end
end