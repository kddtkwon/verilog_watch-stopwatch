`timescale 1ns / 1ps
module top_new (
    input        clk,
    input        rst,
    input        rx,
    input        btnL,
    input        btnR,
    input        btnU,
    input        btnD,
    input        sw0,    // physical display select
    input        sw1,    // physical mode select
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output       tx
);
    wire [7:0] rx_data;
    wire       rx_done;
    wire [7:0] btn_out;
    wire       esc_rst;
    wire dbL, dbR, dbU, dbD;


    // debounce physical buttons
    button_btn dbL_i (.clk(clk), .rst(rst), .i_btn(btnL), .o_btn(dbL));
    button_btn dbR_i (.clk(clk), .rst(rst), .i_btn(btnR), .o_btn(dbR));
    button_btn dbU_i (.clk(clk), .rst(rst), .i_btn(btnU), .o_btn(dbU));
    button_btn dbD_i (.clk(clk), .rst(rst), .i_btn(btnD), .o_btn(dbD));

    // UART controller
    uart_controller U_UART (
        .clk(clk), .rst(rst), .btn_start(1'b0),
        .rx(rx), .tx_din(8'h00), .tx(tx),
        .rx_data(rx_data), .rx_done(rx_done), .tx_done()
    );

    // decode keyboard
    control_unit U_CU (
        .clk(clk), .rst(rst),
        .rx_data(rx_data), .rx_done(rx_done),
        .btn_out(btn_out), .esc_rst(esc_rst)
    );

    // system reset including ESC
    wire sys_rst = rst | esc_rst;
    // mode and display selection via physical or UART toggles
    wire mode_sel = sw1 | btn_out[1];
    wire disp_sel = sw0 | btn_out[0];

    // instantiate existing top
    top U_TOP (
        .clk(clk), .rst(sys_rst),
        .btnL(dbL  | btn_out[5]),
        .btnR(dbR  | btn_out[4]),
        .btnU(dbU  | btn_out[3]),
        .btnD(dbD  | btn_out[2]),
        .sel(mode_sel), .sw0(disp_sel),
        .fnd_com(fnd_com), .fnd_data(fnd_data)
    );
endmodule
