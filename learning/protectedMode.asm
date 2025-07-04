; Entering Protected Mode
; Created: 1/07/2025
; Last Updated: 1/07/2025
; Changelog:
; - Added A20 line
; TODO:
; - Set up the IDT

	use16 ; Use 16-bit mode, aka real mode
	org 0x7c00 ; Set the origin to 0x7c00

	jmp startReal ; jump over labels and instructions for printing

%include "funcs/print16.asm"

startReal: ; Any code that needs to be run once goes below here and above the loop label.

	mov ah, 0x00 ; Tell BIOS Interrupt to set video mode
	mov al, 0x03 ; 80x25 @ 16 colour mode
	int 0x10 ; Call BIOS Interrupt

	mov ah, 0x0b ; Tell BIOS Interrupt to set colour registers
	mov bh, 0x01 ; Palette colour ID
	mov bl, 0x03 ; Colour value when BH is 0, Palette value when BH = 1
	int 0x10 ; Call BIOS Interrupt

	mov ah, 0x09 ; Tell BIOS Interrupt to set text colour
	mov bh, 0x00 ; Display page
	mov bl, 0x04 ; Colour of text
	int 0x10 ; Call BIOS Interrupt

	mov ah, 0x0e ; TTY (TeleTYpewriter) mode

	mov bx, bits16 ; Function to print: 'Currently in 16-bit mode.'
	call sprintLn16 ; Call the print function

	; Enabling the A20 line via the Fast A20 Gate as described by the osdev wiki here:
	; https://wiki.osdev.org/A20_Line#:~:text=in%20al%2C%200x92%0Aor%20al%2C%202%0Aout%200x92%2C%20al
	in al, 0x92 ; Take in... something from the IBM PS/2?
	or al, 2 ; Flip second bit, must be the A20 flag :sob:
	out 0x92, al ; Send back :D

	; Time to enter protected mode.
	cli ; Clear interrupts
	lgdt [GDTDescriptor] ; Move the GDT descriptor into the special gdtr register
	mov eax, cr0 ; Move control register to eax
	or eax, 1 ; Flip pmode bit
	mov cr0, eax ; Move eax back into control register
	jmp CODE_SEG:startProtected ; Perform far jump (jmp to another segment)

bits16: db 'Currently in 16-bit mode.', 0

; The GDT Descriptor is very weird and obscure and took me forever to understand, and I had to do a
; lot of googling and watching videos to explain it, so to save you a bit of time, here are two
; resources that helped me immensely:
; https://wiki.osdev.org/Babystep6
; https://www.youtube.com/watch?v=Wh5nPn2U_1w
GDTStart: ; Must be at the end of real mode code.
nullDescriptor:
	dd 0x0, 0x0 ; First two bytes are null

codeDescriptor:
	dw 0xffff ; Define the first 16 bits of the 20-bit code segment limit
	db 0x0, 0x0, 0x0 ; Define the 24 bits of the 32-bit base of the code segment
	
	; The first bit in this byte describes that there is a code segment present.
	; The second and third bit describe the privilege as "ring", or 00, which is the highest
	; privilege.
	; The fourth bit describes the current segment is the code segment.
	; The fifth bit describes that the segment contains code, part of the type flags.
	; The sixth bit describes that the segments are non-conforming, meaning codein these
	; segments can be executed from lower privilged segments, and since we are at the highest
	; privilege, we should set this to 0.
	; The seventh bit describes that constants are readable by our instructions.
	; The last bit describes that the code here is managed by the CPU, also known as the
	; Accessed flag.
	db 0b10011010
	
	; The first bit describes that we are able to use the whole 4 gigabytes of memory, also
	; known as the granularity bit.
	; The second bit describes that the segment will use 32 bit memory.
	; Since we are not using 64-bit (yet!) and AVL, the third and fourth bit are set to 0.
	; I also do not know what AVL does. I can't find it on google either.
	; The last four bits describe the last 4 bits of the 20-bit limit of the code segment, set
	; to 0xf to give us the maximum available limit.
	db 0b11001111
	
	db 0x0 ; Define the last 8 bits of the 32-bit base of the code segment

dataDescriptor:
	dw 0xffff ; Same as above, except we change a few things.
	db 0x0, 0x0, 0x0
	; This is different, since we need to change the type flags
	; The fifth bit is set to 0 to indicate that this is not code, and that it is the data
	; segment.
	; Since the fifth bit is now data, the sixth bit is now the direction flag, which means
	; which way the data expands, and we want it to expand upwards, since we are starting the
	; segment at 0, we want it to expand upwards, so we set the bit to 0.
	; Since the fifth bit is now data, the seventh bit is now the writable flag, which allows
	; data to be edited, and we want our data to be writable, so we set it to 1.
	db 0b10010010
	
	db 0b11001111
	db 0x0

GDTEnd:
GDTDescriptor:
	dw GDTEnd - GDTStart - 1 ; Last byte in GDT table
	dd GDTStart ; Start of GDT table

CODE_SEG equ codeDescriptor - GDTStart ; Code segment and data segment locations are defined at
DATA_SEG equ dataDescriptor - GDTStart ; assemble-time to allow changes to code above.

	use32 ; Use 32-bit mode, aka protected mode

startProtected:
	mov esi, bits32 ; Move the label of our message into esi
	mov edi, 0xb8000 ; Video memory in 32-bit mode starts at 0xb8000
	add edi, 160 * 1 ; Skip the first line to preserve our original message

.print_line:
	lodsb ; Loads single byte located in esi into the eax register
	cmp al, 0 ; Check if null byte is located
	je .done ; If so, stop printing and hang
	mov ah, 0x07 ; Set the colour to light grey, to match the 16-bit printing.
	mov [edi], ax ; Move character into memory location of the cursor in video memory
	add edi, 2 ; Move the cursor right
	jmp .print_line ; Similar to a while true loop with a return at the top, no upper limit.

.done:
	jmp $ ; Hang
	
bits32 db "Now in 32-bit mode!", 0

	times 510 - ($-$$) db 0 ; Fills empty space with 0s
	dw 0xaa55 ; Boot sector sig
