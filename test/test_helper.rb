# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "fission"

require "minitest/autorun"
require "tmpdir"

module FixtureHelper
  def fixture_path(name)
    File.join(__dir__, "fixtures", name)
  end
end
