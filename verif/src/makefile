CC  	:= sdcc
SRC 	:= $(wildcard *.c)
OBJ 	:= $(patsubst %.c,%.hex,$(SRC))
DBG 	:= $(patsubst %.c,%.disasm,$(SRC))

all: $(OBJ) $(DBG)

.SECONDARY:

%.ihx: %.c
	python ~/ice51/verif//utils/output_checks.py $< 
	$(CC) $< -I ~/ice51/verif/inc/
	
%.hex: %.ihx
	python ~/ice51/verif/utils/output_hex.py $< > $@

%.disasm: %.ihx
	/usr/share/sdcc/scripts/mcs51-disasm.pl $< > $@


.PHONY: clean
clean:
	rm -f *.checks *.hex *.asm *.ihx *.lk *.lst *.map *.mem *.rel *.rst *.sym *.disasm
