module tb_sha256();

    // ========== SIGNALS ==========
    reg clk;
    reg rst_n;
    reg start;
    reg [511:0] message_block;
    reg last_block;
    wire [255:0] final_hash;
    wire hash_valid;
    wire ready_for_next_block;
    
    // ========== INSTANTIATE DUT ==========
    sha256_round_scheduler_include dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .message_block(message_block),
        .last_block(last_block),
        .final_hash(final_hash),
        .hash_valid(hash_valid),
        .ready_for_next_block(ready_for_next_block)
    );
    
    // ========== CLOCK ==========
    always #5 clk = ~clk;
    
    // ========== MESSAGE BLOCK THEO DU LIEU BAN DUA ==========
    // Message block 512-bit tu file cua ban:
    // 01110100 01101000 01100001 01100011 (thac)
    // 01101111 01101101 01101111 01100010 (omob)
    // 01101001 01101000 01101111 01101101 (ihom)
    // 01100101 10000000 00000000 00000000 (e...)
    // ... cac byte 0 ...
    // 00000000 00000000 00000000 01101000 (last 3 bytes 0, byte cuoi 0x68 = 'h')
    
    reg [511:0] test_block;
    
    initial begin
        // Xay dung message block tu du lieu ban dua
        // Byte 0:  01110100 = 0x74 = 't'
        // Byte 1:  01101000 = 0x68 = 'h'
        // Byte 2:  01100001 = 0x61 = 'a'
        // Byte 3:  01100011 = 0x63 = 'c'
        // Byte 4:  01101111 = 0x6F = 'o'
        // Byte 5:  01101101 = 0x6D = 'm'
        // Byte 6:  01101111 = 0x6F = 'o'
        // Byte 7:  01100010 = 0x62 = 'b'
        // Byte 8:  01101001 = 0x69 = 'i'
        // Byte 9:  01101000 = 0x68 = 'h'
        // Byte 10: 01101111 = 0x6F = 'o'
        // Byte 11: 01101101 = 0x6D = 'm'
        // Byte 12: 01100101 = 0x65 = 'e'
        // Byte 13: 10000000 = 0x80 (padding)
        // Byte 14-61: 0x00
        // Byte 62: 0x00
        // Byte 63: 0x68 (???) - theo du lieu cuoi cung cua ban
        test_block = {
            128'h746861636F6D6F62_69686F6D65800000,  // 16 bytes (128 bit)
            128'h0000000000000000_0000000000000000,  // 16 bytes
            128'h0000000000000000_0000000000000000,  // 16 bytes  
            128'h0000000000000000_0000000000000068   // 16 bytes (byte cuoi 0x68)
        };
    end
    
    // ========== TEST SEQUENCE ==========
    initial begin
        // Khoi tao
        clk = 0;
        rst_n = 0;
        start = 0;
        message_block = 512'h0;
        last_block = 0;
        
        // Reset
        #20;
        rst_n = 1;
        #10;
        
        $display("==========================================");
        $display("START TEST");
        $display("==========================================");
        $display("Message Block: %h", test_block);
        $display("");
        
        // Load message block
        message_block = test_block;
        last_block = 1;  // Block cuoi cung
        
        // Start processing
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        $display("Started SHA-256 processing at time %0t", $time);
        $display("");
        
        // Wait for hash valid
        wait(hash_valid == 1);
        @(posedge clk);
        
        // Display result
        $display("==========================================");
        $display("RESULT");
        $display("==========================================");
        $display("Final Hash: %h", final_hash);
        $display("Hash Valid: %b", hash_valid);
        $display("==========================================");
        
        #100;
        $finish;
    end
    
    // ========== MONITOR ==========
    initial begin
        $monitor("Time=%0t | state=%d | round=%0d | round_s2=%0d | ready=%b | valid=%b", 
                 $time, dut.state, dut.round, dut.round_s2, ready_for_next_block, hash_valid);
        $monitor();
    end
    
    // ========== WAVE DUMP ==========
    initial begin
        $dumpfile("sha256_tb.vcd");
        $dumpvars(0, tb_sha256);
    end
    
endmodule
