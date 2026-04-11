module sha256_message_padding (
    input              clk,
    input              rst_n,
    input              input_start,      // Start signal to begin processing
    input              input_complete,   // Signal indicating the input sequence is complete
    input      [  5:0] inp_data,         // 6-bit input from switches
    output reg [511:0] padded_msg,       // Output padded message (512-bit)
    output reg         padding_complete  // Output done signal when processing is complete
);

  localparam IDLE = 2'b00;
  localparam PROCESSING = 2'b01;
  localparam COMPLETE = 2'b10;
  reg [1:0] CURRENT_STATE, NEXT_STATE;


  reg [5:0] write_pointer;         // Write pointer for memory (supports up to 64 characters)(we need only 55)
  reg [7:0] memory[0:63];  // Internal memory array to store ASCII characters (upto 55)
  wire [7:0] decoded_ascii;  // Wire for decoder result

  integer msg_length;  // To track the original message length in bits
  integer i;

  sha256_decode_mapping map (
      .inp_data (inp_data),
      .ascii_out(decoded_ascii)
  );


  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      CURRENT_STATE <= IDLE;

      for (i = 0; i <= 63; i = i + 1) begin
        memory[i] <= 8'b0;  // Clear all memory locations
      end


      padded_msg       <= 512'b0;  // Clear the padded message
      padding_complete <= 0;
      write_pointer    <= 0;  // Reset write pointer
      msg_length       <= 0;  // Reset message length

    end else begin
      CURRENT_STATE <= NEXT_STATE;

      if (!input_complete && CURRENT_STATE == PROCESSING) begin
        memory[write_pointer] <= decoded_ascii;
        write_pointer <= write_pointer + 1;  // tang dia chi 
        msg_length <= msg_length + 8;  // msg padded + 8bit chuyen q

      end else if (CURRENT_STATE == COMPLETE) begin
        // padding logic
        for (i = 0; i < write_pointer && i <= 63; i = i + 1) padded_msg[511-(i*8)-:8] <= memory[i];

        // add 1 bit padding cuoi message
        padded_msg[511-(write_pointer*8)] <= 1'b1;


        // padding bit 0 voi 448 bit dau  
        for (i = 0; i < 448; i = i + 1) if (i >= write_pointer * 8 + 1) padded_msg[511-i] <= 1'b0;

        // add 64 bit cuoi 
        padded_msg[63:0] <= msg_length;

        // trigger done signal
        padding_complete <= 1;
      end



    end

  end


endmodule
