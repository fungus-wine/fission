# frozen_string_literal: true

module Fission
  class CLI
    USAGE = <<~TEXT
      Usage:
        fission combine [options] FILE1 FILE2 [FILE3 ...]
        fission rotate  [options] FILE1 ANGLE1 FILE2 [ANGLE2 FILE3 ...]

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

      files = @argv.map { |path| GcodeFile.new(path) }
      result = Combiner.new(files, mode: :tool_change).combine
      write_output(result, output_file)
      0
    end

    def run_rotate(output_file)
      if @argv.length < 3
        $stderr.puts "Error: rotate requires at least two files with an angle between them"
        $stderr.puts USAGE
        return 1
      end

      files, rotations = parse_rotate_args(@argv)
      result = Combiner.new(files, mode: :fourth_axis, rotations: rotations).combine
      write_output(result, output_file)
      0
    end

    # Parses alternating file/angle arguments: FILE1 ANGLE1 FILE2 [ANGLE2 FILE3 ...]
    def parse_rotate_args(args)
      files = []
      rotations = []

      args.each_with_index do |arg, i|
        if i.even?
          files << GcodeFile.new(arg)
        else
          rotations << Float(arg)
        end
      end

      if files.length < 2
        raise Error, "rotate requires at least two files"
      end

      if rotations.length != files.length - 1
        raise Error, "Expected #{files.length - 1} angle(s) between #{files.length} files"
      end

      [files, rotations]
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
