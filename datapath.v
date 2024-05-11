`include "opcodes.v"

module datapath #(
    parameter WORD_SIZE = 16
)
    (
        input clk,
        input reset_n,
        input inputReady,
        inout [WORD_SIZE-1:0] data,
        output readM,
        output [WORD_SIZE-1:0] address,
        output [WORD_SIZE-1:0] num_inst,
        output [WORD_SIZE-1:0] output_port,
        
        input RegDst,
        input RegWrite,
        input ALUSrc,
        input ALUOp,
        input Jump,
        input isWWD,
        input sign_ex,
        
        output [3:0] opcode,
        output [5:0] func_code
    );

    wire [WORD_SIZE-1:0] ALUout;
    wire [WORD_SIZE-1:0] ALUin1;
    wire [WORD_SIZE-1:0] ALUin2;

    ALU ALU (
        .C(ALUout),
        .A(ALUin1),
        .B(ALUin2),
        .OP(ALUOp)
    );

    wire [1:0] Addr1_rf;
    wire [1:0] Addr2_rf;
    wire [1:0] Addr3_rf;
    wire [WORD_SIZE-1:0] data1_rf;
    wire [WORD_SIZE-1:0] data2_rf;
    wire [WORD_SIZE-1:0] data3_rf;
    wire write;
    
    reg [1:0] Addr1_rf_reg;
    reg [1:0] Addr2_rf_reg;
    reg [1:0] Addr3_rf_reg;

    reg [WORD_SIZE-1:0] data3_rf_reg;

    assign data3_rf = ALUout;
    assign write = RegWrite;

    RF RF (
        .addr1(Addr1_rf), // read addr
        .addr2(Addr2_rf), // read addr
        .addr3(Addr3_rf), // write addr
        .data1(data1_rf), // read data
        .data2(data2_rf), // read data
        .data3(data3_rf), // write data
        .write(RegWrite), // write enble
        .clk(clk),
        .reset_n(reset_n)
    );
    
    reg [WORD_SIZE-1:0] address_reg;
    reg readM_reg;
    wire [WORD_SIZE-1:0] imm_extend;
    reg [WORD_SIZE-1:0] inst_reg;  

    assign readM = readM_reg;
    assign address = address_reg;
   
    assign Addr1_rf = inst_reg[11:10]; // assign rs to Addr1 of rf
    assign Addr2_rf = inst_reg[9:8]; // assign rt to Addr2 of rf
    assign ALUin1 = data1_rf; // assign read data1 of rf to ALU input1
    
    // instruction parsing
    wire [7:0] imm;
    assign imm = inst_reg[7:0];
    wire [11:0] target_addr;
    assign target_addr = inst_reg[11:0];
    assign opcode = inst_reg[15:12];
    assign func_code = inst_reg[5:0];

    assign Addr3_rf = RegDst ? inst_reg[7:6] : inst_reg[9:8]; // if RegDst is 1 then assign rd of inst to write address of rf. if not then assign rt
    assign imm_extend = sign_ex ? {{8{imm[7]}}, imm} : {imm, {8{1'b0}}}; // sign extension or concatenation of 8bits of zeros
    assign ALUin2 = ALUSrc ? imm_extend : data2_rf; // assign imm field value or read data2 of rf
    assign output_port = isWWD ? data1_rf : 16'bz; // assign read data1 of rf to output port when isWWD is 1
     
    always @(posedge inputReady) begin
        inst_reg = data; // save instruction
        readM_reg = 0; // make readM 0
    end

    always @(negedge inputReady) begin
        if(Jump) begin
            address_reg = {address[3:0], inst_reg[11:0]}; // operation of JUM
        end
        else begin
            address_reg = address + 1; // nextpc = pc + 1
        end
    end

    reg [WORD_SIZE - 1 : 0] num_inst_reg;
    assign num_inst = num_inst_reg;

    always @(posedge clk ) begin
        if(reset_n) begin
            readM_reg <= 1; // make readM 1 when posedge of clk
            num_inst_reg <= num_inst + 1; // increment num_inst 1
        end 
    end
    always @(*) begin
        if(!reset_n) begin // reset
            address_reg <= 0;
            num_inst_reg <= 0;
        end
    end

endmodule