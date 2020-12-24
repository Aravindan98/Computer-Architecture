// V.Aravindan
// 2017B4A70849P
module MUX_SMALL(out,in,sel);
input [1:0]in;
input sel;
output out;
assign out=sel?in[1]:in[0];
endmodule

module MUX_BIG(out,in,sel);
input [7:0]in;
input [2:0]sel;
output out;
wire w00,w01,w10,w11,w1,w0;
MUX_SMALL m1(w00,{in[4],in[0]},sel[2]);
MUX_SMALL m2(w01,{in[5],in[1]},sel[2]);
MUX_SMALL m3(w10,{in[6],in[2]},sel[2]);
MUX_SMALL m4(w11,{in[7],in[3]},sel[2]);
MUX_SMALL m5(w1,{w11,w01},sel[1]);
MUX_SMALL m6(w0,{w10,w00},sel[1]);
MUX_SMALL m7(out,{w1,w0},sel[0]);
endmodule

module TFF(out,t,clear,clk);
input t,clear,clk;
output reg out;
always@(posedge clk)
  begin
    if(t)
      out=~out;
    else
      out=out;
  end
always@(clear)
  begin
    if(clear)
      out<=0;
  end
endmodule

module COUNTER_4BIT(Q,clear,clk);
input clear,clk;
output [3:0]Q;
wire w1,w2;
TFF tff1(Q[0],1'b1,clear,clk);
TFF tff2(Q[1],Q[0],clear,clk);
and a1(w1,Q[0],Q[1]);
TFF tff3(Q[2],w1,clear,clk);
and a2(w2,Q[1],Q[2]);
TFF tff4(Q[3],w2,clear,clk);
endmodule

module COUNTER_3BIT(Q,clear,clk);
input clear,clk;
output [2:0]Q;
wire w1;
TFF tff1(Q[0],1'b1,clear,clk);
TFF tff2(Q[1],Q[0],clear,clk);
and a1(w1,Q[0],Q[1]);
TFF tff3(Q[2],w1,clear,clk);
endmodule

module MEMORY(D,A);
input [3:0]A;
output reg [7:0]D;
reg [7:0]memory[0:15];
initial
  begin
    memory[0]=8'hCC;
    memory[1]=8'hAA;
    memory[2]=8'hCC;
    memory[3]=8'hAA;
    memory[4]=8'hCC;
    memory[5]=8'hAA;
    memory[6]=8'hCC;
    memory[7]=8'hAA;
    memory[8]=8'hCC;
    memory[9]=8'hAA;
    memory[10]=8'hCC;
    memory[11]=8'hAA;
    memory[12]=8'hCC;
    memory[13]=8'hAA;
    memory[14]=8'hCC;
    memory[15]=8'hAA;
  end
always@(A)
  begin
    case(A)
      4'd0: D=memory[0];
      4'd1: D=memory[1];
      4'd2: D=memory[2];
      4'd3: D=memory[3];
      4'd4: D=memory[4];
      4'd5: D=memory[5];
      4'd6: D=memory[6];
      4'd7: D=memory[7];
      4'd8: D=memory[8];
      4'd9: D=memory[9];
      4'd10: D=memory[10];
      4'd11: D=memory[11];
      4'd12: D=memory[12];
      4'd13: D=memory[13];
      4'd14: D=memory[14];
      4'd15: D=memory[15];
    endcase
  end
endmodule

module INTG(out,clear,clk1);
  input clk1,clear;
  output out;
  wire [3:0]A;
  wire [2:0]S;
  wire [7:0]I;
  wire clk2;
  COUNTER_3BIT c3(S,clear,clk1);
  assign clk2=S[2] & S[1] & S[0];
  COUNTER_4BIT c4(A,clear,clk2);
  MEMORY m(I,A);
  MUX_BIG mux(out,I,S);
endmodule

module testbench;
  initial
    begin
      $dumpfile("2018.vcd");
      $dumpvars;
    end

  reg clk1,clear;
  wire out;

  INTG i(out,clear,clk1);

  always
    #0.5 clk1=~clk1;

  initial
    $monitor($time,"   clk1=%b |||||| output=%b ",clk1,out);

  initial
    begin
      clk1=1'b0; clear=1'b1;
      #1 clear=1'b0;
      #200 $finish;
    end

endmodule
