## WARNING: Alpha Software
This code is a hobby project, WIP, and should be considered alpha software at best. It may not even work and hasn't been tested. Like any NC code, its output should be verified witha simulator and/or on your machine before trusting the code.

# Fission

Fission combines separate [Fusion 360](https://www.autodesk.com/products/fusion-360) CNC files into a single G-code program for the [Makera Carvera](https://www.makera.com/).

The free version of Fusion 360 doesn't support tool changers or 4th axis machining. Fission works around these limitations by stitching together multiple setups into one program that's ready to send to your Carvera.

## What It Does

**Tool changes** — Combine multiple Fusion setups that use different tools into a single file. Fission strips the duplicate headers and footers and produces a unified program with proper tool change commands (`T<n> M6`).

**4th axis rotations** — Combine setups with A-axis rotations in between. Fission inserts the rotation commands (`G0 A<angle>`) with automatic spindle stop and Z retract for safety, so you can machine multiple faces of a part without manually editing G-code.

## Installation

This gem is not yet on Rubygems. You have to build and install it locally:

```bash
# from the gem's root directory:
gem build fission.gemspec
gem install fission-0.1.0.gemspec

```

## Usage

### Combining with tool changes

Merge two or more setups into one program. The files are concatenated in order, keeping the header from the first file and the footer from the last.

```bash
fission combine roughing.nc finishing.nc
```

Write to a file instead of stdout:

```bash
fission combine -o merged.nc roughing.nc finishing.nc
```

Works with any number of files:

```bash
fission combine -o merged.nc op1.nc op2.nc op3.nc op4.nc
```

### Combining with 4th axis rotations

Arguments are a free-form mix of files and angles. Numbers are rotation commands; everything else is a file. You can have multiple files between rotations (e.g. rough + finish the same face before rotating):

```bash
# One file per face
fission rotate -o part.nc front.nc 90 right.nc 180 back.nc 270 left.nc

# Multiple operations per face
fission rotate -o part.nc front_rough.nc front_finish.nc 90 right_rough.nc right_finish.nc

# Decimal angles
fission rotate -o part.nc front.nc 45.5 angled.nc
```

Each angle inserts:
1. `M5` — stop spindle
2. `G0 Z10` — retract Z to safe height
3. `G0 A<angle>` — rotate 4th axis

### Options

```
-o, --output FILE    Write output to a file (default: stdout)
-h, --help           Show help
-v, --version        Show version
```

## Validation
Fission does some basic validation checks of the files. It is not a fully featured validator, and is only to be used as a sanity check to make sure nothing obvious is wrong. Validation includes:

-- insert validation details here --

## Workflow

A typical workflow looks like this:

1. Design your part in Fusion 360
2. Create separate Manufacturing setups for each tool or each face of the part
3. Post-process each setup individually using the Carvera post processor, producing separate `.nc` files
4. Use Fission to combine them into a single program
5. Upload the combined file to your Carvera

## How It Works

Fission parses each G-code file into three sections:

- **Header** — Setup commands (G90, G17, G21, coordinate system, etc.)
- **Body** — Tool calls, spindle commands, and cutting moves
- **Footer** — Spindle stop, retract, and program end (M30)

When combining, it keeps the first file's header and last file's footer, concatenating the bodies. In 4th axis mode, it inserts safety commands (M5 spindle stop, G0 Z10 retract) and the A-axis rotation between each body.
