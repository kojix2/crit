# Repository service (create, list, and manage repositories)
require "../models/repository"
require "log"

module Gcirt
  module Services
    # Repository service class
    #
    # Provides Git-specific operations for repositories such as listing files,
    # getting file content, and listing branches. This service layer interacts
    # with Git commands to perform operations on repositories.
    #
    # ## Example
    # ```
    # # List files in a repository
    # files = Gcirt::Services::RepoService.list_files("my-project", "master")
    # ```
    class RepoService
      # Gets file listing for a repository at a specific path and reference
      #
      # @param repo_name [String] The name of the repository
      # @param ref [String] The Git reference (branch, tag, or commit)
      # @param path [String] The path within the repository
      # @return [Array<{type: String, mode: String, hash: String, name: String}>] Array of file entries
      # @return [Nil] If the repository or path doesn't exist
      def self.list_files(repo_name : String, ref : String = "master", path : String = "")
        begin
          # Handle repository names with or without .git extension
          repo_name = repo_name.ends_with?(".git") ? repo_name : "#{repo_name}.git"
          repo_path = File.join(Gcirt::Config::REPO_ROOT, repo_name)
          return nil unless Dir.exists?(repo_path)

          # Sanitize inputs to prevent command injection
          unless ref.matches?(/^[a-zA-Z0-9_\-\.\/]+$/)
            Log.warn { "Invalid Git reference format: #{ref}" }
            return nil
          end

          unless path.empty? || path.matches?(/^[a-zA-Z0-9_\-\.\/]+$/)
            Log.warn { "Invalid path format: #{path}" }
            return nil
          end

          # Construct the git command to list files
          path_spec = path.empty? ? "" : "#{path}/"

          output = IO::Memory.new
          error = IO::Memory.new

          status = Process.run(
            "git",
            ["--git-dir=#{repo_path}", "ls-tree", "#{ref}:#{path_spec}"],
            output: output,
            error: error
          )

          if !status.success?
            error.rewind
            error_message = error.gets_to_end
            Log.error { "Failed to list files: #{error_message}" }
            return nil
          end

          # Parse the output
          output.rewind
          entries = [] of {type: String, mode: String, hash: String, name: String}

          output.each_line do |line|
            # Format: <mode> <type> <hash>\t<name>
            if line =~ /^(\d+)\s+(\w+)\s+([a-f0-9]+)\t(.+)$/
              mode = $1
              type = $2
              hash = $3
              name = $4
              entries << {type: type, mode: mode, hash: hash, name: name}
            end
          end

          entries
        rescue ex
          Log.error { "Error listing files: #{ex.message}" }
          nil
        end
      end

      # Gets file content for a specific file in a repository
      #
      # @param repo_name [String] The name of the repository
      # @param ref [String] The Git reference (branch, tag, or commit)
      # @param path [String] The path to the file within the repository
      # @return [String] The content of the file
      # @return [Nil] If the repository or file doesn't exist
      def self.get_file_content(repo_name : String, ref : String = "master", path : String = "")
        begin
          # Handle repository names with or without .git extension
          repo_name = repo_name.ends_with?(".git") ? repo_name : "#{repo_name}.git"
          repo_path = File.join(Gcirt::Config::REPO_ROOT, repo_name)
          return nil unless Dir.exists?(repo_path)

          # Sanitize inputs to prevent command injection
          unless ref.matches?(/^[a-zA-Z0-9_\-\.\/]+$/)
            Log.warn { "Invalid Git reference format: #{ref}" }
            return nil
          end

          unless path.matches?(/^[a-zA-Z0-9_\-\.\/]+$/)
            Log.warn { "Invalid path format: #{path}" }
            return nil
          end

          output = IO::Memory.new
          error = IO::Memory.new

          status = Process.run(
            "git",
            ["--git-dir=#{repo_path}", "show", "#{ref}:#{path}"],
            output: output,
            error: error
          )

          if !status.success?
            error.rewind
            error_message = error.gets_to_end
            Log.error { "Failed to get file content: #{error_message}" }
            return nil
          end

          # Return the file content
          output.rewind
          output.gets_to_end
        rescue ex
          Log.error { "Error getting file content: #{ex.message}" }
          nil
        end
      end

      # Gets list of branches for a repository
      #
      # @param repo_name [String] The name of the repository
      # @return [Array<String>] Array of branch names
      # @return [Array<String>] Empty array if the repository doesn't exist or has no branches
      def self.list_branches(repo_name : String)
        begin
          # Handle repository names with or without .git extension
          repo_name = repo_name.ends_with?(".git") ? repo_name : "#{repo_name}.git"
          repo_path = File.join(Gcirt::Config::REPO_ROOT, repo_name)
          return [] of String unless Dir.exists?(repo_path)

          output = IO::Memory.new
          error = IO::Memory.new

          status = Process.run(
            "git",
            ["--git-dir=#{repo_path}", "branch"],
            output: output,
            error: error
          )

          if !status.success?
            error.rewind
            error_message = error.gets_to_end
            Log.error { "Failed to list branches: #{error_message}" }
            return [] of String
          end

          # Parse the output
          output.rewind
          branches = [] of String

          output.each_line do |line|
            # Format: [*] <branch_name>
            if line =~ /^\*?\s+(.+)$/
              branches << $1.strip
            end
          end

          branches
        rescue ex
          Log.error { "Error listing branches: #{ex.message}" }
          [] of String
        end
      end
    end
  end
end
