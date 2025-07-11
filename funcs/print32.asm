; 32-bit BIOS Print Functions
; Created: 3/07/2025
; Last Updated: 10/07/2025
; Changelog:
; - Removed a few push and pops from sprintf32DONOTCALLDIRECTLY
; - Better explained how functions may be called

; Do not call sprintf directly. use sprint, sprintLn, and newLine.

; Functions take in the string's memory location into esi and an offset into video memory into edi.
; Example call may look like this:
; mov esi, string
; mov edi, offset
; call sprintLn32
sprint32:
	pusha
	call sprintf32DONOTCALLDIRECTLY
	popa
	ret

sprintLn32:
	pusha
	call sprintf32DONOTCALLDIRECTLY
	;mov eax, [edi] ; Get current offset
	;mov ecx, 160 ; We're going to divide eax by ecx, moving 160 into the divisor
	;xor edx, edx ; Set the upper half of the numerator to 0 (numerator is EDX:EAX for div)
	;div ecx ; divide EAX by ECX, EAX = line number, EDX = offset in line
	;inc eax ; Go to next line
	;mul ecx ; EAX = offset for start of next line
	;mov [edi], eax ; Update screen_offset
	call newLine32 ; Calling newline saves 44 bytes to call over copy the code!! :sob:
	popa
	ret

newLine32:
	pusha
	mov eax, [edi] ; Get current offset
	mov ecx, 160 ; We're going to divide eax by ecx, moving 160 into the divisor
	xor edx, edx ; Set the upper half of the numerator to 0 (numerator is EDX:EAX for div)
	div ecx ; divide EAX by ECX, EAX = line number, EDX = offset in line
	inc eax ; Go to next line
	mul ecx ; EAX = offset for start of next line
	mov [edi], eax ; Update screen_offset
	popa
	ret

; Let's create a function that can print a string.
sprintf32DONOTCALLDIRECTLY:
	mov ebx, [edi] ; EBX = current offset
	mov edx, 0xB8000 ; VGA text buffer base
.sprintfLoop:
	lodsb ; AL = [ESI], ESI++
	cmp al, 0
	je .done
	mov ah, 0x07 ; Set the colour to light grey, to match the 16-bit printing.
	mov [edx + ebx], ax ; Write character at offset passed in
	add ebx, 2 ; Advance offset by 2 bytes, mutates input
	jmp .sprintfLoop
.done:
	mov [edi], ebx ; Store updated offset back
	ret