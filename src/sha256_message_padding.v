module sha256_message_padding (
    input              clk,
    input              rst_n,        //reset active low
    input              input_start,  //bat dau nhap
    input              input_done,   //nhap xong
    input      [  5:0] inp_data,     //input
    output reg [511:0] padded_msg,   //msg da pad xong      
    output reg         padding_done  //co bao da pad xong
);
  localparam IDLE = 2'b00;  //trang thai cho
  localparam PROCESSING = 2'b01;  //trang thai xu ly
  localparam DONE = 2'b10;  //trang thai xong
  reg [1:0] curr, next;  //luu trang thai
  reg  [ 5:0] write_ptr;  //con tro ghi
  wire [ 7:0] decoded_ascii;  //ascii sau khi giai ma
  reg  [63:0] msg_length;  //do dai msg goc
  sha256_decode_mapping map (  //giai ma input
      .inp_data (inp_data),
      .ascii_out(decoded_ascii)
  );
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin  //reset
      curr <= IDLE;
      padded_msg <= 512'b0;
      padding_done <= 0;
      write_ptr <= 0;
      msg_length <= 0;
    end else begin
      curr <= next;
      case (curr)
        IDLE: begin //Trang thai cho
          padding_done <= 0;
          if (input_start) begin
            padded_msg <= 512'b0;
            write_ptr <= 6'd0;
            msg_length <= 64'd0;
          end
        end
        PROCESSING:  //Trang thai xu ly
        if (!input_done && write_ptr < 6'd55) begin  //Neu chua nap du input
          padded_msg[511-(write_ptr*8)-:8] <= decoded_ascii;  //Ghi ascii vao padded_msg
          write_ptr <= write_ptr + 1;  //Tang con tro ghi
          msg_length <= msg_length + 8;  //Tang do dai len 8bit=1byte
        end
        DONE: begin  //Done,
          padded_msg[511-(write_ptr*8)] <= 1'b1;  //Them bit 1 vao cuoi msg
          padded_msg[63:0] <= msg_length;  //Them do dai vao cuoi padded_msg
          padding_done <= 1;
        end
      endcase
    end
  end
  always @(*) begin
    case (curr)
      IDLE: next = input_start ? PROCESSING : IDLE;
      PROCESSING: next = (!input_done && write_ptr < 6'd55) ? PROCESSING : DONE;
      DONE: next = IDLE;
      default: next = IDLE;
    endcase
  end
endmodule
