# V8Power Tools
#### Putting the power of an 8-cylinder engine under the hood of DOS batch files. ######
Copyright 2016 Jerome Shidel.<br>
Released under the GPL v2.0 License.<br>

* * *

The V8Power Tools project is being designed in cooperation with
[Jim Hall](http://www.freedos.org/jhall) for the [FreeDOS™](http://www.freedos.org)
operating system. It is intended to expand the functionality of scripts written
using batch files and to provide them with a better looking user interface with
increased functionality.

* * *

## Compiling V8Power Tools

#### &nbsp;&nbsp; Prerequisites ######

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;8086 or better cpu. <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;EGA or better video adapter. <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[FreeDOS™ 1.1 or higher](http://www.freedos.org) <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[NASM™ for DOS version 2.11.08](http://wwww.nasm.us) <br>

#### &nbsp;&nbsp; Compiling ######

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Insure the NASM directory is in your path spec. <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Download the latest sources from [GitHub](http://github.com/LoopZ/V8Power).<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Run the mkV8.bat script. <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;All executibles will be placed in newly
created <b>BIN</b> directory.<br>

#### &nbsp;&nbsp; For lazy people, like me ######

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Precompiled versions are available at [http://up.lod.bz/V8Power](http://up.lod.bz/V8Power).<br>

* * *

## V8Power Tools Tested Compatibility

* FreeDOS 1.1+<br>

Limited compatiblilty of advanced features <i>(no "set /p" batch support)</i>:

* MS-DOS 6.2 and 6.22<br>
* PC-DOS 7.0, 7.01 and 2000<br>
* DR-DOS 7.03<br>
* DosBOX (i/o redirection or querying using stdout will NOT work)<br>
* Windows 3.11 Shell<br>
* Windows 98 Shell and Command Line<br>
* Windows XP SP3 Shell (except vcursor)<br>

* * *

## V8Power Tools Usage

Here is some basic information reguarding all utilities and how they operate.<br>
 * Options, values and hexidecimal numbers are not case specific **/f white** is the same as **/F wHIte**.<br>
 * Hexidecimal numbers may be prefixed with **0x** to prevent them from being treated as base ten.
<i>(Example: <b>10</b> and <b>0x10</b>)</i><br>
 * Spaces are mostly optional. **/B7/f0** is the same as **/B 7 /F 0**. But, not **/ B7 / F0**.<br>
 * To use a **/** or spaces in a value, put it in qoutes. Like **"Jack and/or Jill"**.<br>
 * Use multiple qoutes to use quotes. Like **"Jack's house"** or **'Say "What?"'**.<br>
 * Unless overriden, most utilities use the text attribute at the current cursor location.<br>
<br>

Here is color table used for all **/A**, **/F** and **/B** switches:

<table>
<tr><th>Decimal</th><th>Hex</th><th>Label (Not case specific)</th></tr>
<tr><td>0</td><td>0x00</td><td>Black</td></tr>
<tr><td>1</td><td>0x01</td><td>Blue</td></tr>
<tr><td>2</td><td>0x02</td><td>Green</td></tr>
<tr><td>3</td><td>0x03</td><td>Cyan</td></tr>
<tr><td>4</td><td>0x04</td><td>Red</td></tr>
<tr><td>5</td><td>0x05</td><td>Magenta</td></tr>
<tr><td>6</td><td>0x06</td><td>Brown</td></tr>
<tr><td>7</td><td>0x07</td><td>Gray</td></tr>
<tr><td>8</td><td>0x08</td><td>DarkGray</td></tr>
<tr><td>9</td><td>0x09</td><td>LightBlue</td></tr>
<tr><td>10</td><td>0x0a</td><td>LightGreen</td></tr>
<tr><td>11</td><td>0x0b</td><td>LightCyan</td></tr>
<tr><td>12</td><td>0x0c</td><td>LightRed</td></tr>
<tr><td>13</td><td>0x0d</td><td>LightMagenta</td></tr>
<tr><td>14</td><td>0x0e</td><td>Yellow</td></tr>
<tr><td>15</td><td>0x0f</td><td>White</td></tr>
</table>

* * *

#### v8help *[options]* ######
Displays help text from V8Power Tools README.TXT document.
<table>
<tr><td width="125pt"></td><td>Lists all V8Power Tools commands.</td></tr>
<tr><td><b><i>commmand</i></b></td><td>Displays help for that V8Power Tool.</td></tr>
</table>

* * *

#### vcls *[options]* ######
Clear screen, area or row (line).
<table>
<tr><td width="125pt"></td><td>Clear the screen with the current text attribute.</td></tr>
<tr><td><b><i>n</i></b></td><td>Set text attribute to <b><i>n</i></b>.</td></tr>
<tr><td><b>/A <i>n</i></b></td><td>Set text attribute to <b><i>n</i></b>.</td></tr>
<tr><td><b>/B <i>color</i></b></td><td>Set the background text attribute to
<b><i>color</i></b> (or a <b><i>value</i></b>).</td></tr>
<tr><td><b>/F <i>color</i></b></td><td>Set the forground text attribute to
<b><i>color</i></b> (or a <b><i>value</i></b>).</td></tr>
<tr><td><b>/G</b></td><td>Global Screen Clear. (Default)</b></td></tr>
<tr><td><b>/L</b></td><td>Local Screen Clear. Detects its surroundings and only clears that.
	Probably, a box or line or something. You don't really need this option. Because,
	you can just redraw the box, maybe.</b></td></tr>
<tr><td><b>TEXT</b></td><td>Clear the text only. Leave all colors intact and ignore their color attributes.</td></tr>
<tr><td><b>EOL</b></td><td>Clear from cursor to End of Line only.</td></tr>
<tr><td><b>/C <i>code</i></b></td><td>Clear by filling with an ASCII character
<b><i>code</i></b>.</td></tr>
<tr><td><b>/X <i>column</i></b></td><td>Absolute screen <b><i>column</i></b> to start clear.</td></tr>
<tr><td><b>/Y <i>row</i></b></td><td>Absolute screen <b><i>row</i></b> to start clear.</td></tr>
<tr><td><b>/W <i>width</i></b></td><td>Total <b><i>width</i></b> of area to clear.</td></tr>
<tr><td><b>/H <i>height</i></b></td><td>Total <b><i>height</i></b> of area to clear.</td></tr>
</table>

* * *

#### vcursor *[options]* ######
Change or query the cursor size and shape.
<table>
<tr><td width="125pt"></td><td>Outputs the current cursor shape to <b>STDOUT</b>.</td></tr>
<tr><td><b><i>n</i></b></td><td>Set the current cursor shape as <b><i>n</i></b>.</td></tr>
<tr><td><b>HIDE</b></td><td>Hides the cursor.</td></tr>
<tr><td><b>SMALL</b></td><td>Sets a small cursor</td>.</tr>
<tr><td><b>HALF</b></td><td>Sets the cursor to 1/2 of the text height.</td></tr>
<tr><td><b>FULL</b></td><td>Sets the cursro to the full height of text.</td></tr>
</table>
<i>Note: Although this utility is fully compatible with DOSBox, there is no
way to store the current cursor shape. See the examples, on how to work
around this issue. Also, this utility will not have any effect in a
Windows terminal.</i>

* * *

#### vdelay *[ms]* ######
Simple delay in milliseconds.
<table>
<tr><td width="125pt"></td><td>Default is 1000ms (1 second) delay.</td></tr>
<tr><td><b><i>ms</i></b></td><td>Delay for <b><i>ms</i></b> milliseconds. (0-65535, 0x0000-0xffff) </td></tr>
<tr><td><i>/D</i></td><td>Detect method used for timing. <i>(Not compatible with VirtualBox)</i></td></tr>
<tr><td><i>/S</i></td><td>Use safe general purpose timer. <i>(Default)</i></td></tr>
<tr><td><i>/I</i></td><td>Use high precision interrupt timer. <i>(Not compatible with VirtualBox)</i></td></tr>
</table>

* * *

#### vecho *[options]* *[text]* ######
Output text to display.
<table>
<tr><td width="125pt"></td><td>Preforms a Carriage Return and Line Feed to the display.</td></tr>
<tr><td><b><i>text</i></b></td><td>Writes <b><i>text</i></b> to the display.</td></tr>
<tr><td><b>/A <i>n</i></b></td><td>Set text attribute to <b><i>n</i></b>.</td></tr>
<tr><td><b>/B <i>color</i></b></td><td>Set the background text attribute to
<b><i>color</i></b> (or <b><i>value</i></b>).</td></tr>
<tr><td><b>/F <i>color</i></b></td><td>Set the forground text attribute to
<b><i>color</i></b> (or <b><i>value</i></b>).</td></tr>
<tr><td><b>/N</td><td>Do not write a CRLF when done.</td></tr>
<tr><td><b>/P</td><td>Perform a CRLF now.</td></tr>
<tr><td><b>/S +</td><td>Insert a space character between parameters. <b>(default)</b></td></tr>
<tr><td><b>/S -</td><td>Do not add space character between multiple parameters.</td></tr>
<tr><td><b>/C <i>code</i></b></td><td>Write an ASCII character
<b><i>code</i></b>.</td></tr>
<tr><td><b>/R <i>times</i></b></td><td>Repeat the next write <b><i>times</i></b> number of times. (1-65535)</td></tr>
<tr><td><b>/I</td><td>Write text that may waiting from the STDIN device.</td></tr>
<tr><td><b>/G</td><td>Write text ignoring all framing.</td></tr>
<tr><td><b>/L</td><td>Write text locally with regards to framing. <b>(DEFAULT)</b></td></tr>
<tr><td><b>/X <i>code</i></b></td><td>Erase rest of line using ASCII
<b><i>code</i></b>, but don't move the cursor.</td></tr>
<tr><td><b>/E</b></td><td>Same as using <b>/X <i>0x20</i></b></td></tr>
<tr><td><b>/T <i>file ID</i></b></td><td>Look up <b><i>ID</i></b> in <b><i>file</i></b>
 and process it like command line options.<br>
    			Any additional options that follow this switch are used to<br>
    			populate <b><i>%1</i></b>-<b><i>%9</i></b> variables in the text string.
</td></tr>

<tr><td><i>tba</i></td><td><i>(Still under development, more to be announced)</i></td></tr>
</table>

* * *

#### vgotoxy *[options]* ######
Move or query cursor position.
<table>
<tr><td width="125pt"></td><td>Preforms no action.</td></tr>
<tr><td><b>/Q <i>x</i></b> or <b><i>y</i></b></td><td>Queries the current <b><i>X</i></b>
 or <b><i>Y</i></b> position of the cursor and outputs it to <b>STDOUT</b>.</td></tr>
<tr><td><b>/X <i>column</i></b></td><td>Move cursor to <b><i>column</i></b>.</td></tr>
<tr><td><b>/Y <i>row</i></b></td><td>Move cursor to <b><i>row</i></b>.</td></tr>
<tr><td><b>/G</b></td><td>Move cursor based on entire screen. (default)</td></tr>
<tr><td><b>/L</b></td><td>Move cursor based on its surroundings.</td></tr>
<tr><td><i>direction</i></td><td>Move cursor <b><i>up</i></b>, <b><i>down</i></b>,
<b><i>left</i></b> or <b><i>right</i></b> one space.</td></tr>
<tr><td><i>shift</i></td><td>Move cursor to the <b><i>previous</i></b> or <b><i>next</i></b>
position and change rows if needed.</td></tr>
<tr><td><i>position</i></td><td>Move cursor to the <b><i>SOP</i></b> <i>(Start of Page)</i>,
<b><i>EOP</i></b> <i>(End of Page)</i>,
<b><i>SOR</i></b> <i>(Start of Row)</i>,
<b><i>EOR</i></b> <i>(End of Row)</i>,
<b><i>SOL</i></b> <i>(Start of Text on Line)</i>,
<b><i>EOL</i></b> <i>(End of Text on Line)</i>,
<b><i>SOT</i></b> <i>(Start of All Text)</i> or
<b><i>EOT</i></b> <i>(End of All Text)</i>
position.</td></tr>
</table>

* * *

#### vframe *[options]* ######
Draw a box windowing thingy and move cursor to its inside top left position.
<table>
<tr><td width="125pt"></td><td>Draw a box that encloses the entire screen.</td></tr>
<tr><td><b>/A <i>n</i></b></td><td>Set text attribute to <b><i>n</i></b>.</td></tr>
<tr><td><b>/B <i>color</i></b></td><td>Set the background text attribute to
<b><i>color</i></b> (or <b><i>value</i></b>).</td></tr>
<tr><td><b>/F <i>color</i></b></td><td>Set the forground text attribute to
<b><i>color</i></b> (or <b><i>value</i></b>).</td></tr>
<tr><td><b>/X <i>column</i></b></td><td>Screen <b><i>column</i></b> to start the box.</td></tr>
<tr><td><b>/Y <i>row</i></b></td><td>Screen <b><i>row</i></b> to start the box.</td></tr>
<tr><td><b>/W <i>width</i></b></td><td>Total <b><i>width</i></b> of the box.</td></tr>
<tr><td><b>/H <i>height</i></b></td><td>Total <b><i>height</i></b> of the box.</td></tr>
<tr><td><b><i>/C</i></b></td><td>Centers the box horizontally and vertically.</td></tr>
<tr><td><b>/T <i>file ID</i></b></td><td>Look up <b><i>ID</i></b> in <b><i>file</i></b>
 and process it like command line options.<br>
    			Any additional options that follow this switch are used to<br>
    			populate <b><i>%1</i></b>-<b><i>%9</i></b> variables in the text string.
<tr><td><i>style</i></td><td>Box <i>styles</i> are <b><i>Single</i></b>, <b><i>Double</i></b>,
<b><i>SingleSides</i></b>, <b><i>DoubleSides</i></b> and <b><i>Hidden</i></b>.</td></tr>
<tr><td><i><b>shadow</b></i></td><td>Add a 3D style <b><i>shadow</i></b>.</td></tr>
<tr><td><i><b>textbox</b></i></td><td>Draw a <b><i>textbox</i></b> style frame with a little padding and margins.</td></tr>
<tr><td><i><b>optionbox</b></i></td><td>Draw a hidden style <b><i>optionbox</i></b> for choices inside a frame.</td></tr>
</table>

* * *

#### vpcspkr *[hz:][ms]* ######
Generate a tone using the built in speaker.
<table>
<tr><td width="125pt"></td><td>No output.</td></tr>
<tr><td><i>hz:ms</i></td><td>Use the PC Speaker to generate a <b><i>hz</i></b> frequency tone.
Then, delay for <b><i>ms</i></b> milliseconds. (Note: 0 frequency turns off speaker. If no frequency is provided
then 0 is assumed)</td></tr>
<tr><td><i>/D</i></td><td>Detect method used for timing. <i>(Not compatible with VirtualBox)</i></td></tr>
<tr><td><i>/S</i></td><td>Use safe general purpose timer. <i>(Default)</i></td></tr>
<tr><td><i>/I</i></td><td>Use high precision interrupt timer. <i>(Not compatible with VirtualBox)</i></td></tr>
<tr><td><i>tba</i></td><td><i>(Still under development, more to be announced)</i></td></tr>
</table>

* * *

#### vver *[options]* ######
V8Power information program.
<table>
<tr><td width="125pt"></td><td>Outputs all info to <b>STDOUT</b>.</td></tr>
<tr><td><b><i>all</i></b></td><td>Outputs <b><i>all</i></b> info to <b>STDOUT</b>.</td></tr>
<tr><td><b><i>title</i></b></td><td>Outputs full <b><i>title</i></b> to <b>STDOUT</b>.</td></tr>
<tr><td><b><i>copyright</i></b></td><td>Outputs the <b><i>copyright</i></b> message to <b>STDOUT</b>.</td></tr>
<tr><td><b><i>version</i></b></td><td>Outputs the <b><i>version</i></b> information to <b>STDOUT</b>.</td></tr>
<tr><td><b><i>license</i></b></td><td>Outputs <b><i>license</i></b> information to <b>STDOUT</b>.</td></tr>
<tr><td><b><i>url</i></b></td><td>Outputs the website <b><i>url</i></b> information to <b>STDOUT</b>.</td></tr>
</table>

* * *

#### vprogres *[options]* ######
Draw a progress bar at current location without moving cursor.
<table>
<tr><td width="125pt"></td><td>Draw a progress bar at 0%.</td></tr>
<tr><td><b>/A <i>n</i></b></td><td>Set text attribute to <b><i>n</i></b>.</td></tr>
<tr><td><b>/B <i>color</i></b></td><td>Set the background text attribute to
<b><i>color</i></b> (or <b><i>value</i></b>).</td></tr>
<tr><td><b>/F <i>color</i></b></td><td>Set the forground text attribute to
<b><i>color</i></b> (or <b><i>value</i></b>).</td></tr>
<tr><td><b>/W <i>width</i></b></td><td>Override default <b><i>width</i></b>
of the bar (default is from cursor to end of line).</td></tr>
<tr><td><i>value</i></td><td>Sets the <b><i>value</i></b> in a percent of progress.</td></tr>
<tr><td><b><i>off</i></b></td><td>Do not display percentage number.</td></tr>
<tr><td><i>align</i></td><td>Percentage number on <b><i>left</i></b>,
<b><i>center</i></b> (Default) or <b><i>right</i></b> side of the progress bar.</td></tr>
<tr><td><b>OF <i>max</i></b></td><td>Calculate percentage of <b><i>max</i></b>. Example 5 of 7.</td></tr>
</table>

* * *

#### vchoice *[options]* ######
Choose an option.<br>
It returns an errorlevel of choice selected based on its entry number. Not
the letter/number of the choice. For example, if the second item is chosen,
it will return an errorlevel of 2. Regardless of any prefix (Like C, 1, R, etc).
Also, I personally recommend using <b><i>auto</i></b> for any set of choices that
you prefix with a letter or number.
<table>
<tr><td width="125pt"></td><td>Perform using all automatic defaults settings.</td></tr>
<tr><td><b>/A <i>n</i></b></td><td>Set text attribute to <b><i>n</i></b> for selected item.</td></tr>
<tr><td><b>/B <i>color</i></b></td><td>Set the background text attribute to
<b><i>color</i></b> for selected item.</td></tr>
<tr><td><b>/F <i>color</i></b></td><td>Set the forground text attribute to
<b><i>color</i></b> for selected item.</td></tr>
<tr><td><b>/D <i>n</i></b></td><td>Preselect item number <b><i>n</i></b>
as the default choice.</td></tr>
<tr><td><i>type</i></td><td>Direct keypress selection type.<br>
	 <b><i>off</i></b> Select with only arrow keys.<br>
	 <b><i>auto</i></b> Detect direct jump characters. (Default)<br>
	 <b><i>alpha</i></b> Jump to selections using A-Z.<br>
	 <b><i>digit</i></b> Jump to selections using 1-9 (+0).<br>
<tr><td><b>/Q</td><td>Query for result. When the choice is made, it's text will be
sent to STDOUT.</td></tr>
<tr><td><b>/T <i>seconds</i></b></td><td>Delay in <b><i>seconds</i></b> before the default item is automatically selected (0-3600).
Note that even if the user navigates to a different item, the original default item will be
selected when the timeout is achieved.</td></tr>
<tr><td><b>/P <i>n</i></b></td><td>Use <b>polling</b> mode and preselect item
number <b><i>n</i></b> as the current choice. Note, any change of selection
will exit vchoice and return 100+ the current choice number.</td></tr>
<tr><td><b><i>CTRL-C</i></b></td><td>When specified and <b><i>CTRL-C</i></b> is pressed, will exit with
errorlevel of 200.</td></tr>
<tr><td><i>tba</i></td><td><i>(Still under development, more to be announced)</i></td></tr>
</table>

* * *

#### vpause *[options]* ######
Simple wait for keypress or  time-out.
<table>
<tr><td width="125pt"></td><td>Wait forever for keypress.</td></tr>
<tr><td><b>/D <i>seconds</i></b></td><td>Delay in <b><i>seconds</i></b> to wait before the
pause times-out. (returns errorlevel 1) (/T has been depreciated)</td></tr>
<tr><td><b><i>CTRL-C</i></b></td><td>When specified and <b><i>CTRL-C</i></b> is pressed, will exit with
errorlevel of 200.</td></tr>
<tr><td><i>tba</i></td><td><i>(Still under development, more to be announced)</i></td></tr>
</table>

* * *

#### vline *[options]* ######
Draws a line.
<table><tr><td width="125pt"></td><td>Draws as local single dumb line on the current row. Wait forever for keypress.</td></tr>
<tr><td><b><i>single</i></b></td><td>Draws a <b><i>single</i></b> line.</td></tr>
<tr><td><b><i>double</i></b></td><td>Draws a <b><i>double</i></b> line.</td></tr>
<tr><td><b><i>hidden</i></b></td><td>Draws a <b><i>hidden</i></b> dumb line.</td></tr>
<tr><td><b><i>dumb</i></b></td><td>Draws a <b><i>dumb</i></b> without regard to what already exists.</td></tr>
<tr><td><i>tba</i></td><td><i>(Still under development, more to be announced)</i></td></tr>
</table>

* * *

#### vinfo *[options]* ######
General system information utility.
<table><tr><td width="125pt"></td><td>Does nothing.</td></tr>
<tr><td><b><i>/V </i></b></td><td>Verbose Mode.</td></tr>
<tr><td><b>/D <i>a</i></b></td><td>Test <b><i>a</i></b> drives status.<br>
Returns these error codes:<br>
<br>
<pre>
15 - Not Present<br>
5 - Not Formatted (for DOS)<br>
4 - Network Drive (untested)<br>
3 - CD/DVD-ROM (MSCDEX Only, most report error 15)<br>
2 - Removable Media (like Floppy)<br>
1 - (Reserved)<br>
0 - No Special Conditions<br>
</pre>
</td></tr>
<tr><td><b>/M</b></td><td>Return Machine Type (This may break on future platforms).<br>
Returns these exit codes:<br>
<br>
<pre>
0 - Unknown, Normal or Native 8086 Hardware.<br>
1 - 80186<br>
2 - 80286<br>
3 - 80386<br>
4 - 80486<br>
5 - 80586<br>
6 - 80686 or better<br>
101 - DOSBox.<br>
102 - QEMU.<br>
103 - VirtualBox<br>
104 - VMware<br>
200 - General, other emulator detected.<br>
</pre>
<tr><td><i>tba</i></td><td><i>(Still under development, more to be announced)</i></td></tr>
</table>

* * *

#### verrlvl *[options]* ######
Sets current errorlevel. Mostly for testing batch file logic.
<table>
<tr><td width="125pt"></td><td>Sets errorlevel to 0</td></tr>
<tr><td><b><i>n</i></b></td><td>Sets errorlevel to <b><i>n</i></b> (0-255)</td></tr>
</table>

* * *

#### vmath *[options]* ######
Super simple math utility. It is NOT as a calculator and is limited to working
on numbers from 0-32767. Good for looping, determining screen offsets and etc.
<table>
<tr><td width="125pt"><b><i>+</i></b>,<b><i>ADD</i></b></td><td>Add next number to sum.</td></tr>
<tr><td><b><i>-</i></b>,<b><i>SUB</i></b></td><td>Subtract next number from sum.</td></tr>
<tr><td><b><i>*</i></b>,<b><i>MUL</i></b></td><td>Multiply sum by next number.</td></tr>
<tr><td><b><i>/</i></b>,<b><i>DIV</i></b></td><td>Divide sum by next number.</td></tr>
<tr><td><b><i>\</i></b>,<b><i>MOD</i></b></td><td>Divide sum by next number and set sum to the remainder.</td></tr>
<tr><td><b><i>AND</i></b></td><td>Logical AND.</td></tr>
<tr><td><b><i>OR</i></b></td><td>Logical OR.</td></tr>
<tr><td><b><i>XOR</i></b></td><td>Logical XOR.</td></tr>
<tr><td><b><i>SHR</i></b></td><td>Bit shift right.</td></tr>
<tr><td><b><i>SHL</i></b></td><td>Bit shift left.</td></tr>
<tr><td><b><i>/H</i></b></td><td>Set output to hexadecimal.</td></tr>
<tr><td><b><i>/D</i></b></td><td>Set output to decimal.</td></tr>
<tr><td><i>tba</i></td><td><i>(Still under development, more to be announced)</i></td></tr>
</table>

* * *

#### vstr *[options]* ######
Simple String processing utility. Outputs results to STDOUT.
<table>
<tr><td width="125pt"></td><td>Preforms a Carriage Return and Line Feed to STDOUT.</td></tr>
<tr><td><b>/N</td><td>Do not write a CRLF when done.</td></tr>
<tr><td><b>/U</td><td>Input Filter: Convert to upper case.</td></tr>
<tr><td><b>/D</td><td>Input Filter: Convert to lower case.</td></tr>
<tr><td><b>/B</td><td>Input Filter: Ignore blank lines.</td></tr>
<tr><td><b>/I</td><td>Input Filter: Ignore indentation.</td></tr>
<tr><td><b>/C <i>code</i></b></td><td>Write an ASCII character
<b><i>code</i></b>.</td></tr>
<tr><td><b>/R <i>times</i></b></td><td>Repeat the next write <b><i>times</i></b> number of times. (1-65535)</td></tr>
<tr><td><b>/L <i>line</i></b></td><td>Return only this <b><i>line</i></b> from standard input. (0-65535)<br>
<i>(Note: vline /L <b>TOTAL</b> will return the total number of lines.)</i>
Also, adding :n will output n number of lines.</td></tr>
<tr><td><b>/S <i>s1 s2</i></b></td><td>Search and replace all occurrences of <b><i>s1</b></i> with <b><i>s2</b></i>.</td></tr>
<tr><td><b>/F <i>s1 s2</i></b></td><td>Set delimiter to <b><i>s1</b></i> and only return field position or range <b><i>s2</b></i>. </td></tr>
<tr><td><b>/T <i>s2</i></b></td><td>Return tab field position or range <b><i>s2</b></i>. </td></tr>
<tr><td><b>/P <i>s1</i></b></td><td>Print text <b><i>s1</b></i>. </td></tr>
<tr><td><i>tba</i></td><td><i>(Still under development, more to be announced)</i></td></tr>
</table>

* * *

#### vmode *[options]* ######
Set and query current video text modes.
<table>
<tr><td width="125pt"></td><td>Outputs current video mode and font to STDOUT.</td></tr>
<tr><td><b>VESA<i></i></b></td><td>Outputs a list of <b><i>VESA</i></b> modes to STDOUT.</td></tr>
<tr><td><b>mode<i></i></b></td><td>Set current video <b><i>mode</i></b>.
(0-0xffff) or a mode label with optional font setting.<br>
<pre>
Modes:
	BW40	Black and White 40 Column (also B40).
	BW80	Black and White 80 Column (also B80, BW).
	CO40	Color 40 Column (also C40).
	CO80	Color 80 Column (also C80, COLOR).
	MONO	Mono 80 Column.

Fonts:
	Font8	Select 8x8 ROM font. (also F8)
	Font14	Select 8x14 EGA ROM font. (also F14)
	Font16	Select 8x16 VGA ROM font. (also F16)
</pre>
</td></tr>
</table>

* * *

#### vfdutil *[options]* ######
File and directory utility.
<table><tr><td width="125pt"></td><td>Does nothing.</td></tr>
<tr><td><b><i>/D file</i></b></td><td>Calculate and output drive letter of file to STDOUT.</td></tr>
<tr><td><b><i>/P file</i></b></td><td>Calculate and output path of file to STDOUT.</td></tr>
<tr><td><b><i>/C</i></b></td><td>Use before /D or /P to change drive or path without text output.</td></tr>
<tr><td><b><i>/X</i></b></td><td>Use before /D or /P to return errorlevel 1-26 of drive letter.</td></tr>
<tr><td><b><i>/F file</i></b></td><td>Calculate and output complete filename to STDOUT.</td></tr>
<tr><td><b><i>/N file</i></b></td><td>Calculate and output file's basename to STDOUT.</td></tr>
<tr><td><b><i>/E file</i></b></td><td>Calculate and output file's extension to STDOUT.</td></tr>
<tr><td><b><i>/U template</i></b></td><td>Calculate and output unique file/dir name based on template to STDOUT.
The drive and path must exist.<br> Example: "vfdutil /u C:\TEMP\TEST????.$$$"</td></tr>
<tr><td><b><i>/S filespec</i></b></td><td>Search the PATH for a given filespec and output all matching files to STDOUT. The current directory is not searched. If any filespec is not found, exits with an errorlevel 1.</td></tr>
<tr><td><b><i>/T filespec</i></b></td><td>Just like /S except only errorlevel 0 or 1 is returned.</td></tr>
</table>

* * *

#### vask ######
Prompt for text input.
<table>
<tr><td width="125pt"></td><td>Use detected settings for input.</td></tr>
<tr><td><b><i>text</i></b></td><td>Preset edited <b><i>text</i></b>.</td></tr>
<tr><td><b>/A <i>n</i></b></td><td>Set text attribute to <b><i>n</i></b>.</td></tr>
<tr><td><b>/B <i>color</i></b></td><td>Set the background text attribute to
<b><i>color</i></b> (or <b><i>value</i></b>).</td></tr>
<tr><td><b>/F <i>color</i></b></td><td>Set the forground text attribute to
<b><i>color</i></b> (or <b><i>value</i></b>).</td></tr>
<tr><td><b>/G</td><td>Input text ignoring all framing.</td></tr>
<tr><td><b>/L</td><td>Input text locally with regards to framing. <b>(DEFAULT)</b></td></tr>
<tr><td><b>/C</td><td>When specified and Control-C is pressed, will exit with
                errorlevel of 200 and return the default value.</td></tr>
<tr><td><b>/T <i>file ID</i></b></td><td>Look up <b><i>ID</i></b> in <b><i>file</i></b>
 and process it like command line options.<br>
    			Any additional options that follow this switch are used to<br>
    			populate <b><i>%1</i></b>-<b><i>%9</i></b> variables in the text string.
</td></tr>
<tr><td><b>/D <i>seconds</i></b></td><td>Delay in <b><i>seconds</i></b> to wait before the
prompt times-out and returns the initial default value. (returns errorlevel 1)</td></tr>

<tr><td><i>tba</i></td><td><i>(Still under development, more to be announced)</i></td></tr>
</table>

* * *

#### vinsert *[options]* ######
Insert a blank row (line) at the current location.
<table>
<tr><td width="125pt"></td><td>Insert a blank line.</td></tr>
<tr><td><b><i>n</i></b></td><td>Insert <b><i>n</i></b> blank lines.</td></tr>
<tr><td><b>/A <i>n</i></b></td><td>Set text attribute to <b><i>n</i></b>.</td></tr>
<tr><td><b>/B <i>color</i></b></td><td>Set the background text attribute to
<b><i>color</i></b> (or a <b><i>value</i></b>).</td></tr>
<tr><td><b>/F <i>color</i></b></td><td>Set the forground text attribute to
<b><i>color</i></b> (or a <b><i>value</i></b>).</td></tr>
<tr><td><b>/G</b></td><td>Global Insert.</td></tr>
<tr><td><b>/L</b></td><td>Local Insert. <b>(Default)</b></td></tr>
</table>

* * *

#### vdelete *[options]* ######
Delete row (line) at the current location.
<table>
<tr><td width="125pt"></td><td>Delete line.</td></tr>
<tr><td><b><i>n</i></b></td><td>Delete <b><i>n</i></b> lines.</td></tr>
<tr><td><b>/A <i>n</i></b></td><td>Set text attribute to <b><i>n</i></b>.</td></tr>
<tr><td><b>/B <i>color</i></b></td><td>Set the background text attribute to
<b><i>color</i></b> (or a <b><i>value</i></b>).</td></tr>
<tr><td><b>/F <i>color</i></b></td><td>Set the forground text attribute to
<b><i>color</i></b> (or a <b><i>value</i></b>).</td></tr>
<tr><td><b>/G</b></td><td>Global Delete.</td></tr>
<tr><td><b>/L</b></td><td>Local Delete. <b>(Default)</b></td></tr>
</table>

* * *

#### veach *[options]* ######
Do something for each item in a list.
<table>
<tr><td width="125pt"><b><i>/S</i></b></td>
    <td>Turn on list sorting.</td></tr>
<tr><td><b><i>/L</i></b></td>
    <td>Display list contents.</td></tr>
<tr><td><b>/F <i>file</i></b></td>
    <td>Add items to list from <b><i>file</i></b>.</td></tr>
<tr><td><b><i>/I</i></b></td>
    <td>Add items to list from the Standard Input device.</td></tr>
<tr><td><b>/D <i>spec</i></b></td>
    <td>Modifies /d <b><i>spec</i></b> to the list.</td></tr>
<tr><td><b>/A <i>+/-</i></b></td>
    <td>Modifies <b>/D</b> switch to enable all files and directories.
    </td></tr>
<tr><td><b>/C</b></td>
    <td>When the <b>/X</b> switch is used, allows continuing despite a
	subprocess error.</td></tr>
<tr><td><b>/X <i>cmdln</i></b></td>
    <td>Execute item with command line and all subsequent switches
	are passed to the subprocess. * is expanded to item, # is
	number of items and @ is index of item. If no command line
	data follows the <b>/X</b> switch, * is assumed.</td></tr>

<tr><td><i>tba</i></td><td><i>(Still under development, more to be announced)</i></td></tr>

</table>
