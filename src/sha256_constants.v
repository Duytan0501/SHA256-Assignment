module sha256_constants (
    input [5:0] addr,
    output reg [31:0] get_k_constant
);

  // SHA-256 Round constants (first 32 bits of the fractional parts of the cube roots of the first 64 primes)
  localparam [31:0] K00 = 32'h428a2f98, K01 = 32'h71374491, K02 = 32'hb5c0fbcf, K03 = 32'he9b5dba5,
                  K04 = 32'h3956c25b, K05 = 32'h59f111f1, K06 = 32'h923f82a4, K07 = 32'hab1c5ed5,
                  K08 = 32'hd807aa98, K09 = 32'h12835b01, K10 = 32'h243185be, K11 = 32'h550c7dc3,
                  K12 = 32'h72be5d74, K13 = 32'h80deb1fe, K14 = 32'h9bdc06a7, K15 = 32'hc19bf174,
                  K16 = 32'he49b69c1, K17 = 32'hefbe4786, K18 = 32'h0fc19dc6, K19 = 32'h240ca1cc,
                  K20 = 32'h2de92c6f, K21 = 32'h4a7484aa, K22 = 32'h5cb0a9dc, K23 = 32'h76f988da,
                  K24 = 32'h983e5152, K25 = 32'ha831c66d, K26 = 32'hb00327c8, K27 = 32'hbf597fc7,
                  K28 = 32'hc6e00bf3, K29 = 32'hd5a79147, K30 = 32'h06ca6351, K31 = 32'h14292967,
                  K32 = 32'h27b70a85, K33 = 32'h2e1b2138, K34 = 32'h4d2c6dfc, K35 = 32'h53380d13,
                  K36 = 32'h650a7354, K37 = 32'h766a0abb, K38 = 32'h81c2c92e, K39 = 32'h92722c85,
                  K40 = 32'ha2bfe8a1, K41 = 32'ha81a664b, K42 = 32'hc24b8b70, K43 = 32'hc76c51a3,
                  K44 = 32'hd192e819, K45 = 32'hd6990624, K46 = 32'hf40e3585, K47 = 32'h106aa070,
                  K48 = 32'h19a4c116, K49 = 32'h1e376c08, K50 = 32'h2748774c, K51 = 32'h34b0bcb5,
                  K52 = 32'h391c0cb3, K53 = 32'h4ed8aa4a, K54 = 32'h5b9cca4f, K55 = 32'h682e6ff3,
                  K56 = 32'h748f82ee, K57 = 32'h78a5636f, K58 = 32'h84c87814, K59 = 32'h8cc70208,
                  K60 = 32'h90befffa, K61 = 32'ha4506ceb, K62 = 32'hbef9a3f7, K63 = 32'hc67178f2;

  always @(*) begin
    case (addr)
      6'd0: get_k_constant = K00;
      6'd1: get_k_constant = K01;
      6'd2: get_k_constant = K02;
      6'd3: get_k_constant = K03;
      6'd4: get_k_constant = K04;
      6'd5: get_k_constant = K05;
      6'd6: get_k_constant = K06;
      6'd7: get_k_constant = K07;
      6'd8: get_k_constant = K08;
      6'd9: get_k_constant = K09;
      6'd10: get_k_constant = K10;
      6'd11: get_k_constant = K11;
      6'd12: get_k_constant = K12;
      6'd13: get_k_constant = K13;
      6'd14: get_k_constant = K14;
      6'd15: get_k_constant = K15;
      6'd16: get_k_constant = K16;
      6'd17: get_k_constant = K17;
      6'd18: get_k_constant = K18;
      6'd19: get_k_constant = K19;
      6'd20: get_k_constant = K20;
      6'd21: get_k_constant = K21;
      6'd22: get_k_constant = K22;
      6'd23: get_k_constant = K23;
      6'd24: get_k_constant = K24;
      6'd25: get_k_constant = K25;
      6'd26: get_k_constant = K26;
      6'd27: get_k_constant = K27;
      6'd28: get_k_constant = K28;
      6'd29: get_k_constant = K29;
      6'd30: get_k_constant = K30;
      6'd31: get_k_constant = K31;
      6'd32: get_k_constant = K32;
      6'd33: get_k_constant = K33;
      6'd34: get_k_constant = K34;
      6'd35: get_k_constant = K35;
      6'd36: get_k_constant = K36;
      6'd37: get_k_constant = K37;
      6'd38: get_k_constant = K38;
      6'd39: get_k_constant = K39;
      6'd40: get_k_constant = K40;
      6'd41: get_k_constant = K41;
      6'd42: get_k_constant = K42;
      6'd43: get_k_constant = K43;
      6'd44: get_k_constant = K44;
      6'd45: get_k_constant = K45;
      6'd46: get_k_constant = K46;
      6'd47: get_k_constant = K47;
      6'd48: get_k_constant = K48;
      6'd49: get_k_constant = K49;
      6'd50: get_k_constant = K50;
      6'd51: get_k_constant = K51;
      6'd52: get_k_constant = K52;
      6'd53: get_k_constant = K53;
      6'd54: get_k_constant = K54;
      6'd55: get_k_constant = K55;
      6'd56: get_k_constant = K56;
      6'd57: get_k_constant = K57;
      6'd58: get_k_constant = K58;
      6'd59: get_k_constant = K59;
      6'd60: get_k_constant = K60;
      6'd61: get_k_constant = K61;
      6'd62: get_k_constant = K62;
      6'd63: get_k_constant = K63;
      default: get_k_constant = 32'h0;
    endcase
  end
endmodule
