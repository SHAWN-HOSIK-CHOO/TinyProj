module bin2bcd_Ctl(
    input wire Rst_,
    input wire Clock,
    input wire Start,
    input wire A8gt4,
    input wire A4gt4,
    input wire A0gt4,
    input wire K,
    output reg sela8, sela4, sela0,
    output reg load_Bin, sh_left, load_A, Done, cl_A
);

reg [2:0] nextState;
reg [2:0] State;

parameter S00 = 3'b011, S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 =3'b111,
            S01 = 3'b100;
//Control signal logic
always @(*) begin
    load_Bin = 1'b0; sh_left = 1'b0; load_A = 1'b0; Done = 1'b0;
    sela0 = 1'b0; sela4 = 1'b0; sela8 = 1'b0; cl_A = 1'b0;
    case (State)
        S00:
            begin
                
            end
        S01:
            begin
                load_Bin = 1'b1; 
                cl_A = 1'b1;
            end
        S0:
            begin
                sh_left = 1'b1;
            end
        S1:
            begin
                if(K == 1'b0)
                begin
                    sela0 = A0gt4;
                    sela4 = A4gt4;
                    sela8 = A8gt4;
                    load_A = 1'b1;
                end
                else begin
                    
                end
            end
        S2:
            begin
                Done = 1'b1;
            end
        default: begin
            load_Bin = 1'b0; sh_left = 1'b0; load_A = 1'b0; Done = 1'b0;
            sela0 = 1'b0; sela4 = 1'b0; sela8 = 1'b0;
        end
    endcase
end

//Next state logic
always @(*) begin
    nextState = S00;
    case (State)
        S00:
            begin
                if(Start) nextState = S01; else nextState = S00;
            end
        S01:
            begin
                nextState = S0;
            end
        S0:
            begin
                nextState = S1;
            end
        S1:
            begin
                if(K == 1'b1) nextState = S2;
                else nextState = S0;
            end
        S2:
            begin
                nextState = S00; 
            end
        default: nextState = S00;
    endcase
end

//State register
always @(posedge Clock or negedge Rst_) begin
    if(!Rst_) State <= S00;
    else State <= nextState;
end
endmodule