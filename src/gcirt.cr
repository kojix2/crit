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
# Example: LOG_LEVEL=DEBUG ./gcirt
Log.setup_from_env

Log.info { "Starting GCIRT server" }

# Initialize repository directory
Gcirt::Models::Repository.ensure_repo_dir

# Setup authentication
Gcirt::Helpers::Auth.setup_basic_auth

# Setup routes
Gcirt::Routes::Web.setup
Gcirt::Routes::Git.setup

# Start the server
Kemal.run
