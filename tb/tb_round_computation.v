`timescale 1ns / 1ps

module tb_round_computation;
    reg clk;
    reg rst_n;
    reg done;
    reg [511:0] message_block;
    wire [255:0] hash;
    wire rounds_done;
    
    // Instance DUT
    sha256_round_computation_v2 dut (
        .clk(clk),
        .rst_n(rst_n),
        .done(done),
        .message_block(message_block),
        .hash(hash),
        .rounds_done(rounds_done)
    );
    
    // Clock 10ns
    always #5 clk = ~clk;
    
    // Test message "abc"
    initial begin
        $display("==========================================");
        $display("DEBUG SHA256 ROUND COMPUTATION");
        $display("Message: 'abc'");
        $display("Expected: ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad");
        $display("==========================================\n");
        
        // Khoi tao
        clk = 0;
        rst_n = 0;
        done = 0;
        message_block = 512'h61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018;
        
        // Reset
        #20;
        rst_n = 1;
        #20;
        
        // Trigger
        @(posedge clk);
        done = 1;
        @(posedge clk);
        done = 0;
        
        $display("Started at time %0t\n", $time);
        
        // Cho rounds_done voi timeout
        #1000;
        
        if (rounds_done) begin
            $display("\n==========================================");
            $display("RESULT:");
            $display("Hash: %064h", hash);
            
            if (hash === 256'hba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad) begin
                $display("\n✅ TEST PASSED!");
            end else begin
                $display("\n❌ TEST FAILED!");
            end
        end else begin
            $display("\n❌ TIMEOUT - rounds_done not set!");
        end
        
        $finish;
    end
    
    // Debug: In ra state va round_index moi clock
    always @(posedge clk) begin
        $display("Time=%0t | PS=%0d | round=%0d | rounds_done=%0b | hash=%064h", 
                 $time, dut.PS, dut.round_index, rounds_done, hash);
        
        // In chi tiet khi dang trong ROUNDS
        if (dut.PS == 2'd1 && dut.round_index < 64) begin
            $display("  a=%h, b=%h, e=%h, f=%h", dut.a, dut.b, dut.e, dut.f);
            $display("  Wt=%h, Kt=%h", dut.msg_sched.W_data, dut.Kt);
            $display("  T1=%h, T2=%h", dut.T1, dut.T2);
        end
        
        // In khi ket thuc
        if (dut.PS == 2'd2) begin
            $display("\n*** FINAL STATE ***");
        end
    end
    
endmodule
