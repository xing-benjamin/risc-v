#============================
# risc-v/core/Makefile
#============================

BUILD_DIR := ./build
SRC_DIR := ./src
TB_DIR := ./tb

core: $(BUILD_DIR)/core.vvp
	vvp -n -l $(BUILD_DIR)/core_tb.log $(BUILD_DIR)/core.vvp

$(BUILD_DIR)/core.vvp: build_dir $(SRC_DIR)/core.sv $(TB_DIR)/core_tb.sv
	iverilog -Wall -g2012 -o $@ -c$(TB_DIR)/cmd_files/core_sim.cf

regfile: $(BUILD_DIR)/regfile.vvp
	vvp -n -l $(BUILD_DIR)/regfile.log $(BUILD_DIR)/regfile.vvp

$(BUILD_DIR)/regfile.vvp: build_dir $(SRC_DIR)/regfile.sv $(TB_DIR)/regfile_tb.sv
	iverilog -Wall -g2012 -o $@ -c$(TB_DIR)/cmd_files/regfile_sim.cf

alu: $(BUILD_DIR)/alu.vvp
	vvp -n -l $(BUILD_DIR)/alu.log $(BUILD_DIR)/alu.vvp > /dev/null

$(BUILD_DIR)/alu.vvp: build_dir $(SRC_DIR)/alu.sv $(TB_DIR)/alu_tb.sv
	iverilog -Wall -g2012 -o $@ -c$(TB_DIR)/cmd_files/alu_sim.cf

%.v %.sv:
	touch $@

.PHONY: build_dir
build_dir:
	mkdir -p build

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)