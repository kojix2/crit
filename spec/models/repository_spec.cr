require "../spec_helper"

describe Crit::Models::Repository do
  # Test setup and teardown
  before_each do
    # Set up a test repository directory
    ENV["CRIT_REPO_ROOT"] = "./test_repos"
    FileUtils.rm_rf(Crit::Config::REPO_ROOT) if Dir.exists?(Crit::Config::REPO_ROOT)
    Crit::Models::Repository.ensure_repo_dir
  end

  after_each do
    # Clean up test repository directory
    FileUtils.rm_rf(Crit::Config::REPO_ROOT) if Dir.exists?(Crit::Config::REPO_ROOT)
  end

  # Test initialization and validation
  describe "#initialize" do
    it "creates a repository instance with a valid name" do
      repo = Crit::Models::Repository.new("test")
      repo.name.should eq("test")
    end

    it "raises ArgumentError for empty name" do
      expect_raises(ArgumentError, "Repository name cannot be empty") do
        Crit::Models::Repository.new("")
      end
    end

    it "raises ArgumentError for name with invalid characters" do
      expect_raises(ArgumentError, "Repository name contains invalid characters") do
        Crit::Models::Repository.new("test/repo")
      end
    end

    it "raises ArgumentError for name exceeding maximum length" do
      long_name = "a" * (Crit::Models::Repository::MAX_NAME_LENGTH + 1)
      expect_raises(ArgumentError, "Repository name cannot exceed") do
        Crit::Models::Repository.new(long_name)
      end
    end

    it "raises ArgumentError for reserved names" do
      expect_raises(ArgumentError, "Repository name 'admin' is reserved") do
        Crit::Models::Repository.new("admin")
      end
    end
  end

  # Test path generation
  describe "#path" do
    it "returns the correct repository path" do
      repo = Crit::Models::Repository.new("test")
      repo.path.should eq(File.join(Crit::Config::REPO_ROOT, "test.git"))
    end

    it "handles repository names with .git extension" do
      repo = Crit::Models::Repository.new("test.git")
      repo.path.should eq(File.join(Crit::Config::REPO_ROOT, "test.git"))
    end
  end

  # Test existence checking
  describe "#exists?" do
    it "returns false for non-existent repository" do
      repo = Crit::Models::Repository.new("test")
      repo.exists?.should be_false
    end

    it "returns true for existing repository" do
      repo = Crit::Models::Repository.new("test")
      Dir.mkdir_p(repo.path)
      repo.exists?.should be_true
    end
  end

  # Test repository creation
  describe "#create" do
    it "creates a new repository" do
      repo = Crit::Models::Repository.new("test")
      result = repo.create
      result.should be_true
      Dir.exists?(repo.path).should be_true
    end

    it "returns false if repository already exists" do
      repo = Crit::Models::Repository.new("test")
      repo.create
      result = repo.create
      result.should be_false
    end

    it "creates a repository with a hyphenated name" do
      repo = Crit::Models::Repository.new("test-repo")
      result = repo.create
      result.should be_true
      Dir.exists?(repo.path).should be_true
    end

    it "creates a repository with an underscore in the name" do
      repo = Crit::Models::Repository.new("test_repo")
      result = repo.create
      result.should be_true
      Dir.exists?(repo.path).should be_true
    end
  end

  # Test repository listing
  describe ".list" do
    it "returns empty array when no repositories exist" do
      Crit::Models::Repository.list.should eq([] of String)
    end

    it "returns list of repositories" do
      repo1 = Crit::Models::Repository.new("test1")
      repo2 = Crit::Models::Repository.new("test2")
      repo1.create
      repo2.create

      list = Crit::Models::Repository.list
      list.size.should eq(2)
      list.should contain("test1.git")
      list.should contain("test2.git")
    end

    it "returns sorted list of repositories" do
      repo1 = Crit::Models::Repository.new("c-repo")
      repo2 = Crit::Models::Repository.new("a-repo")
      repo3 = Crit::Models::Repository.new("b-repo")
      repo1.create
      repo2.create
      repo3.create

      list = Crit::Models::Repository.list
      list.should eq(["a-repo.git", "b-repo.git", "c-repo.git"])
    end
  end
  # Test repository directory creation
  describe ".ensure_repo_dir" do
    it "creates the repository directory if it doesn't exist" do
      FileUtils.rm_rf(Crit::Config::REPO_ROOT)
      result = Crit::Models::Repository.ensure_repo_dir
      result.should be_true
      Dir.exists?(Crit::Config::REPO_ROOT).should be_true
    end

    it "returns true if the repository directory already exists" do
      # Directory is already created in before_each
      result = Crit::Models::Repository.ensure_repo_dir
      result.should be_true
    end
  end
end
