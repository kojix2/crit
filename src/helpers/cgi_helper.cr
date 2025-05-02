# CGI helper functions (for git-http-backend, environment variables, etc.)
require "../../config/config"

module Gcirt
  module Helpers
    module CGI
      def self.prepare_cgi_env(env, name, path_info)
        repo_path = File.expand_path(File.join(Gcirt::Config::REPO_ROOT, "#{name}.git"))

        {
          "GIT_PROJECT_ROOT" => File.expand_path(Gcirt::Config::REPO_ROOT),
          "GIT_HTTP_EXPORT_ALL" => "1",
          "PATH_INFO" => "/#{name}.git#{path_info}",
          "REQUEST_METHOD" => env.request.method,
          "QUERY_STRING" => env.request.query || "",
          "CONTENT_TYPE" => env.request.headers["Content-Type"]? || "",
          "REMOTE_USER" => "",
          "REMOTE_ADDR" => (env.request.remote_address.try(&.to_s) || ""),
          "AUTH_TYPE" => "",
          "SERVER_PROTOCOL" => env.request.version,
          "REQUEST_URI" => env.request.resource,
          "GATEWAY_INTERFACE" => "CGI/1.1",
          "SERVER_PORT" => (ENV["PORT"]? || "3000"),
          "SERVER_NAME" => env.request.headers["Host"]? || "",
        }
      end

      def self.run_git_http_backend(env, cgi_env)
        io = IO::Memory.new
        status = Process.run(
          "git",
          ["http-backend"],
          input: (env.request.body || Process::Redirect::Close),
          output: io,
          env: cgi_env
        )

        io.rewind
        raw = io.gets_to_end
        header, body = raw.split("\r\n\r\n", 2)
        header.lines.each do |line|
          if m = line.match(/^([A-Za-z0-9\-]+):\s*(.+)$/)
            env.response.headers[m[1]] = m[2]
          end
        end
        env.response.print body
        ""
      end
    end
  end
end
