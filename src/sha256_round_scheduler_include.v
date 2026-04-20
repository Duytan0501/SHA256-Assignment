module sha256_round_scheduler_include (
    input clk,
    input rst_n,
    input start,                    // bắt đầu xử lý
    input [511:0] message_block,    // block hiện tại
    input last_block,               // 1 = đây là block cuối cùng
    output reg [255:0] hash,        // hash cuối cùng
    output reg hash_valid,          // 1 = hash đã sẵn sàng
    output reg ready_for_next_block // 1 = có thể nạp block tiếp theo
);

    // ========== FSM STATES ==========
    localparam IDLE       = 3'b000;
    localparam LOAD_IV    = 3'b001;
    localparam RUN_ROUNDS = 3'b010;
    localparam UPDATE_HASH= 3'b011;
    localparam WAIT_LAST  = 3'b100;
    localparam DONE       = 3'b101;

    reg [2:0] state, next_state;
    reg [5:0] round;           // 0..63
    reg [255:0] current_hash;  // hash đang xây dựng
    reg [255:0] final_hash;
    
    // ========== HASH STATE (8 registers) ==========
    reg [31:0] a, b, c, d, e, f, g, h;
    reg [31:0] a_old, b_old, c_old, d_old, e_old, f_old, g_old, h_old;
    
    // ========== MESSAGE SCHEDULING ==========
    reg [31:0] W [0:63];
    // W_pipe tinh truoc gia tri cho W[data]
    reg [31:0] W_pipe1, W_pipe2;
    reg [5:0] round_use;
    
    // ========== CONSTANTS (giữ nguyên) ==========
    (* ramstyle = "M9K" *) reg [31:0] K [0:63];
    initial begin
        // ... (64 giá trị K như cũ)
        K[0] = 32'h428a2f98; K[1] = 32'h71374491; // ... đầy đủ
        K[63]= 32'hc67178f2;
    end
    
    // ========== HÀM LOGIC (sigma, ch, maj) ==========
    // ... (giữ nguyên các function từ code trước)
    // chua co function, can cap nhat
    
    // ========== FSM: NEXT STATE ==========
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: 
                if (start) next_state = LOAD_IV;
                
            LOAD_IV: 
                next_state = RUN_ROUNDS;
                
            RUN_ROUNDS: 
                if (round == 63) next_state = UPDATE_HASH;
                
            UPDATE_HASH: 
                if (last_block) next_state = WAIT_LAST;
                else next_state = IDLE;  // còn block tiếp theo
                
            WAIT_LAST: 
                next_state = DONE;
                
            DONE: 
                if (!start) next_state = IDLE;
        endcase
    end
    
    // ========== FSM: STATE UPDATE ==========
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            round <= 0;
            ready_for_next_block <= 0;
            hash_valid <= 0;
        end else begin
            state <= next_state;
            
            case (next_state)
                IDLE: begin
                    round <= 0;
                    ready_for_next_block <= 1;
                    hash_valid <= 0;
                end
                
                LOAD_IV: begin
                    round <= 0;
                    ready_for_next_block <= 0;
                    
                    // IMPORTANT: Load IV từ current_hash (block trước)
                    // hoặc giá trị khởi tạo nếu là block đầu tiên
                    if (current_hash == 256'h0) begin
                        // Block đầu tiên: dùng IV chuẩn
                        a <= 32'h6a09e667;
                        b <= 32'hbb67ae85;
                        c <= 32'h3c6ef372;
                        d <= 32'ha54ff53a;
                        e <= 32'h510e527f;
                        f <= 32'h9b05688c;
                        g <= 32'h1f83d9ab;
                        h <= 32'h5be0cd19;
                    end else begin
                        // Block tiếp theo: dùng hash từ block trước
                        {a, b, c, d, e, f, g, h} <= current_hash;
                    end
                    
                    // Lưu lại giá trị cũ để cộng dồn sau
                    {a_old, b_old, c_old, d_old, e_old, f_old, g_old, h_old} <= 
                        {a, b, c, d, e, f, g, h};
                    
                    // Khởi tạo W[0:15] từ message_block
                    for (int i = 0; i < 16; i++) begin
                        W[i] <= message_block[511 - 32*i -: 32];
                    end
                end
                
                RUN_ROUNDS: begin
                    if (round < 63) round <= round + 1;
                end
                
                UPDATE_HASH: begin
                    // Cộng dồn: new_hash = old_hash + state_after_rounds
                    current_hash <= {a_old, b_old, c_old, d_old, e_old, f_old, g_old, h_old}
                                   + {a, b, c, d, e, f, g, h};
                    
                    if (last_block) begin
                        final_hash <= {a_old, b_old, c_old, d_old, e_old, f_old, g_old, h_old}
                                    + {a, b, c, d, e, f, g, h};
                    end
                end
                
                WAIT_LAST: begin
                    hash_valid <= 1;
                    hash <= final_hash;
                end
                
                DONE: begin
                    hash_valid <= 0;
                end
            endcase
        end
    end
    
    // ========== MESSAGE SCHEDULING PIPELINE ==========
    always @(posedge clk) begin
        if (state == RUN_ROUNDS) begin
          // vd W_pipe1, W_pipe2 duoc tinh truoc 1, vd round nay la 16 thi
          // round cycle truoc la rounfd = 15, su dung round = 15 
          if (round >= 0 && round <= 47) begin 
            W_pipe1 <= W[round] + sigma_lower_0(W[round + 1]);
            W_pipe2 <= W[round + 9] + sigma_lower_1(W[round + 14]);
            round_use <= round;
          end

          // vd W[16] = W_pipe1 + W_pipe2 = W[0] + sigma_lower_0(W[1]) + W[9]
          // + sigma_lower_1(W[14])
          if (round_use >= 0 && round_use <= 47) W[round_use + 16] <= W_pipe1 + W_pipe2;
        end
    end



    // ========== ROUND COMPUTATION PIPELINE ==========
    // ... (giữ nguyên pipeline 3 stage từ code trước)
    reg [31:0] T1_stage1, T1_stage2, T2_stage1;
    reg [31:0] sigma0_a, sigma1_e, ch_efg, maj_abc;
    
    always @(posedge clk) begin
        if (state == RUN_ROUNDS) begin
            // Stage 1: Tính intermediate values
            // vd trong cycle truoc, round = 1, round_use = 0 >= 0
            sigma0_a <= sigma0(a);
            sigma1_e <= sigma1(e);
            ch_efg   <= ch(e, f, g);
            maj_abc  <= maj(a, b, c);
            
            // Stage 2: Tính T1_stage1 và T2_stage1 (dùng sigma1_e, ch_efg, sigma0_a, maj_abc từ cycle trước)
            // tai cuoi cycle nay(tuc la posedge clk xong) round = 2, round_use = 1
            // T1_stage1 = h (round_use = 0 + sigma1_e (round_use = 0) + ch_efg
            // (round_use = 0)
            // T2_stage1 = sigma0_a (round_use = 0) + maj_abc (round_use = 0) 
            T1_stage1 <= h + sigma1_e + ch_efg;
            T2_stage1 <= sigma0_a + maj_abc;
            
            // Stage 3: Tính T1_stage2
            // T1_stage2 = T1_stage1 (round_use = 0) + K (round_use = 0)
            // + W[round_use = 0]
            T1_stage2 <= T1_stage1 + K[round_use] + W[round_use];
            
            // Stage 4: Cập nhật thanh ghi a-h (dùng T1_stage2 và T2_stage1 từ cycle trước)
            // a = T1 (round_use )
            a <= T1_stage2 + T2_stage1;
            b <= a;
            c <= b;
            d <= c;
            e <= d + T1_stage2;
            f <= e;
            g <= f;
            h <= g;
        end
    end

endmodule
