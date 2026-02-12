-include Makefile.local

-include Makefile.db

.PHONY: all
all: build

.PHONY: build

build:
	@echo "Building the project..."
	dune build

clean:
	rm -rf _build error.log schema_spark.json
