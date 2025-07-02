; Printing Test
; Created: 3/07/2025
; Last Updated: 3/07/2025

	use16
	org 0x7c00

	mov ax, 0x03 ; Quick n' dirty clear screen by setting video mode
	int 0x10

	cli ; Better explained in protectedMode.asm
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

%include "src/print32.asm"
start: ; Start of actual bootloader

	mov esi, myString ; String to print
	mov edi, screen_offset ; Pointer to offset
	mov ah, 0x07 ; Light grey on black
	call sprintLn32

	jmp $ ; Hang

myString db "Welcome to 32-bit mode!", 0
screen_offset dd 0

	times 510 - ($-$$) db 0
	dw 0xaa55
