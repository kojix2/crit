require "./spec_helper"

describe Gcirt do
  describe "Configuration" do
    it "loads default configuration values" do
      Gcirt::Config::USERNAME.should eq("admin") unless ENV.has_key?("GCIRT_USER")
      Gcirt::Config::PASSWORD.should eq("yourpassword") unless ENV.has_key?("GCIRT_PASS")
      Gcirt::Config::REPO_ROOT.should eq("./repos") unless ENV.has_key?("GCIRT_REPO_ROOT")
    end
  end

  describe "Integration" do
    it "initializes repository directory on startup" do
      # This test relies on the fact that spec_helper requires gcirt,
      # which calls Gcirt::Models::Repository.ensure_repo_dir
      Dir.exists?(Gcirt::Config::REPO_ROOT).should be_true
    end
  end
end
