; 16-bit BIOS Print Functions - From my old project found here: https://github.com/ka-iden/ASM-Test
; Created: 18/06/2023
; Last updated: 1/07/2025
; Changelog:
; - Removed hex and decimal printing functions.
; - Converted macros to functions.
; - Appended 16 to names to signify 16-bit
; - Went a bit overboard with the naming to signify that sprintf16 should not be called directly :^)

; Do not call sprintf directly. use sprint, sprintLn, and newLine.
; Functions to print a string, replaced the macros for higher code efficiency.
sprint16:
	pusha
	call sprintf16DONOTCALLDIRECTLY
	popa
	ret

sprintLn16:
	pusha
	call sprintf16DONOTCALLDIRECTLY
	mov si, newLineString16
	call sprintf16DONOTCALLDIRECTLY
	popa
	ret

newLine16:
	pusha
	mov si, newLineString16
	call sprintf16DONOTCALLDIRECTLY
	popa
	ret

; Let's create a function that can print a string.
sprintf16DONOTCALLDIRECTLY:
	pusha
.sprintfLoop16:
	mov al, [si] ; Move primitive bx into al
	cmp al, 0 ; Is al == 0?
	je .sprintfEnd16 ; If al == 0, jump to endPrint. Basically a "while (true)" loop with a break.
	mov ah, 0x0e ; Tell BIOS to print character in al
	int 0x10 ; BIOS Interrupt
	inc si ; Move 1 byte, next character
	jmp .sprintfLoop16 ; Recursive call to print.
.sprintfEnd16:
	popa
	ret

newLineString16: db 0x0a, 0x0d, 0 ; New line, Carriage return, null terminator
