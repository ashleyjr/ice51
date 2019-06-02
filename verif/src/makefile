src = $(wildcard *.c)
obj = $(src:.c=)

myprog: $(obj)
	sdcc $^.c 
	sdas8051 -plosgffw $^.asm
	python ../utils/lst_to_hex.py $^.lst > $^.hex

