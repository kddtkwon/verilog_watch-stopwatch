`timescale 1ns / 1ps

module top(
    input       clk,
    input       rst,
    input       btnL,
    input       btnR,
    input       btnD,
    input       btnU,
    input       sel,
    input       sw0,
    output [3:0]fnd_com,
    output [7:0]fnd_data
);
    wire [6:0]wt_msec_f, w_msec_f;
    wire [5:0]wt_sec_f, w_sec_f;
    wire [5:0]wt_min_f, w_min_f;
    wire [4:0]wt_hour_f, w_hour_f;
    wire [23:0] w_mux_to_f;
    wire [3:0] demux_sw;
    wire [3:0] demux_wt;

    // 디바운스 없이 버튼 직접 연결
    wire w_D = btnD;
    wire w_U = btnU;
    wire w_L = btnL;
    wire w_R = btnR;

    stopwatch top_sw(
        .clk(clk),
        .rst(rst),
        .btnL_clear(demux_sw[3]),
        .btnR_RunStop(demux_sw[2]),
        .sel(sel),
        .w_msec(w_msec_f),
        .w_sec(w_sec_f),
        .w_min(w_min_f),
        .w_hour(w_hour_f)
    );

    watch top_wt(
        .clk(clk),
        .rst(rst),
        .btnL_clear(demux_wt[3]),
        .btnR_RunStop(demux_wt[2]),
        .btnU(demux_wt[1]),
        .btnD(demux_wt[0]),
        .sw0(sw0),
        .wt_msec(wt_msec_f),
        .wt_sec(wt_sec_f),
        .wt_min(wt_min_f),
        .wt_hour(wt_hour_f)
    );

    fnd_controllr U_FND_CNTL (
        .clk(clk),
        .sel(sw0),
        .reset(rst),
        .msec(w_mux_to_f[6:0]),
        .sec(w_mux_to_f[12:7]),
        .min(w_mux_to_f[18:13]),
        .hour(w_mux_to_f[23:19]),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );

    mux_2X1_tof U_mux_fnd(
        .sel(sel),
        .sw_to_m({w_hour_f, w_min_f, w_sec_f, w_msec_f}),
        .wt_to_m({wt_hour_f, wt_min_f, wt_sec_f, wt_msec_f}),
        .m_to_f(w_mux_to_f[23:0])
    );

    demux U_btn_demux(
        .sel(sel),
        .input_button({w_L,w_R,w_U,w_D}),
        .sel_wt(demux_wt),
        .sel_sw(demux_sw)
    );
endmodule

module mux_2X1_tof(
    input      sel,
    input      [23:0] sw_to_m,
    input      [23:0] wt_to_m,
    output     [23:0] m_to_f
);
    reg [23:0] r_bcd;
    assign m_to_f = r_bcd;

    always @(*) begin
        case (sel)
            1'b0: r_bcd = wt_to_m;
            1'b1: r_bcd = sw_to_m;
        endcase
    end
endmodule

module demux(
    input   sel,
    input   [3:0] input_button,
    output  reg[3:0]sel_wt,
    output  reg[3:0]sel_sw
);
    always @(*) begin
        sel_wt = 0;
        sel_sw = 0;
        if(sel == 0) begin
            sel_wt= input_button;
        end else if (sel ==1)begin
            sel_sw = input_button ;
        end
    end
endmodule
