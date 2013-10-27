require "upstatic"
require "thor"

module Upstatic
  class CLI < Thor
    include Thor::Actions

    desc "deploy", "Deploy to S3"
    def deploy
      Deployer.new(configuration).deploy!
    end

    private

    def configuration
      @configuration ||= Configuration.read("./Upstatic")
    end

  end
end
