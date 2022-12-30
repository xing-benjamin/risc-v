#!/usr/bin/python3

import sys
import os
import math
import argparse

dl_path = os.environ.get('DESIGN_LIB')
path = dl_path + '/lib'

parser = argparse.ArgumentParser()
parser.add_argument('outputWidth', help='Output bitwidth')
parser.add_argument('-io', help='Input and output port formatting (packed or unpacked)', 
                    default='pp', choices=['pp', 'pu', 'up', 'uu'])
args = parser.parse_args()

outputWidth = int(args.outputWidth)
inputWidth = math.ceil(math.log2(outputWidth))

input_fmt = args.io[0]
output_fmt = args.io[1]

modulename = 'dl_decoder_{0}{1}{2}{3}'.format(inputWidth, input_fmt, outputWidth, output_fmt)

filename = modulename + '.sv'

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
    '`ifndef __' + modulename.upper() + '_SV__\n',
    '`define __' + modulename.upper() + '_SV__\n\n'
    ])
fh.writelines([
    'module ' + modulename + ' #(\n',
    '    localparam OUTPUT_WIDTH = {},\n'.format(outputWidth),
    '    localparam INPUT_WIDTH = $clog2(OUTPUT_WIDTH)\n',
    ')(\n'
    ])

if input_fmt == 'p':
    fh.write('    input  logic [INPUT_WIDTH-1:0]  in,\n')
elif input_fmt == 'u':
    for i in range(inputWidth):
        fh.write('    input  logic                    in{0},\n'.format(i))

if output_fmt == 'p':
    fh.write('    output logic [OUTPUT_WIDTH-1:0] out\n')
elif output_fmt == 'u':
    for o in range(outputWidth-1):
        fh.write('    output logic                    out{0},\n'.format(o))
    fh.write('    output logic                    out{0}\n'.format(outputWidth-1))

fh.write(');\n\n'),

if input_fmt == 'u':
    fh.write('    logic [INPUT_WIDTH-1:0]  in;\n')
    fh.write('    assign in = {')
    for i in range(inputWidth-1):
        fh.write('in{0}, '.format(i))
    fh.write('in{0}}};\n\n'.format(inputWidth-1))
if output_fmt == 'u':
    fh.write('    logic [OUTPUT_WIDTH-1:0] out;\n\n')

fh.writelines([
    '    always_comb begin\n',
    '        out = \'0;\n',
    '        case (in)\n'
])

for in_val in range(outputWidth):
    fh.write('            {}\'d{}:   out[{}] = 1\'b1;\n'.format(inputWidth, in_val, in_val))

fh.writelines([
    '        endcase\n',
    '    end\n\n',
])

if output_fmt == 'u':
    for o in range(outputWidth):
        fh.write('    assign out{0} = out[{0}];\n'.format(o))
    fh.write('\n')

fh.writelines([
    'endmodule\n\n',
    '`endif // __' + modulename.upper() + '_SV__\n'
])

fh.close()
