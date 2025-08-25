`timescale 1ns / 1ps


module watch_dp(
    input            clk,
    input            rst,
    input            i_min,
    input            i_hour,
    input            i_sec,
    input            btn_up,
    input            btn_down,
    output      [6:0]o_msec,
    output      [5:0]o_sec,
    output      [5:0]o_min,
    output      [4:0]o_hour
    );
    wire w_tick_100hz, w_sec_tick, w_min_tick, w_hour_tick;
    wire reset, clk_runstop;
    wire [6:0] msec;
    wire [5:0] sec, min;
    wire [4:0] hour;
    assign o_msec = msec;
    assign o_sec  = sec;
    assign o_min  = min;
    assign o_hour = hour;
    assign reset = rst;
    assign clk_runstop = clk;
    time_counter_wt #(
        .BIT_WIDTH(7),
        .TICK_COUNT(100)
    ) U_MSEC (
        .clk(clk),
        .rst(reset),
        .i_tick(w_tick_100hz),
        .o_time(msec),
        .o_tick(w_sec_tick)
    );
    time_counter_wt #(
        .BIT_WIDTH(6),
        .TICK_COUNT(60)
    ) U_SEC (
        .clk(clk),
        .rst(reset),
        .btn_up(btn_up),
        .btn_down(btn_down),
        .i_tick(w_sec_tick),
        .cu_time(i_sec),
        .o_time(sec),
        .o_tick(w_min_tick)
    );
    time_counter_wt #(
        .BIT_WIDTH(6),
        .TICK_COUNT(60)
    ) U_MIN (
        .clk(clk),
        .rst(reset),
        .btn_up(btn_up),
        .btn_down(btn_down),
        .i_tick(w_min_tick),
        .cu_time(i_min),
        .o_time(min),
        .o_tick(w_hour_tick)
    );    
    time_counter_wt #(
        .BIT_WIDTH(5),
        .TICK_COUNT(24),
        .TIME_START(12)
    ) U_HOUR (
        .clk(clk),
        .rst(reset),
        .btn_up(btn_up),
        .btn_down(btn_down),
        .cu_time(i_hour),
        .i_tick(w_hour_tick),
        .o_time(hour)  
    );
    
    tick_gen_100hz_wt U_Tick_100hz(
        .clk(clk_runstop),
        .rst(reset),
        .o_tick_100(w_tick_100hz)
    );
endmodule

module time_counter_wt #(
    parameter BIT_WIDTH = 7, TICK_COUNT = 100, TIME_START = 0
) (
    input                      clk,
    input                      rst,
    input                      i_tick,
    input                      cu_time,
    input                      btn_down,
    input                      btn_up,
    output     [BIT_WIDTH-1:0] o_time,
    output                     o_tick
);

    reg [$clog2(TICK_COUNT) -1:0] count_reg, count_next;
    reg o_tick_reg, o_tick_next;

    assign o_time = count_reg;
    assign o_tick = o_tick_reg; // latch 제거
    // state register
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            count_reg     <=TIME_START;
            o_tick_reg    <= 0;
        end else begin
            count_reg     <= count_next;
            o_tick_reg    <= o_tick_next;
        end
    end

    // CL next state
always @(*) begin
    count_next  = count_reg;
    o_tick_next = 1'b0;

    // 1. 수동 버튼 입력은 언제나 허용 (cu_time이 1일 때만 활성화)
    if (cu_time && btn_down) begin
        count_next = (count_reg == 0) ? TICK_COUNT - 1 : count_reg - 1;
    end else if (cu_time && btn_up) begin
        count_next = (count_reg == TICK_COUNT - 1) ? 0 : count_reg + 1;
    end

    // 2. 자동 흐름 (tick에 따라 항상 동작)
    if (i_tick == 1'b1) begin
        if (count_next == TICK_COUNT - 1) begin
            count_next  = 0;
            o_tick_next = 1'b1;
        end else begin
            count_next  = count_next + 1;
        end
    end
end
reg btn_up_d, btn_up_rise;
always @(posedge clk) begin
    btn_up_d <= btn_up;
    btn_up_rise <= btn_up & ~btn_up_d;
end

endmodule

module tick_gen_100hz_wt(
    input clk,
    input rst,
    output reg o_tick_100
);

    parameter FCOUNT = 1_000_000;
    
    reg[$clog2(FCOUNT)-1:0] r_counter;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter  <= 0;
            o_tick_100 <= 0; // tick gen 올리기
        end else begin
            if(r_counter == FCOUNT -1)begin
                o_tick_100 <= 1'b1; // 카운트 값이 일치했을때, o_tick상승 tickgenerator 상승한단 소리
                r_counter  <=0;
            end else begin
                o_tick_100 <= 1'b0;
                r_counter  <= r_counter +1;
            end
        end
    end
endmodule