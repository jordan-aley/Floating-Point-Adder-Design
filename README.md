# Floating-Point-Adder-Design
Designed two Single Precision (32-bit) Floating Point Adders:

The first used vendor specific components for the Adder core

The second used modified 24-bit pipelined Adder core
 
Inputs: Op_A, Op_B, Clk, Reset, EnL, EnR

Outputs: Op_Q, DONE

Used Matlab to create input/output test vector files for both design

Created testbench to simulate and test both designs using your Matlab test-vector files.

Created .DO files for the simulations, and properly sorted signals.

Created DATAFLOW schematics for both designs

Used Xilinx Design Suite V 14.7 and synthesized both design using:

Virtex 4, LX100, Package FF1148, Speed Grade -12

Tabulated:
-- max operating frequency
-- % logic  and  % routing
-- resources used: LUTS, FlipFlops, Slices etc
