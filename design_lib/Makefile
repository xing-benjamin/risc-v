# design_lib makefile

BUILD_DIR := ./build
LIB_DIR := ./lib
TB_DIR := ./tb

dl_dff: build_dir
	iverilog -g2012 -o $(BUILD_DIR)/dl_dff.vvp -D 'BUILD_DIR_PATH="$(BUILD_DIR)"' -c design_lib.cf $(TB_DIR)/dl_dff_tb.sv
	vvp -n -l $(BUILD_DIR)/dl_dff.log $(BUILD_DIR)/dl_dff.vvp

.PHONY: build_dir
build_dir:
	mkdir -p build

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)