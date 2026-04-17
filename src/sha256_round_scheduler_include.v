module sha256_round_scheduler_include (
    input clk,
    input rst_n,
    input start,
    input [511:0] message_block,
    output reg [255:0] hash,
    output reg hash_valid
);

    // ========== PIPELINE STAGE 1: Message Scheduling ==========
    reg [31:0] W [0:63];
    reg [31:0] W_pipe1, W_pipe2;
    reg [5:0] round_calc, round_use;
    
    // Message expansion với pipeline riêng
    always @(posedge clk) begin
        if (round_calc >= 16 && round_calc <= 63) begin
            // Tính W cho round tiếp theo (stage 1)
            W_pipe1 <= W[round_calc-16] + sigma_lower_0(W[round_calc-15]);
            W_pipe2 <= W[round_calc-7] + sigma_lower_1(W[round_calc-2]);
        end
    end
    
    always @(posedge clk) begin
        if (round_calc >= 16 && round_calc <= 63) begin
            W[round_calc] <= W_pipe1 + W_pipe2;  // Stage 2
        end
    end
    
    // ========== PIPELINE STAGE 2-3: Round Computation ==========
    reg [31:0] a,b,c,d,e,f,g,h;
    reg [31:0] T1_stage1, T1_stage2, T2_stage1;
    reg [31:0] sigma0_a, sigma1_e, ch_efg, maj_abc;
    
    // Stage 1: Tính các hàm (combinational)
    always @(posedge clk) begin
        sigma0_a <= {a[1:0], a[31:2]} ^ {a[12:0], a[31:13]} ^ {a[21:0], a[31:22]};
        sigma1_e <= {e[5:0], e[31:6]} ^ {e[10:0], e[31:11]} ^ {e[24:0], e[31:25]};
        ch_efg  <= (e & f) ^ (~e & g);
        maj_abc  <= (a & b) ^ (a & c) ^ (b & c);
    end
    
    // Stage 2: Tính T1, T2
    always @(posedge clk) begin
        T1_stage1 <= h + sigma1_e + ch_efg;
        T2_stage1 <= sigma0_a + maj_abc;
    end
    
    always @(posedge clk) begin
        T1_stage2 <= T1_stage1 + K[round_use] + W[round_use];
    end
    
    // Stage 3: Cập nhật state
    always @(posedge clk) begin
        a <= T1_stage2 + T2_stage1;
        b <= a;
        c <= b;
        d <= c;
        e <= d + T1_stage2;
        f <= e;
        g <= f;
        h <= g;
    end
    
    // ========== CONSTANTS ROM với RAM block ==========
    (* ramstyle = "M9K" *) reg [31:0] K [0:63];
    
    // Khởi tạo K constants
    initial begin
        K[0] = 32'h428a2f98; K[1] = 32'h71374491; // ... (all 64 constants)
    end
    
endmodule
