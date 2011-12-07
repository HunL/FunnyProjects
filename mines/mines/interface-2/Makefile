all:b clean

CC=gcc

CFLAGS=`pkg-config gtk+-2.0 --cflags`
LDFLAGS=`pkg-config gtk+-2.0 --libs`

b.o:b.c
#	$(CC) -o a a.c $(CFLAGS)

b:b.o
	$(CC) $(LDFLAGS) -o $@ b.o 

clean:
	rm -rf *.o
