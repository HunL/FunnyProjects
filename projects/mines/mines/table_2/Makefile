
# Makefile - compile the interface.c
all:mines clean  

CC=gcc

CFLAGS=`pkg-config gtk+-2.0 --cflags`
LDFLAGS=`pkg-config gtk+-2.0 --libs`

#object=*.o

mines:mines.o
	$(CC) $(LDFLAGS) -o $@ mines.o

mines.o:mines.c

clean:
	rm -rf *.o
