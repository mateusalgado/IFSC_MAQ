CC ?= cc
CFLAGS ?= -std=c11 -O1 -g -Wall -Wextra -Werror -pedantic
CORE = src/elevator.c src/motor.c src/inputs.c src/display.c src/controller.c
KIT = ports/stm32f411/kit
.PHONY: test clean sanitize
test: build/test_elevator build/test_kit
	./build/test_elevator
	./build/test_kit
build/test_kit: tests/test_kit.c $(KIT)/kit_signals.c $(KIT)/kit_signals.h $(wildcard include/*.h)
	mkdir -p build
	$(CC) $(CFLAGS) -Iinclude -I$(KIT) tests/test_kit.c $(KIT)/kit_signals.c -o $@
build/test_elevator: $(CORE) tests/test_elevator.c $(wildcard include/*.h)
	mkdir -p build
	$(CC) $(CFLAGS) -Iinclude $(CORE) tests/test_elevator.c -o $@
sanitize:
	mkdir -p build
	$(CC) $(CFLAGS) -fsanitize=address,undefined -fno-omit-frame-pointer -Iinclude $(CORE) tests/test_elevator.c -o build/test_sanitize
	./build/test_sanitize
	$(CC) $(CFLAGS) -fsanitize=address,undefined -fno-omit-frame-pointer -Iinclude -I$(KIT) tests/test_kit.c $(KIT)/kit_signals.c -o build/test_kit_sanitize
	./build/test_kit_sanitize
clean:
	rm -f build/test_elevator build/test_sanitize build/test_kit build/test_kit_sanitize
