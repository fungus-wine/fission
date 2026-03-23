# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Fission is a Ruby gem CLI tool that combines separate Fusion 360 CNC (G-code) files into a single program for the Makera Carvera CNC machine. It exists because the free version of Fusion 360 doesn't support tool changers or 4th axis machining.

Two modes:
- **combine** (tool change): Concatenates G-code files, stripping duplicate headers/footers into a unified program
- **rotate** (4th axis): Like combine, but inserts A-axis rotation commands (`G0 A<angle>`) between setups, with spindle stop and Z retract for safety

## Commands

```bash
bundle exec rake test        # run all tests
bundle exec ruby -Ilib:test test/test_combiner.rb  # run a single test file
bundle exec ruby -Ilib:test test/test_combiner.rb -n test_combine_tool_change_includes_both_bodies  # run a single test
```

## Architecture

The gem has three core classes under `lib/fission/`:

- **GcodeFile** (`gcode_file.rb`) — Parses a Fusion 360 G-code file into `header`, `body`, and `footer` arrays. Header/footer detection uses regex patterns matching G-code conventions (G17, G21, G90, M30, etc.). The boundary between header and body is the first tool call or spindle command (T/M lines).

- **Combiner** (`combiner.rb`) — Takes an array of GcodeFile objects and produces a single combined G-code string. Uses the first file's header and last file's footer. In `:fourth_axis` mode, inserts M5 (spindle stop), Z retract, and `G0 A<angle>` between each file's body.

- **CLI** (`cli.rb`) — Parses argv into commands. `combine FILE1 FILE2 ...` for tool changes. `rotate FILE1 ANGLE1 FILE2 ...` for 4th axis (alternating file/angle args). Output goes to stdout by default or to a file with `-o`.

## Carvera G-code Notes

- Tool changes: `T1 M6` format. Tools 1-6 use the automatic tool changer; 7-99 trigger manual tool change.
- 4th axis: `G0 A<degrees>` for rapid rotation. Always stop spindle (M5) and retract Z before rotating.
- Program end: `M30`. Program delimiter: `%`.
- The Carvera uses GRBL-based G-code. Files are uploaded to the machine, not streamed.

## Test Fixtures

`test/fixtures/` contains sample `.nc` files (roughing.nc, finishing.nc, third_op.nc) that mimic Fusion 360 Carvera post-processor output structure.
