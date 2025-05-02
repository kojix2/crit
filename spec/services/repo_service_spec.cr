require "../spec_helper"

describe Crit::Services::RepoService do
  before_each do
    # Set up a test repository directory
    ENV["CRIT_REPO_ROOT"] = "./test_repos"
    FileUtils.rm_rf(Crit::Config::REPO_ROOT) if Dir.exists?(Crit::Config::REPO_ROOT)
    Crit::Models::Repository.ensure_repo_dir

    # Create a test repository
    repo = Crit::Models::Repository.new("test")
    repo.create

    # Initialize the repository with some content
    repo_path = repo.path

    # Create a temporary working directory
    temp_dir = File.join(Dir.tempdir, "crit_test_#{Time.utc.to_unix}")
    Dir.mkdir_p(temp_dir)

    # Clone the bare repository
    Process.run("git clone #{repo_path} #{temp_dir}", shell: true)

    # Create some test files and commit them
    File.write(File.join(temp_dir, "README.md"), "# Test Repository\n\nThis is a test repository.")
    Dir.mkdir_p(File.join(temp_dir, "src"))
    File.write(File.join(temp_dir, "src", "main.cr"), "puts \"Hello, World!\"")

    # Commit the changes
    Dir.cd(temp_dir) do
      Process.run("git config user.name \"Test User\"", shell: true)
      Process.run("git config user.email \"test@example.com\"", shell: true)
      Process.run("git add .", shell: true)
      Process.run("git commit -m \"Initial commit\"", shell: true)
      Process.run("git push origin master", shell: true)
    end

    # Clean up the temporary directory
    FileUtils.rm_rf(temp_dir)
  end

  after_each do
    # Clean up test repository directory
    FileUtils.rm_rf(Crit::Config::REPO_ROOT) if Dir.exists?(Crit::Config::REPO_ROOT)
  end

  describe ".list_files" do
    it "returns files in the root directory" do
      files = Crit::Services::RepoService.list_files("test", "master")
      files.should_not be_nil

      if files
        file_names = files.map { |f| f[:name] }
        file_names.should contain("README.md")
        file_names.should contain("src")

        # Verify the types
        readme_file = files.find { |f| f[:name] == "README.md" }
        src_dir = files.find { |f| f[:name] == "src" }

        readme_file.should_not be_nil
        src_dir.should_not be_nil

        if readme_file && src_dir
          readme_file[:type].should eq("blob")
          src_dir[:type].should eq("tree")
        end
      end
    end

    it "handles repository names with .git extension" do
      files = Crit::Services::RepoService.list_files("test.git", "master")
      files.should_not be_nil

      if files
        file_names = files.map { |f| f[:name] }
        file_names.should contain("README.md")
        file_names.should contain("src")

        # Verify the types
        readme_file = files.find { |f| f[:name] == "README.md" }
        src_dir = files.find { |f| f[:name] == "src" }

        readme_file.should_not be_nil
        src_dir.should_not be_nil

        if readme_file && src_dir
          readme_file[:type].should eq("blob")
          src_dir[:type].should eq("tree")
        end
      end
    end

    it "returns files in a subdirectory" do
      files = Crit::Services::RepoService.list_files("test", "master", "src")
      files.should_not be_nil

      if files
        file_names = files.map { |f| f[:name] }
        file_names.should contain("main.cr")
      end
    end

    it "returns nil for non-existent repository" do
      files = Crit::Services::RepoService.list_files("nonexistent", "master")
      files.should be_nil
    end
  end

  describe ".get_file_content" do
    it "returns content of a file" do
      content = Crit::Services::RepoService.get_file_content("test", "master", "README.md")
      content.should_not be_nil

      if content
        content.should contain("# Test Repository")
      end
    end

    it "handles repository names with .git extension" do
      content = Crit::Services::RepoService.get_file_content("test.git", "master", "README.md")
      content.should_not be_nil

      if content
        content.should contain("# Test Repository")
      end
    end

    it "returns nil for non-existent file" do
      content = Crit::Services::RepoService.get_file_content("test", "master", "nonexistent.txt")
      content.should be_nil
    end
  end

  describe ".list_branches" do
    it "returns list of branches" do
      branches = Crit::Services::RepoService.list_branches("test")
      branches.should_not be_empty
      branches.should contain("master")
    end

    it "handles repository names with .git extension" do
      branches = Crit::Services::RepoService.list_branches("test.git")
      branches.should_not be_empty
      branches.should contain("master")
    end

    it "returns empty array for non-existent repository" do
      branches = Crit::Services::RepoService.list_branches("nonexistent")
      branches.should be_empty
    end
  end
end
