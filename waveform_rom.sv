//-----------------------------------------------------
// File Name   : alu.sv
// Function    : ALU module for picoMIPS
// Author:  Yu-Cheng Lai
// Last rev. 29 April 2025
//-----------------------------------------------------
module waveform_rom (
    input logic [7:0] address,
    output logic [7:0] data
);
    (* romstyle = "M9K" *) logic [7:0] rom [0:255];

    initial begin
        $readmemh("wave.hex", rom);
    end

    always_comb begin
        data = rom[address];
    end
endmodule