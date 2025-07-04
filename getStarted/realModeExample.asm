; Real Mode Example
; Created: 28/06/2025
; Last Updated: 3/07/2025

	use16 ; Use 16-bit mode
	org 0x7c00 ; Set the origin to 0x7c00

	mov ax, 0x03
	int 0x10

	jmp start

%include "funcs/print16.asm"
start: ; Any code that needs to be run once goes below here and above the loop label.

	mov si, string ; Move the address of the start of string into bx
	call sprintLn16 ; Call sprintLn16 function, which will print each character and then a new line

loop: ; Any code that needs to be run infinitely goes below here.
	mov ah, 0x00 ; Tell BIOS Interrupt to read key
	int 0x16 ; Read key from keyboard

	cmp al, 0x1b ; Check if escape key was pressed
	jne loop ; If enter key was pressed, end program
; End of loop, all loop code goes above this line.
	
	int 0x19 ; Reboot

string db 'Hello, World!', 0 ; String to be printed

	times 510 - ($-$$) db 0 ; Fills empty space with 0s
	dw 0xaa55 ; Boot sector sig
