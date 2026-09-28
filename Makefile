SRCDIR = src
INCDIR = include
OBJDIR = build
BINDIR = bin

OPTS = -Wall
LIBS = -lfl
# busca todos los archivos .c de src/
SRCS = $(wildcard $(SRCDIR)/*.c)
# "path substitute" reemplaza los src/*.c por build/*.o
OBJS = $(patsubst $(SRCDIR)/%.c, $(OBJDIR)/%.o, $(SRCS)) $(OBJDIR)/lexer.o

help:
	@echo "Uso: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  help	  		Muestra este mensaje"
	@echo "  compile		Compila el proyecto y genera el binario bin/main"
	@echo "  clean  		Elimina los archivos generados por make build"

compile: $(BINDIR)/main

clean:
	rm -r $(BINDIR) $(OBJDIR)

$(BINDIR)/main: $(OBJS) | $(BINDIR) # asegura que OBJS y BINDIR existen
  # $@ es el nombre del target, en este caso $(BINDIR)/main
	gcc -o $@ $(OBJS) -I$(INCDIR) $(OPTS) $(LIBS)

$(OBJDIR)/%.o: $(SRCDIR)/%.c | $(OBJDIR)
  # para cada posible archivo src/*.c ($<), creamos un build/*.o ($@)
	gcc -c -o $@ $< -I$(INCDIR) $(OPTS)

$(OBJDIR)/%.o: $(OBJDIR)/%.c | $(OBJDIR)
  # para cada posible archivo build/*.c ($<), por ejemplo lexer.c y rules.c, creamos un build/*.o ($@)
	gcc -c -o $@ $< -I$(INCDIR) -I$(OBJDIR)/include $(OPTS)

$(OBJDIR)/lexer.c: $(SRCDIR)/lexer.l $(OBJDIR)/rules.c | $(OBJDIR)
	flex -o $@ $<

$(OBJDIR)/rules.c: $(SRCDIR)/rules.y | $(OBJDIR) $(OBJDIR)/include
	bison -o $@ -d $<
	mv $(OBJDIR)/rules.h $(OBJDIR)/include/rules.h

$(OBJDIR) $(BINDIR) $(OBJDIR)/include:
	mkdir -p $@
