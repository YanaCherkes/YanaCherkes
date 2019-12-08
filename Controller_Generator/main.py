# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
import math
import sys
from block_generator import block_generator
from arithmetic_block_generator import arithmetic_block_generator
from package_declare_generator import package_declare_generator
import block_help_generator

def main():
  
  #get all the JSON file to convert to VHDL files
  JSON_names = open("json_names.txt","r+") 
  line = JSON_names.readline().replace('\n',' ')
  block_names = []
  opcodes = []
  base_opcode = 130
  opcode_length = 8
  max_num_of_inputs_and_outputs = 0
  opcode_array = []
  
  #get memory size - assume correct input
  memory_dimensions = input ("Please enter the dimensions of the memory. The memory is an nxn matrix, as n is a power of 2, for example 512, 1024 etc.\nFor default settings press d.\n")
  
  if memory_dimensions == "d":
      memory_dimensions = 512 
  
  num_of_bits = int(math.log(int(memory_dimensions),2))   
    
  #get processing area start - assume correct input
  processing_area_init = input ("Please enter the first column of the processing area.\nFor default settings press d.\n")
  
  if processing_area_init == "d":
      #calculate the maximum inputs in order to select the processing area start
      while line:
          num_of_inputs_and_outputs = int(block_help_generator.find_num_of_inputs_and_outputs(line))
          if (max_num_of_inputs_and_outputs < num_of_inputs_and_outputs):
              max_num_of_inputs_and_outputs = num_of_inputs_and_outputs
          line = JSON_names.readline().replace('\n',' ')
          
      JSON_names.close()
      processing_area_init = int(max_num_of_inputs_and_outputs) + int(0.05*max_num_of_inputs_and_outputs) #the begining of the processing area, 5% shift after input and output
  else:
      if int(processing_area_init) >= int(memory_dimensions):
        print ("Column is out of the memory. \n")
        print ("--Exiting Program--\n")
        sys.exit()
        
  #get processing area size - assume correct input
  processing_area_size = input ("Please enter the size of the processing area.\nFor default settings press d.\n")
  
  if processing_area_size == "d":
      #calculate the maximum size, till the end of the memory
      processing_area_size = memory_dimensions - processing_area_init - 1
  else:
        if int(processing_area_init) + int(processing_area_size) >= int(memory_dimensions):
            print ("Processing area size is out of the memory. \n")
            print ("--Exiting Program--\n")
            sys.exit()
            
  #start creating a VHDL block for all JSON files
  JSON_names = open("json_names.txt","r") 
  line = JSON_names.readline().replace('\n',' ')
  while line:
      (file_name) = block_generator(line, processing_area_init, num_of_bits)
      block_names.append(file_name)
      opcodes.append(block_help_generator.num2binary(base_opcode,opcode_length))
      opcode_array.append(base_opcode)
      line = JSON_names.readline().replace('\n',' ')
      base_opcode = base_opcode + 1
  
  #create txt file with opcodes data
  block_help_generator.opcodes_file(opcode_array, block_names)  
  
  #create additional necessary VHDL blocks
  arithmetic_block_generator(block_names, opcodes, int(num_of_bits), int(processing_area_init), int(processing_area_size))
  package_declare_generator(int(num_of_bits), processing_area_init, processing_area_size, memory_dimensions)
  
  print ("--VHDL blocks has been produced in the vhdl_controller directoty. The controller is ready to use--")