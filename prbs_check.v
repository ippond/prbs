`timescale 1ns/100ps
module prbs_check
#(
parameter C_DWIDTH     = 16                       ,
parameter C_PRIMPOLY   = 17'b1_0001_0000_0000_1011,
parameter C_POLY_WIDTH = 16
)
(
input                      I_clk         ,
input       [C_DWIDTH-1:0] I_data        ,
input                      I_data_v      ,
output reg                 O_check_v     ,
output reg                 O_check_right
);

reg [C_DWIDTH+C_POLY_WIDTH-1:0] S_reg;
reg S_data_v = 0;

always @(posedge I_clk)
begin
    if(I_data_v)
        S_reg <= {S_reg[C_POLY_WIDTH-1:0],I_data}; 
    O_check_right <= F_prbs_output(F_bit_reverse(S_reg[C_DWIDTH+:C_POLY_WIDTH])) == S_reg[C_DWIDTH-1:0];
    S_data_v <= I_data_v;
    O_check_v <= S_data_v;
end

function [C_DWIDTH-1:0] F_prbs_output;
input [C_POLY_WIDTH-1:0] S_cal_init;
reg [C_POLY_WIDTH-1:0] S_temp;
integer F_i;
begin
    S_temp = S_cal_init;
    for(F_i=0;F_i<C_POLY_WIDTH;F_i=F_i+1)
    begin
        S_temp = {^(S_temp & C_PRIMPOLY[C_POLY_WIDTH-1:0]),S_temp[C_POLY_WIDTH-1:1]};
    end
    for(F_i=0;F_i<C_DWIDTH;F_i=F_i+1)
    begin
        F_prbs_output[C_DWIDTH-1-F_i] = S_temp[0];
        S_temp = {^(S_temp & C_PRIMPOLY[C_POLY_WIDTH-1:0]),S_temp[C_POLY_WIDTH-1:1]};
        
    end
end
endfunction

function [C_POLY_WIDTH-1:0] F_bit_reverse;
input [C_POLY_WIDTH-1:0] S_data_ori;
integer F_i;
begin
for(F_i=0;F_i<C_POLY_WIDTH;F_i=F_i+1)
    F_bit_reverse[F_i] = S_data_ori[C_POLY_WIDTH-1-F_i];
end
endfunction

endmodule