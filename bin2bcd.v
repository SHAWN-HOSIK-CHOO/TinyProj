module bin2bcd #(parameter No_bits = 10) 
(
  input wire bin2bcd_clk,
  input wire reset_,
  input wire start_i,
  input wire [No_bits-1:0] vmm_out,
  output wire done_o,
  output reg [3:0] A12, A8, A4, A0,
  output reg [3:0] K
);

///////////  Datapath 
  wire L_Bin, L_A, Shl;

// Register Bin
  reg[No_bits-1:0]  Bin;
  always @(posedge bin2bcd_clk, negedge reset_)  begin
      if (!reset_)  Bin <= 0;
      else if (L_Bin) Bin <= vmm_out;
      else if (Shl) Bin[No_bits-1:0] <= {Bin[No_bits-2:0], 1'b0};
  end


// Register A
  wire        sela0, sela4, sela8;
  wire cl_A;
  always@(posedge bin2bcd_clk, negedge reset_)  begin
      if (!reset_)  begin A0 <= 0; A4 <= 0; A8 <= 0; A12 <= 0; end
      else if (Shl) begin A12[3:0] <= { A12[2:0], A8[3] } ;   A8[3:0] <= {A8[2:0], A4[3] } ;
                           A4[3:0] <= { A4[2:0], A0[3] } ;    A0[3:0] <= {A0[2:0], Bin[No_bits-1] } ;  
                     end
      else if (L_A) begin 
                          if (sela8) A8 <= A8 + 3; else A8 <= A8;
                          if (sela4) A4 <= A4 + 3; else A4 <= A4;
                          if (sela0) A0 <= A0 + 3; else A0 <= A0;
                     end
      else if(cl_A) begin
                          A0 <= 0; A4 <= 0; A8 <= 0; A12 <= 0;
                    end
      else begin
                    A0 <= A0; A4 <= A4; A8 <= A8; A12 <= A12;
      end
   end


// Register K
  //reg[3:0] K;
  always @(posedge bin2bcd_clk) begin
    if(L_Bin) K <= 4'b1010;         // MUST match No_bits
    else if(Shl) K <= K - 1;
    else K <= K;
  end

///////////  Control
  wire NORK = ~|K;
  wire [2:0] State;
  wire A8gt, A4gt, A0gt;
  assign A8gt = A8 > 4 ;
  assign A4gt = A4 > 4 ;
  assign A0gt = A0 > 4 ;
  bin2bcd_Ctl C1 (.Rst_(reset_), .Clock(bin2bcd_clk), .Start(start_i), .load_Bin(L_Bin), .sh_left(Shl), .load_A(L_A), 
                  .A8gt4(A8gt),  .A4gt4(A4gt),  .A0gt4(A0gt), .K(NORK),
                  .sela8(sela8), .sela4(sela4), .sela0(sela0), .Done(done_o),.cl_A(cl_A));

endmodule
