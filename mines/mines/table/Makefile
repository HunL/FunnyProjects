
# Makefile - compile the interface.c
all:interface clean  

CC=gcc

CFLAGS=`pkg-config gtk+-2.0 --cflags`
LDFLAGS=`pkg-config gtk+-2.0 --libs`

#object=*.o

interface:interface.o
	$(CC) $(LDFLAGS) -o $@ interface.o

interface.o:interface.c

clean:
	rm -rf *.o
