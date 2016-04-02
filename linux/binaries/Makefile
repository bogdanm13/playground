
all: build

build: dynamic static run_file

dynamic:
	gcc -o link_dynamic.elf link.c -Llibc
	gcc -o link_func_dynamic.elf link_func.c -Llibc

static:
	gcc -o link_static.elf link.c -static     
	gcc -o link_func_static.elf link_func.c -static     

clean:
	rm link*elf

run_file:
	file link*elf

