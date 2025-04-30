// testbench.sv
module testbench;
    logic clk;
    logic fastclk;
    logic reset;
    logic [8:0] SW;
    logic [7:0] LED;
    logic [7:0] prev_LED;
    logic [7:8] captured_led_iter1;
    logic [7:0] captured_led_iter2;
    logic [5:0] pc;

    picoMIPS UUT (
        .clk(clk),
        .reset(reset),
        .SW(SW),
        .LED(LED),
        .pc(pc)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        fastclk = 0;
        forever #1 fastclk = ~fastclk;
    end

    // Test stimulus
    initial begin
        reset = 1;
        SW = 9'h1FF; // SW[9]=1 (reset), SW[8]=1, SW[7:0]=0xFF
        $display("Time: %0t, Testbench: Asserting Reset (SW[9]=0), SW = %h", $time, SW);
        #100;
        reset = 0;
        SW[9] = 0; // Deassert reset
        $display("Time: %0t, Testbench: Deasserting Reset (SW[9]=1), SW = %h", $time, SW);
        #200;

        // First iteration: SW8=0, set index i=0x14
        SW[8] = 0;
        SW[7:0] = 8'h14;
        $display("Time: %0t, Testbench: Setting SW[7:0]=14 while SW[8]=0", $time);
        #500;

        // SW8 rising edge (0 to 1), start computation
        SW[8] = 1;
        $display("Time: %0t, Testbench: Setting SW[8]=1. Core should read index.", $time);
        #500; // Extended to ensure OUTPUT is reached

        // Capture LED output after computation
        captured_led_iter1 = LED;
        $display("Time: %0t, Testbench: First iteration (i=20) finished. Captured LED = %h", $time, captured_led_iter1);

        $display("Time: %0t, Testbench: Simulation finished", $time);
        $finish;
    end

    // Monitor LED changes
    always @(LED) begin
        prev_LED <= LED;
    end
endmodule