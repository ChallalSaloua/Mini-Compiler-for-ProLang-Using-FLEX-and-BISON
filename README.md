# Mini Compiler for ProLang Using FLEX and BISON

## Overview

This project presents the design and implementation of a complete mini-compiler for **ProLang**, a custom programming language developed within the Compilation course at USTHB. The compiler covers the major phases of a traditional compilation process, from lexical analysis to machine code generation.

The implementation relies on the **FLEX** and **BISON** tools for lexical and syntax-directed analysis, while additional modules handle semantic verification, symbol table management, intermediate code generation, optimization, and final assembly code production.

The project aims to provide a practical understanding of compiler construction techniques and language processing systems.

---

## Objectives

The main goals of this project are:

* Design a compiler for the ProLang language.
* Implement lexical analysis using FLEX.
* Implement syntax and semantic analysis using BISON.
* Build and manage a symbol table using hashing techniques.
* Generate intermediate code in quadruplet form.
* Apply intermediate code optimization techniques.
* Generate executable assembly code in Intel 8086 format.
* Detect and report compilation errors with precise diagnostics.

---

## ProLang Language Features

### Program Structure

A ProLang program follows the structure:

```text
BeginProject Project_Name;

Setup :
%% Declarations

Run :
{
    %% Instructions
}

EndProject;
```

The language is divided into two major sections:

* Declaration Section
* Execution Section

---

### Data Types

ProLang supports two primitive data types:

* Integer
* Float

Examples:

```text
define age : integer;
define average : float;

const PI : float = 3.14159;
```

---

### Variable Declaration

Single variable declaration:

```text
define x : integer;
```

Multiple variables:

```text
define a | b | c : integer;
```

Initialization:

```text
define score : integer = 100;
define average : float = 15.75;
```

---

### Array Declaration

Arrays are declared using:

```text
define Tab : [integer ; 20];
```

Features:

* Fixed size arrays.
* Positive integer size.
* Static allocation.

---

### Constant Declaration

Constants are immutable values:

```text
const PI : float = 3.14159;
const MAX : integer = 100;
```

---

### Instructions Supported

#### Assignment

```text
A <- 23;

B[5] <- (H + 2) / (5 - b + (-3));
```

#### Conditional Statements

```text
if (A > B) then:
{
    X <- X + 1;
}
else
{
    X <- X - 1;
}
endIf;
```

#### While Loop

```text
loop while (x < 10)
{
    x <- x + 1;
}
endloop;
```

#### For Loop

```text
for i in 1 to 10
{
    sum <- sum + i;
}
endfor;
```

#### Input / Output

```text
in(UserName);

out("User Name: ", UserName);
```

---

## Compiler Architecture

The compiler is divided into six major phases.

### 1. Lexical Analysis (FLEX)

The lexical analyzer scans the source code and identifies:

* Keywords
* Identifiers
* Constants
* Operators
* Delimiters
* Comments

Generated output:

* Stream of tokens used by the parser.

---

### 2. Syntax Analysis (BISON)

The parser verifies that the program follows the grammar of ProLang.

Responsibilities:

* Grammar validation.
* Parse tree construction.
* Detection of syntax errors.

Examples of checked structures:

* Declarations
* Assignments
* Conditions
* Loops
* Expressions

---

### 3. Semantic Analysis

The semantic analyzer ensures program correctness beyond syntax.

Checks include:

* Multiple declarations.
* Undeclared identifiers.
* Type compatibility.
* Constant modification attempts.
* Array bounds verification.
* Semantic consistency of expressions.

---

### 4. Symbol Table Management

A hash-table-based symbol table is implemented to store information about:

* Variables
* Constants
* Arrays
* Program identifiers

Stored attributes:

* Name
* Type
* Nature
* Value
* Size
* Scope

Operations supported:

* Insertion
* Search
* Update
* Display

---

### 5. Intermediate Code Generation

The compiler generates intermediate code using quadruplets.

General form:

```text
(OP, ARG1, ARG2, RESULT)
```

Example:

```text
(+, A, B, T1)
(*, T1, C, T2)
(:=, T2, -, X)
```

Advantages:

* Machine-independent representation.
* Easier optimization.
* Simplified code generation.

---

### 6. Intermediate Code Optimization

Several optimization techniques are applied:

* Constant propagation.
* Constant folding.
* Dead code elimination.
* Redundant operation elimination.
* Temporary variable reduction.

Goals:

* Reduce execution time.
* Minimize generated code size.
* Improve runtime efficiency.

---

### 7. Assembly Code Generation

The optimized quadruplets are translated into:

* Intel 8086 Assembly Language

Generated instructions include:

* Arithmetic operations.
* Data movement.
* Conditional jumps.
* Loop control instructions.
* Input/Output support.

This phase produces the final executable representation of the source program.

---

## Error Handling

The compiler provides detailed diagnostics during all compilation stages.

Supported error categories:

### Lexical Errors

Examples:

* Invalid identifiers.
* Unknown symbols.
* Malformed constants.

### Syntax Errors

Examples:

* Missing semicolon.
* Unmatched braces.
* Incorrect statement structure.

### Semantic Errors

Examples:

* Undeclared variables.
* Type mismatches.
* Constant reassignment.
* Invalid array usage.



---

## Technologies Used

* C Programming Language
* FLEX
* BISON
* Hash Tables
* Quadruplets
* Intel 8086 Assembly
* Linux Environment
* GCC Compiler

---



---

## Key Contributions

* Design of the ProLang programming language.
* Complete compiler implementation using FLEX and BISON.
* Hash-based symbol table management.
* Semantic verification framework.
* Quadruplet-based intermediate representation.
* Intermediate code optimization module.
* Intel 8086 assembly code generation.
* Comprehensive error handling and diagnostics.

---

## Future Work

Potential extensions include:

* Function and procedure support.
* Nested scopes.
* Dynamic memory management.
* Boolean data type integration.
* Object-oriented language extensions.
* Register allocation optimization.
* Target code generation for modern architectures.

---

## Author

**CHALLAL Saloua**
Master's Student in Visual Computing (MIV)
University of Science and Technology Houari Boumediene (USTHB)
Academic Year 2025–2026
