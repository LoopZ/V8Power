@echo off

call mkClean.bat
if not exist BIN mkdir BIN

echo V8 Power!
NASM.EXE -ISOURCE\ SOURCE\VCLS.ASM -fbin -O9 -o BIN\VCLS.COM
echo Inspecting tires...
NASM.EXE -ISOURCE\ SOURCE\VECHO.ASM -fbin -O9 -o BIN\VECHO.COM
bin\vecho "Examining " /f lightgreen fluids /f Gray ...
NASM.EXE -ISOURCE\ SOURCE\VFRAME.ASM -fbin -O9 -o BIN\VFRAME.COM
bin\vecho "Checking " /f yellow spark-plugs /f Gray ...
NASM.EXE -ISOURCE\ SOURCE\VGOTOXY.ASM -fbin -O9 -o BIN\VGOTOXY.COM
bin\vecho /n "Adjusting "
bin\vecho /f 13 carburetor /f gray ...
NASM.EXE -ISOURCE\ SOURCE\VCURSOR.ASM -fbin -O9 -o BIN\VCURSOR.COM
bin\vecho "Cleaning " /f 15 "air filter" /f gray ...
NASM.EXE -ISOURCE\ SOURCE\VDELAY.ASM -fbin -O9 -o BIN\VDELAY.COM
bin\vecho "Studying " /f 13 guages /f gray ...
NASM.EXE -ISOURCE\ SOURCE\VPROGRES.ASM -fbin -O9 -o BIN\VPROGRES.COM
bin\vecho "Tuning " /f 10 radio /f gray ...
NASM.EXE -ISOURCE\ SOURCE\VPCSPKR.ASM -fbin -O9 -o BIN\VPCSPKR.COM
bin\vecho "Referencing " /f 11 "Zen and the Art of Motorcycle Maintenance" /f gray ...
NASM.EXE -ISOURCE\ SOURCE\VINFO.ASM -fbin -O9 -o BIN\VINFO.COM

goto Done

NASM.EXE -ISOURCE\ SOURCE\VLINE.ASM -fbin -O9 -o BIN\VLINE.COM
NASM.EXE -ISOURCE\ SOURCE\VCHOICE.ASM -fbin -O9 -o BIN\VCHOICE.COM
NASM.EXE -ISOURCE\ SOURCE\VPAUSE.ASM -fbin -O9 -o BIN\VPAUSE.COM
NASM.EXE -ISOURCE\ SOURCE\VDISKINF.ASM -fbin -O9 -o BIN\VDISKINF.COM
NASM.EXE -ISOURCE\ SOURCE\VMODE.ASM -fbin -O9 -o BIN\VMODE.COM
NASM.EXE -ISOURCE\ SOURCE\VASK.ASM -fbin -O9 -o BIN\VASK.COM
NASM.EXE -ISOURCE\ SOURCE\VVIEW.ASM -fbin -O9 -o BIN\VVIEW.COM

:Done
echo Vroom, Vroom. Ready to roll!