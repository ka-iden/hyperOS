; === stage1.asm ===
use16
org 0x7C00

	mov ax, 0x03
	int 0x10

	mov ah, 0x02 ; Function 2(?)
	mov al, 1 ; Read 1 sector
	mov ch, 0 ; Low 8 bytes of Cylinder (cylinder 0)
	mov cl, 2 ; Sector 2
	mov dh, 0 ; Head 0, top of head
	mov dl, 0 ; Drive number, 0 = floppy
	mov bx, 0x7E0
	mov es, bx ; ES = 0x7e0
	xor bx, bx ; BX = 0
	int 0x13 ; Reads ES:BX, which for us is 0x7e0:0, which points to 0x7e00 somehow
	jc disk_error

	; Enable A20
	in al, 0x92
	or al, 2
	out 0x92, al

	; Protected mode switch
	cli
	lgdt [GDTInfo]
	mov eax, cr0
	or eax, 1
	mov cr0, eax
	jmp CODE_SEG:0x7E00

disk_error:
	cli
	hlt
	jmp disk_error

%include "src/GDT.asm"

times 510 - ($-$$) db 0
dw 0xAA55
