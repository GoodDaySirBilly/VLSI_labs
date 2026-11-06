# Tools
GHDL    := ghdl
GTKWAVE := gtkwave

# Project configuration
LAB     ?= 1
PROJECT ?= lab$(LAB)

SRC_DIR   := src/$(PROJECT)
TEST_DIR  := tests/$(PROJECT)
BUILD_DIR := build/$(PROJECT)

# VHDL sources and testbenches
SOURCES := $(sort $(wildcard $(SRC_DIR)/*.vhd))
TESTS   := $(sort $(wildcard $(TEST_DIR)/*.vhd))

# Supported testbench naming: *_tb.vhd or tb_*.vhd
TOPS := $(basename $(notdir $(filter %_tb.vhd,$(TESTS))))

# Projects containing testbenches
TEST_PROJECTS := $(sort $(notdir $(patsubst %/,%,$(dir \
    $(wildcard tests/*/*_tb.vhd)))))

# Simulator options
GHDL_FLAGS := --std=08 --workdir=$(BUILD_DIR)

.PHONY: lab1 lab2 lab3 lab4 lab5 run wave test clean

# Individual laboratories
lab1 lab2 lab3 lab4 lab5: lab%:
	@$(MAKE) --no-print-directory run PROJECT=$@

# Compile and simulate
run:
	@test -n "$(SOURCES)" || { echo "No sources in $(SRC_DIR)"; exit 1; }
	@test -n "$(TOPS)" || { echo "No testbenches in $(TEST_DIR)"; exit 1; }
	@mkdir -p $(BUILD_DIR)
	$(GHDL) -a $(GHDL_FLAGS) $(SOURCES) $(TESTS)
	@set -e; for top in $(TOPS); do \
		$(GHDL) -e $(GHDL_FLAGS) $$top; \
		$(GHDL) -r $(GHDL_FLAGS) $$top \
			--wave=$(BUILD_DIR)/$$top.ghw; \
	done

# Simulate and open waveform
wave: run
	$(GTKWAVE) $(BUILD_DIR)/$(firstword $(TOPS)).ghw

# Run all available testbenches
test:
	@set -e; for project in $(TEST_PROJECTS); do \
		$(MAKE) --no-print-directory run PROJECT=$$project; \
	done

# Remove generated artifacts
clean:
	rm -rf build/