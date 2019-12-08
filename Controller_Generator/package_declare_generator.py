# -*- coding: utf-8 -*-
"""
Created on Mon Sep  9 20:10:09 2019

@author: yanac
"""
import os

def package_declare_generator(num_of_bits, processing_area_init, processing_area_size, memory_dimensions):
    
    path = 'vhdl_controller'
    if not os.path.exists(path):
        os.makedirs(path)
    
    full_file_name = "Package_Declare.vhd"
    file = open(os.path.join(path, full_file_name), 'w')
    
    file.writelines(
    "----------------------------------------------------------\n" +
    "---------   Define the input voltages and const.  --------\n" +
    "----------------------------------------------------------\n" +
    "\n" +
    "library ieee;\n" +
    "use ieee.std_logic_1164.all;\n" +
    "\n" +
    "package Declare is\n" +
    "type Vin is (floating, Vcond, Vset, VcondN, VsetN, gnd, Vw0, Vw1, Vr, Rg, Rref, Vg1, Vg2, Vg3, Vg4, Visolate);\n" +
    "type Row_Col is (rows, columns); --defines the prefered processing type - as row vectors or as column vectors\n" +
    "\n" +
    "\n" +
    "constant row_max_input		: integer := "+ str(memory_dimensions) +";		--number of maximum rows (instruction length limit)\n" +
    "constant col_max		: integer := "+ str(memory_dimensions) +";		--number of maximum column (instruction length limit)\n" +
    "constant processing_area_init		: integer := "+ str(processing_area_init) +";		--number of maximum column (instruction length limit)\n" +    
    "constant processing_area_size		: integer := "+ str(processing_area_size) +";		--number of maximum column (instruction length limit)\n" +    
    "\n" +
    "-- all sizes are minus 1 the full size\n" +
    "constant num_of_bits		: integer := "+str(num_of_bits-1)+";		--num of bits to present a row and column\n" +
    "constant state_len 		: integer := 1;	--num of bits to reperesent the state\n" +
    "constant opcode_len 		: integer := 7;	--num of bits to reperesent the opcode\n" +
    "constant type_len 		: integer := 1;	--num of bits to reperesent the type\n" +
    "constant operation_len 		: integer := type_len +1 + opcode_len + 1 + state_len + 1 + num_of_bits*8 + 8 -1;	--num of bits to reperesent the type\n" +
    "\n" +
    "end Declare;\n" )
