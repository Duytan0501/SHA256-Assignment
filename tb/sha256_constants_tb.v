module sha256_constants_tb;
  reg [5:0] addr;
  wire [31:0] get_k_constant;
  
  // Instantiate DUT
  sha256_constants uut (
    .addr(addr),
    .get_k_constant(get_k_constant)
  );
  
  // Expected constants
  reg [31:0] expected;
  
  integer i;
  integer error_count;
  
  initial begin
    $display("\n========== SHA256 CONSTANTS TEST ==========");
    error_count = 0;
    
    for (i = 0; i < 64; i = i + 1) begin
      addr = i;
      #10;
      
      // Set expected value based on addr
      case (addr)
        6'd0:  expected = 32'h428a2f98;
        6'd1:  expected = 32'h71374491;
        6'd2:  expected = 32'hb5c0fbcf;
        6'd3:  expected = 32'he9b5dba5;
        6'd4:  expected = 32'h3956c25b;
        6'd5:  expected = 32'h59f111f1;
        6'd6:  expected = 32'h923f82a4;
        6'd7:  expected = 32'hab1c5ed5;
        6'd8:  expected = 32'hd807aa98;
        6'd9:  expected = 32'h12835b01;
        6'd10: expected = 32'h243185be;
        6'd11: expected = 32'h550c7dc3;
        6'd12: expected = 32'h72be5d74;
        6'd13: expected = 32'h80deb1fe;
        6'd14: expected = 32'h9bdc06a7;
        6'd15: expected = 32'hc19bf174;
        6'd16: expected = 32'he49b69c1;
        6'd17: expected = 32'hefbe4786;
        6'd18: expected = 32'h0fc19dc6;
        6'd19: expected = 32'h240ca1cc;
        6'd20: expected = 32'h2de92c6f;
        6'd21: expected = 32'h4a7484aa;
        6'd22: expected = 32'h5cb0a9dc;
        6'd23: expected = 32'h76f988da;
        6'd24: expected = 32'h983e5152;
        6'd25: expected = 32'ha831c66d;
        6'd26: expected = 32'hb00327c8;
        6'd27: expected = 32'hbf597fc7;
        6'd28: expected = 32'hc6e00bf3;
        6'd29: expected = 32'hd5a79147;
        6'd30: expected = 32'h06ca6351;
        6'd31: expected = 32'h14292967;
        6'd32: expected = 32'h27b70a85;
        6'd33: expected = 32'h2e1b2138;
        6'd34: expected = 32'h4d2c6dfc;
        6'd35: expected = 32'h53380d13;
        6'd36: expected = 32'h650a7354;
        6'd37: expected = 32'h766a0abb;
        6'd38: expected = 32'h81c2c92e;
        6'd39: expected = 32'h92722c85;
        6'd40: expected = 32'ha2bfe8a1;
        6'd41: expected = 32'ha81a664b;
        6'd42: expected = 32'hc24b8b70;
        6'd43: expected = 32'hc76c51a3;
        6'd44: expected = 32'hd192e819;
        6'd45: expected = 32'hd6990624;
        6'd46: expected = 32'hf40e3585;
        6'd47: expected = 32'h106aa070;
        6'd48: expected = 32'h19a4c116;
        6'd49: expected = 32'h1e376c08;
        6'd50: expected = 32'h2748774c;
        6'd51: expected = 32'h34b0bcb5;
        6'd52: expected = 32'h391c0cb3;
        6'd53: expected = 32'h4ed8aa4a;
        6'd54: expected = 32'h5b9cca4f;
        6'd55: expected = 32'h682e6ff3;
        6'd56: expected = 32'h748f82ee;
        6'd57: expected = 32'h78a5636f;
        6'd58: expected = 32'h84c87814;
        6'd59: expected = 32'h8cc70208;
        6'd60: expected = 32'h90befffa;
        6'd61: expected = 32'ha4506ceb;
        6'd62: expected = 32'hbef9a3f7;
        6'd63: expected = 32'hc67178f2;
        default: expected = 32'h0;
      endcase
      
      if (get_k_constant === expected) begin
        $display("✅ addr=%2d | K[%2d] = %h", i, i, get_k_constant);
      end else begin
        $display("❌ addr=%2d | Expected: %h | Got: %h", i, expected, get_k_constant);
        error_count = error_count + 1;
      end
    end
    
    // Test default case (addr=64)
    addr = 6'd63;
    #10;
    if (get_k_constant == 32'h0) begin
      $display("✅ addr=64 (default) = %h (OK)", get_k_constant);
    end else begin
      $display("❌ addr=64 default: Expected 0 | Got: %h", get_k_constant);
      error_count = error_count + 1;
    end
    
    $display("\n========== RESULT ==========");
    if (error_count == 0) begin
      $display("✅ ALL TESTS PASSED!");
    end else begin
      $display("❌ FAILED: %0d errors", error_count);
    end
    
    #50 $finish;
  end
  
  // Dump waves
  initial begin
    $dumpfile("constants.vcd");
    $dumpvars(0, sha256_constants_tb);
  end
endmodule
