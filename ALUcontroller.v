module ALUcontroller(operation,F,aluop);
input [1:0]aluop;
input [5:0]F;
output [2:0]operation;
assign operation[0]= (aluop[1]) & (F[3] | F[0]);
assign operation[1]= (~aluop[1]) | (~F[2]);
assign operation[2]= (aluop[0]) | (aluop[1] & F[1]);
endmodule

module testbench;
reg [1:0]aluop;
wire [2:0]operation;
reg [5:0]F;

ALUcontroller ac(operation,F,aluop);

initial
  $monitor($time, " aluop=%b F=%b  || operation=%b",aluop,F,operation);
initial
begin
  #0 aluop=2'b00; F=6'b000000;
  #2 aluop=2'b01;
  #2 F=6'b000000; aluop=2'b10;
  #2 F=6'b100010; aluop=2'b10;
  #2 F=6'b100100; aluop=2'b10;
  #2 F=6'b000101; aluop=2'b10;
  #2 F=6'b001010; aluop=2'b10;
  $finish;
end
endmodule
