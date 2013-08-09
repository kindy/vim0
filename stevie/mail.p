if test -f 'MANIFEST' -a "${1}" != "-c" ; then 
  echo shar: Will not clobber existing file \"'MANIFEST'\"
else
echo shar: Extracting \"'MANIFEST'\" \(1044 characters\)
sed "s/^X//" >'MANIFEST' <<'END_OF_FILE'
X   File Name		Archive #	Description
X-----------------------------------------------------------
X MANIFEST                   1	This shipping list
X README                     1	
X alloc.c                    1	
X ascii.h                    1	
X cmdline.c                  2	
X edit.c                     2	
X fileio.c                   1	
X help.c                     2	
X hexchars.c                 1	
X keymap.h                   1	
X linefunc.c                 1	
X main.c                     2	
X makefile.os2               1	
X makefile.tos               1	
X makefile.usg               1	
X mark.c                     1	
X misccmds.c                 2	
X normal.c                   4	
X os2.c                      1	
X param.c                    1	
X param.h                    1	
X porting.doc                1	
X ptrfunc.c                  1	
X screen.c                   3	
X search.c                   3	
X source.doc                 1	
X stevie.doc                 3	
X term.h                     1	
X tos.c                      1	
X unix.c                     1	
END_OF_FILE
if test 1044 -ne `wc -c <'MANIFEST'`; then
    echo shar: \"'MANIFEST'\" unpacked with wrong size!
fi
# end of 'MANIFEST'
fi
if test -f 'README' -a "${1}" != "-c" ; then 
  echo shar: Will not clobber existing file \"'README'\"
else
echo shar: Extracting \"'README'\" \(1257 characters\)
sed "s/^X//" >'README' <<'END_OF_FILE'
STEVIE Source Release
X
This is a source release of the STEVIE editor, a public domain clone
of the UNIX editor 'vi'. The program was originally developed for the
Atari ST, but has been ported to UNIX and OS/2 as well.
X
To compile STEVIE, you'll also need Henry Spencer's regular expression
library.
X
The files included in this release are:
X
README
X	This file.
X
stevie.doc
X	Reference manual for STEVIE. Assumes familiarity with vi.
X
source.doc
X	Quick overview of the major data structures used.
X
porting.doc
X	Tips for porting STEVIE to other systems.
X
makefile.os2
makefile.usg
makefile.tos
X	Makefiles for OS/2, UNIX System V, and the Atari ST respectively.
X
os2.c
unix.c
tos.c
X	System-dependent routines for the same.
X
alloc.c ascii.h cmdline.c edit.c fileio.c help.c hexchars.c
keymap.h linefunc.c main.c mark.c misccmds.c normal.c param.c
param.h ptrfunc.c screen.c search.c stevie.h term.h
X
X	C source and header files for STEVIE.
X
To compile STEVIE for one of the provided systems:
X
X	1. Compile the regular expression library and install as
X	   appropriate for your system.
X
X	2. Edit the file 'stevie.h' to set the system defines as needed.
X
X	3. Check the makefile for your system, and modify as needed.
X
X	4. Compile.
X
Good Luck...
X
Tony Andrews
X3/12/88
END_OF_FILE
if test 1257 -ne `wc -c <'README'`; then
    echo shar: \"'README'\" unpacked with wrong size!
fi
# end of 'README'
fi
if test -f 'alloc.c' -a "${1}" != "-c" ; then 
  echo shar: Will not clobber existing file \"'alloc.c'\"
else
echo shar: Extracting \"'alloc.c'\" \(3967 characters\)
sed "s/^X//" >'alloc.c' <<'END_OF_FILE'
X/*
X * STevie - ST editor for VI enthusiasts.    ...Tim Thompson...twitch!tjt...
X *
X * Extensive modifications by:  Tony Andrews       onecom!wldrdg!tony
X *
X */
X
X#include "stevie.h"
X
X/*
X * This file contains various routines dealing with allocation and
X * deallocation of data structures.
X */
X
char *
alloc(size)
unsigned size;
X{
X	char *p;		/* pointer to new storage space */
X
X	p = malloc(size);
X	if ( p == (char *)NULL ) {	/* if there is no more room... */
X		emsg("alloc() is unable to find memory!");
X	}
X	return(p);
X}
X
char *
strsave(string)
char *string;
X{
X	return(strcpy(alloc((unsigned)(strlen(string)+1)),string));
X}
X
void
screenalloc()
X{
X	/*
X	 * If we're changing the size of the screen, free the old arrays
X	 */
X	if (Realscreen != NULL)
X		free(Realscreen);
X	if (Nextscreen != NULL)
X		free(Nextscreen);
X
X	Realscreen = malloc((unsigned)(Rows*Columns));
X	Nextscreen = malloc((unsigned)(Rows*Columns));
X}
X
X/*
X * Allocate and initialize a new line structure with room for
X * 'nchars' characters.
X */
LINE *
newline(nchars)
int	nchars;
X{
X	register LINE	*l;
X
X	if ((l = (LINE *) alloc(sizeof(LINE))) == NULL)
X		return (LINE *) NULL;
X
X	l->s = alloc(nchars);		/* the line is empty */
X	l->s[0] = NUL;
X	l->size = nchars;
X
X	l->prev = (LINE *) NULL;	/* should be initialized by caller */
X	l->next = (LINE *) NULL;
X
X	return l;
X}
X
X/*
X * filealloc() - construct an initial empty file buffer
X */
void
filealloc()
X{
X	if ((Filemem->linep = newline(1)) == NULL) {
X		fprintf(stderr,"Unable to allocate file memory!\n");
X		exit(1);
X	}
X	if ((Fileend->linep = newline(1)) == NULL) {
X		fprintf(stderr,"Unable to allocate file memory!\n");
X		exit(1);
X	}
X	Filemem->index = 0;
X	Fileend->index = 0;
X
X	Filemem->linep->next = Fileend->linep;
X	Fileend->linep->prev = Filemem->linep;
X
X	*Curschar = *Filemem;
X	*Topchar  = *Filemem;
X
X	Filemem->linep->num = 0;
X	Fileend->linep->num = 0xffff;
X
X	clrall();		/* clear all marks */
X}
X
X/*
X * freeall() - free the current buffer
X *
X * Free all lines in the current buffer.
X */
void
freeall()
X{
X	LINE	*lp, *xlp;
X
X	for (lp = Filemem->linep; lp != NULL ;lp = xlp) {
X		if (lp->s != NULL)
X			free(lp->s);
X		xlp = lp->next;
X		free(lp);
X	}
X
X	Curschar->linep = NULL;		/* clear pointers */
X	Filemem->linep = NULL;
X	Fileend->linep = NULL;
X}
X
X/*
X * bufempty() - return TRUE if the buffer is empty
X */
bool_t
bufempty()
X{
X	return (buf1line() && Filemem->linep->s[0] == NUL);
X}
X
X/*
X * buf1line() - return TRUE if there is only one line
X */
bool_t
buf1line()
X{
X	return (Filemem->linep->next == Fileend->linep);
X}
X
X/*
X * lineempty() - return TRUE if the current line is empty
X */
bool_t
lineempty()
X{
X	return (Curschar->linep->s[0] == NUL);
X}
X
X/*
X * endofline() - return TRUE if the given position is at end of line
X *
X * This routine will probably never be called with a position resting
X * on the NUL byte, but handle it correctly in case it happens.
X */
bool_t
endofline(p)
register LPTR	*p;
X{
X	return (p->linep->s[p->index] == NUL || p->linep->s[p->index+1] == NUL);
X}
X/*
X * canincrease(n) - returns TRUE if the current line can be increased 'n' bytes
X *
X * This routine returns immediately if the requested space is available.
X * If not, it attempts to allocate the space and adjust the data structures
X * accordingly. If everything fails it returns FALSE.
X */
bool_t
canincrease(n)
register int	n;
X{
X	register int	nsize;
X	register char	*s;		/* pointer to new space */
X
X	nsize = strlen(Curschar->linep->s) + 1 + n;	/* size required */
X
X	if (nsize <= Curschar->linep->size)
X		return TRUE;
X
X	/*
X	 * Need to allocate more space for the string. Allow some extra
X	 * space on the assumption that we may need it soon. This avoids
X	 * excessive numbers of calls to malloc while entering new text.
X	 */
X	if ((s = alloc(nsize + SLOP)) == NULL) {
X		emsg("Can't add anything, file is too big!");
X		State = NORMAL;
X		return FALSE;
X	}
X
X	Curschar->linep->size = nsize + SLOP;
X	strcpy(s, Curschar->linep->s);
X	free(Curschar->linep->s);
X	Curschar->linep->s = s;
X	
X	return TRUE;
X}
END_OF_FILE
if test 3967 -ne `wc -c <'alloc.c'`; then
    echo shar: \"'alloc.c'\" unpacked with wrong size!
fi
# end of 'alloc.c'
fi
if test -f 'ascii.h' -a "${1}" != "-c" ; then 
  echo shar: Will not clobber existing file \"'ascii.h'\"
else
echo shar: Extracting \"'ascii.h'\" \(358 characters\)
sed "s/^X//" >'ascii.h' <<'END_OF_FILE'
X/*
X * STEVIE - ST Editor for VI Enthusiasts   ...Tim Thompson...twitch!tjt...
X *
X * Extensive modifications by:  Tony Andrews       onecom!wldrdg!tony
X *
X */
X
X/*
X * Definitions of various common control characters
X */
X
X#define	NUL	'\0'
X#define	BS	'\010'
X#define	TAB	'\011'
X#define	NL	'\012'
X#define	CR	'\015'
X#define	ESC	'\033'
X
X#define	CTRL(x)	((x) & 0x1f)
END_OF_FILE
if test 358 -ne `wc -c <'ascii.h'`; then
    echo shar: \"'ascii.h'\" unpacked with wrong size!
fi
# end of 'ascii.h'
fi
if test -f 'fileio.c' -a "${1}" != "-c" ; then 
  echo shar: Will not clobber existing file \"'fileio.c'\"
else
echo shar: Extracting \"'fileio.c'\" \(4113 characters\)
sed "s/^X//" >'fileio.c' <<'END_OF_FILE'
X/*
X * STEVIE - ST Editor for VI Enthusiasts   ...Tim Thompson...twitch!tjt...
X *
X * Extensive modifications by:  Tony Andrews       onecom!wldrdg!tony
X *
X */
X
X#include "stevie.h"
X
void
filemess(s)
char *s;
X{
X	smsg("\"%s\" %s", (Filename == NULL) ? "" : Filename, s);
X}
X
void
renum()
X{
X	LPTR	*p;
X	unsigned int l = 0;
X
X	for (p = Filemem; p != NULL ;p = nextline(p), l += LINEINC)
X		p->linep->num = l;
X
X	Fileend->linep->num = 0xffff;
X}
X
X#ifdef	MEGAMAX
overlay "fileio"
X#endif
X
bool_t
readfile(fname,fromp,nochangename)
char	*fname;
LPTR	*fromp;
bool_t	nochangename;	/* if TRUE, don't change the Filename */
X{
X	FILE	*f, *fopen();
X	LINE	*curr;
X	char	buff[1024];
X	char	*p;
X	int	i, c;
X	long	nchars;
X	int	unprint = 0;
X	int	linecnt = 0;
X	bool_t	wasempty = bufempty();
X
X	curr = fromp->linep;
X
X	if ( ! nochangename )
X		Filename = strsave(fname);
X
X	if ( (f=fopen(fname,"r")) == NULL )
X		return TRUE;
X
X	filemess("");
X
X	for (i=nchars=0; (c=getc(f)) != EOF ;nchars++) {
X		if (c >= 0x80) {
X			c -= 0x80;
X			unprint++;
X		}
X
X		/*
X		 * Nulls are special, so they can't show up in the file.
X		 * We should count nulls seperate from other nasties, but
X		 * this is okay for now.
X		 */
X		if (c == NUL) {
X			unprint++;
X			continue;
X		}
X
X		if (c == '\n') {	/* process the completed line */
X			int	len;
X			LINE	*lp;
X
X			buff[i] = '\0';
X			len = strlen(buff) + 1;
X			if ((lp = newline(len)) == NULL)
X				exit(1);
X
X			strcpy(lp->s, buff);
X
X			curr->next->prev = lp;	/* new line to next one */
X			lp->next = curr->next;
X
X			curr->next = lp;	/* new line to prior one */
X			lp->prev = curr;
X
X			curr = lp;		/* new line becomes current */
X			i = 0;
X			linecnt++;
X		}
X		else
X			buff[i++] = c;
X	}
X	fclose(f);
X
X	/*
X	 * If the buffer was empty when we started, we have to go back
X	 * and remove the "dummy" line at Filemem and patch up the ptrs.
X	 */
X	if (wasempty) {
X		LINE	*dummy = Filemem->linep;	/* dummy line ptr */
X
X		free(dummy->s);				/* free string space */
X		Filemem->linep = Filemem->linep->next;
X		free(dummy);				/* free LINE struct */
X		Filemem->linep->prev = NULL;
X
X		Curschar->linep = Filemem->linep;
X		Topchar->linep  = Filemem->linep;
X	}
X
X	if ( unprint > 0 )
X		p="\"%s\" %d lines, %ld characters (%d un-printable))";
X	else
X		p="\"%s\" %d lines, %ld characters";
X
X	sprintf(buff, p, fname, linecnt, nchars, unprint);
X	msg(buff);
X	renum();
X	return FALSE;
X}
X
X
X/*
X * writeit - write to file 'fname' lines 'start' through 'end'
X *
X * If either 'start' or 'end' contain null line pointers, the default
X * is to use the start or end of the file respectively.
X */
bool_t
writeit(fname, start, end)
char	*fname;
LPTR	*start, *end;
X{
X	FILE	*f, *fopen();
X	FILE	*fopenb();		/* open in binary mode, where needed */
X	char	buff[80];
X	char	backup[16], *s;
X	long	nchars;
X	int	lines;
X	LPTR	*p;
X
X	sprintf(buff, "\"%s\"", fname);
X	msg(buff);
X
X	/*
X	 * Form the backup file name - change foo.* to foo.bak
X	 */
X	strcpy(backup, fname);
X	for (s = backup; *s && *s != '.' ;s++)
X		;
X	*s = NUL;
X	strcat(backup, ".bak");
X
X	/*
X	 * Delete any existing backup and move the current version
X	 * to the backup. For safety, we don't remove the backup
X	 * until the write has finished successfully. And if the
X	 * 'backup' option is set, leave it around.
X	 */
X	rename(fname, backup);
X
X
X	f = P(P_CR) ? fopen(fname, "w") : fopenb(fname, "w");
X
X	if ( f == NULL ) {
X		emsg("Can't open file for writing!");
X		return FALSE;
X	}
X
X	/*
X	 * If we were given a bound, start there. Otherwise just
X	 * start at the beginning of the file.
X	 */
X	if (start == NULL || start->linep == NULL)
X		p = Filemem;
X	else
X		p = start;
X
X	lines = nchars = 0;
X	do {
X		fprintf(f, "%s\n", p->linep->s);
X		nchars += strlen(p->linep->s) + 1;
X		lines++;
X
X		/*
X		 * If we were given an upper bound, and we just did that
X		 * line, then bag it now.
X		 */
X		if (end != NULL && end->linep != NULL) {
X			if (end->linep == p->linep)
X				break;
X		}
X
X	} while ((p = nextline(p)) != NULL);
X
X	fclose(f);
X	sprintf(buff,"\"%s\" %d lines, %ld characters", fname, lines, nchars);
X	msg(buff);
X	UNCHANGED;
X
X	/*
X	 * Remove the backup unless they want it left around
X	 */
X	if (!P(P_BK))
X		remove(backup);
X
X	return TRUE;
X}
END_OF_FILE
if test 4113 -ne `wc -c <'fileio.c'`; then
    echo shar: \"'fileio.c'\" unpacked with wrong size!
fi
# end of 'fileio.c'
fi
if test -f 'hexchars.c' -a "${1}" != "-c" ; then 
  echo shar: Will not clobber existing file \"'hexchars.c'\"
else
echo shar: Extracting \"'hexchars.c'\" \(3075 characters\)
sed "s/^X//" >'hexchars.c' <<'END_OF_FILE'
X/*
X * STevie - ST editor for VI enthusiasts.    ...Tim Thompson...twitch!tjt...
X *
X * Extensive modifications by:  Tony Andrews       onecom!wldrdg!tony
X *
X */
X
X#include "stevie.h"
X
X/*
X * This file shows how to display characters on the screen. This is
X * approach is something of an overkill. It's a remnant from the
X * original code that isn't worth messing with for now. TABS are
X * special-cased depending on the value of the "list" parameter.
X */
X
struct charinfo chars[] = {
X	/* 000 */	1, NULL,
X	/* 001 */	2, "^A",
X	/* 002 */	2, "^B",
X	/* 003 */	2, "^C",
X	/* 004 */	2, "^D",
X	/* 005 */	2, "^E",
X	/* 006 */	2, "^F",
X	/* 007 */	2, "^G",
X	/* 010 */	2, "^H",
X	/* 011 */	2, "^I",
X	/* 012 */	7, "[ERROR]",	/* shouldn't occur */
X	/* 013 */	2, "^K",
X	/* 014 */	2, "^L",
X	/* 015 */	2, "^M",
X	/* 016 */	2, "^N",
X	/* 017 */	2, "^O",
X	/* 020 */	2, "^P",
X	/* 021 */	2, "^Q",
X	/* 022 */	2, "^R",
X	/* 023 */	2, "^S",
X	/* 024 */	2, "^T",
X	/* 025 */	2, "^U",
X	/* 026 */	2, "^V",
X	/* 027 */	2, "^W",
X	/* 030 */	2, "^X",
X	/* 031 */	2, "^Y",
X	/* 032 */	2, "^Z",
X	/* 033 */	2, "^[",
X	/* 034 */	2, "^\\",
X	/* 035 */	2, "^]",
X	/* 036 */	2, "^^",
X	/* 037 */	2, "^_",
X	/* 040 */	1, NULL,
X	/* 041 */	1, NULL,
X	/* 042 */	1, NULL,
X	/* 043 */	1, NULL,
X	/* 044 */	1, NULL,
X	/* 045 */	1, NULL,
X	/* 046 */	1, NULL,
X	/* 047 */	1, NULL,
X	/* 050 */	1, NULL,
X	/* 051 */	1, NULL,
X	/* 052 */	1, NULL,
X	/* 053 */	1, NULL,
X	/* 054 */	1, NULL,
X	/* 055 */	1, NULL,
X	/* 056 */	1, NULL,
X	/* 057 */	1, NULL,
X	/* 060 */	1, NULL,
X	/* 061 */	1, NULL,
X	/* 062 */	1, NULL,
X	/* 063 */	1, NULL,
X	/* 064 */	1, NULL,
X	/* 065 */	1, NULL,
X	/* 066 */	1, NULL,
X	/* 067 */	1, NULL,
X	/* 070 */	1, NULL,
X	/* 071 */	1, NULL,
X	/* 072 */	1, NULL,
X	/* 073 */	1, NULL,
X	/* 074 */	1, NULL,
X	/* 075 */	1, NULL,
X	/* 076 */	1, NULL,
X	/* 077 */	1, NULL,
X	/* 100 */	1, NULL,
X	/* 101 */	1, NULL,
X	/* 102 */	1, NULL,
X	/* 103 */	1, NULL,
X	/* 104 */	1, NULL,
X	/* 105 */	1, NULL,
X	/* 106 */	1, NULL,
X	/* 107 */	1, NULL,
X	/* 110 */	1, NULL,
X	/* 111 */	1, NULL,
X	/* 112 */	1, NULL,
X	/* 113 */	1, NULL,
X	/* 114 */	1, NULL,
X	/* 115 */	1, NULL,
X	/* 116 */	1, NULL,
X	/* 117 */	1, NULL,
X	/* 120 */	1, NULL,
X	/* 121 */	1, NULL,
X	/* 122 */	1, NULL,
X	/* 123 */	1, NULL,
X	/* 124 */	1, NULL,
X	/* 125 */	1, NULL,
X	/* 126 */	1, NULL,
X	/* 127 */	1, NULL,
X	/* 130 */	1, NULL,
X	/* 131 */	1, NULL,
X	/* 132 */	1, NULL,
X	/* 133 */	1, NULL,
X	/* 134 */	1, NULL,
X	/* 135 */	1, NULL,
X	/* 136 */	1, NULL,
X	/* 137 */	1, NULL,
X	/* 140 */	1, NULL,
X	/* 141 */	1, NULL,
X	/* 142 */	1, NULL,
X	/* 143 */	1, NULL,
X	/* 144 */	1, NULL,
X	/* 145 */	1, NULL,
X	/* 146 */	1, NULL,
X	/* 147 */	1, NULL,
X	/* 150 */	1, NULL,
X	/* 151 */	1, NULL,
X	/* 152 */	1, NULL,
X	/* 153 */	1, NULL,
X	/* 154 */	1, NULL,
X	/* 155 */	1, NULL,
X	/* 156 */	1, NULL,
X	/* 157 */	1, NULL,
X	/* 160 */	1, NULL,
X	/* 161 */	1, NULL,
X	/* 162 */	1, NULL,
X	/* 163 */	1, NULL,
X	/* 164 */	1, NULL,
X	/* 165 */	1, NULL,
X	/* 166 */	1, NULL,
X	/* 167 */	1, NULL,
X	/* 170 */	1, NULL,
X	/* 171 */	1, NULL,
X	/* 172 */	1, NULL,
X	/* 173 */	1, NULL,
X	/* 174 */	1, NULL,
X	/* 175 */	1, NULL,
X	/* 176 */	1, NULL,
X	/* 177 */	5, "[DEL]",
X};
END_OF_FILE
if test 3075 -ne `wc -c <'hexchars.c'`; then
    echo shar: \"'hexchars.c'\" unpacked with wrong size!
fi
# end of 'hexchars.c'
fi
if test -f 'keymap.h' -a "${1}" != "-c" ; then 
  echo shar: Will not clobber existing file \"'keymap.h'\"
else
echo shar: Extracting \"'keymap.h'\" \(1008 characters\)
sed "s/^X//" >'keymap.h' <<'END_OF_FILE'
X/*
X * STEVIE - ST Editor for VI Enthusiasts   ...Tim Thompson...twitch!tjt...
X *
X * Extensive modifications by:  Tony Andrews       onecom!wldrdg!tony
X *
X */
X
X/*
X * Keycode definitions for special keys
X *
X * On systems that have any of these keys, the routine 'inchar' in the
X * machine-dependent code should return one of the codes here.
X */
X
X#define	K_HELP		0x80
X#define	K_UNDO		0x81
X#define	K_INSERT	0x82
X#define	K_HOME		0x83
X#define	K_UARROW	0x84
X#define	K_DARROW	0x85
X#define	K_LARROW	0x86
X#define	K_RARROW	0x87
X#define	K_CGRAVE	0x88	/* control grave accent */
X
X#define	K_F1		0x91	/* function keys */
X#define	K_F2		0x92
X#define	K_F3		0x93
X#define	K_F4		0x94
X#define	K_F5		0x95
X#define	K_F6		0x96
X#define	K_F7		0x97
X#define	K_F8		0x98
X#define	K_F9		0x99
X#define	K_F10		0x9a
X
X#define	K_SF1		0xa1	/* shifted function keys */
X#define	K_SF2		0xa2
X#define	K_SF3		0xa3
X#define	K_SF4		0xa4
X#define	K_SF5		0xa5
X#define	K_SF6		0xa6
X#define	K_SF7		0xa7
X#define	K_SF8		0xa8
X#define	K_SF9		0xa9
X#define	K_SF10		0xaa
END_OF_FILE
if test 1008 -ne `wc -c <'keymap.h'`; then
    echo shar: \"'keymap.h'\" unpacked with wrong size!
fi
# end of 'keymap.h'
fi
if test -f 'linefunc.c' -a "${1}" != "-c" ; then 
  echo shar: Will not clobber existing file \"'linefunc.c'\"
else
echo shar: Extracting \"'linefunc.c'\" \(1590 characters\)
sed "s/^X//" >'linefunc.c' <<'END_OF_FILE'
X/*
X * STevie - ST editor for VI enthusiasts.    ...Tim Thompson...twitch!tjt...
X *
X * Extensive modifications by:  Tony Andrews       onecom!wldrdg!tony
X *
X */
X
X#include "stevie.h"
X
X/*
X * nextline(curr)
X *
X * Return a pointer to the beginning of the next line after the one
X * referenced by 'curr'. Return NULL if there is no next line (at EOF).
X */
X
LPTR *
nextline(curr)
LPTR *curr;
X{
X	static	LPTR	next;
X
X	if (curr->linep->next != Fileend->linep) {
X		next.index = 0;
X		next.linep = curr->linep->next;
X		return &next;
X	}
X	return (LPTR *) NULL;
X}
X
X/*
X * prevline(curr)
X *
X * Return a pointer to the beginning of the line before the one
X * referenced by 'curr'. Return NULL if there is no prior line.
X */
X
LPTR *
prevline(curr)
LPTR *curr;
X{
X	static	LPTR	prev;
X
X	if (curr->linep->prev != NULL) {
X		prev.index = 0;
X		prev.linep = curr->linep->prev;
X		return &prev;
X	}
X	return (LPTR *) NULL;
X}
X
X/*
X * coladvance(p,col)
X *
X * Try to advance to the specified column, starting at p.
X */
X
LPTR *
coladvance(p, col)
LPTR	*p;
int	col;
X{
X	static	LPTR	lp;
X	int	c, in;
X
X	lp.linep = p->linep;
X	lp.index = p->index;
X
X	/* If we're on a blank ('\n' only) line, we can't do anything */
X	if (lp.linep->s[lp.index] == '\0')
X		return &lp;
X	/* try to advance to the specified column */
X	for ( c=0; col-- > 0; c++ ) {
X		/* Count a tab for what it's worth (if list mode not on) */
X		if ( gchar(&lp) == TAB && !P(P_LS) ) {
X			in = ((P(P_TS)-1) - c%P(P_TS));
X			col -= in;
X			c += in;
X		}
X		/* Don't go past the end of */
X		/* the file or the line. */
X		if (inc(&lp)) {
X			dec(&lp);
X			break;
X		}
X	}
X	return &lp;
X}
END_OF_FILE
if test 1590 -ne `wc -c <'linefunc.c'`; then
    echo shar: \"'linefunc.c'\" unpacked with wrong size!
fi
# end of 'linefunc.c'
fi
if test -f 'makefile.os2' -a "${1}" != "-c" ; then 
  echo shar: Will not clobber existing file \"'makefile.os2'\"
else
echo shar: Extracting \"'makefile.os2'\" \(1343 characters\)
sed "s/^X//" >'makefile.os2' <<'END_OF_FILE'
X#
X# Makefile for OS/2
X#
X# The make command with OS/2 is really stupid.
X#
X
LIBS = ..\regexp\regexp.obj ..\regexp\regsub.obj
X
X#
X# Compact model lets us edit large files, but keep small model code
X#
MODEL= -AC
CFLAGS = $(MODEL) -I..\regexp
X
MACH=	os2.obj
X
OBJ=	main.obj edit.obj linefunc.obj normal.obj cmdline.obj hexchars.obj \
X	misccmds.obj help.obj ptrfunc.obj search.obj alloc.obj \
X	mark.obj screen.obj fileio.obj param.obj $(MACH)
X
main.obj:	main.c
X	cl -c $(CFLAGS) main.c
X
alloc.obj : alloc.c
X	cl -c $(CFLAGS) alloc.c
X
edit.obj : edit.c
X	cl -c $(CFLAGS) edit.c
X
linefunc.obj : linefunc.c
X	cl -c $(CFLAGS) linefunc.c
X
normal.obj : normal.c
X	cl -c $(CFLAGS) normal.c
X
cmdline.obj : cmdline.c
X	cl -c $(CFLAGS) cmdline.c
X
hexchars.obj : hexchars.c
X	cl -c $(CFLAGS) hexchars.c
X
misccmds.obj : misccmds.c
X	cl -c $(CFLAGS) misccmds.c
X
help.obj : help.c
X	cl -c $(CFLAGS) help.c
X
ptrfunc.obj : ptrfunc.c
X	cl -c $(CFLAGS) ptrfunc.c
X
search.obj : search.c
X	cl -c $(CFLAGS) search.c
X
mark.obj : mark.c
X	cl -c $(CFLAGS) mark.c
X
screen.obj : screen.c
X	cl -c $(CFLAGS) screen.c
X
fileio.obj : fileio.c
X	cl -c $(CFLAGS) fileio.c
X
param.obj : param.c
X	cl -c $(CFLAGS) param.c
X
os2.obj : os2.c
X	cl -c $(CFLAGS) os2.c
X
stevie.exe : $(OBJ)
X	cl $(MODEL) *.obj $(LIBS) -o stevie.exe
X	copy stevie.exe rstevie.exe
X	bind rstevie.exe \lib\api.lib \lib\doscalls.lib
END_OF_FILE
if test 1343 -ne `wc -c <'makefile.os2'`; then
    echo shar: \"'makefile.os2'\" unpacked with wrong size!
fi
# end of 'makefile.os2'
fi
if test -f 'makefile.tos' -a "${1}" != "-c" ; then 
  echo shar: Will not clobber existing file \"'makefile.tos'\"
else
echo shar: Extracting \"'makefile.tos'\" \(815 characters\)
sed "s/^X//" >'makefile.tos' <<'END_OF_FILE'
X#
X# Makefile for the Atari ST - Megamax C compiler
X#
X
LIBS = \megamax\regexp.lib
X
CFLAGS = -DMEGAMAX
X
X#	Megamax rule
X.c.o:
X	mmcc $(CFLAGS) $<
X	mmimp $*.o
X	mmlib rv vi.lib $*.o
X
MACH=	tos.o
X
OBJ=	main.o edit.o linefunc.o normal.o cmdline.o hexchars.o \
X	misccmds.o help.o ptrfunc.o search.o alloc.o \
X	mark.o screen.o fileio.o param.o $(MACH)
X
all : stevie.ttp
X
stevie.ttp : $(OBJ)
X	$(LINKER) vi.lib $(LIBS) -o stevie.ttp
X
clean :
X	$(RM) $(OBJ) vi.lib
X
arc :
X	arc a vi.arc alloc.c ascii.h cmdline.c edit.c
X	arc a vi.arc fileio.c help.c hexchars.c keymap.h linefunc.c
X	arc a vi.arc main.c makefile.os2 makefile.tos makefile.usg mark.c
X	arc a vi.arc misccmds.c normal.c os2.c param.c param.h porting.doc
X	arc a vi.arc ptrfunc.c readme screen.c search.c source.doc stevie.doc
X	arc a vi.arc stevie.h term.h tos.c unix.c
END_OF_FILE
if test 815 -ne `wc -c <'makefile.tos'`; then
    echo shar: \"'makefile.tos'\" unpacked with wrong size!
fi
# end of 'makefile.tos'
fi
if test -f 'makefile.usg' -a "${1}" != "-c" ; then 
  echo shar: Will not clobber existing file \"'makefile.usg'\"
else
echo shar: Extracting \"'makefile.usg'\" \(346 characters\)
sed "s/^X//" >'makefile.usg' <<'END_OF_FILE'
X#
X# Makefile for UNIX (System V)
X#
X
LIBS = ../regexp/regexp.a
LDFLAGS=
X
CFLAGS = -I../regexp -O
X
MACH=	unix.o
X
OBJ=	main.o edit.o linefunc.o normal.o cmdline.o hexchars.o \
X	misccmds.o help.o ptrfunc.o search.o alloc.o \
X	mark.o screen.o fileio.o param.o $(MACH)
X
all : stevie
X
stevie : $(OBJ)
X	$(CC) $(OBJ) $(LIBS) -o stevie
X
clean :
X	rm $(OBJ)
END_OF_FILE
if test 346 -ne `wc -c <'makefile.usg'`; then
    echo shar: \"'makefile.usg'\" unpacked with wrong size!
fi
# end of 'makefile.usg'
fi
if test -f 'mark.c' -a "${1}" != "-c" ; then 
  echo shar: Will not clobber existing file \"'mark.c'\"
else
echo shar: Extracting \"'mark.c'\" \(2257 characters\)
sed "s/^X//" >'mark.c' <<'END_OF_FILE'
X/*
X * STevie - ST editor for VI enthusiasts.
X *
X * Extensive modifications by:  Tony Andrews       onecom!wldrdg!tony
X *
X */
X
X#include "stevie.h"
X
X#ifdef	MEGAMAX
overlay "mark"
X#endif
X
X/*
X * This file contains routines to maintain and manipulate marks.
X */
X
X#define	NMARKS	10		/* max. # of marks that can be saved */
X
struct	mark {
X	char	name;
X	LPTR	pos;
X};
X
static	struct	mark	mlist[NMARKS];
static	struct	mark	pcmark;		/* previous context mark */
static	bool_t	pcvalid = FALSE;	/* true if pcmark is valid */
X
X/*
X * setmark(c) - set mark 'c' at current cursor position
X *
X * Returns TRUE on success, FALSE if no room for mark or bad name given.
X */
bool_t
setmark(c)
char	c;
X{
X	int	i;
X
X	if (!isalpha(c))
X		return FALSE;
X
X	/*
X	 * If there is already a mark of this name, then just use the
X	 * existing mark entry.
X	 */
X	for (i=0; i < NMARKS ;i++) {
X		if (mlist[i].name == c) {
X			mlist[i].pos = *Curschar;
X			return TRUE;
X		}
X	}
X
X	/*
X	 * There wasn't a mark of the given name, so find a free slot
X	 */
X	for (i=0; i < NMARKS ;i++) {
X		if (mlist[i].name == NUL) {	/* got a free one */
X			mlist[i].name = c;
X			mlist[i].pos = *Curschar;
X			return TRUE;
X		}
X	}
X	return FALSE;
X}
X
X/*
X * setpcmark() - set the previous context mark to the current position
X */
void
setpcmark()
X{
X	pcmark.pos = *Curschar;
X	pcvalid = TRUE;
X}
X
X/*
X * getmark(c) - find mark for char 'c'
X *
X * Return pointer to LPTR or NULL if no such mark.
X */
LPTR *
getmark(c)
char	c;
X{
X	register int	i;
X
X	if (c == '\'' || c == '`')	/* previous context mark */
X		return pcvalid ? &(pcmark.pos) : (LPTR *) NULL;
X
X	for (i=0; i < NMARKS ;i++) {
X		if (mlist[i].name == c)
X			return &(mlist[i].pos);
X	}
X	return (LPTR *) NULL;
X}
X
X/*
X * clrall() - clear all marks
X *
X * Used mainly when trashing the entire buffer during ":e" type commands
X */
void
clrall()
X{
X	register int	i;
X
X	for (i=0; i < NMARKS ;i++)
X		mlist[i].name = NUL;
X	pcvalid = FALSE;
X}
X
X/*
X * clrmark(line) - clear any marks for 'line'
X *
X * Used any time a line is deleted so we don't have marks pointing to
X * non-existent lines.
X */
void
clrmark(line)
LINE	*line;
X{
X	register int	i;
X
X	for (i=0; i < NMARKS ;i++) {
X		if (mlist[i].pos.linep == line)
X			mlist[i].name = NUL;
X	}
X	if (pcvalid && (pcmark.pos.linep == line))
X		pcvalid = FALSE;
X}
END_OF_FILE
if test 2257 -ne `wc -c <'mark.c'`; then
    echo shar: \"'mark.c'\" unpacked with wrong size!
fi
# end of 'mark.c'
fi
if test -f 'os2.c' -a "${1}" != "-c" ; then 
  echo shar: Will not clobber existing file \"'os2.c'\"
else
echo shar: Extracting \"'os2.c'\" \(1581 characters\)
sed "s/^X//" >'os2.c' <<'END_OF_FILE'
X/*
X * OS/2 System-dependent routines.
X */
X
X#include "stevie.h"
X
X/*
X * inchar() - get a character from the keyboard
X */
int
inchar()
X{
X	int	c;
X
X	flushbuf();		/* flush any pending output */
X
X	c = getch();
X
X	if (c == 0x1e)		/* control-^ */
X		return K_CGRAVE;
X	else
X		return c;
X}
X
X#define	BSIZE	2048
static	char	outbuf[BSIZE];
static	int	bpos = 0;
X
flushbuf()
X{
X	if (bpos != 0)
X		write(1, outbuf, bpos);
X	bpos = 0;
X}
X
X/*
X * Macro to output a character. Used within this file for speed.
X */
X#define	outone(c)	outbuf[bpos++] = c; if (bpos >= BSIZE) flushbuf()
X
X/*
X * Function version for use outside this file.
X */
void
outchar(c)
register char	c;
X{
X	outbuf[bpos++] = c;
X	if (bpos >= BSIZE)
X		flushbuf();
X}
X
void
outstr(s)
register char	*s;
X{
X	while (*s) {
X		outone(*s++);
X	}
X}
X
void
beep()
X{
X	outone('\007');
X}
X
sleep(n)
int	n;
X{
X	extern	far pascal DOSSLEEP();
X
X	DOSSLEEP(1000L * n);
X}
X
void
delay()
X{
X	DOSSLEEP(500L);
X}
X
void
windinit()
X{
X	Columns = 80;
X	P(P_LI) = Rows = 25;
X}
X
void
windexit(r)
int r;
X{
X	flushbuf();
X	exit(r);
X}
X
void
windgoto(r, c)
register int	r, c;
X{
X	r += 1;
X	c += 1;
X
X	/*
X	 * Check for overflow once, to save time.
X	 */
X	if (bpos + 8 >= BSIZE)
X		flushbuf();
X
X	outbuf[bpos++] = '\033';
X	outbuf[bpos++] = '[';
X	if (r >= 10)
X		outbuf[bpos++] = r/10 + '0';
X	outbuf[bpos++] = r%10 + '0';
X	outbuf[bpos++] = ';';
X	if (c >= 10)
X		outbuf[bpos++] = c/10 + '0';
X	outbuf[bpos++] = c%10 + '0';
X	outbuf[bpos++] = 'H';
X}
X
XFILE *
fopenb(fname, mode)
char	*fname;
char	*mode;
X{
X	FILE	*fopen();
X	char	modestr[16];
X
X	sprintf(modestr, "%sb", mode);
X	return fopen(fname, modestr);
X}
END_OF_FILE
if test 1581 -ne `wc -c <'os2.c'`; then
    echo shar: \"'os2.c'\" unpacked with wrong size!
fi
# end of 'os2.c'
fi
if test -f 'param.c' -a "${1}" != "-c" ; then 
  echo shar: Will not clobber existing file \"'param.c'\"
else
echo shar: Extracting \"'param.c'\" \(3830 characters\)
sed "s/^X//" >'param.c' <<'END_OF_FILE'
X/*
X * STEVIE - ST Editor for VI Enthusiasts   ...Tim Thompson...twitch!tjt...
X *
X * Extensive modifications by:  Tony Andrews       onecom!wldrdg!tony
X *
X */
X
X/*
X * Code to handle user-settable parameters. This is all pretty much table-
X * driven. To add a new parameter, put it in the params array, and add a
X * macro for it in param.h. If it's a numeric parameter, add any necessary
X * bounds checks to doset(). String parameters aren't currently supported.
X */
X
X#include "stevie.h"
X
struct	param	params[] = {
X
X	{ "tabstop",	"ts",		8,	P_NUM },
X	{ "scroll",	"scroll",	12,	P_NUM },
X	{ "report",	"report",	5,	P_NUM },
X	{ "lines",	"lines",	25,	P_NUM },
X
X	{ "vbell",	"vb",		TRUE,	P_BOOL },
X	{ "showmatch",	"sm",		FALSE,	P_BOOL },
X	{ "wrapscan",	"ws",		TRUE,	P_BOOL },
X	{ "errorbells",	"eb",		FALSE,	P_BOOL },
X	{ "showmode",	"mo",		FALSE,	P_BOOL },
X	{ "backup",	"bk",		FALSE,	P_BOOL },
X	{ "return",	"cr",		TRUE,	P_BOOL },
X	{ "list",	"list",		FALSE,	P_BOOL },
X#if 0
X	/* not yet implemented */
X	{ "autoindent",	"ai",		FALSE,	P_BOOL },
X#endif
X	{ "",		"",		0,	0, }		/* end marker */
X
X};
X
static	void	showparms();
X
void
doset(arg, inter)
char	*arg;		/* parameter string */
bool_t	inter;		/* TRUE if called interactively */
X{
X	int	i;
X	char	*s;
X	bool_t	did_lines = FALSE;
X
X	bool_t	state = TRUE;		/* new state of boolean parms. */
X
X	if (arg == NULL) {
X		showparms(FALSE);
X		return;
X	}
X	if (strncmp(arg, "all", 3) == 0) {
X		showparms(TRUE);
X		return;
X	}
X	if (strncmp(arg, "no", 2) == 0) {
X		state = FALSE;
X		arg += 2;
X	}
X
X	for (i=0; params[i].fullname[0] != NUL ;i++) {
X		s = params[i].fullname;
X		if (strncmp(arg, s, strlen(s)) == 0)	/* matched full name */
X			break;
X		s = params[i].shortname;
X		if (strncmp(arg, s, strlen(s)) == 0)	/* matched short name */
X			break;
X	}
X
X	if (params[i].fullname[0] != NUL) {	/* found a match */
X		if (params[i].flags & P_NUM) {
X			did_lines = (i == P_LI);
X			if (inter && (arg[strlen(s)] != '=' || state == FALSE))
X				emsg("Invalid set of numeric parameter");
X			else {
X				params[i].value = atoi(arg+strlen(s)+1);
X				params[i].flags |= P_CHANGED;
X			}
X		} else /* boolean */ {
X			if (inter && (arg[strlen(s)] == '='))
X				emsg("Invalid set of boolean parameter");
X			else {
X				params[i].value = state;
X				params[i].flags |= P_CHANGED;
X			}
X		}
X	} else {
X		if (inter)
X			emsg("Unrecognized 'set' option");
X	}
X
X	/*
X	 * Update the screen in case we changed something like "tabstop"
X	 * or "list" that will change its appearance.
X	 */
X	if (inter)
X		updatescreen();
X
X	if (did_lines) {
X		Rows = P(P_LI);
X		screenalloc();		/* allocate new screen buffers */
X		screenclear();
X		updatescreen();
X	}
X	/*
X	 * Check the bounds for numeric parameters here
X	 */
X	if (P(P_TS) <= 0 || P(P_TS) > 32) {
X		if (inter)
X			emsg("Invalid tab size specified");
X		P(P_TS) = 8;
X		return;
X	}
X
X	if (P(P_SS) <= 0 || P(P_SS) > Rows) {
X		if (inter)
X			emsg("Invalid scroll size specified");
X		P(P_SS) = 12;
X		return;
X	}
X
X	/*
X	 * Check for another argument, and call doset() recursively, if
X	 * found. If any argument results in an error, no further
X	 * parameters are processed.
X	 */
X	while (*arg != ' ' && *arg != '\t') {	/* skip to next white space */
X		if (*arg == NUL)
X			return;			/* end of parameter list */
X		arg++;
X	}
X	while (*arg == ' ' || *arg == '\t')	/* skip to next non-white */
X		arg++;
X
X	if (*arg)
X		doset(arg);	/* recurse on next parameter, if present */
X}
X
static	void
showparms(all)
bool_t	all;	/* show ALL parameters */
X{
X	struct	param	*p;
X	char	buf[64];
X
X	gotocmd(TRUE, TRUE, 0);
X	outstr("Parameters:\r\n");
X
X	for (p = &params[0]; p->fullname[0] != NUL ;p++) {
X		if (!all && ((p->flags & P_CHANGED) == 0))
X			continue;
X		if (p->flags & P_BOOL)
X			sprintf(buf, "\t%s%s\r\n",
X				(p->value ? "" : "no"), p->fullname);
X		else
X			sprintf(buf, "\t%s=%d\r\n", p->fullname, p->value);
X
X		outstr(buf);
X	}
X	wait_return();
X}
END_OF_FILE
if test 3830 -ne `wc -c <'param.c'`; then
    echo shar: \"'param.c'\" unpacked with wrong size!
fi
# end of 'param.c'
fi
if test -f 'param.h' -a "${1}" != "-c" ; then 
  echo shar: Will not clobber existing file \"'param.h'\"
else
echo shar: Extracting \"'param.h'\" \(1311 characters\)
sed "s/^X//" >'param.h' <<'END_OF_FILE'
X/*
X * STEVIE - ST Editor for VI Enthusiasts   ...Tim Thompson...twitch!tjt...
X *
X * Extensive modifications by:  Tony Andrews       onecom!wldrdg!tony
X *
X */
X
X/*
X * Settable parameters
X */
X
struct	param {
X	char	*fullname;	/* full parameter name */
X	char	*shortname;	/* permissible abbreviation */
X	int	value;		/* parameter value */
X	int	flags;
X};
X
extern	struct	param	params[];
X
X/*
X * Flags
X */
X#define	P_BOOL		0x01	/* the parameter is boolean */
X#define	P_NUM		0x02	/* the parameter is numeric */
X#define	P_CHANGED	0x04	/* the parameter has been changed */
X
X/*
X * The following are the indices in the params array for each parameter
X */
X
X/*
X * Numeric parameters
X */
X#define	P_TS		0	/* tab size */
X#define	P_SS		1	/* scroll size */
X#define	P_RP		2	/* report */
X#define	P_LI		3	/* lines */
X
X/*
X * Boolean parameters
X */
X#define	P_VB		4	/* visual bell */
X#define	P_SM		5	/* showmatch */
X#define	P_WS		6	/* wrap scan */
X#define	P_EB		7	/* error bells */
X#define	P_MO		8	/* show mode */
X#define	P_BK		9	/* make backups when writing out files */
X#define	P_CR		10	/* use cr-lf to terminate lines on writes */
X#define	P_LS		11	/* show tabs and newlines graphically */
X
X#if 0
X#define	P_AI		12	/* auto-indent (not really in yet) */
X#endif
X
X/*
X * Macro to get the value of a parameter
X */
X#define	P(n)	(params[n].value)
END_OF_FILE
if test 1311 -ne `wc -c <'param.h'`; then
    echo shar: \"'param.h'\" unpacked with wrong size!
fi
# end of 'param.h'
fi
if test -f 'porting.doc' -a "${1}" != "-c" ; then 
  echo shar: Will not clobber existing file \"'porting.doc'\"
else
echo shar: Extracting \"'porting.doc'\" \(2404 characters\)
sed "s/^X//" >'porting.doc' <<'END_OF_FILE'
X
X		 Release Notes for STEVIE - Version 3.10
X
X		   Atari ST Editor for VI Enthusiasts
X
X			        Porting
X
X
X			      Tony Andrews
X
X			 	 3/6/88
X
X
X	Porting the editor is a relatively simple task. Most of the
code is pretty machine-independent. For each environment, there is
a file of routines that perform various low-level operations that
tend to vary a lot from one machine to another. Another file contains
the escape sequences to be used for each machine.
X
X	The machine-dependent files currently used are:
X
tos.c:	Atari ST - ifdef for either Megamax or Alcyon
X
unix.c:	UNIX System V
X
os2.c:	Microsoft OS/2
X
X
X	Each of these files are around 150 lines long and deal with
low-level issues like character I/O to the terminal, terminal
initialization, cursor addressing, and so on. There are different
tradeoffs to be made depending on the environment. For example, the
UNIX version buffers terminal output because of the relatively high
overhead of system calls. A quick look at the files will make it clear
what needs to be done in a new environment.
X
X	Terminal escape sequences are in the file "term.h". These are
defined statically, for the time being. There is some discussion in
term.h regarding which sequences are optional and which are not. The
editor is somewhat flexible in dealing with a lack of terminal
capabilities.
X
X	Because not all C compilers support command line macro definitions,
the #define's for system-specific macros are placed at the beginning of the
file 'stevie.h'. If you port to a new system, add another line there to
define the macro you choose for your port.
X
X	The basic process for doing a new port is:
X
X	1. Come up with a macro name to use when ifdef'ing your system-
X	   specific changes. Add a line at the top of 'stevie.h' to define
X	   the macro name you've chosen.
X
X	2. Look at unix.c, tos.c, and os2.c and copy the one that comes
X	   closest to working on your system. Then modify your new file
X	   as needed.
X
X	3. Look at term.h and edit the file appropriately adding a new
X	   set of escape sequence definitions for your system.
X
X	4. If you haven't already, get a copy of Henry Spencer's regular
X	   expression library and compile it. This has been very simple
X	   every time I've done it.
X
X	5. Compiling and debug the editor.
X
X
X	In most cases it should really be that simple. I've done two
ports (UNIX and OS/2) and both were complete in just a couple of hours.
END_OF_FILE
if test 2404 -ne `wc -c <'porting.doc'`; then
    echo shar: \"'porting.doc'\" unpacked with wrong size!
fi
# end of 'porting.doc'
fi
if test -f 'ptrfunc.c' -a "${1}" != "-c" ; then 
  echo shar: Will not clobber existing file \"'ptrfunc.c'\"
else
echo shar: Extracting \"'ptrfunc.c'\" \(2571 characters\)
sed "s/^X//" >'ptrfunc.c' <<'END_OF_FILE'
X/*
X * STevie - ST editor for VI enthusiasts.    ...Tim Thompson...twitch!tjt...
X *
X * Extensive modifications by:  Tony Andrews       onecom!wldrdg!tony
X *
X */
X
X#include "stevie.h"
X
X/*
X * The routines in this file attempt to imitate many of the operations
X * that used to be performed on simple character pointers and are now
X * performed on LPTR's. This makes it easier to modify other sections
X * of the code. Think of an LPTR as representing a position in the file.
X * Positions can be incremented, decremented, compared, etc. through
X * the functions implemented here.
X */
X
X/*
X * inc(p)
X *
X * Increment the line pointer 'p' crossing line boundaries as necessary.
X * Return 1 when crossing a line, -1 when at end of file, 0 otherwise.
X */
int
inc(lp)
register LPTR	*lp;
X{
X	register char *p = &(lp->linep->s[lp->index]);
X
X	if (*p != NUL) {			/* still within line */
X		lp->index++;
X		return ((p[1] != NUL) ? 0 : 1);
X	}
X
X	if (lp->linep->next != Fileend->linep) {  /* there is a next line */
X		lp->index = 0;
X		lp->linep = lp->linep->next;
X		return 1;
X	}
X
X	return -1;
X}
X
X/*
X * dec(p)
X *
X * Decrement the line pointer 'p' crossing line boundaries as necessary.
X * Return 1 when crossing a line, -1 when at start of file, 0 otherwise.
X */
int
dec(lp)
register LPTR	*lp;
X{
X	if (lp->index > 0) {			/* still within line */
X		lp->index--;
X		return 0;
X	}
X
X	if (lp->linep->prev != NULL) {		/* there is a prior line */
X		lp->linep = lp->linep->prev;
X		lp->index = strlen(lp->linep->s);
X		return 1;
X	}
X
X	return -1;				/* at start of file */
X}
X
X/*
X * gchar(lp) - get the character at position "lp"
X */
int
gchar(lp)
register LPTR	*lp;
X{
X	return (lp->linep->s[lp->index]);
X}
X
X/*
X * pchar(lp, c) - put character 'c' at position 'lp'
X */
void
pchar(lp, c)
register LPTR	*lp;
char	c;
X{
X	lp->linep->s[lp->index] = c;
X}
X
X/*
X * pswap(a, b) - swap two position pointers
X */
void
pswap(a, b)
register LPTR	*a, *b;
X{
X	LPTR	tmp;
X
X	tmp = *a;
X	*a  = *b;
X	*b  = tmp;
X}
X
X/*
X * Position comparisons
X */
X
bool_t
lt(a, b)
register LPTR	*a, *b;
X{
X	register int an, bn;
X
X	an = LINEOF(a);
X	bn = LINEOF(b);
X
X	if (an != bn)
X		return (an < bn);
X	else
X		return (a->index < b->index);
X}
X
bool_t
gt(a, b)
LPTR	*a, *b;
X{
X	register int an, bn;
X
X	an = LINEOF(a);
X	bn = LINEOF(b);
X
X	if (an != bn)
X		return (an > bn);
X	else
X		return (a->index > b->index);
X}
X
bool_t
equal(a, b)
register LPTR	*a, *b;
X{
X	return (a->linep == b->linep && a->index == b->index);
X}
X
bool_t
ltoreq(a, b)
register LPTR	*a, *b;
X{
X	return (lt(a, b) || equal(a, b));
X}
X
bool_t
gtoreq(a, b)
LPTR	*a, *b;
X{
X	return (gt(a, b) || equal(a, b));
X}
END_OF_FILE
if test 2571 -ne `wc -c <'ptrfunc.c'`; then
    echo shar: \"'ptrfunc.c'\" unpacked with wrong size!
fi
# end of 'ptrfunc.c'
fi
if test -f 'source.doc' -a "${1}" != "-c" ; then 
  echo shar: Will not clobber existing file \"'source.doc'\"
else
echo shar: Extracting \"'source.doc'\" \(4625 characters\)
sed "s/^X//" >'source.doc' <<'END_OF_FILE'
X
X		 Release Notes for STEVIE - Version 3.10
X
X			      Source Notes
X
X			      Tony Andrews
X
X			 	 3/6/88
X
X
Overview
X--------
X
X	This file provides a brief description of the source code for
Stevie. The data structures are described later as well. For information
specific to porting the editor, see the file 'porting.doc'. This document
is more relevant to people who want to hack on the editor apart from doing
a simple port.
X
X	Most of this document was written some time ago so a lot of the
discussion centers on problems related to the Atari ST environment and
compilers. Most of this can be ignored for other systems.
X
Things You Need
X---------------
X
X	Stevie has been compiled with both the Alcyon (4.14A) and the
Megamax C compilers. For the posted binary, Megamax was used because
it's less buggy and provides a reasonable malloc(). Ports to other
compilers should be pretty simple. The current ifdef's for ALCYON and
MEGAMAX should point to the potential trouble areas. (See 'porting.doc'
for more information.)
X
X	The search code depends on Henry Spencer's regular expression
code. I used a version I got from the net recently (as part of a 'grep'
posting) and had absolutely no trouble compiling it on the ST. Thanks,
Henry!
X
X	The file 'getenv.c' contains a getenv routine that may or may
not be needed with your compiler. My version works with Alcyon and
Megamax, under either the Beckemeyer or Gulam shells.
X
X	Lastly, you need a decent malloc. Lots of stuff in stevie is
allocated dynamically. The malloc with Alcyon is problematic because
it allocates from the heap between the end of data and the top of stack.
If you make the stack big enough to edit large files, you wind up
wasting space when working with small files. Mallocs that get their memory
from GEMDOS (in fairly large chunks) are much better.
X
X
Cruft
X-----
X
X	Some artifacts from Tim Thompson's original version remain. In
some cases, code has been re-written, with the original left in place
but ifdef'd out. This will all be cleaned up eventually, but for now
it's sometimes useful to see how things used to work.
X
X
Data Structures
X---------------
X
X	A brief discussion of the evolution of the data structures will
do much to clarify the code, and explain some of the strangeness you may
see.
X
X	In the original version, the file was maintained in memory as a
simple contiguous buffer. References to positions in the file were simply
character pointers. Due to the obvious performance problems inherent in
this approach, I made the following changes.
X
X	The file is now represented by a doubly linked list of 'line'
structures defined as follows:
X
struct	line {
X	struct	line	*prev, *next;	/* previous and next lines */
X	char	*s;			/* text for this line */
X	int	size;			/* actual size of space at 's' */
X	unsigned int	num;		/* line "number" */
X};
X
The members of the line structure are described more completely here:
X
prev	- pointer to the structure for the prior line, or NULL for the
X	  first line of the file
X
next	- like 'prev' but points to the next line
X
s	- points to the contents of the line (null terminated)
X
size	- contains the size of the chunk of space pointed to by s. This
X	  is used so we know when we can add text to a line without getting
X	  more space. When we DO need more space, we always get a little
X	  extra so we don't make so many calls to malloc.
X
num	- This is a pseudo line number that makes it easy to compare
X	  positions within the file. Otherwise, we'd have to traverse
X	  all the links to tell which line came first.
X
X
X	Since character pointers served to mark file positions in the
original, a similar data object was needed for the new data structures.
This purpose is served by the 'lptr' structure which is defined as:
X
struct	lptr {
X	struct	line	*linep;		/* line we're referencing */
X	int	index;			/* position within that line */
X};
X
X
The member 'linep' points to the 'line' structure for the line containing
the location of interest. The integer 'index' is the offset into the line
data (member 's') of the character to be referenced.
X
The following typedef's are more commonly used:
X
typedef	struct line	LINE;
typedef	struct lptr	LPTR;
X
Many operations that were trivial with character pointers had to be
implemented by functions to manipulate LPTR's. Most of these are in the
file 'ptrfunc.c'. There you'll find functions to increment, decrement,
and compare LPTR's.
X
This was the biggest change to the editor. Fortunately, I made this
change very early on, while I was still doing the work on a UNIX system.
Using 'sdb' made it much easier to debug this code than if I had done it
on the ST.
X
X
Summary
X-------
X
END_OF_FILE
if test 4625 -ne `wc -c <'source.doc'`; then
    echo shar: \"'source.doc'\" unpacked with wrong size!
fi
# end of 'source.doc'
fi
if test -f 'term.h' -a "${1}" != "-c" ; then 
  echo shar: Will not clobber existing file \"'term.h'\"
else
echo shar: Extracting \"'term.h'\" \(2817 characters\)
sed "s/^X//" >'term.h' <<'END_OF_FILE'
X/*
X * STEVIE - ST Editor for VI Enthusiasts   ...Tim Thompson...twitch!tjt...
X *
X * Extensive modifications by:  Tony Andrews       onecom!wldrdg!tony
X *
X */
X
X/*
X * This file contains the machine dependent escape sequences that
X * the editor needs to perform various operations. Some of the sequences
X * here are optional. Anything not available should be indicated by
X * a null string. In the case of insert/delete line sequences, the
X * editor checks the capability and works around the deficiency, if
X * necessary.
X *
X * Currently, insert/delete line sequences are used for screen scrolling.
X * There are lots of terminals that have 'index' and 'reverse index'
X * capabilities, but no line insert/delete. For this reason, the editor
X * routines s_ins() and s_del() should be modified to use 'index'
X * sequences when the line to be inserted or deleted line zero.
X */
X
X/*
X * The macro names here correspond (more or less) to the actual ANSI names
X */
X
X#ifdef	ATARI
X#define	T_EL	"\033l"		/* erase the entire current line */
X#define	T_IL	"\033L"		/* insert one line */
X#define	T_DL	"\033M"		/* delete one line */
X#define	T_SC	"\033j"		/* save the cursor position */
X#define	T_ED	"\033E"		/* erase display (may optionally home cursor) */
X#define	T_RC	"\033k"		/* restore the cursor position */
X#define	T_CI	"\033f"		/* invisible cursor (very optional) */
X#define	T_CV	"\033e"		/* visible cursor (very optional) */
X#endif
X
X#ifdef	UNIX
X/*
X * The UNIX sequences are hard-wired for ansi-like terminals. I should
X * really use termcap/terminfo, but the UNIX port was done for profiling,
X * not for actual use, so it wasn't worth the effort.
X */
X#define	T_EL	"\033[2K"	/* erase the entire current line */
X#define	T_IL	"\033[L"	/* insert one line */
X#define	T_DL	"\033[M"	/* delete one line */
X#define	T_ED	"\033[2J"	/* erase display (may optionally home cursor) */
X#define	T_SC	"\0337"		/* save the cursor position */
X#define	T_RC	"\0338"		/* restore the cursor position */
X#define	T_CI	""		/* invisible cursor (very optional) */
X#define	T_CV	""		/* visible cursor (very optional) */
X#endif
X
X#ifdef	OS2
X/*
X * The OS/2 ansi console driver is pretty deficient. No insert or delete line
X * sequences. The erase line sequence only erases from the cursor to the end
X * of the line. For our purposes that works out okay, since the only time
X * T_EL is used is when the cursor is in column 0.
X */
X#define	T_EL	"\033[K"	/* erase the entire current line */
X#define	T_IL	""		/* insert one line */
X#define	T_DL	""		/* delete one line */
X#define	T_ED	"\033[2J"	/* erase display (may optionally home cursor) */
X#define	T_SC	"\033[s"	/* save the cursor position */
X#define	T_RC	"\033[u"	/* restore the cursor position */
X#define	T_CI	""		/* invisible cursor (very optional) */
X#define	T_CV	""		/* visible cursor (very optional) */
X#endif
END_OF_FILE
if test 2817 -ne `wc -c <'term.h'`; then
    echo shar: \"'term.h'\" unpacked with wrong size!
fi
# end of 'term.h'
fi
if test -f 'tos.c' -a "${1}" != "-c" ; then 
  echo shar: Will not clobber existing file \"'tos.c'\"
else
echo shar: Extracting \"'tos.c'\" \(5140 characters\)
sed "s/^X//" >'tos.c' <<'END_OF_FILE'
X/*
X * System-dependent routines for the Atari ST.
X */
X
X#include "stevie.h"
X
X#include <osbind.h>
X
X/*
X * The following buffer is used to work around a bug in TOS. It appears that
X * unread console input can cause a crash, but only if console output is
X * going on. The solution is to always grab any unread input before putting
X * out a character. The following buffer holds any characters read in this
X * fashion. The problem can be easily produced because STEVIE can't yet keep
X * up with the normal auto-repeat rate in insert mode.
X */
X#define	IBUFSZ	128
X
static long inbuf[IBUFSZ];	/* buffer for unread input */
static long *inptr = inbuf;	/* where to put next character */
X
X/*
X * inchar() - get a character from the keyboard
X *
X * Certain special keys are mapped to values above 0x80. These
X * mappings are defined in keymap.h. If the key has a non-zero
X * ascii value, it is simply returned. Otherwise it may be a
X * special key we want to map.
X *
X * The ST has a bug involving keyboard input that seems to occur
X * when typing quickly, especially typing capital letters. Sometimes
X * a value of 0x02540000 is read. This doesn't correspond to anything
X * on the keyboard, according to my documentation. My solution is to
X * loop when any unknown key is seen. Normally, the bell is rung to
X * indicate the error. If the "bug" value is seen, we ignore it completely.
X */
int
inchar()
X{
X	for (;;) {
X		long c, *p;
X
X		/*
X		 * Get the next input character, either from the input
X		 * buffer or directly from TOS.
X		 */
X		if (inptr != inbuf) {	/* input in the buffer, use it */
X			c = inbuf[0];
X			/*
X			 * Shift everything else in the buffer down. This
X			 * would be cleaner if we used a circular buffer,
X			 * but it really isn't worth it.
X			 */
X			inptr--;
X			for (p = inbuf; p < inptr ;p++)
X				*p = *(p+1);
X		} else
X			c = Crawcin();
X	
X		if ((c & 0xff) != 0)
X			return ((int) c);
X	
X		switch ((int) (c >> 16) & 0xff) {
X	
X		case 0x62: return K_HELP;
X		case 0x61: return K_UNDO;
X		case 0x52: return K_INSERT;
X		case 0x47: return K_HOME;
X		case 0x48: return K_UARROW;
X		case 0x50: return K_DARROW;
X		case 0x4b: return K_LARROW;
X		case 0x4d: return K_RARROW;
X		case 0x29: return K_CGRAVE;	/* control grave accent */
X		
X		/*
X		 * Occurs due to a bug in TOS.
X		 */
X		case 0x54:
X			break;
X		/*
X		 * Add the function keys here later if we put in support
X		 * for macros.
X		 */
X	
X		default:
X			beep();
X			break;
X	
X		}
X	}
X}
X
X/*
X * get_inchars - snarf away any pending console input
X *
X * If the buffer overflows, we discard what's left and ring the bell.
X */
static void
get_inchars()
X{
X	while (Cconis()) {
X		if (inptr >= &inbuf[IBUFSZ]) {	/* no room in buffer? */
X			Crawcin();		/* discard the input */
X			beep();			/* and sound the alarm */
X		} else
X			*inptr++ = Crawcin();
X	}
X}
X
void
outchar(c)
char	c;
X{
X	get_inchars();
X	Cconout(c);
X}
X
void
outstr(s)
register char	*s;
X{
X	get_inchars();
X	Cconws(s);
X}
X
X#define	BGND	0
X#define	TEXT	3
X
X/*
X * vbeep() - visual bell
X */
static void
vbeep()
X{
X	int	text, bgnd;		/* text and background colors */
X	long	l;
X
X	text = Setcolor(TEXT, -1);
X	bgnd = Setcolor(BGND, -1);
X
X	Setcolor(TEXT, bgnd);		/* swap colors */
X	Setcolor(BGND, text);
X
X	for (l=0; l < 5000 ;l++)	/* short pause */
X		;
X
X	Setcolor(TEXT, text);		/* restore colors */
X	Setcolor(BGND, bgnd);
X}
X
void
beep()
X{
X	if (P(P_VB))
X		vbeep();
X	else
X		outchar('\007');
X}
X
X/*
X * remove(file) - remove a file
X */
void
remove(file)
char *file;
X{
X	Fdelete(file);
X}
X
X/*
X * rename(of, nf) - rename existing file 'of' to 'nf'
X */
void
rename(of, nf)
char	*of, *nf;
X{
X	Fdelete(nf);		/* if 'nf' exists, remove it */
X	Frename(0, of, nf);
X}
X
void
windinit()
X{
X	if (Getrez() == 0)
X		Columns = 40;		/* low resolution */
X	else
X		Columns = 80;		/* medium or high */
X
X	P(P_LI) = Rows = 25;
X
X	Cursconf(1,NULL);
X}
X
void
windexit(r)
int r;
X{
X	exit(r);
X}
X
void
windgoto(r, c)
int	r, c;
X{
X	outstr("\033Y");
X	outchar(r + 040);
X	outchar(c + 040);
X}
X
X/*
X * System calls or library routines missing in TOS.
X */
X
void
sleep(n)
int n;
X{
X	int k;
X
X	k = Tgettime();
X	while ( Tgettime() <= k+n )
X		;
X}
X
void
delay()
X{
X	long	n;
X
X	for (n = 0; n < 8000 ;n++)
X		;
X}
X
int
system(cmd)
char	*cmd;
X{
X	char	arg[1];
X
X	arg[0] = (char) 0;	/* no arguments passed to the shell */
X
X	if (Pexec(0, cmd, arg, 0L) < 0)
X		return -1;
X	else
X		return 0;
X}
X
X#ifdef	MEGAMAX
char *
strchr(s, c)
char	*s;
int	c;
X{
X	do {
X		if ( *s == c )
X			return(s);
X	} while (*s++);
X	return(NULL);
X}
X#endif
X
X#ifdef	MEGAMAX
X
XFILE *
fopenb(fname, mode)
char	*fname;
char	*mode;
X{
X	char	modestr[10];
X
X	sprintf(modestr, "b%s", mode);
X
X	return fopen(fname, modestr);
X}
X
X#endif
X
X/*
X * getenv() - get a string from the environment
X *
X * Both Alcyon and Megamax are missing getenv(). This routine works for
X * both compilers and with the Beckemeyer and Gulam shells. With gulam,
X * the env_style variable should be set to either "mw" or "gu".
X */
char *
getenv(name)
char *name;
X{
X	extern long _base;
X	char *envp, *p;
X
X	envp = *((char **) (_base + 0x2c));
X
X	for (; *envp ;envp += strlen(envp)+1) {
X		if (strncmp(envp, name, strlen(name)) == 0) {
X			p = envp + strlen(name);
X			if (*p++ == '=')
X				return p;
X		}
X	}
X	return (char *) 0;
X}
END_OF_FILE
if test 5140 -ne `wc -c <'tos.c'`; then
    echo shar: \"'tos.c'\" unpacked with wrong size!
fi
# end of 'tos.c'
fi
if test -f 'unix.c' -a "${1}" != "-c" ; then 
  echo shar: Will not clobber existing file \"'unix.c'\"
else
echo shar: Extracting \"'unix.c'\" \(2241 characters\)
sed "s/^X//" >'unix.c' <<'END_OF_FILE'
X/*
X * System-dependent routines for UNIX System V Release 3.
X */
X
X#include "stevie.h"
X#include <termio.h>
X
X/*
X * inchar() - get a character from the keyboard
X */
int
inchar()
X{
X	char	c;
X
X	flushbuf();		/* flush any pending output */
X
X	while (read(0, &c, 1) != 1)
X		;
X
X	return c;
X}
X
X#define	BSIZE	2048
static	char	outbuf[BSIZE];
static	int	bpos = 0;
X
flushbuf()
X{
X	if (bpos != 0)
X		write(1, outbuf, bpos);
X	bpos = 0;
X}
X
X/*
X * Macro to output a character. Used within this file for speed.
X */
X#define	outone(c)	outbuf[bpos++] = c; if (bpos >= BSIZE) flushbuf()
X
X/*
X * Function version for use outside this file.
X */
void
outchar(c)
register char	c;
X{
X	outbuf[bpos++] = c;
X	if (bpos >= BSIZE)
X		flushbuf();
X}
X
void
outstr(s)
register char	*s;
X{
X	while (*s) {
X		outone(*s++);
X	}
X}
X
void
beep()
X{
X	outone('\007');
X}
X
X/*
X * remove(file) - remove a file
X */
void
remove(file)
char *file;
X{
X	unlink(file);
X}
X
X/*
X * rename(of, nf) - rename existing file 'of' to 'nf'
X */
void
rename(of, nf)
char	*of, *nf;
X{
X	unlink(nf);
X	link(of, nf);
X	unlink(of);
X}
X
void
delay()
X{
X	/* not implemented */
X}
X
static	struct	termio	ostate;
X
void
windinit()
X{
X	char	*getenv();
X	char	*term;
X	struct	termio	nstate;
X
X	if ((term = getenv("TERM")) == NULL || strcmp(term, "vt100") != 0) {
X		fprintf(stderr, "Invalid terminal type '%s'\n", term);
X		exit(1);
X	}
X	Columns = 80;
X	P(P_LI) = Rows = 24;
X
X	/*
X	 * Go into cbreak mode
X	 */
X	 ioctl(0, TCGETA, &ostate);
X	 nstate = ostate;
X	 nstate.c_lflag &= ~(ICANON|ECHO|ECHOE|ECHOK|ECHONL);
X	 nstate.c_cc[VMIN] = 1;
X	 nstate.c_cc[VTIME] = 0;
X	 ioctl(0, TCSETAW, &nstate);
X}
X
void
windexit(r)
int r;
X{
X	/*
X	 * Restore terminal modes
X	 */
X	ioctl(0, TCSETAW, &ostate);
X
X	exit(r);
X}
X
X#define	outone(c)	outbuf[bpos++] = c; if (bpos >= BSIZE) flushbuf()
X
void
windgoto(r, c)
register int	r, c;
X{
X	r += 1;
X	c += 1;
X
X	/*
X	 * Check for overflow once, to save time.
X	 */
X	if (bpos + 8 >= BSIZE)
X		flushbuf();
X
X	outbuf[bpos++] = '\033';
X	outbuf[bpos++] = '[';
X	if (r >= 10)
X		outbuf[bpos++] = r/10 + '0';
X	outbuf[bpos++] = r%10 + '0';
X	outbuf[bpos++] = ';';
X	if (c >= 10)
X		outbuf[bpos++] = c/10 + '0';
X	outbuf[bpos++] = c%10 + '0';
X	outbuf[bpos++] = 'H';
X}
X
XFILE *
fopenb(fname, mode)
char	*fname;
char	*mode;
X{
X	return fopen(fname, mode);
X}
END_OF_FILE
if test 2241 -ne `wc -c <'unix.c'`; then
    echo shar: \"'unix.c'\" unpacked with wrong size!
fi
# end of 'unix.c'
fi
echo shar: End of archive 1 \(of 4\).
cp /dev/null ark1isdone
MISSING=""
for I in 1 2 3 4 ; do
    if test ! -f ark${I}isdone ; then
	MISSING="${MISSING} ${I}"
    fi
done
if test "${MISSING}" = "" ; then
    echo You have unpacked all 4 archives.
    rm -f ark[1-9]isdone
else
    echo You still need to unpack the following archives:
    echo "        " ${MISSING}
fi
##  End of shell archive.
exit 0
-- 
Please send comp.sources.unix-related mail to rs...@uunet.uu.net.
