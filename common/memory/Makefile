#============================
# risc-v/core/Makefile
#============================

BUILD_DIR := ./build
COMMON_DIR := $(ROOTDIR)/common
DESIGN_LIB := $(ROOTDIR)/design_lib

commonlib := -I$(COMMON_DIR)/include \
             -Y .sv -y$(COMMON_DIR)/interfaces
designlib := -y$(DESIGN_LIB)/lib
ivl_options := $(commonlib) $(designlib) \
               -D 'BUILD_DIR_PATH="$(BUILD_DIR)"' \
			   memory_types_pkg.sv

mm: $(BUILD_DIR)/mm.vvp
	vvp -n -l $(BUILD_DIR)/mm.log $(BUILD_DIR)/mm.vvp

$(BUILD_DIR)/mm.vvp: build_dir memory_model.sv memory_model_tb.sv
	iverilog -Wall -g2012 -o $@ $(ivl_options) memory_model.sv memory_model_tb.sv

.PHONY: build_dir
build_dir:
	mkdir -p build

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)