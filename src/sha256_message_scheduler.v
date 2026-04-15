module sha256_message_scheduler (
    input              clk,
    input              rst_n,
    input              trigger,       // trigger signal to indicate padding trigger
    input      [511:0] block,         // 512-bit input message block
    output reg [ 31:0] W_data,        // Output a single 32-bit word at a time
    output reg         schedule_done
);

  reg [31:0] W_temp                         [0:63];  // 64 word 32bit
  reg [ 6:0] round;  // counter from 0 to 63
  reg        busy;

  // Hàm tính σ0 (sigma_lower_0)
  function [31:0] sigma_lower_0;
    input [31:0] x;
    begin
      sigma_lower_0 = {x[6:0], x[31:7]} ^ {x[17:0], x[31:18]} ^ (x >> 3);
    end
  endfunction

  // Hàm tính σ1 (sigma_lower_1)
  function [31:0] sigma_lower_1;
    input [31:0] x;
    begin
      sigma_lower_1 = {x[16:0], x[31:17]} ^ {x[18:0], x[31:19]} ^ (x >> 10);
    end
  endfunction

  integer i;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (i = 0; i < 64; i = i + 1) W_temp[i] <= 32'd0;
      W_data <= 32'd0;
      round <= 7'd0;
      busy <= 1'b0;
      schedule_done <= 1'b0;
    end else begin
      if (trigger && !busy) begin
        busy <= 1'b1;
        round <= 7'd0;
        schedule_done <= 1'b0;
      end

      if (busy) begin
        if (round <= 15) begin
          // 16 từ đầu: lấy trực tiếp từ block
          W_temp[round] <= block[511-(round*32)-:32];
          W_data <= block[511-(round*32)-:32];
          round <= round + 1;
        end else if (round <= 63) begin
          // Tính W_temp[round] từ các từ trước
          W_temp[round] <= W_temp[round-16] + sigma_lower_0(
              W_temp[round-15]
          ) + W_temp[round-7] + sigma_lower_1(
              W_temp[round-2]
          );

          W_data <= W_temp[round-16] + sigma_lower_0(
              W_temp[round-15]
          ) + W_temp[round-7] + sigma_lower_1(
              W_temp[round-2]
          );
          // xem lai
          round <= round + 1;
        end else begin
          // Hoàn thành
          busy <= 1'b0;
          schedule_done <= 1'b1;
        end
      end
    end
  end
endmodule
