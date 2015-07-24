@echo off

if not exist BIN mkdir BIN

NASM.EXE -ISOURCE\ SOURCE\VCLS.ASM -fbin -O9 -o BIN\VCLS.COM
