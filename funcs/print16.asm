; 16-bit BIOS Print Functions - From my old project found here: https://github.com/ka-iden/ASM-Test
; Created: 18/06/2023
; Last updated: 10/07/2025
; Changelog:
; - Removed hex and decimal printing functions.
; - Converted macros to functions.
; - Appended 16 to names to signify 16-bit
; - Went a bit overboard with the naming to signify that sprintf16 should not be called directly :^)
; - Cleaned up newLine16 and removed a few push and pops
; - Better explained how functions may be called

; Do not call sprintf directly. use sprint, sprintLn, and newLine.
; Functions to print a string, replaced the macros for higher code efficiency.

; Functions take in the string's memory location into si
; Example call may look like this:
; mov si, string
; call sprintLn16
sprint16:
	pusha
	call sprintf16DONOTCALLDIRECTLY
	popa
	ret

sprintLn16:
	pusha
	call sprintf16DONOTCALLDIRECTLY
	call newLine16
	popa
	ret

newLine16:
	pusha
	; Abomination of an instruction- telling BIOS to print character in al while setting al to 0x0a
	mov ax, 0x0e0a
	int 0x10
	mov al, 0x0d ; 0x0a is carriage return, 0x0d is new line
	int 0x10
	popa
	ret

; Let's create a function that can print a string.
sprintf16DONOTCALLDIRECTLY:
	mov ah, 0x0e ; Tell BIOS to print character in al
.sprintfLoop16:
	mov al, [si] ; Move primitive bx into al
	cmp al, 0 ; Is al == 0?
	je .sprintfEnd16 ; If al == 0, jump to endPrint. Basically a "while (true)" loop with a break.
	int 0x10 ; BIOS Interrupt
	inc si ; Move 1 byte, next character
	jmp .sprintfLoop16 ; Recursive call to print.
.sprintfEnd16:
	ret
