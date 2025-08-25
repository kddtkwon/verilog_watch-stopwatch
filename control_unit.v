`timescale 1ns / 1ps

// Control Unit: decodes keyboard commands to button pulses, ESC reset, and toggles for sw1/sw0
module control_unit(
    input        clk,
    input        rst,
    input  [7:0] rx_data,
    input        rx_done,
    output reg [7:0] btn_out,  // [5]=btnL, [4]=btnR, [3]=btnU, [2]=btnD, [1]=sw1_flag, [0]=sw0_flag
    output reg       esc_rst    // pulse on ESC key
);
    // button mapping pulses
    localparam IDLE = 8'b00000000;
    localparam CLR  = 8'b00100000; // C/L -> btnL
    localparam RUN  = 8'b00010000; // G/R -> btnR
    localparam UP   = 8'b00001000; // U   -> btnU
    localparam DOWN = 8'b00000100; // D   -> btnD

    // toggle flags
    reg sw1_flag;
    reg sw0_flag;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_out  <= IDLE;
            esc_rst  <= 1'b0;
            sw1_flag <= 1'b0;
            sw0_flag <= 1'b0;
        end else if (rx_done) begin
            // ESC reset pulse
            esc_rst <= (rx_data == 8'h1B);
            // toggle mode/address flags
            if (rx_data == 8'h4E)       // 'N' key
                sw1_flag <= ~sw1_flag;
            else if (rx_data == 8'h4D)  // 'M' key
                sw0_flag <= ~sw0_flag;
            // generate button pulse
            case (rx_data)
                8'h43, 8'h4C: btn_out[5:2] <= CLR[5:2];  // 'C' or 'L'
                8'h47, 8'h52: btn_out[5:2] <= RUN[5:2];  // 'G' or 'R'
                8'h55:        btn_out[5:2] <= UP[5:2];   // 'U'
                8'h44:        btn_out[5:2] <= DOWN[5:2]; // 'D'
                default:      btn_out[5:2] <= IDLE[5:2];
            endcase
            // embed toggle flags into lower bits
            btn_out[1] <= sw1_flag;
            btn_out[0] <= sw0_flag;
        end else begin
            // clear pulses, retain flags
            btn_out[5:2] <= IDLE[5:2];
            btn_out[1]   <= sw1_flag;
            btn_out[0]   <= sw0_flag;
            esc_rst      <= 1'b0;
        end
    end
endmodule