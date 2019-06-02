CC  	:= sdcc
SRC 	:= $(wildcard *.c)
OBJ 	:= $(patsubst %.c,%.hex,$(SRC))

all: $(OBJ)

.SECONDARY:

%.asm: %.c
	$(CC) $<
	
%.lst: %.asm
	sdas8051 -plosgffw $<

%.hex: %.lst
	python ../utils/lst_to_hex.py $< > $@

.PHONY: clean
clean:
	rm -f *.hex *.asm *.ihx *.lk *.lst *.map *.mem *.rel *.rst *.sym
