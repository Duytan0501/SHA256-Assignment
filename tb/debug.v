`timescale 1ns / 1ps

module tb_debug;
    reg clk;
    reg rst_n;
    reg done;
    reg [511:0] message_block;
    wire [255:0] hash;
    wire rounds_done;
    
    sha256_round_computation dut (
        .clk(clk),
        .rst_n(rst_n),
        .done(done),
        .message_block(message_block),
        .hash(hash),
        .rounds_done(rounds_done)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        $display("=== START DEBUG ===");
        
        // Khởi tạo
        clk = 0;
        rst_n = 0;
        done = 0;
        message_block = 512'h61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018;
        
        // Reset
        #20;
        rst_n = 1;
        $display("Reset released at %0t", $time);
        
        // Trigger done trong 1 clock cycle
        @(posedge clk);
        done = 1;
        $display("Done = 1 at %0t", $time);
        
        @(posedge clk);
        done = 0;
        $display("Done = 0 at %0t", $time);
        
        // Monitor vô hạn
        forever begin
            @(posedge clk);
            $display("T=%0t | PS=%0d | round=%0d | sched_round=%0d | Wt=%h | rounds_done=%0b",
                     $time, dut.PS, dut.round_index, dut.msg_sched.round, 
                     dut.msg_sched.W_data, rounds_done);
            
            if (rounds_done) begin
                $display("\n=== FINAL HASH ===");
                $display("%064h", hash);
                $finish;
            end
            
            // Timeout sau 5000 cycles
            if ($time > 50000) begin
                $display("\n=== TIMEOUT ===");
                $finish;
            end
        end
    end
    
endmodule
