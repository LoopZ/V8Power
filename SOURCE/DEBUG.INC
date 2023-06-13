; Copyright (C) 2023 Jerome Shidel
; Open source see License file

; NASM for DOS

%ifdef DEBUG

jmp	Skip_Over_DEBUG

PROC_Debug_Char:
	pushf
	push	ax
	cmp	dl, 0x20
	jae	.Print
	mov	dl, 0xf9
.Print:
	mov	ah, 0x02
	int 	0x21
.NoPrint:
	pop	ax
	popf
	ret

PROC_Debug_CRLF:
	pushf
	push	ax
	push	dx
	mov	ah, 0x02
	mov	dl, 0x0d
	int	0x21
	mov	dl, 0x0a
	int	0x21
	pop	dx
	pop	ax
	popf
	ret

PROC_Debug_Text:
	pushf
	push	ax
	push	ds
	mov	ax, cs
	mov 	ds, ax
	mov	ah, 0x09
	int	0x21
	pop	ds
	pop	ax
	popf
	ret

PROC_Debug_AsciiZ:
	pushf
	cld
	push	ax
	push	dx
	push	ds
	mov	ax, cs
	mov 	ds, ax
	mov	ah, 0x02
.Loop:
	lodsb
	test	al, al
	jz	.Done
	mov	dl, al
	int	0x21
	jmp 	.Loop
.Done:
	pop	ds
	pop	dx
	pop	ax
	popf
	ret

PROC_Debug_Word:
	pushf
	push	cx
	push	dx
	StdOutHexWord ax
	pop	dx
	pop	cx
	popf
	ret

PROC_Debug_Byte:
	pushf
	push	cx
	push	dx
	StdOutHexByte ax
	pop	dx
	pop	cx
	popf
	ret

PROC_Debug_CarryFlag:
	pushf
	push	dx
	mov	dx, .MsgCarry
	call	PROC_Debug_Text
	jc	.Carry
	mov	dx, .MsgSet
	jmp	.Done
.MsgCarry:	db 'Carry Flag $'
.MsgSet:	db 'Set$'
.MsgClear:	db 'Clear$'
.Carry:
	mov	dx, .MsgSet
.Done:
	call	PROC_Debug_Text
	call	PROC_Debug_CRLF
	pop	dx
	popf
	ret

Skip_Over_DEBUG:

%imacro Debug_Char 1
	push	dx
	mov	dl, %1
	call	PROC_Debug_Char
	pop	dx
%endmacro

%imacro Debug_CRLF 0
	call	PROC_Debug_CRLF
%endmacro

%imacro Debug_Text 1+
	push	dx
	mov	dx, %%Msg
	call	PROC_Debug_Text
	pop	dx
	jmp	%%Over
%%Msg:
	db %1,'$'
%%Over:
%endmacro

%imacro Debug_TextLn 1+
	push	dx
	mov	dx, %%Msg
	call	PROC_Debug_Text
	pop	dx
	jmp	%%Over
%%Msg:
	db %1,0x0d,0x0a,'$'
%%Over:
%endmacro

%imacro Debug_AsciiZ 1
	push	si
	mov	si, %1
	call	PROC_Debug_AsciiZ
	pop	si
%endmacro

%imacro Debug_Word 1
	push	ax
	mov	ax, %1
	call	PROC_Debug_Word
	pop	ax
%endmacro

%imacro Debug_Byte 1
	push	ax
	mov	al, %1
	call	PROC_Debug_Byte
	pop	ax
%endmacro

%imacro Debug_CarryFlag 0
	call	PROC_Debug_CarryFlag
%endmacro

%else

%imacro Debug_Char 1
%endmacro

%imacro Debug_CRLF 0
%endmacro

%imacro Debug_Text 1+
%endmacro

%imacro Debug_TextLn 1+
%endmacro

%imacro Debug_AsciiZ 1
%endmacro

%imacro Debug_Word 1
%endmacro

%imacro Debug_Byte 1
%endmacro

%imacro Debug_CarryFlag 0
%endmacro

%endif

