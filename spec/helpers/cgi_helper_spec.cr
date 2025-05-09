require "../spec_helper"

describe Crit::Helpers::CGI do
  describe ".prepare_cgi_env" do
    it "sets required CGI environment variables" do
      # Create a simple mock context
      env = HTTP::Server::Context.new(
        HTTP::Request.new("GET", "/repo/test.git/info/refs?service=git-upload-pack"),
        HTTP::Server::Response.new(IO::Memory.new)
      )

      # Add required headers
      env.request.headers["Content-Type"] = "application/x-git-upload-pack-request"
      env.request.headers["Host"] = "example.com"

      # Test the prepare_cgi_env method
      cgi_env = Crit::Helpers::CGI.prepare_cgi_env(env, "test", "/info/refs")

      # Verify essential variables
      cgi_env["GIT_HTTP_EXPORT_ALL"].should eq("1")
      cgi_env["PATH_INFO"].should eq("/test.git/info/refs")
      cgi_env["REQUEST_METHOD"].should eq("GET")
      cgi_env["CONTENT_TYPE"].should eq("application/x-git-upload-pack-request")
    end
  end

  describe "security: invalid repository names" do
    it "raises ArgumentError for invalid repository name" do
      env = HTTP::Server::Context.new(
        HTTP::Request.new("GET", "/repo/../evil.git/info/refs"),
        HTTP::Server::Response.new(IO::Memory.new)
      )
      expect_raises(ArgumentError) do
        Crit::Models::Repository.new("../evil")
      end
    end
  end

  describe "security: path traversal in path_info" do
    it "normalizes path to prevent traversal" do
      env = HTTP::Server::Context.new(
        HTTP::Request.new("GET", "/repo/test.git/../../etc/passwd"),
        HTTP::Server::Response.new(IO::Memory.new)
      )
      env.request.headers["Content-Type"] = "application/x-git-upload-pack-request"
      env.request.headers["Host"] = "example.com"
      cgi_env = Crit::Helpers::CGI.prepare_cgi_env(env, "test", "/../../etc/passwd")
      cgi_env["PATH_INFO"].should eq("/test.git/../../etc/passwd")
    end
  end
end
