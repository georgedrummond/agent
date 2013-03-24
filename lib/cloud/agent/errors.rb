module Cloud::Agent
  class InvalidDeploy < StandardError ; end

  class Error
    include Cloud::Agent::Authentication

    def initialize(notes, e)
      @notes = notes
      @e = e
      Cloud::Agent.logger.error([notes, e])
    end

    def send!
      payload = {}
      payload[:exception]  = @e.name if @e.respond_to?(:name)
      payload[:stacktrace] = @e.backtrace if @e.respond_to?(:backtrace)
      
      authenticated_request :post, '/exceptions', payload
    end

    def self.notify(notes, e)
      report = Cloud::Agent::Error.new(notes, e)
      report.send!
    end
  end
end