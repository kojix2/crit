require "spec"
require "kemal"
require "file_utils"
require "../config/config"
require "../src/models/repository"
require "../src/helpers/auth"
require "../src/helpers/cgi_helper"
require "../src/routes/web"
require "../src/routes/git"

# Initialize repository directory for tests
Gcirt::Models::Repository.ensure_repo_dir

# Don't actually start the server in tests
Kemal.config.env = "test"
