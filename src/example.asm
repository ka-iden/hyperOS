; Example File
; Created: 28/06/2025
; Last Updated: 28/06/2025

	use16 ; Use 16-bit mode
	org 0x7c00 ; Set the origin to 0x7c00

	jmp start

%include "src/print.asm"
start: ; Any code that needs to be run once goes below here and above the loop label.



loop: ; Any code that needs to be run infinitely goes below here.



; End of loop, all loop code goes above this line.

	cmp al, 0x1b ; Check if escape key was pressed
	jne loop ; If enter key was pressed, end program
	
	int 0x19 ; Reboot

endOfProgram: ; Never called, just sits here to fill the minimum 512 bytes some BIOSes require.
	jmp $ ; Hang
	times 510 - ($-$$) db 0 ; Fills empty space with 0s
	dw 0xaa55 ; Boot sector sig
