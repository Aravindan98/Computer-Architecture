// ID: 2017B4A70849P
// Name:V.Aravindan

module RSFF(Q,S,R,clk,reset);
  input S,R,clk,reset;
  output reg Q;
  always@(posedge clk)
    begin
      case({S,R})
        2'b01: Q=1'b0;
        2'b10: Q=1'b1;
        2'b11: Q=1'b1;
      endcase
    end
  always@(reset)
      begin
        if(reset)
          Q=0;
      end
endmodule

module DFF(Q,D,clk,reset);
input D,clk,reset;
output Q;
wire nd;
assign nd=~D;
RSFF rsff(Q,D,nd,clk,reset);
endmodule

module Ripple_Counter(Q,clk,reset);
input clk,reset;
output [3:0]Q;
DFF FF0(Q[0],~Q[0],clk,reset);
DFF FF1(Q[1],~Q[1],~Q[0],reset);
DFF FF2(Q[2],~Q[2],~Q[1],reset);
DFF FF3(Q[3],~Q[3],~Q[2],reset);
endmodule

module MEM1(Data,Parity,Addr);
input [2:0]Addr;
output reg [7:0]Data;
output reg Parity;
reg [8:0]memory[0:7];
initial
  begin
    memory[0]=9'b0001_1111_1;
    memory[1]=9'b0011_0001_1;
    memory[2]=9'b0101_0011_1;
    memory[3]=9'b0111_0101_1;
    memory[4]=9'b1001_0111_1;
    memory[5]=9'b1011_1001_1;
    memory[6]=9'b1101_1011_1;
    memory[7]=9'b1111_1101_1;
  end
always@(Addr)
  begin
    Parity=1'b1;
    case(Addr)
      3'd0:Data=memory[0][8:1];
      3'd1:Data=memory[1][8:1];
      3'd2:Data=memory[2][8:1];
      3'd3:Data=memory[3][8:1];
      3'd4:Data=memory[4][8:1];
      3'd5:Data=memory[5][8:1];
      3'd6:Data=memory[6][8:1];
      3'd7:Data=memory[7][8:1];
    endcase
  end
endmodule

module MEM2(Data,Parity,Addr);
input [2:0]Addr;
output reg [7:0]Data;
output reg Parity;
reg [8:0]memory[0:7];
initial
  begin
    memory[0]=9'b0000_0000_0;
    memory[1]=9'b0010_0010_0;
    memory[2]=9'b0100_0100_0;
    memory[3]=9'b0110_0110_0;
    memory[4]=9'b1000_1000_0;
    memory[5]=9'b1010_1010_0;
    memory[6]=9'b1100_1100_0;
    memory[7]=9'b1110_1110_0;
  end
always@(Addr)
  begin
    Parity=1'b0;
    case(Addr)
      3'd0:Data=memory[0][8:1];
      3'd1:Data=memory[1][8:1];
      3'd2:Data=memory[2][8:1];
      3'd3:Data=memory[3][8:1];
      3'd4:Data=memory[4][8:1];
      3'd5:Data=memory[5][8:1];
      3'd6:Data=memory[6][8:1];
      3'd7:Data=memory[7][8:1];
    endcase
  end
endmodule

module MUX2To1(out,in,sel);
input [1:0]in;
input sel;
output out;
assign out=(sel)?in[1]:in[0];
endmodule

module MUX16To8(out,in1,in2,sel);
input [7:0]in1,in2;
input sel;
output [7:0]out;
genvar i;
generate
for(i=0;i<8;i=i+1) begin:mux_loop
   MUX2To1 m(out[i],{in2[i],in1[i]},sel);
  end
endgenerate
endmodule

module Fetch_Data(Data,Parity,Addr);
input [3:0]Addr;
wire [7:0]Data1,Data2;
wire Parity1,Parity2;
output [7:0]Data;
output Parity;
MEM1 m1(Data1,Parity1,Addr[2:0]);
MEM2 m2(Data2,Parity2,Addr[2:0]);
MUX2To1 parity_mux(Parity,{Parity2,Parity1},Addr[3]);
MUX16To8 data_mux(Data,Data1,Data2,Addr[3]);
endmodule

module Parity_Checker(Match_result,Data,Parity);
input [7:0]Data;
input Parity;
output Match_result;
wire Data_Parity;
assign Data_Parity=Data[0]+Data[1]+Data[2]+Data[3]+Data[4]+Data[5]+Data[6]+Data[7];
assign Match_result=~(Parity^Data_Parity);
endmodule

module Design(out,clk,reset);
input clk,reset;
output out;
wire [3:0]Addr;
wire [7:0]Data_fetched;
wire Parity_fetched;
Ripple_Counter rc(Addr,clk,reset);
Fetch_Data fd(Data_fetched, Parity_fetched, Addr);
Parity_Checker pc(out,Data_fetched,Parity_fetched);
endmodule

module TestBench;
initial
  begin
    $dumpfile("2017B4A70849P.vcd");
    $dumpvars;
  end
reg clk,reset;
wire out;
Design d(out,clk,reset);
initial
  begin
    clk=1'b0; reset=1'b1;
    #1 reset=1'b0;
    #100 $finish;
  end
always
   #0.5 clk=~clk;
initial
    $monitor($time,"   clk=%b reset=%b |||||| output=%b ",clk,,reset,out);
endmodule
