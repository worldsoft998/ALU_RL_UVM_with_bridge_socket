module alu8 (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic [2:0] op, // 3-bit operation: 000 add,001 sub,010 and,011 or,100 xor,101 slt,110 shl,111 shr
    output logic [7:0] result,
    output logic carry,
    output logic zero
);
    logic [8:0] tmp;
    always_comb begin
        unique case (op)
            3'b000: tmp = {1'b0, a} + {1'b0, b}; // add
            3'b001: tmp = {1'b0, a} - {1'b0, b}; // sub
            default: tmp = 9'd0;
        endcase
        case (op)
            3'b010: result = a & b;
            3'b011: result = a | b;
            3'b100: result = a ^ b;
            3'b101: result = (a < b) ? 8'd1 : 8'd0;
            3'b110: result = a << 1;
            3'b111: result = a >> 1;
            3'b000, 3'b001: result = tmp[7:0];
            default: result = 8'h00;
        endcase
        carry = tmp[8];
        zero  = (result == 8'h00);
    end
endmodule
