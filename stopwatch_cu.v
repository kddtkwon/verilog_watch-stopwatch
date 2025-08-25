`timescale 1ns / 1ps

module stopwatch_cu (

    input  clk,
    input  rst,
    input  i_clear,
    input  i_runstop,
    input  sw,
    output o_clear,
    output o_runstop
);

    parameter STOP = 2'b00, RUN = 2'b01, CLEAR = 2'b10;
    reg [1:0] n_state, c_state;

    assign o_clear   = (c_state == CLEAR) ? 1 : 0;
    assign o_runstop = (c_state == RUN) ? 1 : 0;

    always @(posedge clk, posedge rst) begin

        if (rst) begin
            c_state <= STOP;

        end else begin
            c_state <= n_state;

        end
    end

    always @(*) begin
        n_state = c_state;

        case (c_state)

            STOP: begin
                if (i_runstop == 1) n_state = RUN;
                else if (i_clear == 1) n_state = CLEAR;
                else n_state = c_state;
            end

            RUN: begin
                if (i_runstop == 1) n_state = STOP;
                else n_state = c_state;
            end

            CLEAR: begin
                if (i_clear == 1) n_state = STOP;
                else n_state = c_state;
            end

            default: n_state = c_state;
        endcase
    end

endmodule
