SRC_DIR=source
BUILD_DIR=intermediate
DIST_DIR=dist
MAKE=make
OS_NAME='OS'

.PHONY: all iso bootsector kernel clean always

all: iso

#
# Floppy image
#
iso: $(DIST_DIR)/os.iso
$(DIST_DIR)/os.iso: bootsector
	dd if=/dev/zero of=$(DIST_DIR)/os.img bs=512 count=2880
	mkfs.fat -F12 -n $(OS_NAME) $(DIST_DIR)/os.img
	dd if=$(BUILD_DIR)/bootsector.bin of=$(DIST_DIR)/os.img conv=notrunc 
	mcopy -i $(DIST_DIR)/os.img $(BUILD_DIR)/bootsector.bin "::boot.bin"
	genisoimage -quiet -V $(OS_NAME) -input-charset iso8859-1 -o $(DIST_DIR)/os.iso -b os.img -hide os.img $(DIST_DIR)

#
# Bootsector
#
bootsector: $(BUILD_DIR)/bootsector.bin
$(BUILD_DIR)/bootsector.bin: always
	$(MAKE) -C $(SRC_DIR)/bootsector BUILD_DIR=$(abspath $(BUILD_DIR))

#
# Always
#
always:
	mkdir -p $(BUILD_DIR)
	mkdir -p $(DIST_DIR)

#
# Clean
#
clean:
	$(MAKE) -C $(SRC_DIR)/bootsector BUILD_DIR=$(abspath $(BUILD_DIR)) clean
	rm -rf $(BUILD_DIR)/*
	rm -rf $(DIST_DIR)/*