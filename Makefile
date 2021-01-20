MODULES=table
OBJECTS=$(MODULES:=.cmo)
TEST=table_test.byte
OCAMLBUILD=ocamlbuild -use-ocamlfind -plugin-tag 'package(bisect_ppx-ocamlbuild)'

default: build
	utop

build:
	$(OCAMLBUILD) $(OBJECTS)

test:
	BISECT_COVERAGE=YES $(OCAMLBUILD) -tag 'debug' $(TEST) && ./$(TEST) -runner sequential

bisect: clean test
	bisect-ppx-report html

zip:
	zip tables.zip *.ml* *.csv _tags Makefile .merlin .ocamlinit

clean:
	ocamlbuild -clean
	rm -rf tables.zip _coverage bisect*.coverage
