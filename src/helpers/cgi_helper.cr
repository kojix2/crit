# CGI helper functions (for git-http-backend, environment variables, etc.)
require "../../config/config"
require "base64"
require "log"

module Crit
  module Helpers
    # CGI helper module for git-http-backend integration
    #
    # This module provides functionality to handle Git HTTP protocol
    # by interfacing with git-http-backend CGI script.
    module CGI
      # Set up a dedicated logger for CGI operations
      Log = ::Log.for(self)

      # Extracts username from HTTP Authorization header
      #
      # @param env [HTTP::Server::Context] The HTTP context
      # @return [String, Nil] The extracted username or nil if not found
      def self.extract_username_from_auth_header(env)
        auth_header = env.request.headers["Authorization"]?
        return nil unless auth_header

        if auth_header.starts_with?("Basic ")
          base64 = auth_header.sub("Basic ", "")
          begin
            decoded = Base64.decode_string(base64)
            username, _ = decoded.split(":", 2)
            return username
          rescue ex
            Log.error { "Failed to decode authorization header: #{ex.message}" }
            return nil
          end
        end

        nil
      end

      # Prepares CGI environment variables for git-http-backend
      #
      # @param env [HTTP::Server::Context] The HTTP context
      # @param name [String] Repository name
      # @param path_info [String] Path info part of the URL
      # @return [Hash(String, String)] CGI environment variables
      def self.prepare_cgi_env(env, name, path_info)
        # Handle repository names with or without .git extension
        repo_name = name.ends_with?(".git") ? name : "#{name}.git"
        repo_path = File.expand_path(File.join(Crit::Config::REPO_ROOT, repo_name))

        Log.debug { "CGI env preparation" }
        Log.debug { "name=#{name}, repo_name=#{repo_name}, path_info=#{path_info}" }
        Log.debug { "repo_path=#{repo_path}" }
        Log.debug { "request_path=#{env.request.path}" }
        Log.debug { "request_method=#{env.request.method}" }

        {
          "GIT_PROJECT_ROOT"    => File.expand_path(Crit::Config::REPO_ROOT),
          "GIT_HTTP_EXPORT_ALL" => "1",
          "PATH_INFO"           => "/#{repo_name}#{path_info}",
          "REQUEST_METHOD"      => env.request.method,
          "QUERY_STRING"        => env.request.query || "",
          "CONTENT_TYPE"        => env.request.headers["Content-Type"]? || "",
          "REMOTE_USER"         => extract_username_from_auth_header(env) || "",
          "REMOTE_ADDR"         => (env.request.remote_address.try(&.to_s) || ""),
          "AUTH_TYPE"           => "Basic",
          "SERVER_PROTOCOL"     => env.request.version,
          "REQUEST_URI"         => env.request.resource,
          "GATEWAY_INTERFACE"   => "CGI/1.1",
          "SERVER_PORT"         => (ENV["PORT"]? || "3000"),
          "SERVER_NAME"         => env.request.headers["Host"]? || "",
        }
      end

      # Runs git-http-backend CGI script
      #
      # @param env [HTTP::Server::Context] The HTTP context
      # @param cgi_env [Hash(String, String)] CGI environment variables
      # @return [String] Empty string on success, error message on failure
      def self.run_git_http_backend(env, cgi_env)
        Log.debug { "Running git-http-backend" }

        # Always log CGI environment details at debug level
        # The log system will filter based on the configured level
        Log.debug { "CGI environment:" }
        cgi_env.each do |key, value|
          Log.debug { "  #{key}=#{value}" }
        end

        io = IO::Memory.new
        status = Process.run(
          "git",
          ["http-backend"],
          input: (env.request.body || Process::Redirect::Close),
          output: io,
          env: cgi_env
        )

        Log.debug { "git-http-backend exit status: #{status.exit_code}" }

        io.rewind
        raw = io.gets_to_end
        Log.debug { "git-http-backend raw output length: #{raw.size}" }

        if raw.empty?
          Log.error { "git-http-backend returned empty response" }
          env.response.status_code = 500
          return "Internal Server Error: git-http-backend returned empty response"
        end

        begin
          header, body = raw.split("\r\n\r\n", 2)
          Log.debug { "git-http-backend header length: #{header.size}" }
          Log.debug { "git-http-backend body length: #{body.size}" }

          header.lines.each do |line|
            Log.debug { "Header line: #{line}" }
            if m = line.match(/^([A-Za-z0-9\-]+):\s*(.+)$/)
              env.response.headers[m[1]] = m[2]
              Log.debug { "Set response header #{m[1]}=#{m[2]}" }
            end
          end
          env.response.print body
        rescue ex
          Log.error { "Error processing git-http-backend response: #{ex.message}" }
          env.response.status_code = 500
          return "Internal Server Error: #{ex.message}"
        end

        ""
      end
    end
  end
end
