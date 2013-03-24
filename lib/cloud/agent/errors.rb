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
      payload = {
        :exception => @e.name,
        :stacktrace => @e.backtrace
      }
      authenticated_request :post, '/exceptions', payload
    end

    def self.notify(notes, e)
      report = Cloud::Agent::Error.new(notes, e)
      report.send!
    end
  end
end