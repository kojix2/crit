# Repository model (repository management logic)
require "file_utils"
require "../../config/config"

module Gcirt
  module Models
    # Repository model class
    #
    # Provides basic operations for Git repositories such as creation, existence checking, and listing.
    # This class is responsible for the basic management of repositories,
    # while actual Git operations are handled by the service layer.
    #
    # ## Example
    # ```
    # repo = Gcirt::Models::Repository.new("my-project")
    # if !repo.exists?
    #   repo.create
    # end
    # ```
    class Repository
      # Regular expression for repository name validation
      VALID_NAME_REGEX = /^[a-zA-Z0-9_\-\.]+$/

      # Maximum length for repository names
      MAX_NAME_LENGTH = 100

      # Minimum length for repository names
      MIN_NAME_LENGTH = 1

      # Reserved repository names
      RESERVED_NAMES = ["new", "admin", "settings", "login", "logout", "api"]

      # Repository name
      getter name : String

      # Initializes a new repository instance
      #
      # @param name [String] The name of the repository
      # @raise [ArgumentError] If the repository name is invalid
      def initialize(@name : String)
        validate_name
      end

      # Validates the repository name
      #
      # @raise [ArgumentError] If the repository name is invalid
      private def validate_name
        if @name.empty?
          raise ArgumentError.new("Repository name cannot be empty")
        end

        if @name.size > MAX_NAME_LENGTH
          raise ArgumentError.new("Repository name cannot exceed #{MAX_NAME_LENGTH} characters")
        end

        if @name.size < MIN_NAME_LENGTH
          raise ArgumentError.new("Repository name must be at least #{MIN_NAME_LENGTH} characters")
        end

        if !@name.matches?(VALID_NAME_REGEX)
          raise ArgumentError.new("Repository name contains invalid characters")
        end

        if RESERVED_NAMES.includes?(@name.downcase)
          raise ArgumentError.new("Repository name '#{@name}' is reserved")
        end
      end

      # Returns the full path to the repository
      #
      # @return [String] The full path to the repository
      def path
        # Handle repository names with or without .git extension
        repo_name = @name.ends_with?(".git") ? @name : "#{@name}.git"
        File.join(Gcirt::Config::REPO_ROOT, repo_name)
      end

      # Checks if the repository exists
      #
      # @return [Boolean] True if the repository exists, false otherwise
      def exists?
        Dir.exists?(path)
      end

      # Creates a new bare Git repository
      #
      # @return [Boolean] True if the repository was created successfully, false otherwise
      # @return [Boolean] False if the repository already exists
      def create
        return false if exists?

        output = IO::Memory.new
        error = IO::Memory.new

        status = Process.run(
          "git",
          ["init", "--bare", path],
          output: output,
          error: error
        )

        if !status.success?
          error.rewind
          error_message = error.gets_to_end
          Log.error { "Failed to create repository: #{error_message}" }
        end

        status.success?
      end

      # Lists all repositories
      #
      # @return [Array<String>] Array of repository names
      def self.list
        begin
          Dir.entries(Gcirt::Config::REPO_ROOT)
            .select { |name| name.ends_with?(".git") }
            .sort
        rescue ex
          Log.error { "Failed to list repositories: #{ex.message}" }
          [] of String
        end
      end

      # Ensures the repository directory exists
      #
      # @return [Boolean] True if the directory exists or was created successfully
      def self.ensure_repo_dir
        begin
          FileUtils.mkdir_p(Gcirt::Config::REPO_ROOT)
          true
        rescue ex
          Log.error { "Failed to create repository directory: #{ex.message}" }
          false
        end
      end
    end
  end
end
