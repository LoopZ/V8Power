; Copyright (C) 2016 Jerome Shidel
;
;   This program is free software; you can redistribute it and/or modify
;   it under the terms of the GNU General Public License as published by
;   the Free Software Foundation; either version 2 of the License, or
;   (at your option) any later version.
;
;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.
;
;   You should have received a copy of the GNU General Public License along
;   with this program; if not, write to the Free Software Foundation, Inc.,
;   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

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
    TableEnd
%endmacro
