*******************************************************************************
V8Power Tools for DOS examples
Copyright 2016 Jerome Shidel
Released under GPL v2.0 License.
*******************************************************************************

This Directory contains some basic techniques and examples for using the
V8Power Tools.

The V8Power Tools must be present in your PATH environment variable or located
in the same directory as these examples to use them.

As a rule, each example builds on the functionality demonstrated in the previous
example. Examples 01 - 05 should work under most DOS command shells. Example 06
and higher require I.O redirection and "SET /P" support by the shell. Neither of
these are supported by the default command shell provided with DOSBox.

-------------------------------------------------------------------------------

Example 0 (EX00.BAT)

Simple test to see if V8Power Tools are installed.

-------------------------------------------------------------------------------

Example 1 (EX01.BAT)

Simple test to determine if the batch file is running under the default DOSBox
command shell or other versions of DOS that don't support "set /p".

The DOSBox default command shell does not support I/O redirection at present.
This is not a limitation of V8PT. But, it is to be noted that shell does not
support it. Therefore, batch files that run on DOSBox must work around this
limitation. Things like querying the current cursor shape with "vcursor /q"
will function, but there is now way to save it's output. See Example 2 for a
possible workaround to this specific issue.

If I/O redirection or "SET /P" is still required, you could use an alternate
command shell under DOSBox that supports it. FreeDOS's FreeCOM shell is a good
choice that supports both and can be run inside DOSBox to completely work around
both issues.

-------------------------------------------------------------------------------

Example 2 (EX02.BAT)

Hiding and restoring the cursor.

-------------------------------------------------------------------------------

Example 3 (EX03.BAT)

Simple application style screen drawing with a delay and cleared screen on
exit.

-------------------------------------------------------------------------------

Example 4 (EX04.BAT)

Simple pause with timeout example.

-------------------------------------------------------------------------------

Example 5 (EX05.BAT)

Simple choice box with intentional to many choices that returns errorlevel
of selected choice. Please note that under DOSBox or under FreeDOS without
a memory manager installed, choices with multiple colors are flattened to
to a single color.

-------------------------------------------------------------------------------

Example 6 (EX06.BAT)

Simple choice box that returns the text of the selected choice to stdout.

-------------------------------------------------------------------------------

Example 7 (EX07.BAT)

Simple vmath example of counting to 10.

-------------------------------------------------------------------------------

Example 8 (EX08.BAT)

Progress bar updating and multi-window example.

-------------------------------------------------------------------------------

Example 9 (EX09.BAT)

Non-windowed hard disk drive status scanning example with Progress bar.

-------------------------------------------------------------------------------

Example 10 (EX10.BAT)

Choice Polling example.

-------------------------------------------------------------------------------

Example 11 (EX11.BAT)

Video and vesa mode demo.

-------------------------------------------------------------------------------

Example 12 (EX10.BAT)

Portable string lookups and language translations with vecho. As long as
V8Power Tools are present, it should mostly work in nearly all versions of DOS
command shells.
