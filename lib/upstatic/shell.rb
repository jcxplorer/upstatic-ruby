require "thor/shell"

module Upstatic
  class Shell
    def initialize
      @shell = Thor::Base.shell.new
    end

    def say_status(status, message, log_status=nil)
      @shell.say_status(status, message, log_status)
    end
  end
end
