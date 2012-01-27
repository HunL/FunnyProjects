all:a clean

CC=gcc

CFLAGS=`pkg-config gtk+-2.0 --cflags`
LDFLAGS=`pkg-config gtk+-2.0 --libs`

a.o:a.c
#	$(CC) -o a a.c $(CFLAGS)

a:a.o
	$(CC) $(LDFLAGS) -o $@ a.o 

clean:
	rm -rf *.o
