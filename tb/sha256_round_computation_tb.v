module sha256_round_computation_tb; 

  // Inputs
  reg clk;
  reg rst_n;
  reg done;
  reg [511:0] message_block;

  // Outputs
  wire [255:0] hash;
  wire rounds_done;
  localparam [511:0] MSG_EMPTY = 512'h80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  localparam [255:0] EXPECTED_EMPTY = 256'he3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855;
  localparam [511:0] MSG_ABC = 512'h61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018;
  
  // Expected hash of "abc": 
  // ba7816bf 8f01cfea 414140de 5dae2223 b00361a3 96177a9c b410ff61 f20015ad
  localparam [255:0] EXPECTED_ABC = 256'hba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad;


  // Instantiate DUT
  sha256_round_computation dut (
      .clk(clk),
      .rst_n(rst_n),
      .done(done),
      .message_block(message_block),
      .hash(hash),
      .rounds_done(rounds_done)
  );

  // Clock generation: 100MHz
  always #5 clk = ~clk;  // 10ns period

  // Test data: Message "abc" đã được padding
  // "abc" = 0x616263
  // Sau padding: 1 bit '1', sau đó 423 bits 0, sau đó length = 24

  // Test procedure
  initial begin
    // Initialize
    clk = 0;
    rst_n = 0;
    done = 0;
    message_block = 512'd0;
    
    // Reset sequence
    #20;
    rst_n = 1;
    #10;
    
    // Test 1: Hash "abc"
    $display("\n=== Test 1: Hashing 'abc' ===");
    message_block = MSG_ABC;
    done = 1;
    #10;  // 1 cycle pulse
    done = 0;
    
    // Wait for completion (64 rounds = 64 cycles)
    wait(rounds_done == 1);
    #10;
    
    // Check result
    if (hash == EXPECTED_ABC) begin
      $display("✅ PASS: abc hash correct");
      $display("   Hash = %h", hash);
    end else begin
      $display("❌ FAIL: abc hash incorrect");
      $display("   Expected: %h", EXPECTED_ABC);
      $display("   Got:      %h", hash);
    end
    
    // Test 2: Message empty string (chỉ padding)
    // Empty string: length = 0

    
    #100;
    $display("\n=== Test 2: Hashing empty string ===");
    message_block = MSG_EMPTY;
    done = 1;
    #10;
    done = 0;
    
    wait(rounds_done == 1);
    #10;
    
    if (hash == EXPECTED_EMPTY) begin
      $display("✅ PASS: empty hash correct");
      $display("   Hash = %h", hash);
    end else begin
      $display("❌ FAIL: empty hash incorrect");
      $display("   Expected: %h", EXPECTED_EMPTY);
      $display("   Got:      %h", hash);
    end
    
    // Test 3: Message "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
    // (multi-block message - nếu message scheduler hỗ trợ)
    
    $display("\n=== All tests completed ===");
    #100;
    $finish;
  end

  // Monitor signals
  initial begin
    $monitor("Time=%0t | PS=%d | round=%0d | rounds_done=%b | hash=%h", 
              $time, dut.PS, dut.round_index, rounds_done, hash);
  end

  // Dump waves for debugging (nếu dùng VCD)
  initial begin
    $dumpfile("sha256_tb.vcd");
    $dumpvars(0, sha256_round_computation_tb);
  end

endmodule
