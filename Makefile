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
	@echo "  help	  		   Muestra este mensaje"
	@echo "  compile		   Compila el proyecto y genera el binario bin/main"
	@echo "  rules         Compila el archivo de reglas, mostrando errores y avisos"
	@echo "  clean  		   Elimina los archivos generados por make build"

compile: $(BINDIR)/main

.PHONY: rules
rules:
	$(MAKE) --always-make $(OBJDIR)/rules.c

clean:
	rm -r $(BINDIR) $(OBJDIR) 2>/dev/null

# $@ es el nombre del target, en este caso $(BINDIR)/main
$(BINDIR)/main: $(OBJS) | $(BINDIR) # asegura que OBJS y BINDIR existen
	gcc -o $@ $(OBJS) -I$(INCDIR) $(OPTS) $(LIBS)

# para cada posible archivo src/*.c ($<), creamos un build/*.o ($@)
$(OBJDIR)/%.o: $(SRCDIR)/%.c | $(OBJDIR)
	gcc -c -o $@ $< -I$(INCDIR) $(OPTS)

# para cada posible archivo build/*.c ($<), por ejemplo lexer.c y rules.c, creamos un build/*.o ($@)
$(OBJDIR)/%.o: $(OBJDIR)/%.c | $(OBJDIR)
	gcc -c -o $@ $< -I$(INCDIR) -I$(OBJDIR)/include $(OPTS)

$(OBJDIR)/lexer.c: $(SRCDIR)/lexer.l $(OBJDIR)/rules.c | $(OBJDIR)
	flex -o $@ $<

$(OBJDIR)/rules.c: $(SRCDIR)/rules.y | $(OBJDIR) $(OBJDIR)/include
	bison -o $@ -d $< --verbose
	mv $(OBJDIR)/rules.h $(OBJDIR)/include/rules.h

$(OBJDIR) $(BINDIR) $(OBJDIR)/include:
	mkdir -p $@
