# Repository service (create, list, and manage repositories)
require "../models/repository"

module Gcirt
  module Services
    class RepoService
      # Get file listing for a repository at a specific path and ref
      def self.list_files(repo_name : String, ref : String = "master", path : String = "")
        # Handle repository names with or without .git extension
        repo_name = repo_name.ends_with?(".git") ? repo_name : "#{repo_name}.git"
        repo_path = File.join(Gcirt::Config::REPO_ROOT, repo_name)
        return nil unless Dir.exists?(repo_path)
        
        # Construct the git command to list files
        path_spec = path.empty? ? "" : "#{path}/"
        cmd = "git --git-dir=#{repo_path} ls-tree #{ref}:#{path_spec}"
        
        output = IO::Memory.new
        error = IO::Memory.new
        status = Process.run(cmd, shell: true, output: output, error: error)
        
        return nil unless status.success?
        
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
      end
      
      # Get file content for a specific file in a repository
      def self.get_file_content(repo_name : String, ref : String = "master", path : String = "")
        # Handle repository names with or without .git extension
        repo_name = repo_name.ends_with?(".git") ? repo_name : "#{repo_name}.git"
        repo_path = File.join(Gcirt::Config::REPO_ROOT, repo_name)
        return nil unless Dir.exists?(repo_path)
        
        # Construct the git command to get file content
        cmd = "git --git-dir=#{repo_path} show #{ref}:#{path}"
        
        output = IO::Memory.new
        error = IO::Memory.new
        status = Process.run(cmd, shell: true, output: output, error: error)
        
        return nil unless status.success?
        
        # Return the file content
        output.rewind
        output.gets_to_end
      end
      
      # Get list of branches for a repository
      def self.list_branches(repo_name : String)
        # Handle repository names with or without .git extension
        repo_name = repo_name.ends_with?(".git") ? repo_name : "#{repo_name}.git"
        repo_path = File.join(Gcirt::Config::REPO_ROOT, repo_name)
        return [] of String unless Dir.exists?(repo_path)
        
        cmd = "git --git-dir=#{repo_path} branch"
        
        output = IO::Memory.new
        error = IO::Memory.new
        status = Process.run(cmd, shell: true, output: output, error: error)
        
        return [] of String unless status.success?
        
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
      end
    end
  end
end
