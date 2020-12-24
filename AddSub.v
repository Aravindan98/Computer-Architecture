`include "FA_4.v"

module AddSub(out,out_carry,overflow,a,b,in_carry,b_invert);
  input [3:0] a;
  input [3:0] b;
  input in_carry;
  input b_invert;
  output [3:0]out;
  output out_carry;
  output overflow;
  wire [3:0]bf;
  wire cin;
  xor(bf[0],b[0],b_invert);
  xor(bf[1],b[1],b_invert);
  xor(bf[2],b[2],b_invert);
  xor(bf[3],b[3],b_invert);
  xor(cin,in_carry,b_invert);
  FA_4 fa4(out,out_carry,overflow,a,bf,cin);
endmodule
