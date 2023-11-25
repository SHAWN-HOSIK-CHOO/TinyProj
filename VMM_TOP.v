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

    ////// VMM module //////
    wire[9:0] out;		//MUST match bcd_module input
    wire[4:0] i;        //MUST be equivalent to l
    wire[4:0] j;        //MUST be equivalent to n
    wire[2:0] State;
    wire Done; 
    wire Next;
	assign Next = ~KEY[1];
	assign LEDR[0] = Done;
  
    VMM #(.l(5),.n(5),.m(5)) vmm_module (.vmm_clk(Clk),.rst_(reset_), .done_i(Done), .next_i(Next),.state_o(State),.vmm_out(out),.i(i),.j(j));

	//////bin2bcd module //////

	wire[3:0] A0_out;
	wire[3:0] A4_out;
	wire[3:0] A8_out;
	wire[3:0] A12_out;

	bin2bcd #(.No_bits(10)) bcd_module(.bin2bcd_clk(Clk),.reset_(reset_),.start_i(Next),.vmm_out(out),.done_o(Done),.A12(A12_out),.A8(A8_out),.A4(A4_out),.A0(A0_out),.K(K));

	//Debug
	wire[3:0] K;
	bin7seg H6(K,HEX6);
	/*
	bin7seg U2 ({2'b00,out[9:8]},  HEX2);
	bin7seg U1 (out[7:4],  HEX1);
	bin7seg U0 (out[3:0],  HEX0);
	*/
	//////Output Display
    bin7seg H7({1'b0,State},HEX7);
    bin7seg H5(i[3:0],HEX5);
    bin7seg H4(j[3:0],HEX4);
	
	bin7seg U3 (A12_out, HEX3);
	bin7seg U2 (A8_out,  HEX2);
	bin7seg U1 (A4_out,  HEX1);
	bin7seg U0 (A0_out,  HEX0);
	
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