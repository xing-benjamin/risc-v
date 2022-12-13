#============================
# risc-v/core/Makefile
#============================

BUILD_DIR := ./build
SRC_DIR := ./src
TB_DIR := ./tb
SIM_DIR := ./sim

commonlib := -I$(COMMON_DIR)/include \
             -Y .sv -y$(COMMON_DIR)/interfaces
designlib := -y$(DESIGN_LIB)/lib
ivl_options := $(commonlib) $(designlib) \
               -D 'BUILD_DIR_PATH="$(BUILD_DIR)"'

core: $(BUILD_DIR)/core.vvp
	vvp -n -l $(BUILD_DIR)/core_tb.log $(BUILD_DIR)/core.vvp

$(BUILD_DIR)/core.vvp: build_dir $(SRC_DIR)/core.sv $(TB_DIR)/core_tb.sv
	iverilog -Wall -g2012 -o $@ -c$(SIM_DIR)/core_sim.cf

regfile: $(BUILD_DIR)/regfile.vvp
	vvp -n -l $(BUILD_DIR)/regfile.log $(BUILD_DIR)/regfile.vvp

$(BUILD_DIR)/regfile.vvp: build_dir $(SRC_DIR)/regfile.sv $(TB_DIR)/regfile_tb.sv
	iverilog -Wall -g2012 -o $@ $(ivl_options) $(SRC_DIR)/regfile.sv $(TB_DIR)/regfile_tb.sv

alu: $(BUILD_DIR)/alu.vvp
	vvp -n -l $(BUILD_DIR)/alu.log $(BUILD_DIR)/alu.vvp > /dev/null

$(BUILD_DIR)/alu.vvp: build_dir $(SRC_DIR)/alu.sv $(TB_DIR)/alu_tb.sv
	iverilog -Wall -g2012 -o $@ $(ivl_options) $(SRC_DIR)/alu.sv $(TB_DIR)/alu_tb.sv

%.v %.sv:
	touch $@

.PHONY: build_dir
build_dir:
	mkdir -p build

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)