module sha256_round_computation;

  // Inputs
  reg clk;
  reg rst_n;
  reg done;
  reg [511:0] message_block;

  // Outputs
  wire [255:0] hash;
  wire rounds_done;

  // Test vectors
  localparam [511:0] MSG_ABC = 512'h61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018;
  localparam [255:0] EXPECTED_ABC = 256'hba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad;
  
  localparam [511:0] MSG_EMPTY = 512'h80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  localparam [255:0] EXPECTED_EMPTY = 256'he3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855;

  // Instantiate DUT
  sha256_round_computation dut (
      .clk(clk),
      .rst_n(rst_n),
      .done(done),
      .message_block(message_block),
      .hash(hash),
      .rounds_done(rounds_done)
  );

  // Clock: 100MHz
  always #5 clk = ~clk;

  // Test sequence
  initial begin
    // Init
    clk = 0;
    rst_n = 0;
    done = 0;
    message_block = 512'd0;
    
    // Reset
    #20;
    rst_n = 1;
    #10;
    
    // Test 1: "abc"
    $display("\n========== TEST 1: Hashing 'abc' ==========");
    message_block = MSG_ABC;
    done = 1;
    #10;
    done = 0;
    
    wait(rounds_done == 1);
    #10;
    
    if (hash == EXPECTED_ABC) begin
      $display("✅ PASS: abc");
      $display("   Hash: %h", hash);
    end else begin
      $display("❌ FAIL: abc");
      $display("   Expected: %h", EXPECTED_ABC);
      $display("   Got:      %h", hash);
    end
    
    // Test 2: Empty string
    #50;
    $display("\n========== TEST 2: Hashing empty string ==========");
    message_block = MSG_EMPTY;
    done = 1;
    #10;
    done = 0;
    
    wait(rounds_done == 1);
    #10;
    
    if (hash == EXPECTED_EMPTY) begin
      $display("✅ PASS: empty string");
      $display("   Hash: %h", hash);
    end else begin
      $display("❌ FAIL: empty string");
      $display("   Expected: %h", EXPECTED_EMPTY);
      $display("   Got:      %h", hash);
    end
    
    $display("\n========== SIMULATION COMPLETE ==========");
    #100;
    $finish;
  end

  // Monitor
  initial begin
    $monitor("Time=%0t | State=%d | round=%0d | rounds_done=%b | hash=%h", 
              $time, dut.PS, dut.round_index, rounds_done, hash);
  end

  // Dump waves
  initial begin
    $dumpfile("sha256.vcd");
    $dumpvars(0, sha256_round_computation);
  end

endmodule
