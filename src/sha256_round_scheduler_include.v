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
<<<<<<< HEAD
    // register a, b, c -> h (old) 
=======
>>>>>>> 134c46cdf883fd65b9325f518ec8954a111f359e
    reg [31:0] a_old, b_old, c_old, d_old, e_old, f_old, g_old, h_old;
    
    // ========== MESSAGE SCHEDULING ==========
    reg [31:0] W [0:63];
    // W_pipe tinh truoc gia tri cho W[data]
    reg [31:0] W_pipe1, W_pipe2;
<<<<<<< HEAD
    
    // ========== CONSTANTS ==========
    (* ramstyle = "M9K" *) reg [31:0] K [0:63];

    initial begin
        K[0]  = 32'h428a2f98; K[1]  = 32'h71374491; K[2]  = 32'hb5c0fbcf; K[3]  = 32'he9b5dba5;
        K[4]  = 32'h3956c25b; K[5]  = 32'h59f111f1; K[6]  = 32'h923f82a4; K[7]  = 32'hab1c5ed5;
        K[8]  = 32'hd807aa98; K[9]  = 32'h12835b01; K[10] = 32'h243185be; K[11] = 32'h550c7dc3;
        K[12] = 32'h72be5d74; K[13] = 32'h80deb1fe; K[14] = 32'h9bdc06a7; K[15] = 32'hc19bf174;
        K[16] = 32'he49b69c1; K[17] = 32'hefbe4786; K[18] = 32'h0fc19dc6; K[19] = 32'h240ca1cc;
        K[20] = 32'h2de92c6f; K[21] = 32'h4a7484aa; K[22] = 32'h5cb0a9dc; K[23] = 32'h76f988da;
        K[24] = 32'h983e5152; K[25] = 32'ha831c66d; K[26] = 32'hb00327c8; K[27] = 32'hbf597fc7;
        K[28] = 32'hc6e00bf3; K[29] = 32'hd5a79147; K[30] = 32'h06ca6351; K[31] = 32'h14292967;
        K[32] = 32'h27b70a85; K[33] = 32'h2e1b2138; K[34] = 32'h4d2c6dfc; K[35] = 32'h53380d13;
        K[36] = 32'h650a7354; K[37] = 32'h766a0abb; K[38] = 32'h81c2c92e; K[39] = 32'h92722c85;
        K[40] = 32'ha2bfe8a1; K[41] = 32'ha81a664b; K[42] = 32'hc24b8b70; K[43] = 32'hc76c51a3;
        K[44] = 32'hd192e819; K[45] = 32'hd6990624; K[46] = 32'hf40e3585; K[47] = 32'h106aa070;
        K[48] = 32'h19a4c116; K[49] = 32'h1e376c08; K[50] = 32'h2748774c; K[51] = 32'h34b0bcb5;
        K[52] = 32'h391c0cb3; K[53] = 32'h4ed8aa4a; K[54] = 32'h5b9cca4f; K[55] = 32'h682e6ff3;
        K[56] = 32'h748f82ee; K[57] = 32'h78a5636f; K[58] = 32'h84c87814; K[59] = 32'h8cc70208;
        K[60] = 32'h90befffa; K[61] = 32'ha4506ceb; K[62] = 32'hbef9a3f7; K[63] = 32'hc67178f2;
    end

    // ========== HÀM LOGIC ==========
    function [31:0] maj;
        input [31:0] a, b, c;
        begin
            maj = (a & b) ^ (a & c) ^ (b & c);
        end
    endfunction

    function [31:0] ch;
        input [31:0] e, f, g;
        begin
            ch = (e & f) ^ (~e & g);
        end
    endfunction

    function [31:0] sigma_lower_0;
        input [31:0] x;
        begin
            sigma_lower_0 = {x[6:0], x[31:7]} ^ {x[17:0], x[31:18]} ^ (x >> 3);
        end
    endfunction

    function [31:0] sigma_lower_1;
        input [31:0] x;
        begin
            sigma_lower_1 = {x[16:0], x[31:17]} ^ {x[18:0], x[31:19]} ^ (x >> 10);
        end
    endfunction

    function [31:0] sigma_upper_0;
        input [31:0] x;
        begin
            sigma_upper_0 = {x[1:0], x[31:2]} ^ {x[12:0], x[31:13]} ^ {x[21:0], x[31:22]};
        end
    endfunction

    function [31:0] sigma_upper_1;
        input [31:0] x;
        begin
            sigma_upper_1 = {x[5:0], x[31:6]} ^ {x[10:0], x[31:11]} ^ {x[24:0], x[31:25]};
        end
    endfunction
=======
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
>>>>>>> 134c46cdf883fd65b9325f518ec8954a111f359e
    
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
            current_hash <= 256'h0;
            final_hash <= 256'h0;
        end else begin
            state <= next_state;
            
            case (next_state)
                IDLE: begin
                    round <= 0;
                    ready_for_next_block <= 1;
                    hash_valid <= 0;
                end
                
                LOAD_IV: begin
<<<<<<< HEAD
    round <= 0;
    ready_for_next_block <= 0;
    
    if (current_hash == 256'h0) begin
        a <= 32'h6a09e667;
        b <= 32'hbb67ae85;
        c <= 32'h3c6ef372;
                            d <= 32'ha54ff53a;
                            e <= 32'h510e527f;
                            f <= 32'h9b05688c;
                            g <= 32'h1f83d9ab;
                            h <= 32'h5be0cd19;
                        end else begin
                            {a, b, c, d, e, f, g, h} <= current_hash;
                        end
                        
                        {a_old, b_old, c_old, d_old, e_old, f_old, g_old, h_old} <= 
                            {a, b, c, d, e, f, g, h};
                        
                        // THAY THẾ vòng lặp for bằng 16 dòng gán riêng
                        W[0] <= message_block[511:480];
                        W[1] <= message_block[479:448];
                        W[2] <= message_block[447:416];
                        W[3] <= message_block[415:384];
                        W[4] <= message_block[383:352];
                        W[5] <= message_block[351:320];
                        W[6] <= message_block[319:288];
                        W[7] <= message_block[287:256];
                        W[8] <= message_block[255:224];
                        W[9] <= message_block[223:192];
                        W[10] <= message_block[191:160];
                        W[11] <= message_block[159:128];
                        W[12] <= message_block[127:96];
                        W[13] <= message_block[95:64];
                        W[14] <= message_block[63:32];
                        W[15] <= message_block[31:0];
=======
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
>>>>>>> 134c46cdf883fd65b9325f518ec8954a111f359e
                end
                
                RUN_ROUNDS: begin
                    if (round < 63) round <= round + 1;
                end
                
                UPDATE_HASH: begin
<<<<<<< HEAD
=======
                    // Cộng dồn: new_hash = old_hash + state_after_rounds
>>>>>>> 134c46cdf883fd65b9325f518ec8954a111f359e
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
<<<<<<< HEAD
        end
    end
    
    // ========== MESSAGE SCHEDULING ==========
    always @(posedge clk) begin
        if (state == RUN_ROUNDS) begin
            if (round >= 16 && round <= 63) begin
                W_pipe1 <= W[round-16] + sigma_lower_0(W[round-15]);
                W_pipe2 <= W[round-7]  + sigma_lower_1(W[round-2]);
            end
=======
>>>>>>> 134c46cdf883fd65b9325f518ec8954a111f359e
        end
    end
    
    // ========== MESSAGE SCHEDULING PIPELINE ==========
    always @(posedge clk) begin
<<<<<<< HEAD
        if (state == RUN_ROUNDS && round >= 16 && round <= 62) begin
            W[round+1] <= W_pipe1 + W_pipe2;  // Tính cho round tiếp theo
        end
    end
    
    // ========== ROUND COMPUTATION (FIXED) ==========
=======
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
>>>>>>> 134c46cdf883fd65b9325f518ec8954a111f359e
    reg [31:0] T1_stage1, T1_stage2, T2_stage1;
    reg [31:0] sigma0_a, sigma1_e, ch_efg, maj_abc;
    reg [5:0] round_delayed;  // delay 1 cycle để đồng bộ với W
    
    always @(posedge clk) begin
        if (state == RUN_ROUNDS) begin
<<<<<<< HEAD
            // Stage 1: Tính sigma và ch/maj từ giá trị hiện tại
            sigma0_a <= sigma_upper_0(a);
            sigma1_e <= sigma_upper_1(e);
            ch_efg   <= ch(e, f, g);
            maj_abc  <= maj(a, b, c);
            round_delayed <= round;  // lưu round để dùng ở stage sau
        end
    end
    
    always @(posedge clk) begin
        if (state == RUN_ROUNDS) begin
            // Stage 2: Tính T1_partial và T2
            T1_stage1 <= h + sigma1_e + ch_efg;
            T2_stage1 <= sigma0_a + maj_abc;
        end
    end
    
    always @(posedge clk) begin
        if (state == RUN_ROUNDS) begin
            // Stage 3: Hoàn thành T1 và cập nhật thanh ghi
            T1_stage2 <= T1_stage1 + K[round_delayed] + W[round_delayed];
            
=======
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
>>>>>>> 134c46cdf883fd65b9325f518ec8954a111f359e
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
<<<<<<< HEAD
    
=======

>>>>>>> 134c46cdf883fd65b9325f518ec8954a111f359e
endmodule
