`timescale 1ns / 1ps

module decoderinput_tb;
    reg clk;
    reg rst_n;
    reg input_start;
    reg input_done;
    reg [5:0] inp_data;

    wire [511:0] padded_msg;
    wire padding_done;

    sha256_message_padding dut (
        .clk(clk),
        .rst_n(rst_n),
        .input_start(input_start),
        .input_done(input_done),
        .inp_data(inp_data),
        .padded_msg(padded_msg),
        .padding_done(padding_done)
    );

    always #5 clk = ~clk;

    task send_char;
        input [5:0] char_code;
        begin
            inp_data = char_code;
            @(posedge clk); 
        end
    endtask

    integer i;

    initial begin
        #5000;
        $display("\nTIMEOUT");
        $finish;
    end

    initial begin
        clk = 0;
        rst_n = 0;
        input_start = 0;
        input_done = 0;
        inp_data = 6'b0;

        #20;
        rst_n = 1;
        #20;

        $display("==================================================");
        $display("TEST CASE 1: 24 KY TU");
        $display("CHUOI INPUT: abcdefghijklmnopqrstuvwx");
        
        @(posedge clk);
        input_start = 1;
        @(posedge clk);
        input_start = 0; 

        for (i = 0; i < 24; i = i + 1) begin
            send_char(i);
        end

        input_done = 1;
        @(posedge clk);
        input_done = 0;

        wait(padding_done == 1);
        
        $display("MSG_LENGTH: %0d bits", dut.msg_length);
        $display("PADDED_MSG (HEX): %h", padded_msg);
        $display("==================================================\n");

        #30; 

        $display("==================================================");
        $display("TEST CASE 2: 55 KY TU");
        $display("CHUOI INPUT: bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb");
        
        @(posedge clk);
        input_start = 1;
        @(posedge clk);
        input_start = 0; 

        for (i = 0; i < 55; i = i + 1) begin
            send_char(6'd1);
        end
        
        wait(padding_done == 1);
        
        $display("MSG_LENGTH: %0d bits", dut.msg_length);
        $display("PADDED_MSG (HEX): %h", padded_msg);
        $display("==================================================\n");

        #30;

        $display("==================================================");
        $display("TEST CASE 3: 65 KY TU");
        $display("CHUOI INPUT: ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc");
        
        @(posedge clk);
        input_start = 1;
        @(posedge clk);
        input_start = 0; 

        for (i = 0; i < 65; i = i + 1) begin
            send_char(6'd2);
        end

        input_done = 1;
        @(posedge clk);
        input_done = 0;

        wait(padding_done == 1);
        
        $display("MSG_LENGTH: %0d bits", dut.msg_length);
        $display("PADDED_MSG (HEX): %h", padded_msg);
        $display("==================================================\n");

        $finish;
    end

endmodule