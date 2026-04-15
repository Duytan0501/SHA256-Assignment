module sha256_top(
    input              clk,
    input              rst_n,
    input              input_start,
    input              input_done,
    input      [5:0]   inp_data,
    output     [255:0] hash,
    output             hash_valid  
);
    wire [511:0] padded_msg;
    wire         padding_done;
    sha256_message_padding padding_inst (
        .clk(clk),
        .rst_n(rst_n),
        .input_start(input_start),
        .input_done(input_done),
        .inp_data(inp_data),
        .padded_msg(padded_msg),     // Xuất ra dây nội bộ
        .padding_done(padding_done)  // Xuất ra dây nội bộ
    );
    sha256_round_computation comp_inst (
        .clk(clk),
        .rst_n(rst_n),
        .done(padding_done),         // Nhận tín hiệu từ padding
        .message_block(padded_msg),  // Nhận block 512-bit từ padding
        .hash(hash),                 // Xuất thẳng ra output của top
        .rounds_done(hash_valid)     // Xuất thẳng ra output của top
    );
endmodule