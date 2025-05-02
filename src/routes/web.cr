# Web UI routes (HTML rendering, forms, etc.)
require "../models/repository"
require "../services/repo_service"
require "ecr"

module Gcirt
  module Routes
    module Web
      # Helper method to build file paths
      private def self.file_path(base_path, file_name)
        base_path.empty? ? file_name : "#{base_path}/#{file_name}"
      end
      
      def self.setup
        # Home page - repository list
        get "/" do
          repos = Gcirt::Models::Repository.list
          render "views/index.ecr", "views/layout.ecr"
        end

        # New repository form
        get "/new" do
          render "views/new.ecr", "views/layout.ecr"
        end

        # Create new repository
        post "/new" do |env|
          name = env.params.body["name"]?.to_s.strip
          if name.empty? || name =~ /[^a-zA-Z0-9_\-]/
            next "<p>Invalid name</p><a href=\"/new\">Back</a>"
          end
          
          repo = Gcirt::Models::Repository.new(name)
          if repo.exists?
            next "<p>Repository already exists</p><a href=\"/new\">Back</a>"
          end
          
          if repo.create
            env.response.headers["Location"] = "/repo/#{name}.git".sub(/\.git$/, "")
            env.response.status_code = 302
            ""
          else
            "<p>Failed to create repository</p><a href=\"/new\">Back</a>"
          end
        end

        # Repository details page
        get "/repo/:name" do |env|
          name = env.params.url["name"]
          
          # Handle repository names with or without .git extension
          repo_name = name.ends_with?(".git") ? name : "#{name}.git"
          repo = Gcirt::Models::Repository.new(repo_name)
          
          if !repo.exists?
            next "<p>Repository not found</p><a href=\"/\">Back</a>"
          end
          
          # Get branches
          branches = Gcirt::Services::RepoService.list_branches(name)
          
          # Default to master branch if it exists, otherwise use the first branch
          default_branch = branches.includes?("master") ? "master" : (branches.first? || "master")
          
          # Get files in the root directory
          files = Gcirt::Services::RepoService.list_files(name, default_branch)
          
          render "views/repo.ecr", "views/layout.ecr"
        end
        
        # Show directory contents
        get "/repo/:name/tree/:ref/*path" do |env|
          name = env.params.url["name"]
          ref = env.params.url["ref"]
          path = env.params.url["path"]
          
          # Handle repository names with or without .git extension
          repo_name = name.ends_with?(".git") ? name : "#{name}.git"
          repo = Gcirt::Models::Repository.new(repo_name)
          
          if !repo.exists?
            next "<p>Repository not found</p><a href=\"/\">Back</a>"
          end
          
          files = Gcirt::Services::RepoService.list_files(name, ref, path)
          if !files
            next "<p>Path not found or not a directory</p><a href=\"/repo/#{name}\">Back to repository</a>"
          end
          
          # Calculate parent directory path
          parent_path = path.empty? ? "" : File.dirname(path)
          parent_path = "" if parent_path == "."
          
          render "views/tree.ecr", "views/layout.ecr"
        end
        
        # Show file content
        get "/repo/:name/blob/:ref/*path" do |env|
          name = env.params.url["name"]
          ref = env.params.url["ref"]
          path = env.params.url["path"]
          
          # Handle repository names with or without .git extension
          repo_name = name.ends_with?(".git") ? name : "#{name}.git"
          repo = Gcirt::Models::Repository.new(repo_name)
          
          if !repo.exists?
            next "<p>Repository not found</p><a href=\"/\">Back</a>"
          end
          
          content = Gcirt::Services::RepoService.get_file_content(name, ref, path)
          if !content
            next "<p>File not found</p><a href=\"/repo/#{name}\">Back to repository</a>"
          end
          
          # Determine if this is a binary file (simple check)
          is_binary = content.includes?("\0") || content.each_byte.any? { |b| b < 32 && b != 9 && b != 10 && b != 13 }
          
          # Calculate parent directory path
          parent_path = File.dirname(path)
          parent_path = "" if parent_path == "."
          
          render "views/blob.ecr", "views/layout.ecr"
        end
      end
    end
  end
end
