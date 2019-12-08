module and_3bit (A, B, C, S);
//-------------Input Ports Declarations-----------------------------
input A, B, C;
//-------------Output Ports Declarations-----------------------------
output S;
//-------------Logic-----------------------------------------------
assign S = A & B & C ;
endmodule