*******************************************************************************
V8Power Tools for DOS examples
Copyright 2015 Jerome Shidel
Released under GPL v2.0 License.
*******************************************************************************

This Directory contains some basic techniques and examples for using the
V8Power Tools.

The V8Power Tools must be present in your PATH environment variable or located
in the same directory as these examples to use them.

-------------------------------------------------------------------------------

Example 0 (EX00.BAT)

Simple test to see if V8Power Tools are installed.

-------------------------------------------------------------------------------

Example 1 (EX01.BAT)

Simple test to determine if the batch file is running under DOSBox.

DOSBox does not support I/O redirection at present.  This is not a limitation
of V8PT. But, it is to be noted that DOSBox does not support it. Therefore, 
batch files that run on DOSBox must work around this limitation. Things like
querying the current cursor shape with "vcursor /q" will function, but there
is now way to save it's output. See Example 2 for a workaround to this issue.

-------------------------------------------------------------------------------

Example 2 (EX02.BAT)

Hiding and restoring the cursor.