CC  	:= sdcc
SRC 	:= $(wildcard *.c)
OBJ 	:= $(patsubst %.c,%.hex,$(SRC))
DBG 	:= $(patsubst %.c,%.disasm,$(SRC))

all: $(OBJ) $(DBG)

.SECONDARY:

%.ihx: %.c
	python ../utils/output_checks.py $< 
	$(CC) $< -I ../inc/
	
%.hex: %.ihx
	python ../utils/output_hex.py $< > $@

%.disasm: %.ihx
	/usr/share/sdcc/scripts/mcs51-disasm.pl $< > $@


.PHONY: clean
clean:
	rm -f *.checks *.hex *.asm *.ihx *.lk *.lst *.map *.mem *.rel *.rst *.sym *.disasm
