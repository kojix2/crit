require "../spec_helper"

describe Gcirt::Models::Repository do
  before_each do
    # Set up a test repository directory
    ENV["GCIRT_REPO_ROOT"] = "./test_repos"
    FileUtils.rm_rf(Gcirt::Config::REPO_ROOT) if Dir.exists?(Gcirt::Config::REPO_ROOT)
    Gcirt::Models::Repository.ensure_repo_dir
  end

  after_each do
    # Clean up test repository directory
    FileUtils.rm_rf(Gcirt::Config::REPO_ROOT) if Dir.exists?(Gcirt::Config::REPO_ROOT)
  end

  describe "#initialize" do
    it "creates a repository instance with a name" do
      repo = Gcirt::Models::Repository.new("test")
      repo.name.should eq("test")
    end
  end

  describe "#path" do
    it "returns the correct repository path" do
      repo = Gcirt::Models::Repository.new("test")
      repo.path.should eq(File.join(Gcirt::Config::REPO_ROOT, "test.git"))
    end
  end

  describe "#exists?" do
    it "returns false for non-existent repository" do
      repo = Gcirt::Models::Repository.new("test")
      repo.exists?.should be_false
    end

    it "returns true for existing repository" do
      repo = Gcirt::Models::Repository.new("test")
      Dir.mkdir_p(repo.path)
      repo.exists?.should be_true
    end
  end

  describe "#create" do
    it "creates a new repository" do
      repo = Gcirt::Models::Repository.new("test")
      result = repo.create
      result.should be_true
      Dir.exists?(repo.path).should be_true
    end

    it "returns false if repository already exists" do
      repo = Gcirt::Models::Repository.new("test")
      repo.create
      result = repo.create
      result.should be_false
    end
  end

  describe ".list" do
    it "returns empty array when no repositories exist" do
      Gcirt::Models::Repository.list.should eq([] of String)
    end

    it "returns list of repositories" do
      repo1 = Gcirt::Models::Repository.new("test1")
      repo2 = Gcirt::Models::Repository.new("test2")
      repo1.create
      repo2.create
      
      list = Gcirt::Models::Repository.list
      list.size.should eq(2)
      list.should contain("test1.git")
      list.should contain("test2.git")
    end
  end
end
