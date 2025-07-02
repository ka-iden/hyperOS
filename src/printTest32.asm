; Printing Test
; Created: 3/07/2025
; Last Updated: 3/07/2025
; Changelog:
; - Implemented 32-bit printing
; - Takes keyboard input, prints as hex
; - Keyboard input now is printed to the screen - currently very simple with no caps
; CURRENT BUGS:
; - lshift is printing backslash?? when holding down backslash, it properly repeats, but holding
; lshift only places one backslash, i'm going to make note of that.

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

printChar32:
    pusha
    mov ebx, [screenOffset] ; Current offset in VGA memory
    mov edx, 0xB8000 ; VGA base address
    mov ah, 0x07 ; Light grey on black
    mov [edx + ebx], ax ; Write character and attribute
    add ebx, 2 ; advance cursor by one character (2 bytes)
    mov [screenOffset], ebx ; save new offset
    popa
    ret

; I spent a very, very long time working this out with a LOT of trial and error and a few
; resources here:
; https://stackoverflow.com/questions/61124564/convert-scancodes-to-ascii
; https://commons.wikimedia.org/wiki/File:Ps2_de_keyboard_scancode_set_2.svg
; https://image1.slideserve.com/1839050/ps2-keyboard-scan-codes-n.jpg
; https://www.rapidtables.com/code/text/ascii-table.html
; Most of the codes could be copied from a pre-existing table, but for some reason some keys didn't
; follow the thing? with a LOT of trial and error I found out that the PS/2 keyboard's third row is
; laid out like "..., k, l, ;, ', `, lshift, \". Also ' is 39, ` is 96.
scancodeToAscii db 0, 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=',  0
				db     0, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']',  0
				db      0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', 39,  96, '\\'
				db          'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/',  0
				db        0,  0,  ' ',  0,   0,   0,   0,   0,   0

start: ; Start of actual bootloader
loop:
.wait:
	in al, 0x64 ; Read keyboard controller status register
	test al, 1 ; Check if buffer full
	jz .wait ; If not, keep waiting

	in al, 0x60 ; Read scancode from 0x60
	cmp al, 0x80 ; Check if scancode is break code 
	jnb loop ; If so, ignore and start again

	cmp al, 0x3F ; Check if scancode is > 63
	ja loop ; Ignore if out of LUT range

	movzx eax, al ; Make sure scancode is safe for comp
	mov bl, [scancodeToAscii + eax] ; Properly handle ASCII

	cmp bl, 0 ; Check if LUT returns 0
	je loop ; If so, start again

	mov al, bl ; Move ASCII char to al
	call printChar32 ; Print character

	jmp loop ; Start again :D

screenOffset dd 0 ; Offset from start of video memory

	times 510 - ($-$$) db 0
	dw 0xaa55
