module Cloud::Agent::Authentication

  def authenticated_request(method, path, opts={})
    opts.merge!(
      :accept => 'json', 
      :auth_token => ENV['AUTH_TOKEN']
    )
    RestClient::Resource.new(Cloud::Agent.endpoint)[path].send(method.to_sym, opts)
  end
end