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

# Initialize repository directory
Crit::Models::Repository.ensure_repo_dir

# Setup authentication
Crit::Helpers::Auth.setup_basic_auth

# Setup routes
Crit::Routes::Web.setup
Crit::Routes::Git.setup

# Start the server
Kemal.run
