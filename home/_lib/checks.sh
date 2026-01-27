# -------------------------------------------------------------------
# PURPOSE:
#   Small predicate helpers for environment and platform checks
#   used by chezmoi run_* scripts.
#
# SCOPE:
#   - Sourced by scripts in .chezmoiscripts/
#   - No execution logic
#
# BEHAVIOUR:
#   - Pure functions
#   - Return 0 (true) or 1 (false)
#   - No logging
#   - No exits
# -------------------------------------------------------------------

is_macos() {
  [ "$(uname -s)" = "Darwin" ]
}

is_linux() {
  [ "$(uname -s)" = "Linux" ]
}

is_arm64() {
  [ "$(uname -m)" = "arm64" ]
}

is_intel() {
  [ "$(uname -m)" = "x86_64" ]
}

is_rosetta() {
  sysctl -n sysctl.proc_translated 2>/dev/null | grep -q 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

file_exists() {
  [ -f "$1" ]
}

dir_exists() {
  [ -d "$1" ]
}
