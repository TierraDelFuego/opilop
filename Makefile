PREFIX = /p/polipo
BINDIR = $(PREFIX)/bin
MANDIR = $(PREFIX)/man
INFODIR = $(PREFIX)/info
CONFDIR = $(PREFIX)/etc
LOCAL_ROOT = $(PREFIX)/www
DISK_CACHE_ROOT = $(PREFIX)/cache

# To compile with Unix CC:

# CDEBUGFLAGS=-O

# To compile with GCC:

# CC = gcc
CDEBUGFLAGS = -Os -g -Wall -fno-strict-aliasing

# To compile on a pure POSIX system:

# CC = c89
# CC = c99
# CDEBUGFLAGS=-O

# To compile with icc 7, you need -restrict.  (Their bug.)

# CC=icc
# CDEBUGFLAGS = -O -restrict

# On System V (Solaris, HP/UX) you need the following:

# PLATFORM_DEFINES = -DSVR4

# On Solaris, you need the following:

# LDLIBS = -lsocket -lnsl -lresolv

# On mingw, you need

# EXE=.exe
# LDLIBS = -lws2_32

FILE_DEFINES = -DNO_SYSLOG -DNO_IPv6 -DLOCAL_ROOT=\"$(LOCAL_ROOT)/\" \
               -DDISK_CACHE_ROOT=\"$(DISK_CACHE_ROOT)/\"

# You may optionally also add any of the following to DEFINES:
#
#  -DNO_DISK_CACHE to compile out the on-disk cache and local web server;
#  -DNO_IPv6 to avoid using the RFC 3493 API and stick to stock
#      Berkeley sockets;
#  -DHAVE_IPv6 to force the use of the RFC 3493 API on systems other
#      than GNU/Linux and BSD (let me know if it works);
#  -DNO_FANCY_RESOLVER to compile out the asynchronous name resolution
#      code;
#  -DNO_STANDARD_RESOLVER to compile out the code that falls back to
#      gethostbyname/getaddrinfo when DNS requests fail;
#  -DNO_TUNNEL to compile out the code that handles CONNECT requests;
#  -DNO_SOCKS to compile out the SOCKS gateway code.
#  -DNO_FORBIDDEN to compile out the all of the forbidden URL code
#  -DNO_REDIRECTOR to compile out the Squid-style redirector code
#  -DNO_SYSLOG to compile out logging to syslog

DEFINES = $(FILE_DEFINES) $(PLATFORM_DEFINES)

CFLAGS = $(MD5INCLUDES) $(CDEBUGFLAGS) $(DEFINES) $(EXTRA_DEFINES)

SRCS = util.c event.c io.c chunk.c atom.c object.c log.c diskcache.c main.c \
       config.c local.c http.c client.c server.c auth.c tunnel.c \
       http_parse.c parse_time.c dns.c forbidden.c \
       md5import.c md5.c ftsimport.c fts_compat.c socks.c mingw.c

OBJS = util.o event.o io.o chunk.o atom.o object.o log.o diskcache.o main.o \
       config.o local.o http.o client.o server.o auth.o tunnel.o \
       http_parse.o parse_time.o dns.o forbidden.o \
       md5import.o ftsimport.o socks.o mingw.o

polipo$(EXE): $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o polipo$(EXE) $(OBJS) $(MD5LIBS) $(LDLIBS)

ftsimport.o: ftsimport.c fts_compat.c

md5import.o: md5import.c md5.c

.PHONY: all install install.binary install.man

all: polipo$(EXE) polipo.info html/index.html localindex.html

install: install.binary install.man

install.binary: all
	mkdir -pv $(BINDIR)
	mkdir -pv $(LOCAL_ROOT)
	mkdir -pv $(CONFDIR)
	mkdir -pv $(LOCAL_ROOT)/doc
	mkdir -pv $(DISK_CACHE_ROOT)
	rm -f $(BINDIR)/polipo
	cp -fv config.sample $(CONFDIR)
	cp -fv polipo $(BINDIR)/
	cp -fv html/* $(LOCAL_ROOT)/doc
	cp -fv localindex.html $(LOCAL_ROOT)/index.html

install.man: all
	mkdir -pv $(MANDIR)/man1
	mkdir -pv $(INFODIR)
	cp -fv polipo.man $(MANDIR)/man1/polipo.1
	cp -fv polipo.info $(INFODIR)/
	install-info --info-dir=$(INFODIR) polipo.info

uninstall: uninstall.all

uninstall.all: all
	rm -fv $(BINDIR)/polipo

polipo.info: polipo.texi
	makeinfo polipo.texi

html/index.html: polipo.texi
	mkdir -pv html
	makeinfo --html -o html polipo.texi

polipo.html: polipo.texi
	makeinfo --html --no-split --no-headers -o polipo.html polipo.texi

polipo.pdf: polipo.texi
	texi2pdf polipo.texi

polipo.ps.gz: polipo.ps
	gzip -c polipo.ps > polipo.ps.gz

polipo.ps: polipo.dvi
	dvips -Pwww -o polipo.ps polipo.dvi

polipo.dvi: polipo.texi
	texi2dvi polipo.texi

polipo.man.html: polipo.man
	rman -f html polipo.man > polipo.man.html

TAGS: $(SRCS)
	etags $(SRCS)

.PHONY: clean

clean:
	-rm -fv polipo$(EXE) *.o *~ core TAGS gmon.out
	-rm -fv polipo.cp polipo.fn polipo.log polipo.vr
	-rm -fv polipo.cps polipo.info* polipo.pg polipo.toc polipo.vrs
	-rm -fv polipo.aux polipo.dvi polipo.ky polipo.ps polipo.tp
	-rm -fv polipo.dvi polipo.ps polipo.ps.gz polipo.pdf polipo.html
	-rm -rfv ./html/
	-rm -fv polipo.man.html
