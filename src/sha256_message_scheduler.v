module sha256_message_scheduler (
    input              clk,
    rst_n,
    input              trigger,   // trigger signal to indicate padding trigger
    input      [511:0] block,  // 512-bit input message block
    output reg [31:0] W_data       // Output a single 32-bit word at a time
);
  reg [31:0] W_temp[0:63];  //64 word 32bit
  reg [6:0] round;  // co ve la giong addr
  integer t;


  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (t = 0; t < 64, t = t + 1) W_temp[t] <= 32'd0;
      W_data <= 32'd0;
      round <= t;
    end
    else begin
      if (trigger) begin
        // lay initialized block tu input data (16 block dau)
        if (round <= 15) begin
          W_temp[round] <= block[511 - (round * 32) -: 32];
          W_data <= block[511 - (round * 32) -: 32]; // nonblockign, concurrent nen phai lay data tu tinh chu kgonf lay W_temp[round] vi neu lay => race condition
        end
        else begin
          W_temp[round] <= W_temp[round-16] +
                                 ({W_temp[round-15][6:0], W_temp[round-15][31:7]} ^
                                  {W_temp[round-15][17:0], W_temp[round-15][31:18]} ^
                                 (W_temp[round-15] >> 3)) +
                                 W_temp[round-7] +
                                 ({W_temp[round-2][16:0], W_temp[round-2][31:17]} ^
                                  {W_temp[round-2][18:0], W_temp[round-2][31:19]} ^
                                 (W_temp[round-2] >> 10));
											 
           W_data <= W_temp[round-16] + 
                         ({W_temp[round-15][6:0], W_temp[round-15][31:7]} ^
                          {W_temp[round-15][17:0], W_temp[round-15][31:18]} ^
                         (W_temp[round-15] >> 3)) +
                         W_temp[round-7] +
                         ({W_temp[round-2][16:0], W_temp[round-2][31:17]} ^
                          {W_temp[round-2][18:0], W_temp[round-2][31:19]} ^
                         (W_temp[round-2] >> 10));  // Directly compute W in the same cycle


        end
        
      end

      
    end




  end




endmodule
