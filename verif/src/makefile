CC  	:= sdcc
SRC 	:= $(wildcard *.c)
OBJ 	:= $(patsubst %.c,%.hex,$(SRC))
DBG 	:= $(patsubst %.c,%.disasm,$(SRC))
CHK 	:= $(patsubst %.c,%.checks,$(SRC))
DRV 	:= $(patsubst %.c,%.drives,$(SRC))

all: $(OBJ) $(DBG) $(CHK) $(DRV)

.SECONDARY:

%.ihx: %.c
	$(CC) $< -I ~/ice51/verif/inc/
	
%.checks: %.c
	python ~/ice51/verif/utils/output_driver.py -s "Check Uart" -e "End" -l 128 -f $< > $@

%.drives: %.c
	python ~/ice51/verif/utils/output_driver.py -s "Drive Uart" -e "End" -l 128 -f $< > $@

%.hex: %.ihx
	python ~/ice51/verif/utils/output_hex.py $< > $@

%.disasm: %.ihx
	/usr/share/sdcc/scripts/mcs51-disasm.pl $< > $@


.PHONY: clean
clean:
	rm -f *.checks *.hex *.asm *.ihx *.lk *.lst *.map *.mem *.rel *.rst *.sym *.disasm
