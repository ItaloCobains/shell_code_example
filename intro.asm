.386
.model flat, stdcall;

option casemap:none

include \masm32\include\msvcrt.inc
includelib \masm32\lib\msvcrt.lib
extern printf:proc

.data
    fmt db "%s", 0Ah ;formato
    nome db "ÏtaloCobains" ;meu nome

.code
    start:
        push ebp
        mov ebp, esp
        push offset nome
        push offset fmt
        call printf
        leave
        ret
    end start
