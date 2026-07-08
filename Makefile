.PHONY: all
all: xwiimote gdexample

.PHONY: clean
clean:
	rm -rfv build

.PHONY: xwiimote
xwiimote:
	mkdir -p build/xwiimote && \
	cd build/xwiimote && \
	echo $$(pwd) && \
	../../xwiimote/autogen.sh && \
	CFLAGS="-fPIC" CXXFLAGS="-fPIC" ../../xwiimote/configure --prefix=$$(pwd)/install && \
	make

.PHONY: gdexample
gdexample:
	scons .