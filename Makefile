SRCDIR = src
INCDIR = include
OBJDIR = build
BINDIR = bin

COPT = -Wall
CLIB = -lfl
# busca todos los archivos .c de src/
SRCS = $(wildcard $(SRCDIR)/*.c)
# "path substitute" reemplaza los src/*.c por build/*.o
OBJS = $(patsubst $(SRCDIR)/%.c, $(OBJDIR)/%.o, $(SRCS)) $(OBJDIR)/lexer.o

$(BINDIR)/main: $(OBJS) | $(BINDIR) # asegura que OBJS y BINDIR existen
  # $@ es el nombre del target, en este caso $(BINDIR)/main
	gcc -o $@ $(OBJS) -I$(INCDIR) $(COPT) $(CLIB)

$(OBJDIR)/%.o: $(SRCDIR)/%.c | $(OBJDIR)
  # para cada posible archivo src/*.c ($<), creamos un build/*.o ($@)
	gcc -c -o $@ $< -I$(INCDIR) $(COPT)

$(OBJDIR)/lexer.o: $(OBJDIR)/lexer.c | $(OBJDIR)
	gcc -c -o $@ $< -I$(INCDIR) $(COPT)

$(OBJDIR)/lexer.c: $(SRCDIR)/lexer.l | $(OBJDIR)
	flex -o $@ $<

$(OBJDIR) $(BINDIR):
	mkdir -p $@

clean:
	rm -r $(BINDIR) $(OBJDIR)
