class Cloud::Agent::Exception

  def self.notify(e, notes)
    Cloud::Agent.logger.error([e, notes])
  end
end