# Git client routes (endpoints for git push/pull, etc.)
require "../helpers/cgi_helper"

module Gcirt
  module Routes
    module Git
      def self.setup
        # Endpoint for git client
        # Example: /repo/testrepo.git/info/refs etc.
        post "/repo/:name.git/*" do |env|
          handle_git_http_backend(env)
        end

        get "/repo/:name.git/*" do |env|
          handle_git_http_backend(env)
        end
      end

      private def self.handle_git_http_backend(env)
        name = env.params.url["name"]
        path_info = env.request.path.not_nil!.sub(%r{^/repo/#{name}.git}, "")
        
        cgi_env = Gcirt::Helpers::CGI.prepare_cgi_env(env, name, path_info)
        Gcirt::Helpers::CGI.run_git_http_backend(env, cgi_env)
      end
    end
  end
end
