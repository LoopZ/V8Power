# V8Power Tools
#### Putting the power of an 8-cylinder engine under the hood of DOS batch files. ######
Copyright 2015 Jerome Shidel.<br> 
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
created <b>BIN</b> directory.<br><br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<i>To create a redistributable version use the mkDist.bat script.<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
It will create an <b>DIST</b> folder containing everything you need.</i><br>
* * *

## V8Power Tools Tested Compatibility
	
> FreeDOS 1.1+<br>
> MS-DOS 3.3, 6.2 and 6.22<br>
> PC-DOS 7.0, 7.01 and 2000<br>
> DR-DOS 7.03<br>
> Windows 3.11 Shell<br>
> Windows 98 Shell and Command Line<br>
> Windows XP SP3 Shell (except vcursor)<br>
> DosBOX (no i/o redirection, polling or querying stdout will not work)<br>

* * *

## V8Power Tools Usage

> Here is some basic information reguarding all utilities and how they operate.<br>
> * Options, values and hexidecimal numbers are not case specific **/f white** is the same as **/F wHIte**.<br>
> * Hexidecimal numbers may be prefixed with **0x** to prevent them from being treated as base ten.
<i>(Example: <b>10</b> and <b>0x10</b>)</i><br>
> * Spaces are mostly optional. **/B7/f0** is the same as **/B 7 /F 0**. But, not **/ B7 / F0**.<br>
> * To use a **/** or spaces in a value, put it in qoutes. Like **"Jack and/or Jill"**.<br>
> * Use multiple qoutes to use quotes. Like **"Jack's house"** or **'Say "What?"'**.<br>
> * Unless overriden, most utilities use the text attribute at the current cursor location.<br>
<br>
Here is color table used for all **/A**, **/F** and **/B** switches:
<table>
<tr><th>Decimal</th><th>Hex</th><th>Label (Not case specific)</th></tr>
<tr><td>0</td><td>0x00</td><td>Black</td></tr>
<tr><td>1</td><td>0x01</td><td>Blue</td)</tr>
<tr><td>2</td><td>0x02</td><td>Green</td)</tr>
<tr><td>3</td><td>0x03</td><td>Cyan</td)</tr>
<tr><td>4</td><td>0x04</td><td>Red</td)</tr>
<tr><td>5</td><td>0x05</td><td>Magenta</td)</tr>
<tr><td>6</td><td>0x06</td><td>Brown</td)</tr>
<tr><td>7</td><td>0x07</td><td>Gray</td)</tr>
<tr><td>8</td><td>0x08</td><td>DarkGray</td)</tr>
<tr><td>9</td><td>0x09</td><td>LightBlue</td)</tr>
<tr><td>10</td><td>0x0a</td><td>LightGreen</td)</tr>
<tr><td>11</td><td>0x0b</td><td>LightCyan</td)</tr>
<tr><td>12</td><td>0x0c</td><td>LightRed</td)</tr>
<tr><td>13</td><td>0x0d</td><td>LightMagenta</td)</tr>
<tr><td>14</td><td>0x0e</td><td>Yellow</td)</tr>
<tr><td>15</td><td>0x0f</td><td>White</td)</tr>
</table>

* * *
#### vcls *[options]* ######
Clear screen, area or row (line).
<table>
<tr><td width="125pt"></td><td>Clear the screen with the current text attribute.</td></tr>
<tr><td><b><i>n</i></b></td><td>Set text attribute to <b><i>n</i></b>.</td></tr>
<tr><td><b>/A <i>n</i></a></td><td>Set text attribute to <b><i>n</i></b>.</td></tr>
<tr><td><b>/B <i>color</i></b></td><td>Set the background text attribute to 
<b><i>color</i></b> (or a <b><i>value</i></b>).</td></tr>
<tr><td><b>/F <i>color</i></b></td><td>Set the forground text attribute to 
<b><i>color</i></b> (or a <b><i>value</i></b>).</td></tr>
<tr><td><b>/G</a></td><td>Global Screen Clear. (Default)</b></td></tr>
<tr><td><b>/L</a></td><td>Local Screen Clear. Detects its surroundings and only clears that.
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
* * *
#### vdelay *[ms]* ######
Simple delay in milliseconds.
<table>
<tr><td width="125pt"></td><td>Default is 1000ms (1 second) delay.</td></tr>
<tr><td><b><i>ms</i></b></td><td>Delay for <b><i>ms</i></b> milliseconds. (0-65535, 0x0000-0xffff) </td></tr>
</table>
* * *
#### vecho *[options]* *[text]* ######
Output text to display.
<table>
<tr><td width="125pt"></td><td>Preforms a Carriage Return and Line Feed to the display.</td></tr>
<tr><td><b><i>text</i></b></td><td>Writes <b><i>text</i></b> to the display.</td></tr>
<tr><td><b>/A <i>n</i></a></td><td>Set text attribute to <b><i>n</i></b>.</td></tr>
<tr><td><b>/B <i>color</i></b></td><td>Set the background text attribute to 
<b><i>color</i></b> (or <b><i>value</i></b>).</td></tr>
<tr><td><b>/F <i>color</i></b></td><td>Set the forground text attribute to 
<b><i>color</i></b> (or <b><i>value</i></b>).</td></tr>
<tr><td><b>/N</td><td>Do not write a CRLF when done.</td></tr>
<tr><td><b>/C <i>code</i></b></td><td>Write an ASCII character 
<b><i>code</i></b>.</td></tr>
<tr><td><b>/R <i>times</i></b></td><td>Repeat the next write <b><i>times</i></b> number of times. (1-65535)</td></tr>
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
<tr><td><b>/A <i>n</i></a></td><td>Set text attribute to <b><i>n</i></b>.</td></tr>
<tr><td><b>/B <i>color</i></b></td><td>Set the background text attribute to 
<b><i>color</i></b> (or <b><i>value</i></b>).</td></tr>
<tr><td><b>/F <i>color</i></b></td><td>Set the forground text attribute to 
<b><i>color</i></b> (or <b><i>value</i></b>).</td></tr>
<tr><td><b>/X <i>column</i></b></td><td>Screen <b><i>column</i></b> to start the box.</td></tr>
<tr><td><b>/Y <i>row</i></b></td><td>Screen <b><i>row</i></b> to start the box.</td></tr>
<tr><td><b>/W <i>width</i></b></td><td>Total <b><i>width</i></b> of the box.</td></tr>
<tr><td><b>/H <i>height</i></b></td><td>Total <b><i>height</i></b> of the box.</td></tr>
<tr><td><i>style</i></td><td>Box <i>styles</i> are <b><i>Single</i></b>, <b><i>Double</i></b>, 
<b><i>SingleSides</i></b>, <b><i>DoubleSides</i></b> and <b><i>Hidden</i></b>.</td></tr>
<tr><td><i><b>shadow</b></i></td><td>Add a 3D style <b><i>shadow</i></b>.</td></tr>
</table>
* * *
#### vpcspkr *[hz:][ms]* ######
Generate a tone using the built in speaker.
<table>
<tr><td width="125pt"></td><td>No output.</td></tr>
<tr><td><i>hz:ms</i></td><td>Use the PC Speaker to generate a <b><i>hz</i></b> frequency tone. 
Then, delay for <b><i>ms</i></b> milliseconds. (Note: 0 frequency turns off speaker. If no frequency is provided
then 0 is assumed)</td></tr>
<tr><td><i>tba</i></td><td><i>(Still under development, more to be announced)</i></td></tr>
</table>
* * *
#### vversion *[options]* ######
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
<tr><td><b>/A <i>n</i></a></td><td>Set text attribute to <b><i>n</i></b>.</td></tr>
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
<tr><td><b>/A <i>n</i></a></td><td>Set text attribute to <b><i>n</i></b> for selected item.</td></tr>
<tr><td><b>/B <i>color</i></b></td><td>Set the background text attribute to 
<b><i>color</i></b> for selected item.</td></tr>
<tr><td><b>/F <i>color</i></b></td><td>Set the forground text attribute to 
<b><i>color</i></b> for selected item.</td></tr>
<tr><td><b>/D <i>n</i></a></td><td>Preselect item number <b><i>n</i></b> 
as the default choice.</td></tr>
<tr><td><i>type</i></td><td>Direct keypress selection type.<br>
	 <b><i>off</i></b> Select with only arrow keys.<br>
	 <b><i>auto</i></b> Detect direct jump characters. (Default)<br>
	 <b><i>alpha</i></b> Jump to selections using A-Z.<br>
	 <b><i>digit</i></b> Jump to selections using 1-9 (+0).<br>
<tr><td><b>/Q</td><td>Query for result. When the choice is made, it's text will be
sent to STDOUT.</td></tr>
<tr><td><b>/T <i>seconds</i></a></td><td>Delay in <b><i>seconds</i></b> before the default item is automatically selected (0-3600). 
Note that even if the user navigates to a different item, the original default item will be
selected when the timeout is achieved.</td></tr>
<tr><td><i>tba</i></td><td><i>(Still under development, more to be announced)</i></td></tr>
</td></tr></table>
* * *
#### vline ######
TBA
* * *
#### vpause ######
TBA
* * *
#### vinfo ######
TBA
* * *
#### vmode ######
TBA
* * *
#### vview ######
TBA
* * *
#### vask ######
TBA
