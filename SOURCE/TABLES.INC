; Copyright (C) 2015 Jerome Shidel
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
    DB "BLACK",0,0,0
    DB "BLUE",0,1,0
    DB "GREEN",0,2,0
    DB "CYAN",0,3,0
    DB "RED",0,4,0
    DB "MAGENTA",0,5,0
    DB "BROWN",0,6,0
    DB "GRAY",0,7,0
;    DB "LIGHTGRAY",0,7,0
;   DB "LIGHT GRAY",0,7,0
    DB "DARKGRAY",0,8,0
    DB "DARK GRAY",0,8,0
    DB "LIGHTBLUE",0,9,0
;   DB "LIGHT BLUE",0,9,0
    DB "LIGHTGREEN",0,10,0
;   DB "LIGHT GREEN",0,10,0
    DB "LIGHTCYAN",0,11,0
;   DB "LIGHT CYAN",0,11,0
    DB "LIGHTRED",0,12,0
;   DB "LIGHT RED",0,12,0
    DB "LIGHTMAGENTA",0,13,0
;   DB "LIGHT MAGENTA",0,13,0
    DB "YELLOW",0,14,0
    DB "WHITE",0,15,0
    TableEnd
%endmacro
