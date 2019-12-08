# -*- coding: utf-8 -*-
"""
Created on Fri Dec  6 17:44:36 2019

@author: yanac
"""

import os
import sys

#input_file for example full_adder_1bit 
#row sizes is a list of sizes for example [5,8,10,15]
def simpler_conf_generator(input_file, row_sizes):
    if not os.path.exists(input_file+".v"):
        print ("wrong input. \n")
        print ("--Verilog file doesn't exist--\n")
        sys.exit() 
    file = open("simpler_conf.cfg", 'w')

    file.writelines(
    "[input_output]\n" +
    "; input_path - write the name of the input file \n" +
    "input_path="+ input_file+".v\n" +
    "; input_format - the allowed values: verilog, blif\n" +
    "input_format=verilog\n" +
    "; output_path - write the desired name of the netlist generated using ABC \n" +
    "output_path="+input_file+"_output\n" +
    "\n" +
    "[abc]\n" +
    "; abc_dir_path - write the path to your ABC directory\n" +
    "abc_dir_path=/home/natanpeled/abc/alanmi-abc-eac02745facf\n" +
    "\n" +
    "[SIMPLER_Mapping]\n" +
    "; Max_num_gates - write the maximum number of gates the tool allows\n" +
    "Max_num_gates=20000\n" +
    "; ROW_SIZE - write all the desired row sizes (including the cells storing the inputs)\n" +
    "ROW_SIZE="+row_sizes+"\n" +
    "; generate_json,print_mapping,print_warnings - the allowed values: True/False \n" +
    "generate_json=True\n" +
    "print_mapping=True\n" +
    "print_warnings=True\n" +
    "end_of_line_output=True\n")
