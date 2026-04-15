module sha256_message_scheduler_tb;

  reg clk;
  reg rst_n;
  reg trigger;
  reg [511:0] block;
  wire [31:0] W_data;
  wire schedule_done;

  // Instantiate DUT (Device Under Test)
  sha256_message_scheduler uut (
      .clk(clk),
      .rst_n(rst_n),
      .trigger(trigger),
      .block(block),
      .W_data(W_data),
      .schedule_done(schedule_done)
  );

  // Clock 10ns period
  always #5 clk = ~clk;

  // Biến dùng cho vòng lặp
  integer i;

  // Test sequence
  initial begin
    // Khởi tạo
    clk = 0;
    rst_n = 0;
    trigger = 0;
    block = 512'd0;

    // Reset
    #10 rst_n = 1;

    // Test với message "abc" (đã padding)
    // Block 512-bit cho "abc" theo đúng thứ tự big-endian
    // W[0] = 0x61626380 (chứa 'a','b','c' và bit '1')
    // W[15] = 24 (độ dài 24 bit)

    // block = {
    //     32'h61626380,  // W[0]
    //     32'h00000000,  // W[1]
    //     32'h00000000,  // W[2]
    //     32'h00000000,  // W[3]
    //     32'h00000000,  // W[4]
    //     32'h00000000,  // W[5]
    //     32'h00000000,  // W[6]
    //     32'h00000000,  // W[7]
    //     32'h00000000,  // W[8]
    //     32'h00000000,  // W[9]
    //     32'h00000000,  // W[10]
    //     32'h00000000,  // W[11]
    //     32'h00000000,  // W[12]
    //     32'h00000000,  // W[13]
    //     32'h00000000,  // W[14]
    //     32'h00000018   // W[15] = 24 bit (độ dài)
    // };
    //

    block = 512'h6C656475636E68616E80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000048;

    // Kích hoạt trigger
    #10 trigger = 1;
    #10 trigger = 0;

    // Chờ xử lý xong (64 cycles)
    wait (schedule_done == 1);

    // In ra tất cả W_temp để kiểm tra
    #10;
    $display("\n=== Message Schedule Results ===");
    for (i = 0; i < 64; i = i + 1) begin
      $display("W[%0d] = %h", i, uut.W_temp[i]);
    end

    #50 $finish;
  end

  // Monitor theo dõi tiến trình
  initial begin
    $monitor("Time=%0t | round=%0d | W_data=%h | done=%b", $time, uut.round, W_data, schedule_done);
  end

endmodule
