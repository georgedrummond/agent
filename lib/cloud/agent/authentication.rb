module Cloud::Agent::Authentication

  def authenticated_request(url, opts={})
    opts.merge!(
      :accept => 'json', 
      :auth_token => ENV['AUTH_TOKEN']
    )
    RestClient.get url, opts
  end
end