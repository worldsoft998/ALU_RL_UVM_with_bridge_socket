interface alu_if(input bit clk);
  logic [7:0] a;
  logic [7:0] b;
  logic [2:0] op;
  logic [7:0] result;
  logic carry;
  logic zero;
  modport DUT (input a,b,op, output result, carry, zero);
  modport TB  (output a,b,op, input result, carry, zero);
endinterface
