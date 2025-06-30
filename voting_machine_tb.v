`timescale 1ns / 1ps

module voting_machine_tb;

    parameter CTR_WIDTH = 16;

    // Inputs
    reg clk;
    reg rst_n;
    reg enable_btn;
    reg [1:0] sel;

    // Outputs
    wire [CTR_WIDTH-1:0] tally_0, tally_1, tally_2, tally_3;
    wire [1:0] winner;
    wire tie;

    // Instantiate the voting_machine
    voting_machine #(CTR_WIDTH) uut (
        .clk(clk),
        .rst_n(rst_n),
        .enable_btn(enable_btn),
        .sel(sel),
        .tally_0(tally_0),
        .tally_1(tally_1),
        .tally_2(tally_2),
        .tally_3(tally_3),
        .winner(winner),
        .tie(tie)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Vote pulse generator
    task vote(input [1:0] candidate);
        begin
            sel = candidate;
            enable_btn = 1; #10;
            enable_btn = 0; #10;
        end
    endtask

    // Dump and simulation sequence
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, voting_machine_tb);

        // Reset
        rst_n = 0; enable_btn = 0; sel = 2'b00; #20;
        rst_n = 1; #10;

        // Voting sequence
        vote(2'b00); // vote for candidate 0
        vote(2'b01); // vote for candidate 1
        vote(2'b01); // vote again for candidate 1
        vote(2'b10); // vote for candidate 2
        vote(2'b10); // vote again for candidate 2
        vote(2'b11); // vote for candidate 3
        vote(2'b11); // vote again for candidate 3
        vote(2'b11); // vote again for candidate 3

        #50; // wait before finish
        $finish;
    end

endmodule