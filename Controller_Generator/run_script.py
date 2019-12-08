# -*- coding: utf-8 -*-
"""
Created on Fri Nov 15 22:57:09 2019

@author: yanac
"""

#main script to create a controller based on SIMPLER output

import simpler_main
import main
import sys
import os
from block_help_generator import check_json_names
from simpler_conf_generator import simpler_conf_generator

#run simpler by the configuration file
JSON_names = open("json_names.txt","w") 
answer = input ("Please create a Config_file. The config shall have the names of verilog files, and a list of wanted row sizes separated by space.\n Press y when the file is ready. ")
if answer == "y":
    configuration_file = open("Config_file","r") 
    line = configuration_file.readline().replace('\n','')
    while line:
        input_file = line.split(" ")[0]
        row_sizes = line.split(" ")[1]
        simpler_conf_generator(input_file, row_sizes)
        print ("--Simpler for function " + input_file + " is Running--\n")
        simpler_main.main()
        print ("--Finished - " + input_file + " JSON files has been generated--\n")
        #create json_names file
        row_sizes_list = row_sizes.replace('[','').replace(']','').split(',')
        for i in list(row_sizes_list):
            json_file_name = "JSON_"+i+"_"+input_file+".json"
            if not os.path.exists(json_file_name):
                continue
            else:
                JSON_names.writelines(json_file_name)
                JSON_names.writelines("\n")
        line = configuration_file.readline().replace('\n',' ')
else:
    print ("wrong input. \n")
    print ("--Exiting Program--\n")
    sys.exit() 
JSON_names.close()
  
#run VHDL generator
flag = 0
answer = input ("Please make sure json_names.txt file includes the blocks you want to convert to VHDL. Press y when the file is ready. ")
while flag == 0:
    if answer == "y":
        flag = check_json_names("json_names.txt")
        if flag == 0:
            answer = input ("Please make sure json_names.txt file includes correct names. Press y when the file is ready. ")
    else:
        print ("wrong input. \n")
        print ("--Exiting Program--\n")
        sys.exit() 
        

main.main()

