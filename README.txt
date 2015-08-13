*******************************************************************************
V8Power Tools
Copyright 2015 Jerome Shidel
Released under GPL v2.0 License.
*******************************************************************************

Putting the power of an 8-cylinder engine under the hood of DOS batch files.

===============================================================================

The V8Power Tools project is being designed in cooperation with
Jim Hall for the FreeDOS(TM) (http://www.freedos.org) operating system. It is
intended to expand the functionality of scripts written using batch files and
to provide them with a better looking user interface with increased 
functionality.

===============================================================================

Compiling V8Power Tools

	Prerequisites:

		8086 or better cpu. 
		EGA or better video adapter.
		FreeDOS(TM) 1.1 or higher (http://www.freedos.org)
		NASM for DOS version 2.11.08 (http://wwww.nasm.us)

	Compiling:

		Insure the NASM directory is in your path spec.
		Download the latest sources from http://github.com/LoopZ/V8Power
		Run the mkV8.bat script.
		All executibles will be placed in newly created BIN directory.
		
		( To create a redistributable version use the mkDist.bat script.
		It will create an DIST folder containing everything you need.)

-------------------------------------------------------------------------------

V8Power Tools Tested Compatibility
	
	FreeDOS 1.1+
	MS-DOS 3.3, 6.2 and 6.22
	PC-DOS 7.0, 7.01 and 2000
	DR-DOS 7.03
	Windows 3.11 Shell
	Windows 98 Shell and Command Line
	Windows XP SP3 Shell (except vcursor)
	DosBOX (no i/o redirection, polling or querying stdout will not work)

-------------------------------------------------------------------------------

V8Power Tools Usage

Here is some basic information reguarding all utilities and how they operate.

	Options, values and hexidecimal numbers are not case specific /f white is 
	the same as /F wHIte.

	Hexidecimal numbers may be prefixed with 0x to prevent them from being 
	treated as base ten. (Example: 10 and 0x10)
	
	Spaces are mostly optional. /B7/f0 is the same as /B 7 /F 0. 
	But, not / B7 / F0.
	
	To use a / or spaces in a value, put it in qoutes. Like "Jack and/or Jill".
	
	Use multiple qoutes to use quotes. Like "Jack's house" or 'Say "What?"'.
	
	Unless overriden, most utilities use the text attribute at the current 
	cursor location.

===============================================================================
vcls [options]

Clear screen, area or row (line).

	[none] 		Clear the screen with the current text attribute.
	n			Set text attribute to n.
	/A n		Set text attribute to n.
	/B color	Set the background text attribute to color (or a value).
	/F color	Set the forground text attribute to color (or a value).
	/G			Global Screen Clear. (Default)
	/L			Local Screen Clear. Detects its surroundings and only clears 
				that.  Probably, a box or line or something. You don't really 
				need this option. Because, you can just redraw the box, maybe.			
	TEXT		Clear the text only. Leave all colors intact and ignore their 
				color attributes.
	EOL			Clear from cursor to End of Line only.
	/C code		Clear by filling with an ASCII character code.
	/X column	Absolute screen column to start clear.
	/Y row		Absolute screen row to start clear.
	/W width	Total width of area to clear.
	/H height	Total height of area to clear.
	
-------------------------------------------------------------------------------
vcursor [options]

Change or query the cursor size and shape.

	[none]		Outputs the current cursor shape to STDOUT.
	n			Set the current cursor shape as n.
	HIDE		Hides the cursor.
	SMALL		Sets a small cursor.
	HALF		Sets the cursor to 1/2 of the text height.
	FULL		Sets the cursro to the full height of text.

-------------------------------------------------------------------------------

vdelay [ms]

Simple delay in milliseconds.
	
	[none]		Default is 1000ms (1 second) delay.
	ms			Delay for ms milliseconds. (0-65535, 0x0000-0xffff)
	
-------------------------------------------------------------------------------

vecho [options] [text]

Output text to display.
	
	[none]		Preforms a Carriage Return and Line Feed to the display.
	text		Writes text to the display.
	/A n		Set text attribute to n.
	/B color	Set the background text attribute to color (or a value).
	/F color	Set the forground text attribute to color (or a value).
	/N			Do not write a CRLF when done.
	/C code		Write an ASCII character code.
	/R times	Repeat the next write times number of times. (1-65535)
	
	tba			(Still under development, more to be announced)
	
-------------------------------------------------------------------------------

vgotoxy [options]

Move or query cursor position.

	[none]		Preforms no action.
	/Q x or y	Queries the current X or Y position of the cursor and outputs 
				it to STDOUT.
	/X column	Move cursor to column.
	/Y row 		Move cursor to row.
	/G			Move cursor based on entire screen. (default)
	/L			Move cursor based on its surroundings.
	direction	Move cursor up, down, left or right one space.
	shift		Move cursor to the previous or next position and change 
				rows if needed.
	position	Move cursor to the 
					SOP (Start of Page),
					EOP (End of Page),
					SOR (Start of Row),
					EOR (End of Row), 
					SOL (Start of Text on Line), 
					EOL (End of Text on Line), 
					SOT (Start of All Text) or  
					EOT (End of All Text) position.


-------------------------------------------------------------------------------

vframe [options]

Draw a box windowing thingy and move cursor to its inside top left position.
<table>
<tr><td width="125pt"></td><td>Draw a box that encloses the entire screen</td></tr>
<tr><td><b>/A <i>n</i></a></td><td>Set text attribute to <b><i>n</i></b></td></tr>
<tr><td><b>/B <i>color</i></b></td><td>Set the background text attribute to 
<b><i>color</i></b> (or <b><i>value</i></b>)</td></tr>
<tr><td><b>/F <i>color</i></b></td><td>Set the forground text attribute to 
<b><i>color</i></b> (or <b><i>value</i></b>)</td></tr>
<tr><td><b>/X <i>column</i></b></td><td>Screen <b><i>column</i></b> to start the box.</td></tr>
<tr><td><b>/Y <i>row</i></b></td><td>Screen <b><i>row</i></b> to start the box.</td></tr>
<tr><td><b>/W <i>width</i></b></td><td>Total <b><i>width</i></b> of the box.</td></tr>
<tr><td><b>/H <i>height</i></b></td><td>Total <b><i>height</i></b> of the box.</td></tr>
<tr><td><i>style</i></td><td>Box <i>styles</i> are <b><i>Single</i></b>, <b><i>Double</i></b>, 
<b><i>SingleSides</i></b>, <b><i>DoubleSides</i></b> and <b><i>Hidden</i></b></td></tr>
<tr><td><i><b>shadow</b></i></td><td>Add a 3D style <b><i>shadow</i></b></td></tr>
</table>

-------------------------------------------------------------------------------

vpcspkr [hz:][ms]

Generate a tone using the built in speaker.
<table>
<tr><td width="125pt"></td><td>No output.</td></tr>
<tr><td><i>hz:ms</i></td><td>Use the PC Speaker to generate a <b><i>hz</i></b> frequency tone. 
Then Delay for <b><i>ms</i></b> milliseconds. (Note: 0 frequency turns off speaker. If no frequency is provided
then 0 is assumed)</td></tr>
<tr><td><i>tba</i></td><td><i>(Still under development, more to be announced)</i></td></tr>
</table>

-------------------------------------------------------------------------------

vversion [options]

V8Power information program.
<table>
<tr><td width="125pt"></td><td>Outputs all info to <b>STDOUT</b></td></tr>
<tr><td><b><i>all</i></b></td><td>Outputs <b><i>all</i></b> info to <b>STDOUT</b></td></tr>
<tr><td><b><i>title</i></b></td><td>Outputs full <b><i>title</i></b> to <b>STDOUT</b></td></tr>
<tr><td><b><i>copyright</i></b></td><td>Outputs the <b><i>copyright</i></b> message to <b>STDOUT</b></td></tr>
<tr><td><b><i>version</i></b></td><td>Outputs the <b><i>version</i></b> information to <b>STDOUT</b></td></tr>
<tr><td><b><i>license</i></b></td><td>Outputs <b><i>license</i></b> information to <b>STDOUT</b></td></tr>
<tr><td><b><i>url</i></b></td><td>Outputs the website <b><i>url</i></b> information to <b>STDOUT</b></td></tr>
</table>

-------------------------------------------------------------------------------

vprogres [options]

Draw a progress bar at current location without moving cursor.
<table>
<tr><td width="125pt"></td><td>Draw a progress bar at 0%</td></tr>
<tr><td><b>/A <i>n</i></a></td><td>Set text attribute to <b><i>n</i></b></td></tr>
<tr><td><b>/B <i>color</i></b></td><td>Set the background text attribute to 
<b><i>color</i></b> (or <b><i>value</i></b>)</td></tr>
<tr><td><b>/F <i>color</i></b></td><td>Set the forground text attribute to 
<b><i>color</i></b> (or <b><i>value</i></b>)</td></tr>
<tr><td><b>/W <i>width</i></b></td><td>Override default <b><i>width</i></b> of the bar (default is from cursor to end of line)</td></tr>
<tr><td><i>value</i></td><td>Sets the <b><i>value</i></b> in percent of progress</td></tr>
<tr><td><b><i>off</i></b></td><td>Do not display percentage number</td></tr>
<tr><td><i>align</i></td><td>Percentage number on <b><i>left</i></b>, 
<b><i>center</i></b> (Default) or <b><i>right</i></b> side of the progress bar</td></tr>
</table>

-------------------------------------------------------------------------------

vchoice [options]

Choose an option.

It returns an errorlevel of choice selected based on its entry number. Not
the letter/number of the choice. For example, if the second item is chosen,
it will return an errorlevel of 2. Regardless of any prefix (Like C, 1, R, etc). 
Also, I personally recommend using auto for any set of choices that
you prefix with a letter or number.
 
	[none]		Perform using all automatic defaults settings.</td></tr>
<tr><td><b>/A <i>n</i></a></td><td>Set text attribute to <b><i>n</i></b> for selected item</td></tr>
<tr><td><b>/B <i>color</i></b></td><td>Set the background text attribute to 
<b><i>color</i></b> for selected item.</td></tr>
<tr><td><b>/F <i>color</i></b></td><td>Set the forground text attribute to 
<b><i>color</i></b> for selected item.</td></tr>
<tr><td><b>/D <i>n</i></a></td><td>Preselect item number <b><i>n</i></b></td></tr>
<tr><td><i>type</i></td><td>Direct keypress selection type.<br>
	 <b><i>off</i></b> Select with only arrow keys.<br>
	 <b><i>auto</i></b> Detect direct jump characters (Default)<br>
	 <b><i>alpha</i></b> Jump to selections using A-Z.<br>
	 <b><i>digit</i></b> Jump to selections using 1-9 (+0).<br>
<tr><td><i>tba</i></td><td><i>(Still under development, more to be announced)</i></td></tr>
</td></tr></table>

-------------------------------------------------------------------------------

vline

TBA

-------------------------------------------------------------------------------

vpause

TBA

-------------------------------------------------------------------------------

vinfo

TBA

-------------------------------------------------------------------------------

vmode

TBA

-------------------------------------------------------------------------------

vview

TBA

-------------------------------------------------------------------------------

vask

TBA
