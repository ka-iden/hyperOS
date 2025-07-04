; Stage 1 of bootloader
; Created: 5/07/2025
; Last Updated: 5/07/2025

	org 0x7c00
	bits 16
	jmp start

%include "funcs/print16.asm"
start:

	mov ax, 0x03
	int 0x10 ; Rough clear screen

	; BIOS loads us to 0x7C00, so set up the stack and segments
	cli
	xor ax, ax
	mov ds, ax ; Set data segment to 0
	mov es, ax ; Set extra segment to 0
	mov ss, ax ; Set stack segment to 0
	mov sp, 0x7c00 ; Set stack pointer to 0x7c00
	sti

	mov si, stage1Msg1
	call sprintLn16
	mov si, stage1Msg2
	call sprintLn16

	; === BIOS int 13h read: load stage2.bin ===
	; Load, say, 4 sectors from LBA 1 (CHS sector 2)
	mov ah, 0x02 ; Function 02h - Read sectors
	mov al, 4 ; Number of sectors to read
	mov ch, 0 ; Cylinder
	mov dh, 0 ; Head
	mov cl, 2 ; Sector (CHS counts from 1!)
	mov dl, 0 ; Drive (0 = floppy A)
	mov bx, 0x7e00 ; Load address
	int 0x13
	jc diskError ; If carry flag set, read failed

	jmp 0x0000:0x7e00 ; Jump to where stage 2 is loaded

diskError:
	mov si, diskMsg
	call sprintLn16 ; Print read disk error
	jmp $

stage1Msg1 db 'Currently in stage 1.', 0
stage1Msg2 db 'Starting to load stage 2...', 0
diskMsg db 'Disk Read Error!', 0

times 510 - ($ - $$) db 0
dw 0xaa55
