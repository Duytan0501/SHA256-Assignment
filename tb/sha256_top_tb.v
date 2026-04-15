`timescale 1ns/1ps

module sha256_top_tb;

    // Inputs
    reg clk;
    reg rst_n;
    reg input_start;
    reg input_done;
    reg [5:0] inp_data;

    // Outputs
    wire [255:0] hash;
    wire hash_valid;

    // Expected Hashes (Giá trị kỳ vọng để so sánh)
    localparam [255:0] EXP_TOI_YEU_UIT    = 256'h920c567af0b7856f601b3b9b5e31fd8dfbf4c8658514d672818b5e10dc7ea28b;
    localparam [255:0] EXP_TANPRODZ       = 256'h1c241145f61fecc7e5fb3d2811558e68b589548a671f5ad6d8b19b497539648b;
    localparam [255:0] EXP_THACOMOBIHOME  = 256'haf7b22556046c054aeaf26c243188cbe9723544cf03ccc7a79916cb9c56b01d3;

    // Instantiate DUT
    sha256_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .input_start(input_start),
        .input_done(input_done),
        .inp_data(inp_data),
        .hash(hash),
        .hash_valid(hash_valid)
    );

    // Clock Generation (100MHz)
    always #5 clk = ~clk;

    // Task nạp dữ liệu theo phong cách gọn gàng
    // Dựa trên mapping: a=0, b=1, ..., z=25, _=46, ...
    task send_char(input [5:0] data);
        begin
            inp_data = data;
            #10;
        end
    endtask

    initial begin
        // Khởi tạo các tín hiệu
        clk = 0;
        rst_n = 1;
        input_start = 0;
        input_done = 0;
        inp_data = 6'd0;

        // Reset hệ thống
        #20 rst_n = 0;
        #10 rst_n = 1;
        #10;

        // ==========================================================
        // TEST 1: "toi_yeu_uit"
        // ==========================================================
        $display("\n========== TEST 1: Hashing 'toi_yeu_uit' ==========");
        input_start = 1; #10; input_start = 0;
        
        // Nạp từng ký tự (dựa theo sha256_decode_mapping)
        send_char(6'd19); // t
        send_char(6'd14); // o
        send_char(6'd8);  // i
        send_char(6'd47); // _
        send_char(6'd24); // y
        send_char(6'd4);  // e
        send_char(6'd20); // u
        send_char(6'd47); // _
        send_char(6'd20); // u
        send_char(6'd8);  // i
        send_char(6'd19); // t
        
        input_done = 1; #10; input_done = 0;

        wait(hash_valid == 1);
        if (hash == EXP_TOI_YEU_UIT) $display("✅ [PASS] toi_yeu_uit| Got: %h", hash);
        else $display("❌ [FAIL] toi_yeu_uit | Got: %h", hash);


        // ==========================================================
        // TEST 2: "tanprodz"
        // ==========================================================
        #50;
        $display("\n========== TEST 2: Hashing 'tanprodz' ==========");
        input_start = 1; #10; input_start = 0;
        
        send_char(6'd19); // t
        send_char(6'd0);  // a
        send_char(6'd13); // n
        send_char(6'd15); // p
        send_char(6'd17); // r
        send_char(6'd14); // o
        send_char(6'd3);  // d
        send_char(6'd25); // z
        
        input_done = 1; #10; input_done = 0;

        wait(hash_valid == 1);
        if (hash == EXP_TANPRODZ) $display("✅ [PASS] tanprodz| Got: %h", hash);
        else $display("❌ [FAIL] tanprodz | Got: %h", hash);


        // ==========================================================
        // TEST 3: "thacomobihome"
        // ==========================================================
        #50;
        $display("\n========== TEST 3: Hashing 'thacomobihome' ==========");
        input_start = 1; #10; input_start = 0;
        
        send_char(6'd19); // t
        send_char(6'd7);  // h
        send_char(6'd0);  // a
        send_char(6'd2);  // c
        send_char(6'd14); // o
        send_char(6'd12); // m
        send_char(6'd14); // o
        send_char(6'd1);  // b
        send_char(6'd8);  // i
        send_char(6'd7);  // h
        send_char(6'd14); // o
        send_char(6'd12); // m
        send_char(6'd4);  // e
        
        input_done = 1; #10; input_done = 0;

        wait(hash_valid == 1);
        if (hash == EXP_THACOMOBIHOME) $display("✅ [PASS] thacomobihome| Got: %h", hash);
        else $display("❌ [FAIL] thacomobihome | Got: %h", hash);

        $display("\n========== ALL TESTS COMPLETED ==========");
        #100;
        $stop;
    end

endmodule