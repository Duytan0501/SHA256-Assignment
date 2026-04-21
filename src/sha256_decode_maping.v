module sha256_decode_mapping (
    input [7:0] inp_data,
    output reg [7:0] ascii_out
);
  always @(*) begin

    case (inp_data)
      // Map to lowercase alphabets
      6'd0:  ascii_out = "a";
      6'd1:  ascii_out = "b";
      6'd2:  ascii_out = "c";
      6'd3:  ascii_out = "d";
      6'd4:  ascii_out = "e";
      6'd5:  ascii_out = "f";
      6'd6:  ascii_out = "g";
      6'd7:  ascii_out = "h";
      6'd8:  ascii_out = "i";
      6'd9:  ascii_out = "j";
      6'd10: ascii_out = "k";
      6'd11: ascii_out = "l";
      6'd12: ascii_out = "m";
      6'd13: ascii_out = "n";
      6'd14: ascii_out = "o";
      6'd15: ascii_out = "p";
      6'd16: ascii_out = "q";
      6'd17: ascii_out = "r";
      6'd18: ascii_out = "s";
      6'd19: ascii_out = "t";
      6'd20: ascii_out = "u";
      6'd21: ascii_out = "v";
      6'd22: ascii_out = "w";
      6'd23: ascii_out = "x";
      6'd24: ascii_out = "y";
      6'd25: ascii_out = "z";

      // Map to numbers
      6'd26: ascii_out = "0";
      6'd27: ascii_out = "1";
      6'd28: ascii_out = "2";
      6'd29: ascii_out = "3";
      6'd30: ascii_out = "4";
      6'd31: ascii_out = "5";
      6'd32: ascii_out = "6";
      6'd33: ascii_out = "7";
      6'd34: ascii_out = "8";
      6'd35: ascii_out = "9";

      // Map to symbols
      6'd36: ascii_out = "!";
      6'd37: ascii_out = "@";
      6'd38: ascii_out = "#";
      6'd39: ascii_out = "$";
      6'd40: ascii_out = "%";
      6'd41: ascii_out = "^";
      6'd42: ascii_out = "&";
      6'd43: ascii_out = "*";
      6'd44: ascii_out = "(";
      6'd45: ascii_out = ")";
      6'd46: ascii_out = "-";
      6'd47: ascii_out = "_";
      6'd48: ascii_out = "=";
      6'd49: ascii_out = "+";
      6'd50: ascii_out = "[";
      6'd51: ascii_out = "]";
      6'd52: ascii_out = "{";
      6'd53: ascii_out = "}";
      6'd54: ascii_out = ";";
      6'd55: ascii_out = ":";

      // Map to additional characters
      6'd56: ascii_out = "'";
      6'd57: ascii_out = "\"";
      6'd58: ascii_out = ",";
      6'd59: ascii_out = ".";
      6'd60: ascii_out = "<";
      6'd61: ascii_out = ">";
      6'd62: ascii_out = "/";
      6'd63: ascii_out = "?";

      default: ascii_out = 8'b0;  // Null character for invalid inputs
    endcase
  end
endmodule
