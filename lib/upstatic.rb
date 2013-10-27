require "upstatic/compat"
require "upstatic/configuration"
require "upstatic/deployer"
require "upstatic/manager"
require "upstatic/shell"

module Upstatic
  def self.shell
    @@shell ||= Upstatic::Shell.new
  end

  def self.shell=(shell)
    @@shell = shell
  end
end
