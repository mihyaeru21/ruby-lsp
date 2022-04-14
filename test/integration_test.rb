# frozen_string_literal: true

require "test_helper"
require "open3"

class IntegrationTest < Minitest::Test

  Interface = LanguageServer::Protocol::Interface
  Constant = LanguageServer::Protocol::Constant
  Transport = LanguageServer::Protocol::Transport
  
  def setup
    run_lsp
  end

  def teardown
    Process.kill("SIGTERM", @pid)
  end

  def test_cli
    assert_equal "Starting Ruby LSP...\n", @stderr.gets
    @stdin.write(json)
    @stdin.flush
    assert_equal "", @stderr.read
  end


  def run_lsp
    Bundler.with_unbundled_env do
      stdin, stdout, stderr, wait_thr = Open3.popen3("bundle exec ruby-lsp")
      @stdin = stdin
      @stdout = stdout
      @stderr = stderr
      @pid = wait_thr[:pid]
    end
  end

  def json
      "Content-Length: 52\r\n\r\n{\"jsonrpc\":\"2.0\",\"method\":\"initialized\",\"params\":{}}"
  end
end