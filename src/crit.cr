require "kemal"
require "file_utils"
require "log"
require "./helpers/auth"
require "./routes/web"
require "./routes/git"
require "./models/repository"
require "./services/repo_service"

# Configure logging from environment variables
# The environment variable LOG_LEVEL is used to indicate which severity level to emit
# Example: LOG_LEVEL=DEBUG ./crit
Log.setup_from_env

Log.info { "Starting CRIT server" }

# Minimal hardening: fail fast if credentials are unset or left at defaults.
if Crit::Config::USERNAME.empty? || Crit::Config::PASSWORD.empty?
  Log.fatal { "CRIT_USER and CRIT_PASS must be set." }
  exit(1)
end

if Crit::Config::USERNAME == "admin" || Crit::Config::PASSWORD == "yourpassword"
  Log.fatal { "Default credentials are not allowed. Set CRIT_USER and CRIT_PASS." }
  exit(1)
end

# Initialize repository directory
Crit::Models::Repository.ensure_repo_dir

# Setup authentication
Crit::Helpers::Auth.setup_basic_auth

# Setup routes
Crit::Routes::Web.setup
Crit::Routes::Git.setup

# Start the server
Kemal.run
