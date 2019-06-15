CC  	:= sdcc
SRC 	:= $(wildcard *.c)
OBJ 	:= $(patsubst %.c,%.hex,$(SRC))

all: $(OBJ)

.SECONDARY:

%.ihx: %.c
	python ../utils/output_checks.py $< 
	$(CC) $<
	
%.hex: %.ihx
	python ../utils/output_hex.py $< > $@

.PHONY: clean
clean:
	rm -f *.checks *.hex *.asm *.ihx *.lk *.lst *.map *.mem *.rel *.rst *.sym
