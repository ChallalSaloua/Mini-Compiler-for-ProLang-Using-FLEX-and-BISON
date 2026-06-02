@echo off

bison -d -v syntaxique.y
if errorlevel 1 goto erreur

flex lexical.l
if errorlevel 1 goto erreur

gcc -std=c99 -c SymbolTable.c -o SymbolTable.o
if errorlevel 1 goto erreur

gcc -std=c99 -c quad.c -o quad.o
if errorlevel 1 goto erreur

gcc -std=c99 -c syntaxique.tab.c -o syntaxique.o
if errorlevel 1 goto erreur

gcc -std=c99 -c lex.yy.c -o lexical.o
if errorlevel 1 goto erreur

gcc -o compilateur.exe SymbolTable.o lexical.o syntaxique.o quad.o
if errorlevel 1 goto erreur

echo.
echo Compilation terminee avec succes.
echo Execution avec code.txt :
echo.

compilateur.exe < code.txt

echo.
echo Execution terminee.
goto fin

:erreur
echo.
echo Une erreur est survenue pendant la compilation.

:fin
cmd /k
