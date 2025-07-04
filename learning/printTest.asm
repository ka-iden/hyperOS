; Printing Test
; Created: 25/06/2023
; Last Updated: 29/04/2025
; Changelog:
; - Removed hex and decimal printing functions.
; - Added cursor position tracking and movement functions.
; - Added custom behaviour on special key presses. Works well with typing to my standard.

	use16 ; Use 16-bit mode
	org 0x7c00 ; Set the origin to 0x7c00

	jmp start

%include "funcs/print16.asm"
start:
	; Set Video Mode
	; AL sets Size & Palette Registers
	; See https://stanislavs.org/helppc/int_10-0.html for AL values

	mov ah, 0x00 ; Tell BIOS Interrupt to set video mode
	mov al, 0x03 ; 80x25 @ 16 colour mode
	int 0x10 ; Call BIOS Interrupt

	; Set Colours
	; AH sets Colour Palette Registers
	; See https://stanislavs.org/helppc/int_10-b.html for BL & BH values

	mov ah, 0x0b ; Tell BIOS Interrupt to set colour registers
	mov bh, 0x00 ; 0 to set background and border colour, 1 to select colour palette
	mov bl, 0x01 ; Colour value when BH is 0, Palette value when BH = 1
	int 0x10 ; Call BIOS Interrupt
	mov ah, 0x0e ; TTY (TeleTYpewriter) mode

	mov bx, lines ; Function to print: ====================
	call sprintLn16 ; Call the print function
	mov bx, string1 ; Function to print: Welcome to My OS!
	call sprintLn16 ; Call the print function
	mov bx, string2 ; Function to print: You can type in here, and press enter to restart the system!
	call sprintLn16 ; Call the print function
	mov bx, lines ; Function to print: ====================
	call sprintLn16 ; Call the print function
	call newLine16 ; New line function, wraps around sprintLn

	mov ah, 0x01 ; Tell BIOS Interrupt to set cursor type
	mov ch, 0x00 ; Cursor start line
	mov cl, 0x0f ; Cursor end line
	int 0x10 ; Call BIOS Interrupt

	mov ah, 0x03 ; Tell BIOS Interrupt to get cursor position
	mov bh, 0x00 ; Page number (0 = current page)
	int 0x10 ; Call BIOS Interrupt
	mov [cursorRow], dh ; Store current row in cursorRow
	mov [cursorCol], dl ; Store current column in cursorCol
	call setCursor ; Set cursor to current position, just in case

loop:
	mov ah, 0x00 ; Tell BIOS Interrupt to read key
	int 0x16 ; Read key from keyboard

	cmp al, 0x0D ; Enter key pressed?
	je handleEnter

	cmp al, 0x08 ; Backspace key pressed?
	je handleBackspace

	cmp al, 0x00 ; If al is 0, it's a special key (like arrow keys)
	je specialKey

	; Else
	mov ah, 0x0e ; Call print char interrupt
	int 0x10 ; Call BIOS Interrupt
	inc byte [cursorCol]

	; Any ASCII table will do, but this is the one I used:
	; https://www.rapidtables.com/code/text/ascii-table.html
	cmp al, 0x1b ; Check if escape key was pressed
	jne loop ; If enter key was pressed, end program
	
	int 0x19 ; Reboot

handleEnter:
	call newLine16 ; New line macro

	mov byte [cursorCol], 0 ; Reset column to 0
	inc byte [cursorRow]    ; Move cursor down one row

	call setCursor ; Update BIOS cursor to new position

	jmp loop

handleBackspace:
	; Are we at top-left? (nothing to delete)
	cmp byte [cursorRow], 0
	jne .notTopRow
	cmp byte [cursorCol], 0
	je loop ; At top-left, can't backspace

.notTopRow:
	; If at column 0, move up one row and to last column
	cmp byte [cursorCol], 0
	jne .notLineStart

	; Move up a line
	dec byte [cursorRow]
	mov byte [cursorCol], 79
	call setCursor

	; Overwrite with space
	mov ah, 0x0e
	mov al, ' '
	int 0x10

	; After printing, BIOS moves cursor forward, so set it back
	mov byte [cursorCol], 79
	call setCursor

	jmp loop

.notLineStart:
	; Normal backspace: move left
	dec byte [cursorCol]
	call setCursor

	; Overwrite with space
	mov ah, 0x0e
	mov al, ' '
	int 0x10

	; Set cursor back to deletion point
	call setCursor

specialKey:
	; AL is 0, AH is scan code
	cmp ah, 0x48 ; Up Arrow
	je moveCursorUp
	cmp ah, 0x50 ; Down Arrow
	je moveCursorDown
	cmp ah, 0x4B ; Left Arrow
	je moveCursorLeft
	cmp ah, 0x4D ; Right Arrow
	je moveCursorRight
	jmp loop ; If other special key, just continue

moveCursorUp:
	; Decrease row (cursor Y)
	dec byte [cursorRow]
	call setCursor
	jmp loop

moveCursorDown:
	inc byte [cursorRow]
	call setCursor
	jmp loop

moveCursorLeft:
	dec byte [cursorCol]
	call setCursor
	jmp loop

moveCursorRight:
	inc byte [cursorCol]
	call setCursor
	jmp loop

setCursor:
	pusha
	mov ah, 0x02
	mov bh, 0x00
	mov dh, [cursorRow]
	mov dl, [cursorCol]
	int 0x10
	popa
	ret

cursorRow: db 0
cursorCol: db 0

; Strings can be written as a 'byte', because it's a pointer to a string.
; Strings must terminate with a 0 so the program knows when to stop printing.
lines: db '====================', 0
string1: db 'Welcome to My OS!', 0
string2: db 'You can type in here, and press escape to restart the system!', 0

endOfProgram: ; Never called, just sits here to fill the minimum 512 bytes some BIOSes require.
	jmp $ ; Hang
	times 510 - ($-$$) db 0 ; Fills empty space with 0s
	dw 0xaa55 ; Boot sector sig
