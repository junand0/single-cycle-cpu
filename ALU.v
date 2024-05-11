
`define	OP_ADD	0
`define	OP_ID	1

module ALU(
    input [15:0] A,
    input [15:0] B,
    input OP,
    output reg [15:0] C,
    output reg Cout
    );
    always @(*) begin
         case(OP)
            `OP_ADD: begin
                {Cout, C} = A + B; // allocate MSB to Cout to allocate 1 to Cout when overflow
            end
            `OP_ID: begin
                C = B;
                Cout = 0;
            end
        endcase 
    end
endmodule

