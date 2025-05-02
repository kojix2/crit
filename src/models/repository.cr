# Repository model (repository management logic)
require "file_utils"
require "../../config/config"

module Gcirt
  module Models
    class Repository
      getter name : String

      def initialize(@name : String)
      end

      def path
        File.join(Gcirt::Config::REPO_ROOT, "#{@name}.git")
      end

      def exists?
        Dir.exists?(path)
      end

      def create
        return false if exists?
        status = Process.run("git", ["init", "--bare", path], output: Process::Redirect::Close, error: Process::Redirect::Close)
        status.success?
      end

      def self.list
        Dir.entries(Gcirt::Config::REPO_ROOT)
          .select { |name| name.ends_with?(".git") }
          .sort
      end

      def self.ensure_repo_dir
        FileUtils.mkdir_p(Gcirt::Config::REPO_ROOT)
      end
    end
  end
end
