# frozen_string_literal: true

require "test_helper"

class TestCombiner < Minitest::Test
  include FixtureHelper

  def setup
    @roughing = Fission::GcodeFile.new(fixture_path("roughing.nc"))
    @finishing = Fission::GcodeFile.new(fixture_path("finishing.nc"))
    @third = Fission::GcodeFile.new(fixture_path("third_op.nc"))
  end

  # --- tool_change mode ---

  def test_combine_tool_change_includes_both_bodies
    result = Fission::Combiner.new([@roughing, @finishing], mode: :tool_change).combine
    assert_includes result, "T1 M6"
    assert_includes result, "T2 M6"
  end

  def test_combine_tool_change_uses_first_header
    result = Fission::Combiner.new([@roughing, @finishing], mode: :tool_change).combine
    # Header from roughing (first file) should appear
    assert_includes result, "(roughing)"
  end

  def test_combine_tool_change_has_single_m30
    result = Fission::Combiner.new([@roughing, @finishing], mode: :tool_change).combine
    assert_equal 1, result.scan(/^M30$/i).length
  end

  def test_combine_tool_change_three_files
    result = Fission::Combiner.new([@roughing, @finishing, @third], mode: :tool_change).combine
    assert_includes result, "T1 M6"
    assert_includes result, "T2 M6"
    assert_includes result, "T3 M6"
    assert_equal 1, result.scan(/^M30$/i).length
  end

  def test_combine_tool_change_includes_file_comments
    result = Fission::Combiner.new([@roughing, @finishing], mode: :tool_change).combine
    assert_includes result, "(--- Begin: roughing.nc ---)"
    assert_includes result, "(--- End: roughing.nc ---)"
    assert_includes result, "(--- Begin: finishing.nc ---)"
  end

  # --- fourth_axis mode ---

  def test_combine_fourth_axis_inserts_rotation
    result = Fission::Combiner.new(
      [@roughing, @finishing],
      mode: :fourth_axis,
      rotations: [90]
    ).combine

    assert_includes result, "G0 A90"
    assert_includes result, "Rotate A-axis to 90 degrees"
  end

  def test_combine_fourth_axis_multiple_rotations
    result = Fission::Combiner.new(
      [@roughing, @finishing, @third],
      mode: :fourth_axis,
      rotations: [90, 180]
    ).combine

    assert_includes result, "G0 A90"
    assert_includes result, "G0 A180"
  end

  def test_combine_fourth_axis_stops_spindle_before_rotation
    result = Fission::Combiner.new(
      [@roughing, @finishing],
      mode: :fourth_axis,
      rotations: [90]
    ).combine

    lines = result.lines.map(&:strip)
    rotation_idx = lines.index { |l| l.include?("G0 A90") }
    # Find the M5 that appears before the rotation command
    m5_indices = lines.each_index.select { |i| lines[i] == "M5" }
    spindle_stop_idx = m5_indices.select { |i| i < rotation_idx }.last

    # M5 should appear before the A-axis rotation
    assert spindle_stop_idx, "Expected M5 before rotation"
    assert spindle_stop_idx < rotation_idx
  end

  def test_combine_fourth_axis_retracts_z_before_rotation
    result = Fission::Combiner.new(
      [@roughing, @finishing],
      mode: :fourth_axis,
      rotations: [45.5]
    ).combine

    assert_includes result, "G0 Z10"
    assert_includes result, "G0 A45.500"
  end

  def test_combine_fourth_axis_decimal_formatting
    result = Fission::Combiner.new(
      [@roughing, @finishing],
      mode: :fourth_axis,
      rotations: [90]
    ).combine
    # Integer angles should not have decimal places
    assert_includes result, "G0 A90"
    refute_includes result, "G0 A90.000"
  end

  # --- validation ---

  def test_requires_at_least_two_files
    error = assert_raises(Fission::Error) do
      Fission::Combiner.new([@roughing])
    end
    assert_includes error.message, "At least two files"
  end

  def test_fourth_axis_requires_correct_rotation_count
    error = assert_raises(Fission::Error) do
      Fission::Combiner.new(
        [@roughing, @finishing, @third],
        mode: :fourth_axis,
        rotations: [90]
      )
    end
    assert_includes error.message, "Expected 2 rotation(s)"
  end
end
