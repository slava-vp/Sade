# Changelog

## v0.0.8 (06.07.2026)

### Added:
  - internal error log
    - #set internal_error_log (on/off)
      - wraps code execution in a try/catch for internal error logging
  - wrap for console
  - cyclic processing of arrays
  - the editor preserves indents
  - backspace now removes 4 spaces
  - true/false as 1/0

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

### Other:
  - names for snippets

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
