shared_context :test_data do
  let(:app) { ->(env) { [200, env, "app"] } }
  
  let(:secret) { "SomeSecret" }
  
  let :middleware do
    Rack::JWT.secret = secret
    Rack::JWT.new app
  end
  
  let :prefixed_middleware do
    Rack::JWT.secret = secret
    Rack::JWT.new app, restrict_urls: [/^\/api/]
  end
  
  let :excluded_middleware do
    Rack::JWT.secret = secret
    Rack::JWT.new app, exclude_urls: [/^\/public/]
  end
  
  let :token do
    data = { "user_id" => 1, "full_name" => "John Doe" }
    JWT.encode data, secret
  end
  
  let :invalid_token do
    "SomeRandomDataWhichIsInvalid"
  end
  
  
end