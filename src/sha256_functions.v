module sha256_functions ( 
  input [31:0] inp_data_1, inp_data_2, inp_data_3,  // a hoặc w[t-15]
  output [31:0] choice_func, 
  output [31:0] majority_func, 
  output [31:0] sigma_upper_0, sigma_upper_1, sigma_lower_0, sigma_lower_1   // dùng a (inp_data_1)
);
  
  // Choice: (e & f) ^ (~e & g)
  assign choice_func = (inp_data_1 & inp_data_2) ^ (~inp_data_1 & inp_data_3);
  // Note: cần kiểm tra lại mapping! Thường choice(e,f,g): e=inp_data_2, f=inp_data_3, g=?
  
  // Majority: (a & b) ^ (a & c) ^ (b & c)
  assign majority_func = (inp_data_1 & inp_data_2) ^ (inp_data_1 & inp_data_3) ^ (inp_data_2 & inp_data_3);
  
  // Sigma upper 0 (Σ0): dùng cho a (ROTR 2, 13, 22)
  assign sigma_upper_0 = {inp_data_1[1:0], inp_data_1[31:2]} ^ 
                         {inp_data_1[12:0], inp_data_1[31:13]} ^ 
                         {inp_data_1[21:0], inp_data_1[31:22]};
  
  // Sigma upper 1 (Σ1): dùng cho e (ROTR 6, 11, 25)
  assign sigma_upper_1 = {inp_data_1[5:0], inp_data_1[31:6]} ^ 
                         {inp_data_1[10:0], inp_data_1[31:11]} ^ 
                         {inp_data_1[24:0], inp_data_1[31:25]};
  
  // Sigma lower 0 (σ0): ROTR 7, 18, SHR 3
  assign sigma_lower_0 = {inp_data_1[6:0], inp_data_1[31:7]} ^ 
                         {inp_data_1[17:0], inp_data_1[31:18]} ^ 
                         (inp_data_1 >> 3);
  
  // Sigma lower 1 (σ1): ROTR 17, 19, SHR 10
  assign sigma_lower_1 = {inp_data_1[16:0], inp_data_1[31:17]} ^ 
                         {inp_data_1[18:0], inp_data_1[31:19]} ^ 
                         (inp_data_1 >> 10);
  
endmodule
