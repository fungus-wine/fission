# frozen_string_literal: true

module Fission
  # Combines multiple GcodeFile objects into a single G-code program.
  #
  # Accepts an ordered list of steps — each is either a GcodeFile or a numeric
  # angle (for A-axis rotation). Files are concatenated with the first file's
  # header and last file's footer. Rotation angles insert spindle stop, Z retract,
  # and G0 A<angle> commands between file bodies.
  class Combiner
    attr_reader :steps

    # @param steps [Array<GcodeFile, Numeric>] ordered mix of files and rotation angles
    def initialize(steps)
      @steps = steps
      validate!
    end

    def combine
      lines = []
      files = @steps.select { |s| s.is_a?(GcodeFile) }

      # Use header from the first file
      lines.concat(files.first.header)

      @steps.each do |step|
        if step.is_a?(GcodeFile)
          lines << ""
          lines << "(--- Begin: #{step.filename} ---)"
          lines.concat(step.body)
          lines << "(--- End: #{step.filename} ---)"
        else
          angle = step
          lines << ""
          lines << "(--- Rotate A-axis to #{angle} degrees ---)"
          lines << "M5"
          lines << "G0 Z10"
          lines << "G0 A#{format_angle(angle)}"
          lines << ""
        end
      end

      # Use footer from the last file
      lines.concat(files.last.footer)

      lines.join("\n") + "\n"
    end

    private

    def validate!
      files = @steps.select { |s| s.is_a?(GcodeFile) }
      raise Error, "At least two files are required" if files.length < 2

      # Must start and end with a file, not a rotation
      raise Error, "Steps must start with a file, not an angle" unless @steps.first.is_a?(GcodeFile)
      raise Error, "Steps must end with a file, not an angle" unless @steps.last.is_a?(GcodeFile)
    end

    def format_angle(angle)
      angle == angle.to_i ? angle.to_i.to_s : format("%.3f", angle)
    end
  end
end
