`timescale 1ns / 1ps

module watch_cu (

    input  clk,
    input  rst,
    input  BTN_L,
    input  BTN_R,
    output min,
    output hour,
    output sec,
    input  sw0
);

    parameter HOUR = 3'b100, MIN = 3'b001, SEC = 3'b010;
    reg [2:0] n_state, c_state;

    assign sec  = (sw0 == 1'b0 && c_state == SEC);
    assign min  = (sw0 == 1'b1 && c_state == MIN);
    assign hour = (sw0 == 1'b1 && c_state == HOUR);


    always @(posedge clk, posedge rst) begin

        if (rst) begin
            c_state <= SEC;

        end else begin
            c_state <= n_state;

        end
    end

    always @(*) begin
        n_state = c_state;

        case (c_state)

            SEC: begin
                if (BTN_R == 1) n_state = HOUR;
                else if (BTN_L == 1) n_state = MIN;
                else n_state = c_state;
            end

            MIN: begin
                if (BTN_R) n_state = SEC;
                else if (BTN_L == 1) n_state = HOUR;
                else n_state = c_state;
            end

            HOUR: begin
                if (BTN_L == 1) n_state = SEC;
                else if (BTN_R == 1) n_state = MIN;
                else n_state = c_state;
            end

            default: n_state = c_state;
        endcase
    end

endmodule
