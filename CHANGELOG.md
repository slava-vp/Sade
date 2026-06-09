# Changelog

## v0.8 (06.09.2026)

### Added:
  - internal error log
    - #set internal_error_log (on/off)
      - wraps code execution in a try/catch for internal error logging
  - wrap for console
  - cyclic processing of arrays
  - the editor preserves indents
  - backspace now removes 4 spaces
  - true/false as 1/0
  - the brackets are automatically closed
  - automatically insert four spaces after curly braces
  - chr function
  - added transition to a specific line via Ctrl+G
  - search in code via Ctrl+F
  - the editor can now be expanded to full screen
  - paired lighting ( { [
  - array methods:
    - sort
    - reverse
    - find
    - join
    - clear
    - set_len
    - create
    - cat
    - shuffle
    - min
    - max
    - unique
    - sum
    - avg
  - string methods:
    - split
    - upper
    - lower
    - trim
    - replace
    - del
    - shuffle
    - rev
    - repeat
  - method hints in the editor

### Fixed:
  - multidimensional arrays
  - numbers in multidimensional arrays were strings
  - negative numbers now work correctly
  - negative step in for loops
  - unary minus detection in lexer
  - get_value for numeric strings
  - token_is_* utility functions
  - incorrect build of code for launch
  - the missing //= operator
  - double-draw the scrollbar in File Manager
  - scrolling in the file manager
  - fixed the "continue" keyword for loops
  - range-based loops
  - horizontal and vertical scrolling worked simultaneously
  - when scrolling while selecting, the editor colored the text blue
  - no console when opening the editor
  - no first console output

### Other:
  - names for snippets
  - the line number in the editor starts with 1
  - the file manager is no longer drawn as a GUI
  - the editor depth changes depending on the fullscreen
  - warp strings in the console are disabled by default
  - new version names are x1.x2, where x1 is the major release, x2 is the minor release.
  - code execution time

## v0.0.7 (06.05.2026)

### Added:
  - preprocessor
  - - #include
  - - #include once
  - - #set
  - - - auto_include_once on/off
  - - - unknown_is_zero on/off

### Fixed:
  - token_is_real 'for' cycle
  - editor autocomplete
  - crashes when deleting a file
  - crashes when inserting and renaming a file
  - inserting a file did not update the directory contents
  - extension of the generated code file (from .sade to .sadel)

### Other:
  - lexer now ignores the "#" symbol
  - the context menu, called by right-clicking in the file manager, appears next to the cursor
  - compilation settings are now a structure and can be changed from code

## v0.0.6 (06.04.2026)

### Added:
  - editor

## V0.0.5 (06.01.2026)

### Added:
  - builtin methods
  - testes (Methods overwrite the state of a variable)

## v0.0.4 (05.31.2026)

### Added:
  - arrays
  - logical operators
  - for cycle

### Other:
  - small code rebase

## v0.0.3 (05.30.2026)

### Added:
  - calculations
  - increment, decrement

## v0.0.2 (05.30.2026)

### Added:
  - user-defined functions

### Fixed:
  - if-else statement
