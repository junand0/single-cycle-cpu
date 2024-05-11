`include "opcodes.v"

module control_unit (
    input reset_n,
    input [3:0] opcode,
    input [5:0] func_code,

    output RegDst,
    output Jump,
    output ALUOp,
    output ALUSrc,
    output RegWrite,
    output isWWD,
    output sign_ex // sign extension or concatenation of 8bits of zeros
);

wire Is_Itype;
assign Is_Itype = (0 <= opcode) && (opcode <= 4'b1000); // Is instruction I-type?
assign RegDst = (opcode == `OPCODE_Rtype); // if inst is R-type then RegDst is 1
assign Jump = (opcode == `OPCODE_JMP); // if inst is JMP then Jump is 1
assign ALUOp = ~(opcode == `OPCODE_Rtype | opcode == `OPCODE_ADI); // If inst is R-type or ADI then ALUOp is 0 which is ADD signal
assign ALUSrc = Is_Itype; // if inst is I-type then ALUSrc is 1 meaning that one of the ALU input is imm field value
assign isWWD = (opcode == `OPCODE_Rtype) && (func_code == `FUNC_WWD); // if opcode is R-type and function code is WWD then isWWD is 1
assign sign_ex = (opcode == `OPCODE_ADI); // if opcode is ADI then sign_ex is 1 meaning that apply sign extension for imm field value
assign RegWrite = ((opcode == `OPCODE_Rtype) && ~isWWD || Is_Itype); // if opcode is R-type and not isWWD, or instruction is I-type then RegWrite is 1

endmodule