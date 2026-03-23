# frozen_string_literal: true

module Fission
  # Combines multiple GcodeFile objects into a single G-code program.
  #
  # Two modes:
  #   - tool_change: concatenates bodies, using the first file's header and last file's footer
  #   - fourth_axis: like tool_change, but inserts A-axis rotation commands between setups
  class Combiner
    attr_reader :files, :mode, :rotations

    # @param files [Array<GcodeFile>] ordered list of G-code files to combine
    # @param mode [Symbol] :tool_change or :fourth_axis
    # @param rotations [Array<Numeric>] A-axis angles (degrees) to insert between setups
    #   (only used in :fourth_axis mode, length must equal files.length - 1)
    def initialize(files, mode: :tool_change, rotations: [])
      @files = files
      @mode = mode
      @rotations = rotations

      validate!
    end

    def combine
      lines = []

      # Use header from the first file
      lines.concat(files.first.header)

      files.each_with_index do |file, index|
        # Insert rotation before each file after the first (fourth_axis mode)
        if mode == :fourth_axis && index > 0
          angle = rotations[index - 1]
          lines << ""
          lines << "(--- Rotate A-axis to #{angle} degrees ---)"
          lines << "M5"                         # stop spindle before rotation
          lines << "G0 Z10"                     # retract Z to safe height
          lines << "G0 A#{format_angle(angle)}" # rotate 4th axis
          lines << ""
        end

        # Add a comment showing which file this section came from
        lines << ""
        lines << "(--- Begin: #{file.filename} ---)"
        lines.concat(file.body)
        lines << "(--- End: #{file.filename} ---)"
      end

      # Use footer from the last file
      lines.concat(files.last.footer)

      lines.join("\n") + "\n"
    end

    private

    def validate!
      raise Error, "At least two files are required" if files.length < 2

      if mode == :fourth_axis
        expected = files.length - 1
        if rotations.length != expected
          raise Error, "Expected #{expected} rotation(s) for #{files.length} files, got #{rotations.length}"
        end
      end
    end

    def format_angle(angle)
      angle == angle.to_i ? angle.to_i.to_s : format("%.3f", angle)
    end
  end
end
