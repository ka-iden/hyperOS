; === GDT: To be included in stage1 and stage2 ===
GDTInfo:
	dw GDTEnd - GDT - 1
	dd GDT
GDT dd 0x0, 0x0
codeDescriptor db 0xFF, 0xFF, 0x0, 0x0, 0x0, 10011010b, 11001111b, 0x0
dataDescriptor db 0xFF, 0xFF, 0x0, 0x0, 0x0, 10010010b, 11001111b, 0x0
GDTEnd:

CODE_SEG equ codeDescriptor - GDT
DATA_SEG equ dataDescriptor - GDT
