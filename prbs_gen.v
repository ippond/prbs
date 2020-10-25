`timescale 1ns/100ps
module prbs_gen
#(
parameter C_DWIDTH     = 16                       ,
parameter C_PRIMPOLY   = 17'b1_0001_0000_0000_1011,
parameter C_POLY_WIDTH = 16
)
(
input                         I_clk     ,
input      [C_POLY_WIDTH-1:0] I_init    ,
input                         I_init_v  ,
input                         I_prbs_en ,
output reg [C_DWIDTH-1:0]     O_prbs    ,
output reg                    O_prbs_v
);

//-------------generation table----------------
//4:  X^4+X^1+1
//5:  X^5+X^2+1
//6:  X^6+X^1+1
//7:  X^7+X^3+1
//8:  X^8+X^4+X^3+X^2+1
//9:  X^9+X^4+1
//10: X^10+X^3+1
//11: X^11+X^2+1
//12: X^12+X^6+X^4+X^1+1
//13: X^13+X^4+X^3+X^1+1
//14: X^14+X^10+X^6+X^1+1
//15: X^15+X^1+1
//16: X^16+X^12+X^3+X^1+1
//----------------------------------------------
reg [C_POLY_WIDTH-1:0] S_prbs_reg;
wire [C_POLY_WIDTH-1:0] S_reg_sel;

assign S_reg_sel = I_init_v ? I_init : S_prbs_reg;

always @(posedge I_clk)
begin
    if(I_prbs_en)
    begin
        S_prbs_reg <= F_prbs_reg(S_reg_sel);
        O_prbs <= F_prbs_output(S_reg_sel);
    end
    O_prbs_v <= I_prbs_en;
end

function [C_DWIDTH-1:0] F_prbs_output;
input [C_POLY_WIDTH-1:0] S_cal_init;
reg [C_POLY_WIDTH-1:0] S_temp;
integer F_i;
begin
    S_temp = S_cal_init;
    for(F_i=0;F_i<C_DWIDTH;F_i=F_i+1)
    begin
        F_prbs_output[C_DWIDTH-1-F_i] = S_temp[0];
        S_temp = {^(S_temp & C_PRIMPOLY[C_POLY_WIDTH-1:0]),S_temp[C_POLY_WIDTH-1:1]};
    end
end
endfunction

function [C_POLY_WIDTH-1:0] F_prbs_reg;
input [C_POLY_WIDTH-1:0] S_cal_init;
integer F_i;
begin
    F_prbs_reg = S_cal_init;
    for(F_i=0;F_i<C_DWIDTH;F_i=F_i+1)
        F_prbs_reg = {^(F_prbs_reg & C_PRIMPOLY[C_POLY_WIDTH-1:0]),F_prbs_reg[C_POLY_WIDTH-1:1]};
end
endfunction

endmodule
