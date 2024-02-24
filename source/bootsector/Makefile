ASM=nasm
BUILD_DIR?=intermediate

.PHONY: all clean

all: bootsector

bootsector: $(BUILD_DIR)/bootsector.bin
$(BUILD_DIR)/bootsector.bin:
	$(ASM) -f bin -o $(BUILD_DIR)/bootsector.bin bootsector.asm

clean:
	rm -f $(BUILD_DIR)/bootsector.bin