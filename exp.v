module SimpleDDS(DAC_clk, DAC_data);
input DAC_clk;
output [9:0] DAC_data;

// let's create a 16 bits free-running binary counter
reg [15:0] cnt;
always @(posedge DAC_clk) cnt <= cnt + 16'h1;

// and use it to generate the DAC signal output
wire cnt_tap = cnt[7];     // we take one bit out of the counter (here bit 7 = the 8th bit)
assign DAC_data = {10{cnt_tap}};   // and we duplicate it 10 times to create the 10-bits DAC value 
                                     // with the maximum possible amplitude
endmodule