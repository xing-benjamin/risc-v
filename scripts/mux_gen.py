#!/usr/bin/python3

import sys
import os
import math
import argparse

dl_path = os.environ.get('DESIGN_LIB')
path = dl_path + '/lib/mux'

parser = argparse.ArgumentParser(description='Generate N-to-1 mux')
parser.add_argument('numInputs', help='Number of inputs')
args = parser.parse_args()

numInputs = int(args.numInputs)
modulename = 'dl_mux{0}'.format(numInputs)
filename = modulename + '.sv'

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
    '`ifndef __' + modulename.upper() + '_SV__\n',
    '`define __' + modulename.upper() + '_SV__\n\n'
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
fh.write('            default: out = in0;\n')
fh.writelines([
    '        endcase\n',
    '    end\n',
    'endmodule\n\n',
    '`endif // __' + modulename.upper() + '_SV__\n'
])

fh.close()

