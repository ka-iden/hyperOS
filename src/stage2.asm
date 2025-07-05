; === stage2.asm ===
use32
org 0x7E00

	jmp start

%include "src/GDT.asm"
%include "funcs/print32.asm"

start:
	lgdt [GDTInfo] ; Make sure you load it again!

	mov ax, DATA_SEG
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	mov esi, string
	mov edi, offset
	call sprintLn32

.hang:
	hlt
	jmp .hang

string db 'Test', 0
offset dd 0