module VMM_TOP 
(
    input wire CLOCK_50,
    input wire [3:0] KEY,
    input wire [1:0] SW,
    output wire [17:0] LEDR,
    output wire [0:6] HEX0, HEX1, HEX4, HEX5, HEX7, HEX2, HEX3, HEX6
);

    wire reset_;
    assign reset_ = KEY[0];

    ////// CLOCK DIVIDER //////
    wire Clk;
    reg [24:0] Clock_Down = 0;

    always @(posedge CLOCK_50) begin
        Clock_Down <= Clock_Down + 1;
    end
    
    assign Clk = Clock_Down[24];
    assign LEDR[17] = Clk;

    ////// Datapath //////

    ////// VMM module //////
    wire[7:0] out;
    wire[4:0] i;
    wire[4:0] j;
    wire[2:0] State;
    wire Done; // This heads from VMM module to bin2bcd module
    wire Next;

    //debug
    wire[3:0] dA;
    wire[3:0] dB;
    bin7seg H3(dA,HEX3);
    bin7seg H2(dB,HEX2);
    wire[3:0] dR;
    bin7seg H6(dR,HEX6);
    //debug end

    assign Done = ~KEY[1];
    VMM #(.l(5),.n(5),.m(5)) vmm_module (.debugR(dR),.debugA(dA),.debugB(dB),.vmm_clk(Clk),.rst_(reset_), .done_i(Done), .next_o(Next),.state_o(State),.vmm_out(out),.i(i),.j(j));

    bin7seg H7({1'b0,State},HEX7);
    bin7seg H5(i[3:0],HEX5);
    bin7seg H4(j[3:0],HEX4);
    bin7seg H1(out[7:4],HEX1);
    bin7seg H0(out[3:0],HEX0);

endmodule

module bin7seg (B, display);  // 2~12
	input [3:0] B;
	output [0:6] display;

	reg [0:6] display;

	/*
	 *       0  
	 *      ---  
	 *     |   |
	 *    5|   |1
	 *     | 6 |
	 *      ---  
	 *     |   |
	 *    4|   |2
	 *     |   |
	 *      ---  
	 *       3  
	 */
	always @ (B)
		case (B)
			4'h1: display = 7'b1111001;
			4'h2: display = 7'b0010010;
			4'h3: display = 7'b0000110;
			4'h4: display = 7'b1001100;
			4'h5: display = 7'b0100100;
			4'h6: display = 7'b0100000;
			4'h7: display = 7'b0001111;
			4'h8: display = 7'b0000000;
			4'h9: display = 7'b0000100;
  			4'b1010: display = 7'b0001000;
  			4'b1011: display = 7'b1100000;
  			4'b1100: display = 7'b1110010;
			4'b1101: display = 7'b1000010;
			4'b1110: display = 7'b0110000;
			4'b1111: display = 7'b0111000;
			default: display = 7'b0000001;
		endcase

endmodule