module voting_machine #(parameter CTR_WIDTH = 16)(
    input clk,               // System clock
    input rst_n,             // Active-low reset
    input enable_btn,        // Button to enable a vote
    input [1:0] sel,         // Candidate selection (00 to 11)
    output reg [CTR_WIDTH-1:0] tally_0, // Vote counter for candidate 0
    output reg [CTR_WIDTH-1:0] tally_1, // Vote counter for candidate 1
    output reg [CTR_WIDTH-1:0] tally_2, // Vote counter for candidate 2
    output reg [CTR_WIDTH-1:0] tally_3, // Vote counter for candidate 3
    output reg [1:0] winner,            // Winner candidate index
    output reg tie                     // High if there is a tie
);

    // Register to hold previous value of enable_btn to detect a button press
    reg prev_enable_btn;

    // Wire to detect rising edge (button press)
    wire vote_pulse = enable_btn & ~prev_enable_btn;

    // Update prev_enable_btn on each clock cycle
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            prev_enable_btn <= 0;
        else
            prev_enable_btn <= enable_btn;
    end

    // Vote counters for each candidate
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tally_0 <= 0;
            tally_1 <= 0;
            tally_2 <= 0;
            tally_3 <= 0;
        end else if (vote_pulse) begin
            case (sel)
                2'b00: tally_0 <= tally_0 + 1;
                2'b01: tally_1 <= tally_1 + 1;
                2'b10: tally_2 <= tally_2 + 1;
                2'b11: tally_3 <= tally_3 + 1;
            endcase
        end
    end

    // Winner and tie detection logic
    always @(*) begin
        // Default values
        winner = 2'b00;
        tie = 0;
        
        // Compare and find the maximum vote count
        if (tally_1 > tally_0) begin
            winner = 2'b01;
        end else if (tally_1 == tally_0 && tally_1 != 0) begin
            tie = 1;
        end

        if (tally_2 > (winner == 2'b01 ? tally_1 : tally_0)) begin
            winner = 2'b10;
            tie = 0;
        end else if (tally_2 == (winner == 2'b01 ? tally_1 : tally_0) && tally_2 != 0) begin
            tie = 1;
        end

        if (tally_3 > (winner == 2'b10 ? tally_2 : (winner == 2'b01 ? tally_1 : tally_0))) begin
            winner = 2'b11;
            tie = 0;
        end else if (tally_3 == (winner == 2'b10 ? tally_2 : (winner == 2'b01 ? tally_1 : tally_0)) && tally_3 != 0) begin
            tie = 1;
        end
    end

endmodule