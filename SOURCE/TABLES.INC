; Copyright (C) 2016-2022 Jerome Shidel
; Open source see License file

; NASM for DOS

; common table macros

%imacro TableData 2
	DB %1
	DB 0
	DW %2
%endmacro

%imacro TableEnd 0
	DB 0
	DW 0xffff
%endmacro

%imacro ColorTableData 0
ColorTable:
    TableData "BLACK",0
    TableData "BLUE", 1
    TableData "GREEN",2
    TableData "CYAN",3
    TableData "RED",4
    TableData "MAGENTA",5
    TableData "BROWN",6
    TableData "GRAY",7
    TableData "GREY",7
;    TableData "LIGHTGRAY",7
;   TableData "LIGHT GRAY",7
    TableData "DARKGRAY",8
;    TableData "DARK GRAY",8
    TableData "DARKGREY",8
;    TableData "DARK GREY",8
    TableData "LIGHTBLUE",9
;   TableData "LIGHT BLUE",9
    TableData "LIGHTGREEN",10
;   TableData "LIGHT GREEN",10
    TableData "LIGHTCYAN",11
;   TableData "LIGHT CYAN",11
    TableData "LIGHTRED",12
;   TableData "LIGHT RED",12
    TableData "LIGHTMAGENTA",13
;   TableData "LIGHT MAGENTA",13
    TableData "YELLOW",14
    TableData "WHITE",15
    TableData "LINKOFF",0x8000
    TableData "LINKON",0x8001
    TableEnd
%endmacro
