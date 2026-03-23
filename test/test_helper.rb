# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "fission"

require "minitest/autorun"
require "tmpdir"

module FixtureHelper
  def fixture_path(name)
    File.join(File.dirname(__FILE__), "fixtures", name)
  end
end
