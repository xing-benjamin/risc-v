#!/usr/bin/python3

import sys
import os
import math
import argparse

#parser = argparse.ArgumentParser()
#parser.add_argument('-d', '--dir')
#parser.parse_args()

path = sys.argv[1]
modulename = sys.argv[2]
outputWidth = sys.argv[3]

filename = modulename + '.v'
outputWidth = int(outputWidth)
inputWidth = math.ceil(math.log2(outputWidth))

fh = open(os.path.join(path, filename), 'w')
fh.writelines([
    '//--------------------------------------------------------------\n',
    '/*\n',
    '   Filename: ' + filename + '\n\n',
    '   Parameterized {}-to-{} decoder implementation\n'.format(inputWidth, outputWidth),
    '*/\n',
    '//--------------------------------------------------------------\n\n'
    ])
fh.writelines([
    '`ifndef __' + modulename.upper() + '_V__\n',
    '`define __' + modulename.upper() + '_V__\n\n'
    ])
fh.writelines([
    'module ' + modulename + ' #(\n',
    '    localparam OUTPUT_WIDTH = {},\n'.format(outputWidth),
    '    localparam INPUT_WIDTH = $clog2(OUTPUT_WIDTH)\n',
    ')(\n'
    ])

fh.write('    input  logic [INPUT_WIDTH-1:0]  in,\n')

#for i in range(outputWidth):
#    if (i < outputWidth-1):
#        fh.write('    output logic                    out' + str(i) + ',\n')
#    else:
#        fh.write('    output logic                    out' + str(i) + '\n')
fh.write('    output logic [OUTPUT_WIDTH-1:0]  out\n')

fh.write(');\n\n'),
fh.write('    always_comb begin\n')

#for in_val in range(outputWidth):
#    fh.write('        out{} = 1\'b0;\n'.format(in_val))
fh.write('        out = \'0;\n')
fh.write('        case (in)\n')

for in_val in range(outputWidth):
    fh.write('            {}\'d{}:   out[{}] = 1\'b1;\n'.format(inputWidth, in_val, in_val))

fh.writelines([
    '        endcase\n',
    '    end\n',
    'endmodule\n\n',
    '`endif // __' + modulename.upper() + '_V__\n'
])

fh.close()
