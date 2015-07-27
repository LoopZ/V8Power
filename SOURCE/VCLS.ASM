; Copyright (C) 2015 Jerome Shidel
;
;	This program is free software; you can redistribute it and/or modify
;	it under the terms of the GNU General Public License as published by
;	the Free Software Foundation; either version 2 of the License, or
;	(at your option) any later version.
;
;	This program is distributed in the hope that it will be useful,
;	but WITHOUT ANY WARRANTY; without even the implied warranty of
;	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;	GNU General Public License for more details.
;
;	You should have received a copy of the GNU General Public License along
;	with this program; if not, write to the Free Software Foundation, Inc.,
;	51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

; NASM for DOS

; PROJECTED -- Some options have not been implemented
; Clears screen 
; usage: vcls [options]
; 
; /F color		Set Foreground Color.
; /B color		Set Background Color.
; /A n			Set Text Attribute.
; /T			Clear text only, leave colors.
; /P			Only clear current area, not entire screen.

%include "COMMON.INC"

	mov			ax, 0x0600
	mov			bh, [TextAttr]
	mov			cx, [WindMin]
	mov			dx, [WindMax]
	int			0x10
	GotoXY		cx

	Terminate 0

