module sig_gen(input clk,
               input [4:0] state,
               input [7:0] state_freq,
               input [7:0] state_amp,
               input [7:0] state_phase,
               output reg [13:0]DA_A,
               output DA_CLK_A,
               output DA_WR_A);
    
    parameter MAX_state = 5'd3;
    
    wire t_1sec;
    
    reg [13:0] cnt;
    // reg [4:0] state;
    reg [3:0] en;
    reg [15:0] addr;
    reg [13:0] DAC_data;
    
    wire [11:0] freq;
    wire [2:0] amp;
    wire [7:0] phase;
    
    wire [13:0] saw;
    wire [13:0] Tri; // 'tri' is reserved in verilog
    wire [13:0] sqr;
    wire [13:0] sin;
    wire [13:0] rand;
    
    initial begin
        cnt  <= 16'b0;
        addr <= 15'b0;
        en   <= 4'b0;
    end
    
    assign DA_CLK_A = clk;
    assign DA_WR_A  = ~clk;
    
    assign freq  = 10 ** state_freq; // TODO 1kHz ~ 5GHz?
    assign amp   = 2**state_amp; // 0~9 --> 2^0 ~ 2^-9 times amp
    assign phase = 20*state_phase; // 20*(0~9) --> 0~180 degrees
    
    always @(posedge clk)
    begin
        cnt  <= cnt + 14'h1;
        DA_A <= DAC_data;
        
        
        // if (t_1sec) begin
        //     state = (state == MAX_state)?5'd0:(state + 5'd1); //changes state
        // end
        
        case (state)
            5'd0: begin
                en       <= 4'b0001;
                DAC_data <= saw; //sawtooth
            end
            
            5'd1: begin
                en       <= 4'b0010;
                DAC_data <= Tri; //triangular
            end
            
            5'd2: begin
                en       <= 4'b0100;
                DAC_data <= sqr;
            end
            
            5'd3: begin
                en       <= 4'b1000;
                DAC_data <= sin;
            end
            
            5'd4: begin
                DAC_data <= rand;
            end
            
            5'd10: begin
                en       <= 4'b0000;
                DAC_data <= 14'b0;
            end
            
            default:
            DAC_data <= 14'b0;
        endcase
    end
    
    t1s t1s_inst(
    .clk(clk),
    .s(t_1sec)
    );
    
    saw_gen saw_inst(
    .clk(clk),
    .en(en[0]),
    .freq(freq),
    .amp(amp),
    .phase(phase),
    .DAC_in(saw)
    );
    
    tri_gen tri_inst(
    .clk(clk),
    .en(en[1]),
    .freq(freq),
    .amp(amp),
    .phase(phase),
    .DAC_in(Tri)
    );
    
    sqr_gen sqr_inst(
    .clk(clk),
    .en(en[2]),
    .freq(freq),
    .amp(amp),
    .phase(phase),
    .DAC_in(sqr)
    );
    
    sin_gen sin_inst(
    .clk(clk),
    .en(en[3]),
    .freq(freq),
    .amp(amp),
    .phase(phase),
    .DAC_in(sin)
    );
    
    lfsr lfsr_inst(
    .clk(clk),
    .en(1'b1),
    .DAC_in(rand)
    );
endmodule
