# frozen_string_literal: true

require "test_helper"

class TestCLI < Minitest::Test
  include FixtureHelper

  def test_help_flag
    out, = capture_io { @status = Fission::CLI.new(["--help"]).run }
    assert_equal 0, @status
    assert_includes out, "Usage:"
    assert_includes out, "combine"
    assert_includes out, "rotate"
  end

  def test_version_flag
    out, = capture_io { @status = Fission::CLI.new(["--version"]).run }
    assert_equal 0, @status
    assert_includes out, Fission::VERSION
  end

  def test_no_args_shows_help
    out, = capture_io { @status = Fission::CLI.new([]).run }
    assert_equal 0, @status
    assert_includes out, "Usage:"
  end

  def test_unknown_command
    _, err = capture_io { @status = Fission::CLI.new(["bogus"]).run }
    assert_equal 1, @status
    assert_includes err, "Unknown command"
  end

  def test_combine_to_stdout
    out, = capture_io do
      @status = Fission::CLI.new([
        "combine",
        fixture_path("roughing.nc"),
        fixture_path("finishing.nc")
      ]).run
    end
    assert_equal 0, @status
    assert_includes out, "T1 M6"
    assert_includes out, "T2 M6"
  end

  def test_combine_to_file
    Dir.mktmpdir do |dir|
      output = File.join(dir, "out.nc")
      _, err = capture_io do
        @status = Fission::CLI.new([
          "combine",
          "-o", output,
          fixture_path("roughing.nc"),
          fixture_path("finishing.nc")
        ]).run
      end
      assert_equal 0, @status
      assert File.exist?(output)
      content = File.read(output)
      assert_includes content, "T1 M6"
      assert_includes content, "T2 M6"
      assert_includes err, "Wrote #{output}"
    end
  end

  def test_combine_requires_two_files
    _, err = capture_io do
      @status = Fission::CLI.new([
        "combine",
        fixture_path("roughing.nc")
      ]).run
    end
    assert_equal 1, @status
    assert_includes err, "at least two files"
  end

  def test_rotate_to_stdout
    out, = capture_io do
      @status = Fission::CLI.new([
        "rotate",
        fixture_path("roughing.nc"),
        "90",
        fixture_path("finishing.nc")
      ]).run
    end
    assert_equal 0, @status
    assert_includes out, "G0 A90"
  end

  def test_rotate_multiple_files_between_angles
    out, = capture_io do
      @status = Fission::CLI.new([
        "rotate",
        fixture_path("roughing.nc"),
        fixture_path("finishing.nc"),
        "90",
        fixture_path("third_op.nc")
      ]).run
    end
    assert_equal 0, @status
    assert_includes out, "T1 M6"
    assert_includes out, "T2 M6"
    assert_includes out, "G0 A90"
    assert_includes out, "T3 M6"
  end

  def test_rotate_multiple_angles
    out, = capture_io do
      @status = Fission::CLI.new([
        "rotate",
        fixture_path("roughing.nc"),
        "90",
        fixture_path("finishing.nc"),
        "180",
        fixture_path("third_op.nc")
      ]).run
    end
    assert_equal 0, @status
    assert_includes out, "G0 A90"
    assert_includes out, "G0 A180"
  end

  def test_rotate_requires_minimum_args
    _, err = capture_io do
      @status = Fission::CLI.new([
        "rotate",
        fixture_path("roughing.nc")
      ]).run
    end
    assert_equal 1, @status
    assert_includes err, "at least two files"
  end

  def test_missing_file
    _, err = capture_io do
      @status = Fission::CLI.new([
        "combine",
        "nonexistent1.nc",
        "nonexistent2.nc"
      ]).run
    end
    assert_equal 1, @status
    assert_includes err, "Error:"
  end
end
