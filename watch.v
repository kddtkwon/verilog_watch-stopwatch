`timescale 1ns / 1ps



module watch(
    input       clk,
    input       rst,
    input       btnL_clear,
    input       btnR_RunStop,
    input       btnU,
    input       btnD,
    input       sw0,
    output [6:0] wt_msec,
    output [5:0] wt_sec,
    output [5:0] wt_min,
    output [4:0] wt_hour
    );
    wire cu_set_min;
    wire cu_set_hour;
    wire cu_set_sec;

    watch_cu U_watch_cu(

    .clk(clk),
    .rst(rst),
    .BTN_L(btnL_clear),
    .BTN_R(btnR_RunStop),
    .min(cu_set_min),
    .hour(cu_set_hour),
    .sec(cu_set_sec),
    .sw0(sw0)
    );
    watch_dp U_watch_dp(
    .clk(clk),
    .rst(rst),
    .i_min(cu_set_min),
    .i_hour(cu_set_hour),
    .i_sec(cu_set_sec),
    .btn_down(btnD),
    .btn_up(btnU),
    .o_msec(wt_msec),
    .o_sec(wt_sec),
    .o_min(wt_min),
    .o_hour(wt_hour)
    );
endmodule
