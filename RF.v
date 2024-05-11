
module RF(
    input write, // write enable
    input clk, // clock
    input reset_n, // reset
    input [1:0] addr1, // read addr
    input [1:0] addr2, // read addr
    input [1:0] addr3, // write addr
    output [15:0] data1, // addr1���� read�� data
    output [15:0] data2, // addr2���� read�� data
    input [15:0] data3 // addr3�� write�� data
    );
    reg [15:0] rf [3:0]; // 4 16-bit reg
    
    assign data1 = rf[addr1];
    assign data2 = rf[addr2];
    
    always @(*) begin
        if(reset_n == 0) begin // reset
            rf [2'b00] <= 0;
            rf [2'b01] <= 0;
            rf [2'b10] <= 0;
            rf [2'b11] <= 0;
        end
    end
    always @(posedge clk) begin
        if(reset_n != 0) begin // when reset_n is 0, ignore write enable
            if(write == 1) begin // when write enable is 1, write data
                rf[addr3] <= data3;
            end
        end
    end
endmodule