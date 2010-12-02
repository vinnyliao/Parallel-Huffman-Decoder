APP=Tester
X10_PATH=/opt/x10-2.1.0/bin

all: $(APP).exe

.SUFFIXES: .x10 .exe

run: $(APP).exe 
	./$(APP).exe


.PRECIOUS: .exe .x10
.x10.exe: 
	@echo "compiling: $(X10_NTHREADS)"
	$(X10_PATH)/x10c++ -x10rt sockets -O -report postcompile=5 -o $@ $<

.PHONY: clean
clean:
	rm -f *.cc *.h *.exe *.inc *.out *~ \#*

