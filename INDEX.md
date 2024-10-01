# V8Power

# V8Power Tools
#### Putting the power of an 8-cylinder engine under the hood of DOS batch files. ######
Copyright 2015-2024 Jerome Shidel.<br>
Open source, see License file.<br>

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
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[FreeDOS™ 1.1](http://www.freedos.org) or higher<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[NASM™ for DOS version 2.14.02](http://wwww.nasm.us) or newer <br>

#### &nbsp;&nbsp; Compiling ######

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Ensure the NASM directory is in your path spec. <br>
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
* DOSBox (i/o redirection or querying using stdout will NOT work using the built-in DOSBox shell. However, they work fine in DOSBox when a compatible shell like FreeCOM is used)<br>
* Windows 3.11 Shell<br>
* Windows 98 Shell and Command Line<br>
* Windows XP SP3 Shell (except vcursor)<br>

* * *

## V8Power Tools Usage

Here is some basic information regarding all utilities and how they operate.<br>
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


# Contributing

Thank you for you interest to improve this project.

### Contributing Language Translations

Please do not submit langauges translations directly to this project. The 
language files *(if any)* that may be in this source tree are **NOT** included 
in the software releases. If any exist in this project, they are for development
purposes only. When a version of this project is built and released, all 
language files are pulled directly from the versions in the 
[FD-NLS](https://github.com/shidel/fd-nls) project. If you wish to provide an 
additional language translation or make corrections to an existing one, please 
update the corresponding files in the [FD-NLS](https://github.com/shidel/fd-nls) 
project.
