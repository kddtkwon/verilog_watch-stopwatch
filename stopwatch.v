`timescale 1ns / 1ps


module stopwatch(
    input       clk,
    input       rst,
    input       btnL_clear,
    input       btnR_RunStop,
    input       sel,
    output [6:0] w_msec,
    output [5:0] w_sec,
    output [5:0] w_min,
    output [4:0] w_hour
    );
    wire w_clear, w_runstop;
    wire w_btnl_clear, w_btnr_runstop;
    stopwatch_cu U_StopWatch_CU(
    .clk(clk),
    .rst(rst),
    .i_clear(btnL_clear),
    .i_runstop(btnR_RunStop),
    .o_clear(w_clear),
    .o_runstop(w_runstop)
    );
    stopwatch_dp U_Stopwatch_DP(
    .clk(clk),
    .rst(rst),
    .run_stop(w_runstop),
    .clear(w_clear),
    .msec(w_msec),
    .sec(w_sec),
    .min(w_min),
    .hour(w_hour)
    );

endmodule

