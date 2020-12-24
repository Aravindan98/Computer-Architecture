`timescale 1ms/100us

module MUX_2x1(out,in,sel);
input [1:0]in;
input sel;
output out;
assign out=(sel)?in[1]:in[0];
endmodule

module MUX_8x1(out,in,sel);
input [7:0]in;
input [2:0]sel;
output out;
assign out=(sel[2])?(sel[1]?(sel[0]?(in[7]):(in[6])):(sel[0]?(in[5]):(in[4]))):(sel[1]?(sel[0]?(in[3]):(in[2])):(sel[0]?(in[1]):(in[0])));
// always@*
  // $display($realtime,"  sel=%b in=%b out=%b",sel,in,out);
endmodule

module MUX_ARRAY(E,B,F);
input [7:0]B,F;
output [7:0]E;
genvar i;
generate
for(i=0;i<8;i=i+1) begin:mux_loop
  MUX_2x1 m(E[i],{B[i],1'b0},F[i]);
end
endgenerate
endmodule

module COUNTER_3BIT(out,clk,clear);
output reg [2:0]out;
input clk,clear;
always@(posedge clk)
    begin
      out<=out+1;
    end
always@(clear)
  begin
    if(clear)
     out<=3'b000;
    end
endmodule

module DECODER(B,A,EN);
  input [2:0]A;
  input EN;
  output reg [7:0]B;
  always@(A)
  begin
    if(EN)
    begin
      case(A)
        3'b000: B<=8'b00000001;
        3'b001: B<=8'b00000010;
        3'b010: B<=8'b00000100;
        3'b011: B<=8'b00001000;
        3'b100: B<=8'b00010000;
        3'b101: B<=8'b00100000;
        3'b110: B<=8'b01000000;
        3'b111: B<=8'b10000000;
      endcase
      // $display($realtime," B=%b",B);
    end
  end
endmodule

module MEMORY(out,S);
  input [2:0]S;
  reg [7:0]mem [0:7];
  output reg [7:0] out;
  initial
    begin
      mem[0]=8'h01;
      mem[1]=8'h03;
      mem[2]=8'h07;
      mem[3]=8'h0F;
      mem[4]=8'h1F;
      mem[5]=8'h3F;
      mem[6]=8'h7F;
      mem[7]=8'hFF;
    end
  always@(S)
    begin
      case(S)
        3'd0:out<=mem[0];
        3'd1:out<=mem[1];
        3'd2:out<=mem[2];
        3'd3:out<=mem[3];
        3'd4:out<=mem[4];
        3'd5:out<=mem[5];
        3'd6:out<=mem[6];
        3'd7:out<=mem[7];
      endcase
    end
endmodule

module TOP_MODULE(out,clear,clk,en,S);
  output out;
  input clk,clear,en;
  input [2:0]S;
  wire [2:0] Q;
  wire [7:0]B,E,G;
  // always@*
    // $display(" Q=%b E=%b   out=%b",Q,E,out);
  COUNTER_3BIT counter(Q,clk,clear);
  DECODER d(B,Q,en);
  MEMORY m(G,S);
  MUX_ARRAY ma(E,B,G);
  MUX_8x1 out_mux(out,E,Q);
endmodule

module testbench;
  initial
  begin
    $dumpfile("CAtest.vcd");
    $dumpvars;
  end
  reg clk,clear,en;
  reg [2:0]S;
  wire out;
  TOP_MODULE t(out,clear,clk,1'b1,S);
  initial // to clear the counter
    begin
      clk=1'b0; S=3'b000; clear=1'b1;
      #1 clear=1'b0;
      #100 $finish;
    end
  always
      #0.5 clk=~clk;
  always
      #8 S=S+1;

  initial
      $monitor($time,"  , CLK = %b, S = %b, CLEAR = %b, O = %b", clk, S, clear, out);
endmodule
