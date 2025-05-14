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
    $display("waveform_rom: rom[78]=%h, rom[79]=%h, rom[80]=%h, rom[81]=%h, rom[82]=%h", 
             rom[78], rom[79], rom[80], rom[81], rom[82]);
    end

    always_comb begin
        data = rom[address];
    end
endmodule