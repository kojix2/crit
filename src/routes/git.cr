# Git client routes (endpoints for git push/pull, etc.)
require "../helpers/cgi_helper"
require "log"

module Crit
  module Routes
    # Git client routes module
    #
    # Handles HTTP requests from Git clients for operations like
    # push, pull, clone, etc. by forwarding them to git-http-backend.
    module Git
      # Set up a dedicated logger for Git routes
      Log = ::Log.for(self)

      # Sets up Git HTTP routes
      def self.setup
        # Endpoint for git client
        # Example: /repo/testrepo/info/refs or /repo/testrepo.git/info/refs
        post "/repo/:name/*" do |env|
          name = env.params.url["name"]
          path_info = extract_path_info(env, name)

          Log.debug { "Handling POST request for repository: #{name}" }
          Log.debug { "Path info: #{path_info}" }

          cgi_env = Crit::Helpers::CGI.prepare_cgi_env(env, name, path_info)
          Crit::Helpers::CGI.run_git_http_backend(env, cgi_env)
        end

        get "/repo/:name/*" do |env|
          name = env.params.url["name"]
          path_info = extract_path_info(env, name)

          Log.debug { "Handling GET request for repository: #{name}" }
          Log.debug { "Path info: #{path_info}" }

          cgi_env = Crit::Helpers::CGI.prepare_cgi_env(env, name, path_info)
          Crit::Helpers::CGI.run_git_http_backend(env, cgi_env)
        end
      end

      # Extracts path_info from the request URL
      #
      # @param env [HTTP::Server::Context] The HTTP context
      # @param name [String] Repository name
      # @return [String] The path info part of the URL
      def self.extract_path_info(env, name)
        # Extract path_info based on whether the URL contains .git or not
        if env.request.path.includes?("#{name}.git")
          env.request.path.not_nil!.sub(%r{^/repo/#{name}.git}, "")
        else
          env.request.path.not_nil!.sub(%r{^/repo/#{name}}, "")
        end
      end
    end
  end
end
