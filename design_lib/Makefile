#============================
# risc-v/design_lib/Makefile
#============================

BUILD_DIR := ./build
LIB_DIR := ./lib
TB_DIR := ./tb
COMMON_DIR := $(REPO_TOP)/common

commonlib := -I$(COMMON_DIR)/include \
             -Y .sv -y$(COMMON_DIR)/interfaces
ivl_options := $(commonlib) \
               -D 'BUILD_DIR_PATH="$(BUILD_DIR)"'


dl_%: $(BUILD_DIR)/dl_%.vvp
	vvp -n -l $(BUILD_DIR)/dl_$*.log $(BUILD_DIR)/dl_$*.vvp

$(BUILD_DIR)/dl_%.vvp: build_dir $(LIB_DIR)/dl_%.v $(TB_DIR)/dl_%_tb.sv
	iverilog -g2012 -o $@ $(ivl_options) $(LIB_DIR)/dl_$*.v $(TB_DIR)/dl_$*_tb.sv

%.v %.sv:
	touch $@

.PHONY: build_dir
build_dir:
	mkdir -p build

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)