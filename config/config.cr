# Configuration values and environment variable management
module Gcirt
  module Config
    # Authentication
    USERNAME = ENV["GCIRT_USER"]? || "admin"
    PASSWORD = ENV["GCIRT_PASS"]? || "yourpassword"

    # Repository storage
    REPO_ROOT = ENV["GCIRT_REPO_ROOT"]? || "./repos"
  end
end
