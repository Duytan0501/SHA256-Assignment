module sha256_round_computation_v2 (
input              clk,
input              rst_n,
input              done,
input      [511:0] message_block,
output reg [255:0] hash,
output reg         rounds_done
);
// Internal state variables
reg [31:0] a, b, c, d, e, f, g, h;
reg [31:0] a_next, b_next, c_next, d_next, e_next, f_next, g_next, h_next;
reg [5:0] round_index;

// State Definitions
localparam IDLE = 2'd0;
localparam WAIT_SCHED = 2'd1;  // THÊM state này
localparam ROUNDS = 2'd2;
localparam FINAL = 2'd3;

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

wire [31:0] Wt;
wire [31:0] Kt;
wire schedule_done;  // THÊM wire này
wire [31:0] choice, major, sigma_upper_1, sigma_upper_0, T1, T2;

// Message scheduler
sha256_message_scheduler msg_sched (
    .clk(clk),
    .rst_n(rst_n),
    .trigger(done),
    .block(message_block),
    .W_data(Wt),
    .schedule_done(schedule_done)  // THÊM output này
);

// Constants
sha256_constants constants (
    .addr(round_index),
    .get_k_constant(Kt)
);

// Functions
sha256_functions funcs1 (
    .inp_data_1(e),
    .inp_data_2(f),
    .inp_data_3(g),
    .choice_func(choice),
    .sigma_upper_1(sigma_upper_1)
);

sha256_functions funcs2 (
    .inp_data_1(a),
    .inp_data_2(b),
    .inp_data_3(c),
    .majority_func(major),
    .sigma_upper_0(sigma_upper_0)
);

// Round calculations
assign T1 = h + sigma_upper_1 + choice + Kt + Wt;
assign T2 = sigma_upper_0 + major;

// Next State Logic
always @(*) begin
    NS = PS;
    case (PS)
        IDLE: NS = (done) ? WAIT_SCHED : IDLE;
        WAIT_SCHED: NS = (schedule_done) ? ROUNDS : WAIT_SCHED;
        ROUNDS: NS = (round_index == 63) ? FINAL : ROUNDS;
        FINAL: NS = IDLE;
        default: NS = IDLE;
    endcase
end

// Sequential Logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // Reset
        a <= H0;
        b <= H1;
        c <= H2;
        d <= H3;
        e <= H4;
        f <= H5;
        g <= H6;
        h <= H7;
        round_index <= 6'd0;
        PS <= IDLE;
        hash <= 256'd0;
        rounds_done <= 0;
    end else begin
        PS <= NS;  // Update state mỗi clock
        
        case (PS)
            WAIT_SCHED: begin
                // Chờ scheduler, không làm gì
                round_index <= 6'd0;
            end
            
            ROUNDS: begin
                if (round_index < 64) begin
                    // Tính next values
                    a_next = T1 + T2;
                    b_next = a;
                    c_next = b;
                    d_next = c;
                    e_next = d + T1;
                    f_next = e;
                    g_next = f;
                    h_next = g;
                    
                    // Update registers
                    a <= a_next;
                    b <= b_next;
                    c <= c_next;
                    d <= d_next;
                    e <= e_next;
                    f <= f_next;
                    g <= g_next;
                    h <= h_next;
                    
                    round_index <= round_index + 1;
                end
            end
            
            FINAL: begin
                hash <= {H0 + a, H1 + b, H2 + c, H3 + d, 
                         H4 + e, H5 + f, H6 + g, H7 + h};
                rounds_done <= 1;
                // Reset cho block tiếp theo
                a <= H0;
                b <= H1;
                c <= H2;
                d <= H3;
                e <= H4;
                f <= H5;
                g <= H6;
                h <= H7;
                round_index <= 6'd0;
            end
            
            default: ;
        endcase
    end
end

endmodule
