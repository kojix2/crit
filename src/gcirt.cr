require "kemal"
require "file_utils"
require "./helpers/auth"
require "./routes/web"
require "./routes/git"
require "./models/repository"
require "./services/repo_service"

# Initialize repository directory
Gcirt::Models::Repository.ensure_repo_dir

# Setup authentication
Gcirt::Helpers::Auth.setup_basic_auth

# Setup routes
Gcirt::Routes::Web.setup
Gcirt::Routes::Git.setup

# Start the server
Kemal.run
