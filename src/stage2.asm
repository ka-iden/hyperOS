; Stage 2 of bootloader
; Created: 5/07/2025
; Last Updated: 5/07/2025

	org 0x7e00
	bits 16
	jmp start

%include "funcs/print16.asm"
start:
	mov si, stage2Msg1
	call sprintLn16
	call newLine16
	mov si, stage2Msg2
	call sprintLn16
	jmp $

stage2Msg1 db 'Stage 2 loaded!', 0
stage2Msg2 db 'Everything is working :D', 0
; No 0xaa55 needed! no longer in bootsector :O
