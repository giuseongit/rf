test:
	crystal spec

build:
	crystal build --release -p src/rf.cr -o rf.bin
