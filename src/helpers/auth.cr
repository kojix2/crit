# Authentication helpers (Basic auth, etc.)
require "kemal-basic-auth"
require "../../config/config"

module Crit
  module Helpers
    module Auth
      def self.setup_basic_auth
        basic_auth Crit::Config::USERNAME, Crit::Config::PASSWORD
      end
    end
  end
end
