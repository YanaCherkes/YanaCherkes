# -*- coding: utf-8 -*-
"""
Created on Sun Sep  1 19:27:30 2019

@author: yanac
"""

import re 
import os
import block_help_generator


def block_generator (json_file_name, processing_area_init, num_of_bits):
    json_file_name = json_file_name.replace('\n','')
    json_file_name = json_file_name.replace(' ','')
    simpler = open(json_file_name,"r") 
        
    line = simpler.readline().replace('\n',' ')
    
    for line in simpler:
        line = line.replace(',\n','')
        if line.find("Benchmark") != -1:
            file_name = (line.split(":")[1]).split("\"")[1] #get file name 
        elif line.find("Row size") != -1:
            row_size = (line.split(":")[1]).replace(' ','')
        elif  line.find("Number of Gates") != -1:
            continue
        elif line.find("Inputs") != -1:
            if  line.find("Number of Inputs") != -1:
                continue
            else:
                Inputs = line.split("\"{")[1].split("}\"")[0].split(',')
                num_of_inputs = len (Inputs)
        elif  line.find("Outputs") != -1:
            if  line.find("Number of Outputs") != -1:
                continue
            else:
                Outputs = line.split("\"{")[1].split("}\"")[0].split(',')
                num_of_outputs = len (Outputs)
            first_output = re.findall(r"\(([0-9_]+)\)", Outputs[0])
            first_output = first_output[0]     
        elif  line.find("Total cycles") != -1:
            total_cycles = line.split(":")[1].replace(' ','')
        elif  line.find("Execution sequence") != -1:
            break 
        #print(line)
    
    path = 'vhdl_controller'
    if not os.path.exists(path):
        os.makedirs(path)
    
    full_file_name = file_name + ".vhd"
    vhdl_block = open(os.path.join(path, full_file_name), 'w')
    
    #write basic code to the file
    block_help_generator.library_use_component(vhdl_block)
    block_help_generator.entity(vhdl_block, file_name)
    block_help_generator.states(vhdl_block, total_cycles)
    block_help_generator.signals(vhdl_block)
    block_help_generator.begin(vhdl_block)
    
    
    #Read execution order
    #i - cycle number
    for i in range(int(total_cycles) + 1):
        line = simpler.readline().replace(',\n','')
        if line.find("Initialization") != -1:
            dest = re.findall(r"\(([0-9_]+)\)", line)
            block_help_generator.init_state(vhdl_block,i, dest, row_size, processing_area_init, num_of_inputs)
            
        elif line.find("inv1") != -1:
            dest = re.findall(r"\(([0-9_]+)\)", line)
            output_col = dest[0]
            input_cols = dest[1]
            calc_state(vhdl_block, i, 0,  input_cols, output_col, num_of_bits, total_cycles, num_of_inputs, row_size, first_output, num_of_outputs)
    
        elif line.find("nor2") != -1:
            dest = re.findall(r"\(([0-9_]+)\)", line)
            output_col = dest[0]
            input_cols = dest[1:]
            calc_state(vhdl_block, i, 1,  input_cols, output_col, num_of_bits, total_cycles, num_of_inputs, row_size, first_output, num_of_outputs)
    
        elif line.find("nor3") != -1:
            dest = re.findall(r"\(([0-9_]+)\)", line)
            output_col = dest[0]
            input_cols = dest[1:]
            calc_state(vhdl_block, i, 2,  input_cols, output_col, num_of_bits, total_cycles, num_of_inputs, row_size, first_output, num_of_outputs)
                
        elif line.find("nor4") != -1:
            dest = re.findall(r"\(([0-9_]+)\)", line)
            output_col = dest[0]
            input_cols = dest[1:]
            calc_state(vhdl_block, i, 3,  input_cols, output_col, num_of_bits, total_cycles, num_of_inputs, row_size, first_output, num_of_outputs)
    
    block_help_generator.finish_state(vhdl_block)
    
    vhdl_block.close()                  
    simpler.close()   
    
    return (file_name)

from block_help_generator import num2binary


def calc_state(file, numState, magicState,  inputs, output, n, total_cycles, num_of_inputs, row_size, first_output, num_of_outputs):
    if magicState == 0:
        magicStateStr = "00"
    elif magicState == 1:
        magicStateStr = "01"
    elif magicState == 2:
       magicStateStr = "10"
    elif magicState == 3:
        magicStateStr = "11"
      
    file.writelines(
        "						state_arith	<= \"" +magicStateStr + "\";\n" +
        "						ena_magic_sig	<= '1'; \n" +
        "						row_init	<= ROW_INIT_ADDR;\n" +
        "						row_fin		<= ROW_FIN_ADDR;	\n" )  ;   

    if magicStateStr == "00":
        if (int(inputs[0]) >= int(num_of_inputs)):
            file.writelines("						col1_addr	<= process_area_in +\""+num2binary(int(inputs[0]), n)+"\" -" + " \""+ num2binary(int(num_of_inputs), n) +"\" " + " ;  \n")
        if (int(inputs[0]) < int(num_of_inputs)):
                file.writelines("						col1_addr	<= COL_SRC_ADDR +\""+num2binary(int(inputs[0]), n)+"\";  \n")
                
    elif magicStateStr == "01":
        if (int(inputs[0]) >= int(num_of_inputs)):
            file.writelines("						col1_addr	<= process_area_in +\""+num2binary(int(inputs[0]), n)+"\" -" + " \""+ num2binary(int(num_of_inputs), n) +"\" " + " ;  \n")
        if (int(inputs[0]) < int(num_of_inputs)):
                file.writelines("						col1_addr	<= COL_SRC_ADDR +\""+num2binary(int(inputs[0]), n)+"\";  \n")
        if (int(inputs[1]) >= int(num_of_inputs)):
            file.writelines("						col2_addr	<= process_area_in +\""+num2binary(int(inputs[1]), n)+"\" -" + " \""+ num2binary(int(num_of_inputs), n) +"\" " + " ;  \n")
        if (int(inputs[1]) < int(num_of_inputs)):
                file.writelines("						col2_addr	<= COL_SRC_ADDR +\""+num2binary(int(inputs[1]), n)+"\";  \n")

    elif magicStateStr == "10":
        if (int(inputs[0]) >= int(num_of_inputs)):
            file.writelines("						col1_addr	<= process_area_in +\""+num2binary(int(inputs[0]), n)+"\" -" + " \""+ num2binary(int(num_of_inputs), n) +"\" " + " ;  \n")
        if (int(inputs[0]) < int(num_of_inputs)):
                file.writelines("						col1_addr	<= COL_SRC_ADDR +\""+num2binary(int(inputs[0]), n)+"\";  \n")
        if (int(inputs[1]) >= int(num_of_inputs)):
            file.writelines("						col2_addr	<= process_area_in +\""+num2binary(int(inputs[1]), n)+"\" -" + " \""+ num2binary(int(num_of_inputs), n) +"\" " + " ;  \n")
        if (int(inputs[1]) < int(num_of_inputs)):
                file.writelines("						col2_addr	<= COL_SRC_ADDR +\""+num2binary(int(inputs[1]), n)+"\";  \n")
        if (int(inputs[2]) >= int(num_of_inputs)):
            file.writelines("						col3_addr	<= process_area_in +\""+num2binary(int(inputs[2]), n)+"\" -" + " \""+ num2binary(int(num_of_inputs), n) +"\" " + " ;  \n")
        if (int(inputs[2]) < int(num_of_inputs)):
                file.writelines("						col3_addr	<= COL_SRC_ADDR +\""+num2binary(int(inputs[2]), n)+"\";  \n")


    elif magicStateStr == "11":
        if (int(inputs[0]) >= int(num_of_inputs)):
            file.writelines("						col1_addr	<= process_area_in +\""+num2binary(int(inputs[0]), n)+"\" -" + " \""+ num2binary(int(num_of_inputs), n) +"\" " + " ;  \n")
        if (int(inputs[0]) < int(num_of_inputs)):
                file.writelines("						col1_addr	<= COL_SRC_ADDR +\""+num2binary(int(inputs[0]), n)+"\";  \n")
        if (int(inputs[1]) >= int(num_of_inputs)):
            file.writelines("						col2_addr	<= process_area_in +\""+num2binary(int(inputs[1]), n)+"\" -" + " \""+ num2binary(int(num_of_inputs), n) +"\" " + " ;  \n")
        if (int(inputs[1]) < int(num_of_inputs)):
                file.writelines("						col2_addr	<= COL_SRC_ADDR +\""+num2binary(int(inputs[1]), n)+"\";  \n")
        if (int(inputs[2]) >= int(num_of_inputs)):
            file.writelines("						col3_addr	<= process_area_in +\""+num2binary(int(inputs[2]), n)+"\" -" + " \""+ num2binary(int(num_of_inputs), n) +"\" " + " ;  \n")
        if (int(inputs[2]) < int(num_of_inputs)):
                file.writelines("						col3_addr	<= COL_SRC_ADDR +\""+num2binary(int(inputs[2]), n)+"\";  \n")
        if (int(inputs[3]) >= int(num_of_inputs)):
            file.writelines("						col4_addr	<= process_area_in +\""+num2binary(int(inputs[3]), n)+"\" -" + " \""+ num2binary(int(num_of_inputs), n) +"\" " + " ;  \n")
        if (int(inputs[3]) < int(num_of_inputs)):
                file.writelines("						col4_addr	<= COL_SRC_ADDR +\""+num2binary(int(inputs[3]), n)+"\";  \n")

    if (int(output) >= int(row_size) - int(num_of_outputs)): #this is an output
        file.writelines("						col_dest	<= COL_DEST_ADDR +\""+num2binary(int(output) - int(first_output), n)+"\";  \n")
    if (int(output) < int(row_size) - int(num_of_outputs)):        
        file.writelines("						col_dest	<= process_area_in + \""+num2binary(int(output), n)+"\" -" + " \""+num2binary(int(num_of_inputs), n)+"\" " + ";\n")
    file.writelines("\n");  
   
    if (int(numState) == int(total_cycles)) :
        file.writelines(
        "					when state"+str(numState)+" =>\n" +
        "					        PROCESS_AREA_FINISH	<= process_area_in + \""+num2binary(int(row_size) - int(num_of_inputs), n)+"\";\n" +
        "                                                --update cycle"+str(numState)+  " in crossbar\n"
        "						ROW_OUT		<= row_magic;\n" +
        "						COLUMN_OUT	<= col_magic;\n" +
        "						FINISH 			<= '1';\n"
        )        
        
    else:    
        file.writelines(
        "					when state"+str(numState)+" =>\n" +
        "                                               --update cycle"+str(numState)+  " in crossbar\n"
        "                                                ROW_OUT		<= row_magic; \n" +	  
		  "		                                COLUMN_OUT	<= col_magic;\n" +
        "						--update next state signals\n" +
        "						current_state 	<= state"+str(numState+1)+";\n");
             