require "./spec_helper"

describe Crit do
  describe "Configuration" do
    it "loads default configuration values" do
      Crit::Config::USERNAME.should eq("admin") unless ENV.has_key?("CRIT_USER")
      Crit::Config::PASSWORD.should eq("yourpassword") unless ENV.has_key?("CRIT_PASS")
      Crit::Config::REPO_ROOT.should eq("./repos") unless ENV.has_key?("CRIT_REPO_ROOT")
    end
  end

  describe "Integration" do
    it "initializes repository directory on startup" do
      # This test relies on the fact that spec_helper requires crit,
      # which calls Crit::Models::Repository.ensure_repo_dir
      Crit::Models::Repository.ensure_repo_dir
      Dir.exists?(Crit::Config::REPO_ROOT).should be_true
    end
  end
end
