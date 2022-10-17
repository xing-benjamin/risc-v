#============================
# risc-v/core/Makefile
#============================

BUILD_DIR := ./build
SRC_DIR := ./src
TB_DIR := ./tb
COMMON_DIR := $(ROOTDIR)/common
DESIGN_LIB := $(ROOTDIR)/design_lib

commonlib := -I$(COMMON_DIR)/include \
             -Y .sv -y$(COMMON_DIR)/interfaces
designlib := -y$(DESIGN_LIB)/lib
ivl_options := $(commonlib) $(designlib) \
               -D 'BUILD_DIR_PATH="$(BUILD_DIR)"'

regfile32: $(BUILD_DIR)/regfile32.vvp
	vvp -n -l $(BUILD_DIR)/regfile32.log $(BUILD_DIR)/regfile32.vvp

$(BUILD_DIR)/regfile32.vvp: build_dir $(SRC_DIR)/regfile32.v $(TB_DIR)/regfile32_tb.sv
	iverilog -Wall -g2012 -o $@ $(ivl_options) $(SRC_DIR)/regfile32.v $(TB_DIR)/regfile32_tb.sv

alu: $(BUILD_DIR)/alu.vvp
	vvp -n -l $(BUILD_DIR)/alu.log $(BUILD_DIR)/alu.vvp > /dev/null

$(BUILD_DIR)/alu.vvp: build_dir $(SRC_DIR)/alu.v $(TB_DIR)/alu_tb.sv
	iverilog -Wall -g2012 -o $@ $(ivl_options) $(SRC_DIR)/alu.v $(TB_DIR)/alu_tb.sv

%.v %.sv:
	touch $@

.PHONY: build_dir
build_dir:
	mkdir -p build

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)