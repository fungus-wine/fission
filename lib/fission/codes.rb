# frozen_string_literal: true

module Fission
  module Codes
    Code = Struct.new(:name, :syntax, :description, keyword_init: true)

    G_CODES = [
      # Motion
      Code.new(name: "G0",    syntax: "G0 [X_ Y_ Z_ A_]",       description: "Rapid positioning"),
      Code.new(name: "G1",    syntax: "G1 [X_ Y_ Z_ A_] F_",    description: "Linear interpolation (cutting move)"),
      Code.new(name: "G2",    syntax: "G2 [X_ Y_ Z_] [I_ J_|R_] F_", description: "Circular interpolation, clockwise"),
      Code.new(name: "G3",    syntax: "G3 [X_ Y_ Z_] [I_ J_|R_] F_", description: "Circular interpolation, counter-clockwise"),
      Code.new(name: "G4",    syntax: "G4 P_",                   description: "Dwell (pause for P seconds)"),

      # Coordinate system setup
      Code.new(name: "G10",   syntax: "G10 L2|L20 P_ [X_ Y_ Z_]", description: "Set work coordinate system offset"),

      # Plane selection
      Code.new(name: "G17",   syntax: "G17",                     description: "Select XY plane"),
      Code.new(name: "G18",   syntax: "G18",                     description: "Select XZ plane"),
      Code.new(name: "G19",   syntax: "G19",                     description: "Select YZ plane"),

      # Units
      Code.new(name: "G20",   syntax: "G20",                     description: "Inch units"),
      Code.new(name: "G21",   syntax: "G21",                     description: "Millimeter units"),

      # Homing
      Code.new(name: "G28",   syntax: "G28 [X_ Y_ Z_]",         description: "Return to home position"),
      Code.new(name: "G28.1", syntax: "G28.1",                   description: "Set home position"),
      Code.new(name: "G30",   syntax: "G30 [X_ Y_ Z_]",         description: "Return to second home position"),
      Code.new(name: "G30.1", syntax: "G30.1",                   description: "Set second home position"),

      # Probing
      Code.new(name: "G38.2", syntax: "G38.2 [X_ Y_ Z_] F_",   description: "Probe toward workpiece, error if no contact"),
      Code.new(name: "G38.3", syntax: "G38.3 [X_ Y_ Z_] F_",   description: "Probe toward workpiece, no error if no contact"),
      Code.new(name: "G38.4", syntax: "G38.4 [X_ Y_ Z_] F_",   description: "Probe away from workpiece, error if no loss of contact"),
      Code.new(name: "G38.5", syntax: "G38.5 [X_ Y_ Z_] F_",   description: "Probe away from workpiece, no error if no loss of contact"),

      # Cutter compensation
      Code.new(name: "G40",   syntax: "G40",                     description: "Cancel cutter radius compensation"),

      # Tool length compensation
      Code.new(name: "G43",   syntax: "G43 H_",                  description: "Tool length compensation, positive"),
      Code.new(name: "G43.1", syntax: "G43.1 Z_",               description: "Dynamic tool length offset"),
      Code.new(name: "G49",   syntax: "G49",                     description: "Cancel tool length compensation"),

      # Machine coordinates
      Code.new(name: "G53",   syntax: "G53 [G0|G1] [X_ Y_ Z_]", description: "Move in machine coordinates (non-modal)"),

      # Work coordinate systems
      Code.new(name: "G54",   syntax: "G54",                     description: "Work coordinate system 1"),
      Code.new(name: "G55",   syntax: "G55",                     description: "Work coordinate system 2"),
      Code.new(name: "G56",   syntax: "G56",                     description: "Work coordinate system 3"),
      Code.new(name: "G57",   syntax: "G57",                     description: "Work coordinate system 4"),
      Code.new(name: "G58",   syntax: "G58",                     description: "Work coordinate system 5"),
      Code.new(name: "G59",   syntax: "G59",                     description: "Work coordinate system 6"),

      # Canned drilling cycles
      Code.new(name: "G73",   syntax: "G73 X_ Y_ Z_ R_ Q_ F_",  description: "High-speed peck drilling (chip breaking)"),
      Code.new(name: "G80",   syntax: "G80",                     description: "Cancel canned cycle"),
      Code.new(name: "G81",   syntax: "G81 X_ Y_ Z_ R_ F_",     description: "Simple drilling cycle"),
      Code.new(name: "G82",   syntax: "G82 X_ Y_ Z_ R_ P_ F_",  description: "Drilling cycle with dwell at bottom"),
      Code.new(name: "G83",   syntax: "G83 X_ Y_ Z_ R_ Q_ F_",  description: "Deep hole peck drilling (full retract)"),

      # Distance mode
      Code.new(name: "G90",   syntax: "G90",                     description: "Absolute distance mode"),
      Code.new(name: "G91",   syntax: "G91",                     description: "Incremental distance mode"),
      Code.new(name: "G91.1", syntax: "G91.1",                   description: "Incremental arc distance mode (IJ relative)"),

      # Coordinate system offset
      Code.new(name: "G92",   syntax: "G92 [X_ Y_ Z_]",         description: "Set coordinate system offset"),
      Code.new(name: "G92.1", syntax: "G92.1",                   description: "Clear G92 offsets"),

      # Feed rate mode
      Code.new(name: "G93",   syntax: "G93",                     description: "Inverse time feed rate mode"),
      Code.new(name: "G94",   syntax: "G94",                     description: "Units per minute feed rate mode"),
    ].freeze

    M_CODES = [
      # Program control
      Code.new(name: "M0",  syntax: "M0",           description: "Program pause (wait for resume)"),
      Code.new(name: "M1",  syntax: "M1",           description: "Optional program pause"),
      Code.new(name: "M2",  syntax: "M2",           description: "Program end"),

      # Spindle
      Code.new(name: "M3",  syntax: "M3 S_",        description: "Spindle on, clockwise"),
      Code.new(name: "M4",  syntax: "M4 S_",        description: "Spindle on, counter-clockwise"),
      Code.new(name: "M5",  syntax: "M5",           description: "Spindle stop"),

      # Tool change
      Code.new(name: "M6",  syntax: "T_ M6",        description: "Tool change (T1-T6 ATC, T7+ manual)"),

      # Air blast
      Code.new(name: "M7",  syntax: "M7",           description: "Mist coolant / air blast on"),
      Code.new(name: "M8",  syntax: "M8",           description: "Flood coolant / air blast on"),
      Code.new(name: "M9",  syntax: "M9",           description: "Coolant off"),

      # Vacuum
      Code.new(name: "M10", syntax: "M10",          description: "Vacuum / dust collection on"),
      Code.new(name: "M11", syntax: "M11",          description: "Vacuum / dust collection off"),

      # Program end
      Code.new(name: "M30", syntax: "M30",          description: "Program end and rewind"),

      # Carvera-specific
      Code.new(name: "M37", syntax: "M37",          description: "Automatic tool length measurement"),
      Code.new(name: "M40", syntax: "M40",          description: "Z-axis probe / touch-off"),

      # Overrides
      Code.new(name: "M48", syntax: "M48",          description: "Enable feed rate and spindle overrides"),
      Code.new(name: "M49", syntax: "M49",          description: "Disable feed rate and spindle overrides"),
    ].freeze

    def self.print
      name_width = 6
      syntax_width = (G_CODES + M_CODES).map { |c| c.syntax.length }.max + 2

      puts "Supported Carvera G-codes:"
      puts "-" * (name_width + syntax_width + 40)
      G_CODES.each do |code|
        puts "  %-#{name_width}s %-#{syntax_width}s %s" % [code.name, code.syntax, code.description]
      end

      puts
      puts "Supported Carvera M-codes:"
      puts "-" * (name_width + syntax_width + 40)
      M_CODES.each do |code|
        puts "  %-#{name_width}s %-#{syntax_width}s %s" % [code.name, code.syntax, code.description]
      end
    end
  end
end
