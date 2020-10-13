test:
	crystal spec

lint:
	crystal tool format --check

lint-fix:
	crystal tool format

audit:
	crystal bin/ameba.cr

build:
	crystal build --release -p src/rf.cr -o rf.bin
