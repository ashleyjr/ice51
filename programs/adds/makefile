CC  	:= sdcc
SRC 	:= $(wildcard *.py)
OBJ 	:= $(patsubst %.py,%.c,$(SRC))
HEX 	:= $(patsubst %.py,%.hex,$(SRC))
DRR 	:= $(patsubst %.py,%.driver,$(SRC))
CHK 	:= $(patsubst %.py,%.checks,$(SRC))
DRV 	:= $(patsubst %.py,%.drives,$(SRC))

all: $(OBJ) $(HEX) $(DRR) $(CHK) $(DRV)

.SECONDARY:

%.ihx: %.c
	$(CC) $< -I ~/ice51/verif/inc/

%.hex: %.ihx
	python ~/ice51/verif/utils/output_hex.py $< > $@

%.driver: %.py	
	python $< > $@

%.checks: %.driver
	python ~/ice51/verif/utils/output_driver.py -s "Check Uart" -e "End" -l 65536 -f $< > $@

%.drives: %.driver
	python ~/ice51/verif/utils/output_driver.py -s "Drive Uart" -e "End" -l 66536 -f $< > $@

%.hex: %.ihx
	python ~/ice51/verif/utils/output_hex.py $< > $@



.PHONY: clean
clean:
	rm -f *.driver *.drives *.checks *.hex *.asm *.ihx *.lk *.lst *.map *.mem *.rel *.rst *.sym *.disasm
