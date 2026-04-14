module sha256_functions_tb;
  reg [31:0] a, b, c, d, e, f, g, h;
  reg [31:0] w_t_15, w_t_2;
  wire [31:0] choice, majority, sigma0, sigma1, sig_lower_0, sig_lower_1;
  
  // Instantiate DUT - dùng cho round computation
  sha256_functions uut_round (
    .inp_data_1(a),     // a cho sigma0
    .inp_data_2(e),     // e cho sigma1  
    .inp_data_3(f),     // f cho choice (cần check)
    .choice_func(choice),
    .majority_func(majority),
    .sigma_upper_0(sigma0),
    .sigma_upper_1(sigma1),
    .sigma_lower_0(sig_lower_0),
    .sigma_lower_1(sig_lower_1)
  );
  
  // Test vectors (từ NIST test vectors)
  initial begin
    $display("\n========== SHA256 FUNCTIONS TEST ==========");
    
    // Test 1: Choice function
    e = 32'hA5A5A5A5;
    f = 32'h5A5A5A5A;
    g = 32'hFFFFFFFF;
    #10;
    $display("Choice(e=%h, f=%h, g=%h) = %h", e, f, g, choice);
    
    // Test 2: Majority function
    a = 32'hA5A5A5A5;
    b = 32'h5A5A5A5A;
    c = 32'hFFFFFFFF;
    #10;
    $display("Majority(a=%h, b=%h, c=%h) = %h", a, b, c, majority);
    
    // Test 3: Sigma upper 0 (Σ0)
    a = 32'h5A5A5A5A;
    #10;
    $display("Sigma0(a=%h) = %h", a, sigma0);
    
    // Test 4: Sigma upper 1 (Σ1)
    e = 32'h5A5A5A5A;
    #10;
    $display("Sigma1(e=%h) = %h", e, sigma1);
    
    // Test 5: Sigma lower 0 (σ0)
    w_t_15 = 32'h00000000;
    #10;
    $display("Sigma0_lower(w=%h) = %h", w_t_15, sig_lower_0);
    
    // Test 6: Sigma lower 1 (σ1)
    w_t_2 = 32'h00000000;
    #10;
    $display("Sigma1_lower(w=%h) = %h", w_t_2, sig_lower_1);
    
    #50 $finish;
  end
  
  initial begin
    $dumpfile("functions.vcd");
    $dumpvars(0, sha256_functions_tb);
  end
endmodule
