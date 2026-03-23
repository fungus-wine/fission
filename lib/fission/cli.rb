# frozen_string_literal: true

module Fission
  class CLI
    USAGE = <<~TEXT
      Usage:
        fission combine [options] FILE1 FILE2 [FILE3 ...]
        fission rotate  [options] FILE1 [FILE2 ...] ANGLE1 FILE3 [FILE4 ...] [ANGLE2 FILE5 ...]

      Commands:
        combine    Combine multiple CNC files with tool changes
        rotate     Combine CNC files with 4th axis (A-axis) rotations between setups

      Options:
        -o, --output FILE    Output file (default: stdout)
        -h, --help           Show this help message
        -v, --version        Show version

      Examples:
        fission combine -o merged.nc roughing.nc finishing.nc
        fission rotate -o part.nc front.nc 90 right.nc 180 back.nc
        fission rotate -o part.nc rough.nc finish.nc 90 side_rough.nc side_finish.nc
    TEXT

    def initialize(argv)
      @argv = argv.dup
    end

    def run
      if @argv.empty? || @argv.include?("-h") || @argv.include?("--help")
        puts USAGE
        return 0
      end

      if @argv.include?("-v") || @argv.include?("--version")
        puts "fission #{Fission::VERSION}"
        return 0
      end

      output_file = extract_output_option

      command = @argv.shift
      case command
      when "combine"
        run_combine(output_file)
      when "rotate"
        run_rotate(output_file)
      else
        $stderr.puts "Unknown command: #{command}"
        $stderr.puts USAGE
        1
      end
    rescue Fission::Error => e
      $stderr.puts "Error: #{e.message}"
      1
    rescue Errno::ENOENT => e
      $stderr.puts "Error: #{e.message}"
      1
    end

    private

    def extract_output_option
      output_file = nil
      idx = @argv.index("-o") || @argv.index("--output")
      if idx
        @argv.delete_at(idx)
        output_file = @argv.delete_at(idx)
        raise Error, "Missing output filename after -o/--output" unless output_file
      end
      output_file
    end

    def run_combine(output_file)
      if @argv.length < 2
        $stderr.puts "Error: combine requires at least two files"
        $stderr.puts USAGE
        return 1
      end

      steps = @argv.map { |path| GcodeFile.new(path) }
      result = Combiner.new(steps).combine
      write_output(result, output_file)
      0
    end

    def run_rotate(output_file)
      if @argv.length < 3
        $stderr.puts "Error: rotate requires at least two files with an angle between them"
        $stderr.puts USAGE
        return 1
      end

      steps = parse_rotate_args(@argv)
      result = Combiner.new(steps).combine
      write_output(result, output_file)
      0
    end

    # Parses a free-form mix of files and angles.
    # Numbers are treated as angles, everything else as a file path.
    def parse_rotate_args(args)
      steps = args.map do |arg|
        if arg.match?(/\A-?\d+(\.\d+)?\z/)
          Float(arg)
        else
          GcodeFile.new(arg)
        end
      end

      files = steps.select { |s| s.is_a?(GcodeFile) }
      raise Error, "rotate requires at least two files" if files.length < 2

      angles = steps.select { |s| s.is_a?(Numeric) }
      raise Error, "rotate requires at least one angle" if angles.empty?

      steps
    end

    def write_output(content, output_file)
      if output_file
        File.write(output_file, content)
        $stderr.puts "Wrote #{output_file}"
      else
        puts content
      end
    end
  end
end
