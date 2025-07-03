; Protected Mode Example
; Created: 3/07/2025
; Last Updated: 3/07/2025

	use16 ; Use 16-bit mode
	org 0x7c00 ; Set the origin to 0x7c00

	mov ax, 0x03
	int 0x10

	in al, 0x92
	or al, 2
	out 0x92, al

	cli
	lgdt [GDTInfo]
	mov eax, cr0
	or eax, 1
	mov cr0, eax
	jmp CODE_SEG:start

GDTInfo: ; Better explained in protectedMode.asm
	dw GDTEnd - GDT - 1
	dd GDT
GDT dd 0x0, 0x0
codeDescriptor db 0xff, 0xff, 0x0, 0x0, 0x0, 0b10011010, 0b11001111, 0x0
dataDescriptor db 0xff, 0xff, 0x0, 0x0, 0x0, 0b10010010, 0b11001111, 0x0
GDTEnd:

CODE_SEG equ codeDescriptor - GDT ; Better explained in protectedMode.asm
DATA_SEG equ dataDescriptor - GDT

	use32

start: ; Any code that needs to be run once goes below here and above the loop label.

	mov al, 'A'
	mov ah, 0x07
	mov [0xb8000], ax

loop: ; Any code that needs to be run infinitely goes below here.
	in al, 0x64 ; Read keyboard controller status register
	test al, 1 ; Check if buffer full
	jz loop ; If not, keep waiting

	in al, 0x60 ; Read scancode from 0x60

	cmp al, 0x01 ; Check if escape key was pressed
	jne loop ; If enter key was pressed, end program
; End of loop, all loop code goes above this line.

	; No interrupts to restart os, but fallthrough restarts it ;^)

	times 510 - ($-$$) db 0 ; Fills empty space with 0s
	dw 0xaa55 ; Boot sector sig
