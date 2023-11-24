module VMM #( parameter l = 5, parameter n = 5, parameter m = 5)
(
    input wire vmm_clk,
    input wire rst_,
    input wire done_i,
    output wire [2:0] state_o,
    output wire [3:0] debugA,
    output wire [3:0] debugB,
    output wire [3:0] debugR,
    output reg [7:0] vmm_out,
    output reg [l-1:0] i, 
    output reg [n-1:0] j,
    output wire next_o
);
    ////// Register vmm_out //////
    
    always @(posedge vmm_clk or negedge rst_) begin
        if (!rst_) begin
            vmm_out <= 8'b00000000;
        end
        else if (next_o) begin
            vmm_out <= C[i][j];
        end
        else begin
            vmm_out <= vmm_out;
        end
    end
    

    ////// Register A and B //////
    (*ram_init_file="ram32x4_a.mif"*)reg [3:0] A[l-1:0][m-1:0];
    (*ram_init_file="ram32x4_b.mif"*)reg [3:0] B[m-1:0][n-1:0];

    //debug
    assign debugA = A[i][j];
    assign debugB = B[i][j];
    assign debugR = res[3:0];

    ////// Register C //////
    reg [7:0] C[l-1:0][n-1:0];  
    wire c_w_en;                 

    always @(posedge vmm_clk) begin
        if (c_w_en) begin
            C[i][j] <= res;
        end
        else begin
            C[i][j] <= C[i][j];
        end
    end

    ////// Register res //////
    reg [7:0] res;    
    wire cl_res;
    wire ld_res;                 

    always @(posedge vmm_clk or negedge rst_) begin
        if(!rst_) begin
            res <= 8'b00000000;
        end
        else if (cl_res) begin
            res <= 8'b00000000;
        end
        else if (ld_res) begin
            res <= res + A[i][k] * B[k][j];
        end
        else begin
            res <= res;
        end
    end

    ////// Register i //////
     
    wire cl_i; 
    wire inc_i;   
    wire sel_3;   

    wire ilt_l_or_3;  

    assign ilt_l_or_3 = (sel_3 == 1) ? ((i < 3) ? 1 : 0) : ((i < l) ? 1 : 0);

    always @(posedge vmm_clk or negedge rst_) begin
        if(!rst_) begin
            i <= 5'b0000;
        end
        else if(cl_i) begin
            i <= 5'b00000;
        end
        else if(inc_i) begin
            i <= i + 1;
        end
        else begin
            i <= i;
        end
    end

    ////// Register j //////
                
    wire cl_j;           
    wire inc_j;             

    wire jltn;              

    assign jltn = (j < n) ? 1 : 0;

    always @(posedge vmm_clk or negedge rst_) begin
        if(!rst_) begin
            j <= 5'b0000;
        end
        else if(cl_j) begin
            j <= 5'b00000;
        end
        else if (inc_j) begin
            j <= j + 1;
        end
        else begin
            j <= j;
        end
    end

    ////// Register k //////
    reg [m-1:0] k;            
    wire cl_k;           
    wire inc_k;             

    wire kltm;             

    assign kltm = (k < m) ? 1 : 0;

    always @(posedge vmm_clk or negedge rst_) begin
        if (!rst_) begin
            k <= 5'b00000;
        end
        else if(cl_k) begin
            k <= 5'b00000;
        end
        else if (inc_k) begin
            k <= k + 1;
        end
        else begin
            k <= k;
        end
    end

    ////// Control Unit //////
    VMM_CTL vmm_control(.clk(vmm_clk), .rst_(rst_), .ilt_l_or_3_ctl(ilt_l_or_3),
                        .jltn_ctl(jltn), .kltm_ctl(kltm), .c_w_en_ctl(c_w_en),
                        .cl_res_ctl(cl_res), .ld_res_ctl(ld_res), .cl_i_ctl(cl_i), .inc_i_ctl(inc_i),
                        .sel_3_ctl(sel_3), .cl_j_ctl(cl_j), .inc_j_ctl(inc_j), .next_o_ctl(next_o),
                        .cl_k_ctl(cl_k), .inc_k_ctl(inc_k), .done_i_ctl(done_i), .state(state_o));

endmodule