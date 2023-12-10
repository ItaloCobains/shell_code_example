.386
.model flat, stdcall;

option casemap:none

include \masm32\include\msvcrt.inc
includelib \masm32\lib\msvcrt.lib
extern printf:proc


.code
    start:
        push ebp
        mov ebp, esp
        ; Push to stack an values   
        push 00434241h ; 0X41 0X42 0X43
        mov ebx, esp
        push 00007325h; 0x25 0x73
        mov edx, esp
        push ebx
        push edx
        call printf
        leave
        ret
    end start
