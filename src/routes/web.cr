# Web UI routes (HTML rendering, forms, etc.)
require "../models/repository"
require "../services/repo_service"
require "ecr"
require "log"

module Gcirt
  module Routes
    # Web UI routes module
    #
    # Handles all web interface routes including repository listing,
    # creation, and file/directory browsing. This module is responsible
    # for rendering HTML pages and handling form submissions.
    module Web
      # Helper method to build file paths
      #
      # @param base_path [String] The base directory path
      # @param file_name [String] The file name to append
      # @return [String] The combined path
      private def self.file_path(base_path, file_name)
        base_path.empty? ? file_name : "#{base_path}/#{file_name}"
      end

      # Error response helper
      #
      # @param message [String] The error message to display
      # @param back_url [String] The URL for the "Back" link
      # @return [String] HTML error response
      private def self.error_response(message, back_url = "/")
        <<-HTML
        <div class="error-container">
          <div class="error-message">#{message}</div>
          <a href="#{back_url}" class="button">Back</a>
        </div>
        HTML
      end

      # Sets up all web routes
      def self.setup
        # Home page - repository list
        get "/" do
          begin
            repos = Gcirt::Models::Repository.list
            render "views/index.ecr", "views/layout.ecr"
          rescue ex
            Log.error { "Error rendering index page: #{ex.message}" }
            error_response("An error occurred while loading repositories")
          end
        end

        # New repository form
        get "/new" do
          begin
            render "views/new.ecr", "views/layout.ecr"
          rescue ex
            Log.error { "Error rendering new repository form: #{ex.message}" }
            error_response("An error occurred while loading the form")
          end
        end

        # Create new repository
        post "/new" do |env|
          begin
            name = env.params.body["name"]?.to_s.strip

            begin
              repo = Gcirt::Models::Repository.new(name)
            rescue ex : ArgumentError
              next error_response(ex.message, "/new")
            end

            if repo.exists?
              next error_response("Repository already exists", "/new")
            end

            if repo.create
              env.response.headers["Location"] = "/repo/#{name}"
              env.response.status_code = 302
              ""
            else
              error_response("Failed to create repository", "/new")
            end
          rescue ex
            Log.error { "Error creating repository: #{ex.message}" }
            error_response("An unexpected error occurred", "/new")
          end
        end

        # Repository details page
        get "/repo/:name" do |env|
          begin
            name = env.params.url["name"]

            begin
              repo = Gcirt::Models::Repository.new(name)
            rescue ex : ArgumentError
              next error_response(ex.message)
            end

            if !repo.exists?
              next error_response("Repository not found", "/")
            end

            # Get branches
            branches = Gcirt::Services::RepoService.list_branches(name)

            # Default to main branch if it exists, otherwise try master, then use the first branch
            default_branch = if branches.includes?("main")
                               "main"
                             elsif branches.includes?("master")
                               "master"
                             else
                               branches.first? || "master"
                             end

            # For empty repositories (no branches), we'll show a special view
            if branches.empty?
              files = nil
            else
              # Get files in the root directory
              files = Gcirt::Services::RepoService.list_files(name, default_branch)

              # Only show error if we have branches but can't list files
              if files.nil? && !branches.empty?
                next error_response("Failed to list repository files", "/")
              end
            end

            render "views/repo.ecr", "views/layout.ecr"
          rescue ex
            Log.error { "Error rendering repository page: #{ex.message}" }
            error_response("An error occurred while loading repository", "/")
          end
        end

        # Show directory contents
        get "/repo/:name/tree/:ref/*path" do |env|
          begin
            name = env.params.url["name"]
            ref = env.params.url["ref"]
            path = env.params.url["path"]

            begin
              repo = Gcirt::Models::Repository.new(name)
            rescue ex : ArgumentError
              next error_response(ex.message)
            end

            if !repo.exists?
              next error_response("Repository not found", "/")
            end

            files = Gcirt::Services::RepoService.list_files(name, ref, path)
            if !files
              next error_response("Path not found or not a directory", "/repo/#{name}")
            end

            # Calculate parent directory path
            parent_path = path.empty? ? "" : File.dirname(path)
            parent_path = "" if parent_path == "."

            render "views/tree.ecr", "views/layout.ecr"
          rescue ex
            Log.error { "Error rendering directory contents: #{ex.message}" }
            error_response("An error occurred while loading directory", "/repo/#{name}")
          end
        end

        # Show file content
        get "/repo/:name/blob/:ref/*path" do |env|
          begin
            name = env.params.url["name"]
            ref = env.params.url["ref"]
            path = env.params.url["path"]

            begin
              repo = Gcirt::Models::Repository.new(name)
            rescue ex : ArgumentError
              next error_response(ex.message)
            end

            if !repo.exists?
              next error_response("Repository not found", "/")
            end

            content = Gcirt::Services::RepoService.get_file_content(name, ref, path)
            if !content
              next error_response("File not found", "/repo/#{name}")
            end

            # Determine if this is a binary file (simple check)
            is_binary = content.includes?("\0") || content.each_byte.any? { |b| b < 32 && b != 9 && b != 10 && b != 13 }

            # Calculate parent directory path
            parent_path = File.dirname(path)
            parent_path = "" if parent_path == "."

            render "views/blob.ecr", "views/layout.ecr"
          rescue ex
            Log.error { "Error rendering file content: #{ex.message}" }
            error_response("An error occurred while loading file", "/repo/#{name}")
          end
        end
      end
    end
  end
end
