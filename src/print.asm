; Global BIOS Print Functions - From my old project found here: https://github.com/ka-iden/ASM-Test
; Created: 18/06/2023
; Last updated: 29/04/2025
; Changelog:
; Removed hex and decimal printing functions.

; Macro to print a string, then print a new line.
%macro sprintLn 1
	mov bx, %1
	call sprintf
	mov bx, newLineString
	call sprintf
%endmacro
; Alternative, no new line.
%macro sprint 1
	mov bx, %1
	call sprintf
%endmacro

%macro newLine 0
	mov bx, newLineString
	call sprintf
%endmacro

; Let's create a function that can print a string.
sprintf:
	pusha
.sprintfLoop:
	mov al, [bx] ; Move primitive bx into al
	cmp al, 0 ; Is al == 0?
	je .sprintfEnd ; If al == 0, jump to endPrint. Basically a "while (true)" loop with a break.
	mov ah, 0x0e ; Tell BIOS to print character in al
	int 0x10 ; BIOS Interrupt
	inc bx ; Move 1 byte, next character
	jmp .sprintfLoop ; Recursive call to print.
.sprintfEnd:
	popa
	ret

newLineString: db 0x0a, 0x0d, 0 ; New line, Carriage return, null terminator
