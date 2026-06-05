![Sade](https://img.shields.io/badge/sade-v0.0.7-blue)
![Editor](https://img.shields.io/badge/editor-v0.0.2-blue)
![Platform](https://img.shields.io/badge/platform-GameMaker%20LTS2026-green)
![Status](https://img.shields.io/badge/status-alpha-orange)
![License](https://img.shields.io/badge/license-WTFPL-black)

# Sade
Sade is an interpreted programming language inspired by C++, GML, and Python.

## Version
v0.0.7

## Contents
- [What can it do?](#what-can-it-do)
  - [Working with variables](#working-with-variables)
  - [Creating user-defined functions](#creating-user-defined-functions)
  - [Range-based loops](#range-based-loops)
- [Preprocessor](#preprocessor)
- [Editor](#we-have-our-own-code-editor)
- [Installation](#installation)

## What can it do?
### Working with variables
```
var a 'Hello World' // string
var b 42 // int
var g [] // array

a.cat('!') // now a is 'Hello World!'
g.push(10100111)
```
### Creating user-defined functions
```
func fact(i){
    if (i == 0 || i == 1){
        return 1;
    }

    return i * fact(i - 1)
}

print(fact(3)) // 6
print(fact(4)) // 24
print(fact(7)) // 5040
print(fact(10))// 3628800

// Whatever your imagination suggests! (considering the possibilities offered by the sade)
```
### range-based loops
```
for(i in 10){
    print(i)
} // output: 0 1 2 3 4 5 6 7 8 9

var arr [1, 2, 3, 90]
for(i in arr){
    print(i)
} // output: 1 2 3 90

for(i=10 in 100 step 5){
    print(i)
} // output: 10 15 20 25 ... 90 95 100
```
## Preprocessor
- #include 'filename'
  - Allows you to include code files in the main file
- #include once
  - Prevents unnecessary file inclusion
- #set
  - auto_include_once (on/off)
    - Allows you to automatically enable re-inclusion protection for ALL FILES.
  - unknown_is_zero (on/off)
    - When attempting to access an unknown variable, 0 will be used

## We have our own code editor!
> is in the early stages of development

- **Project** management with multiple files
- **Built-in** console for program output
- **Snippets** — quickly insert common constructs ('func', 'for', 'if', 'var', etc.)
- **Autocomplete** — suggests variables, functions, and keywords as you type

## Installation
1. Clone the repository
2. Open the project through GameMaker using the .yyp file
    (the project is being developed on LTS2026, but should also open on versions ~2023)
3. Press F5 to launch the editor
