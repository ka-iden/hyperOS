; === stage2.asm ===
use32
org 0x7E00

	jmp start

%include "funcs/print32.asm"
%include "src/GDT.asm"

start:
	mov ax, DATA_SEG
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	mov esi, string32
	mov edi, offset
	call sprintLn32

.hang:
	hlt
	jmp .hang

string32 db 'Now in 32-bit mode.', 0
offset dd 160 * 1