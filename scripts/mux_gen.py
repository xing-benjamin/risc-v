#!/usr/bin/python3

import sys
import os
import math

path = sys.argv[1]
modulename = sys.argv[2]
numInputs = sys.argv[3]

filename = modulename + '.v'
numInputs = int(numInputs)

fh = open(os.path.join(path, filename), 'w')
fh.writelines([
    '//--------------------------------------------------------------\n',
    '/*\n',
    '   Filename: ' + filename + '\n\n',
    '   Parameterized {}-to-1 multiplexer implementation\n'.format(numInputs),
    '*/\n',
    '//--------------------------------------------------------------\n\n'
    ])
fh.writelines([
    '`ifndef __' + modulename.upper() + '_V__\n',
    '`define __' + modulename.upper() + '_V__\n\n'
    ])
fh.writelines([
    'module ' + modulename + ' #(\n',
    '    parameter NUM_BITS = 32\n',
    ')(\n'
    ])

selSize = math.ceil(math.log2(numInputs))
for reg in range(numInputs):
    fh.write('    input  logic [NUM_BITS-1:0]  in' + str(reg) + ',\n')

fh.writelines([
    '    input  logic [{}:0]           sel,\n'.format(selSize - 1),
    '    output logic [NUM_BITS-1:0]  out\n',
    ');\n\n',
    '    always_comb begin\n',
    '        case (sel)\n'
    ])

for sel_val in range(numInputs):
    fh.write('            {}\'d{}:   out = in{};\n'.format(selSize, sel_val, sel_val))
fh.write('            default: out = \'x;\n')
fh.writelines([
    '        endcase\n',
    '    end\n',
    'endmodule\n\n',
    '`endif // __' + modulename.upper() + '_V__\n'
])

fh.close()

