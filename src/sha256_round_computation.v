module sha256_round_computation (
    input              clk,
    input              rst_n,
    input              done,           // Done signal to indicate padding done
    input      [511:0] message_block,  // 512-bit input message block
    output reg [255:0] hash,           // SHA256 hash output (256 bits)
    output reg         rounds_done     // To indicate rounds done
);
  // Internal state variables
  reg [31:0] a, b, c, d, e, f, g, h;  // State variables
  reg [5:0] round_index;  // Round index (0 to 63)

  // State Definitions
  localparam IDLE = 2'd0;
  localparam ROUNDS = 2'd1;
  localparam FINAL = 2'd2;

  reg [1:0] PS, NS;

  // Initial hash values
  localparam H0 = 32'h6a09e667;
  localparam H1 = 32'hbb67ae85;
  localparam H2 = 32'h3c6ef372;
  localparam H3 = 32'ha54ff53a;
  localparam H4 = 32'h510e527f;
  localparam H5 = 32'h9b05688c;
  localparam H6 = 32'h1f83d9ab;
  localparam H7 = 32'h5be0cd19;

  wire [31:0] Wt;  // Current message schedule word
  wire [31:0] Kt;  // Round constant for this round
  wire [31:0] choice, major, sigma_upper_1, sigma_upper_0, T1, T2;  // Intermediate values

  // Generate message schedule words using sha_256_message_scheduler
  sha256_message_scheduler msg_sched (
      .clk(clk),
      .rst_n(rst_n),
      .trigger(done),
      .block(message_block),
      .W_data(Wt),
      .schedule_done()
  );

  // Instantiate constant and function modules
  sha256_constants constants (
      .addr(round_index),
      .get_k_constant(Kt)
  );

  sha256_functions funcs1 (
      .inp_data_1(e),
      .inp_data_2(f),
      .inp_data_3(g),
      .choice_func(choice),
      .majority_func(),
      .sigma_upper_0(),
      .sigma_upper_1(sigma_upper_1),
      .sigma_lower_0(),
      .sigma_lower_1()
  );

  sha256_functions funcs2 (
      .inp_data_1(a),
      .inp_data_2(b),
      .inp_data_3(c),
      .choice_func(),
      .majority_func(major),
      .sigma_upper_0(sigma_upper_0),
      .sigma_upper_1(),
      .sigma_lower_0(),
      .sigma_lower_1()
  );


  // Perform SHA-256 round calculations
  assign T1 = h + sigma_upper_1 + choice + Kt + Wt;
  assign T2 = sigma_upper_0 + major;


  // Sequential Logic: State Transition and Register Updates
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // Reset everything
      a <= H0;
      b <= H1;
      c <= H2;
      d <= H3;
      e <= H4;
      f <= H5;
      g <= H6;
      h <= H7;
      round_index <= 6'd0;
      PS <= IDLE;  // Initial state
      hash <= 256'd0;
      rounds_done <= 0;
    end else begin
        PS <= NS;  // Update state
        case (PS)
          IDLE: begin
                rounds_done<=0;
                  a <= H0;
                  b <= H1;
                  c <= H2;
                  d <= H3;
                  e <= H4;
                  f <= H5;
                  g <= H6;
                  h <= H7;
          end
           ROUNDS: begin
              if (round_index < 64) begin
                a <= T1 + T2;
                b <= a;
                c <= b;
                d <= c;
                e <= d + T1;
                f <= e;
                g <= f;
                h <= g;
                round_index <= round_index + 1;
              end
            end
            FINAL: 
              begin
                hash <= {H0 + a, H1 + b, H2 + c, H3 + d, H4 + e, H5 + f, H6 + g, H7 + h};
                rounds_done <= 1;
                // Reset round_index
                round_index <= 6'd0;
              end
            default: ;
          endcase
        end
      end

  // Combinational Logic: Next State Logic
  always @(*) begin
    NS = PS;  // Default assignment to prevent latches
    case (PS) 
        IDLE: if(done) NS = ROUNDS;
        ROUNDS: if (round_index == 63) NS = FINAL; // nhay toi final state
        FINAL: NS = IDLE; 
      default: NS = IDLE;
    endcase
  end

endmodule
