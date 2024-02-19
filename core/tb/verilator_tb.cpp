/**/

// Include common routines
#include <verilated.h>
#include <verilated_vcd_c.h>

// Include model header, generated from Verilating "core.sv"
#include "Vcore.h"

int main(int argc, char** argv) {

    // Prevent unused variable warnings
    if (false && argc && argv) {}

    // Create logs/ directory in case we have traces to put under it
    Verilated::mkdir("logs");

    // Construct a VerilatedContext to hold simulation time, etc.
    // Multiple modules (made later below with Vtop) may share the same
    // context to share time, or modules may have different contexts if
    // they should be independent from each other.

    // Using unique_ptr is similar to
    // "VerilatedContext* contextp = new VerilatedContext" then deleting at end.
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    // Do not instead make Vtop as a file-scope static variable, as the
    // "C++ static initialization order fiasco" may cause a crash

    // Set debug level, 0 is off, 9 is highest presently used
    // May be overridden by commandArgs argument parsing
    contextp->debug(0);

    // Randomization reset policy
    // May be overridden by commandArgs argument parsing
    contextp->randReset(2);

    // Verilator must compute traced signals
    contextp->traceEverOn(true);

    // Pass arguments so Verilated code can see them, e.g. $value$plusargs
    // This needs to be called before you create any model
    contextp->commandArgs(argc, argv);

    // Construct the Verilated model, from Vcore.h generated from Verilating "core.sv".
    // Using unique_ptr is similar to "Vcore* core = new Vcore" then deleting at end.
    // "CORE" will be the hierarchical name of the module.
    const std::unique_ptr<Vcore> core{new Vcore{contextp.get(), "CORE"}};

    const std::unique_ptr<VerilatedVcdC> m_trace{new VerilatedVcdC};
    core->trace(m_trace, 5);
    m_trace->open("core_tb.vcd")

    
    while (!contextp->gotFinish()) {
        
    }

    m_trace->close();

    // Return good completion status
    // Don't use exit() or destructor won't get called
    return 0;

}