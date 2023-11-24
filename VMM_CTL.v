module VMM_CTL
(
    input wire clk,
    input wire rst_,
    input wire ilt_l_or_3_ctl,
    input wire jltn_ctl,
    input wire kltm_ctl,
    input wire done_i_ctl,
    output reg [2:0] state,
    output reg c_w_en_ctl, cl_res_ctl, ld_res_ctl, cl_i_ctl,
                inc_i_ctl, sel_3_ctl, cl_j_ctl, inc_j_ctl,
                cl_k_ctl, inc_k_ctl, next_o_ctl
);

parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011,
            S4 = 3'b100, S5 = 3'b101, S6 = 3'b110, S7 = 3'b111;

reg [2:0] nxtState;

////// Control Signal Logic //////
always @(*) 
begin
    c_w_en_ctl = 1'b0; cl_res_ctl = 1'b0; ld_res_ctl = 1'b0; cl_i_ctl = 1'b0;
    inc_i_ctl = 1'b0; sel_3_ctl = 1'b0; cl_j_ctl = 1'b0; inc_j_ctl = 1'b0;
    cl_k_ctl = 1'b0; inc_k_ctl = 1'b0; next_o_ctl = 1'b0;

    case(state)
        S0 : 
            begin
                
            end
        S1 : 
            begin
                cl_i_ctl = 1'b1;
            end
        S2 : 
            begin
                if (ilt_l_or_3_ctl) begin
                    cl_j_ctl = 1'b1;
                end
                else begin
                    cl_i_ctl = 1'b1;
                    cl_j_ctl = 1'b1; // 
                end
            end
        S3 :
            begin
                if (jltn_ctl) begin
                    cl_res_ctl = 1'b1;
                    cl_k_ctl = 1'b1;
                end
                else begin
                    inc_i_ctl = 1'b1;
                end
            end
        S4 :
            begin
                if (kltm_ctl) begin
                    inc_k_ctl = 1'b1;
                    ld_res_ctl = 1'b1;
                end
                else begin
                    c_w_en_ctl = 1'b1;
                    inc_j_ctl = 1'b1;
                end
            end
        S5 :
            begin
                sel_3_ctl = 1'b1;
                if (ilt_l_or_3_ctl) begin
                    cl_j_ctl = 1'b1;
                end
                else begin
                    
                end
            end
        S6 :
            begin
                if (jltn_ctl) begin
                    
                end
                else begin
                    inc_i_ctl = 1'b1;
                end
            end
        S7 :
            begin
                next_o_ctl = 1'b1;
                if (done_i_ctl) begin
                    inc_j_ctl = 1'b1;
                end
                else begin
                    
                end
            end
        default : ;
    endcase
end

////// Next State Logic //////
always @(*) 
begin
    nxtState = 3'b000;

    case (state)
        S0 : 
            begin
                
            end
        S1 :
            begin
                nxtState = S2;
            end
        S2 :
            begin
                if (ilt_l_or_3_ctl) begin
                    nxtState = S3;
                end
                else begin
                    nxtState = S5;
                end
            end
        S3 :
            begin
                if (jltn_ctl) begin
                    nxtState = S4;
                end
                else begin
                    nxtState = S2;
                end
            end
        S4 :
            begin
                if (kltm_ctl) begin
                    nxtState = S4;
                end
                else begin
                    nxtState = S3;
                end
            end
        S5 :
            begin
                if (ilt_l_or_3_ctl) begin
                    nxtState = S6;
                end
                else begin
                    nxtState = S0;
                end
            end
        S6 : 
            begin
                if (jltn_ctl) begin
                    nxtState = S7;
                end
                else begin
                    nxtState = S5;
                end
            end
        S7 :
            begin
                if (done_i_ctl) begin
                    nxtState = S6;
                end
                else begin
                    nxtState = S7;
                end
            end
        default: ;
    endcase
end

////// State Registers //////
always @(posedge clk or negedge rst_) begin
    if (!rst_) begin
        state <= S1;
    end
    else begin
        state <= nxtState;
    end
end

endmodule