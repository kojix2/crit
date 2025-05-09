# Configuration values and environment variable management
module Crit
  module Config
    # Authentication
    USERNAME = ENV["CRIT_USER"]? || "admin"
    PASSWORD = ENV["CRIT_PASS"]? || "yourpassword"

    # Repository storage
    REPO_ROOT = ENV["CRIT_REPO_ROOT"]? || "./repos"
  end
end
