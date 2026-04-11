module sha256_functions ( 
  input [31:0] inp_data_1, inp_data_2, inp_data_3,
  output [31:0] choice_func, majority_func, sigma_upper_0, sigma_upper_1, sigma_lower_0, sigma_lower_1
);
  assign choice_func = (inp_data_1 & inp_data_2) ^ (~inp_data_1 & inp_data_3); 
  assign majority_func = (inp_data_1 & inp_data_2) ^ (inp_data_1 & inp_data_3) ^ (inp_data_2 & inp_data_3); 

  assign sigma_upper_0 = {inp_data_1[1:0], inp_data_1[31:2]} ^ {inp_data_1[12:0], inp_data_1[31:13]} ^ {inp_data_1[21:0], inp_data_1[31:22]}; 
  assign sigma_upper_1 = {inp_data_1[5:0], inp_data_1[31:6]} ^ {inp_data_1[10:0], inp_data_1[31:11]} ^ {inp_data_1[24:0], inp_data_1[31:25]}; 
  assign sigma_lower_0 = {inp_data_1[6:0], inp_data_1[31:7]} ^ {inp_data_1[17:0], inp_data_1[31:18]} ^ {inp_data_1 >> 3}; 
  assign sigma_lower_1 = {inp_data_1[16:0], inp_data_1[31:17]} ^ {inp_data_1[18:0], inp_data_1[31:19]} ^ {inp_data_1 >> 10}; 
endmodule
