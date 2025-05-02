# Authentication helpers (Basic auth, etc.)
require "kemal-basic-auth"
require "../../config/config"

module Gcirt
  module Helpers
    module Auth
      def self.setup_basic_auth
        basic_auth Gcirt::Config::USERNAME, Gcirt::Config::PASSWORD
      end
    end
  end
end
