*******************************************************************************
V8Power Tools
Copyright 2015-2020 Jerome Shidel
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
        FreeDOS(TM) 1.1 (http://www.freedos.org) or higher
        NASM for DOS version 2.14.02 (http://wwww.nasm.us) or newer

    Compiling:

        Insure the NASM directory is in your path spec.
        Download the latest sources from http://github.com/LoopZ/V8Power
        Run the mkV8.bat script.
        All executibles will be placed in newly created BIN directory.

    For lazy people, like me:

        Precompiled versions are available at http://up.lod.bz/V8Power.

===============================================================================

V8Power Tools Tested Compatibility

    FreeDOS 1.1+

Limited compatiblilty of advanced features (no "set /p" batch support):

    MS-DOS 6.2 and 6.22
    PC-DOS 7.0, 7.01 and 2000
    DR-DOS 7.03
    DOSBox (i/o redirection or querying using stdout will NOT work using the
        built-in DOSBox shell. However, they work fine in DOSBox when a
        compatible shell like FreeCOM is used)
    Windows 3.11 Shell
    Windows 98 Shell and Command Line
    Windows XP SP3 Shell (except vcursor)

===============================================================================

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

Here is color table used for all **/A**, **/F** and **/B** switches:

    Decimal     Hex         Label (Not case specific)

    0           0x00        Black
    1           0x01        Blue
    2           0x02        Green
    3           0x03        Cyan
    4           0x04        Red
    5           0x05        Magenta
    6           0x06        Brown
    7           0x07        Gray / Grey
    8           0x08        DarkGray / DarkGrey
    9           0x09        LightBlue
    10          0x0a        LightGreen
    11          0x0b        LightCyan
    12          0x0c        LightRed
    13          0x0d        LightMagenta
    14          0x0e        Yellow
    15          0x0f        White


