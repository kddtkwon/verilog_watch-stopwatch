`timescale 1ns / 1ps

 module fnd_controllr (
    input        clk,
    input        reset,
    input        sel,
    input  [6:0] msec,
    input  [5:0] sec,
    input  [5:0] min,
    input  [4:0] hour,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);
    wire [3:0] w_bcd, w_msec_1, w_msec_10, w_sec_1, w_sec_10;
    wire [3:0] w_min_10, w_min_1, w_hour_1, w_hour_10, w_bcd_2, w_out_bcd;
    wire w_oclk;
    wire [2:0] final_sel;
    wire [2:0] fnd_sel;
    wire [3:0] w_dot;

    // fnd_sel 연결하기.
    clk_div U_CLK_Div (
        .clk  (clk),
        .reset(reset),
        .o_clk(w_oclk)
    );
    counter_4 U_Counter_4 (
        .clk(w_oclk),
        .reset(reset),
        .fnd_sel(fnd_sel)
    );
    decoder_2x4 U_Decoder_2x4 (
        .fnd_sel(fnd_sel),
        .fnd_com(fnd_com)
    );

    digit_splitter #(
        .BIT_WIDTH(7)
    ) U_DS_MSEC(
    .time_data(msec),
    .digit_1  (w_msec_1),
    .digit_10 (w_msec_10)                   // 10의 자리까지만 있음 댐댐
    );
    digit_splitter #(
        .BIT_WIDTH(6)
    ) U_DS_SEC(
    .time_data(sec),
    .digit_1  (w_sec_1),
    .digit_10 (w_sec_10)                   // 10의 자리까지만 있음 댐댐
    );
    digit_splitter #(
        .BIT_WIDTH(6)
    ) U_DS_MIN(
    .time_data(min),
    .digit_1  (w_min_1),
    .digit_10 (w_min_10)                   // 10의 자리까지만 있음 댐댐
    );    
    digit_splitter #(
        .BIT_WIDTH(5)
    ) U_DS_HOUR(
    .time_data(hour),
    .digit_1  (w_hour_1),
    .digit_10 (w_hour_10)                   // 10의 자리까지만 있음 댐댐
    );
    mux_8x1 U_MUX_4x1 (
        .sel(fnd_sel),
        .digit_1(w_msec_1),
        .digit_10(w_msec_10),
        .digit_100(w_sec_1),
        .digit_1000(w_sec_10),
        .digit_dp_4(4'hf),
        .digit_dp_5(4'hf),
        .digit_dp_6(w_dot),  
        .digit_dp_7(4'hf),
        .bcd(w_bcd)
    );
    bcd U_BCD (
        .bcd(w_out_bcd),
        .fnd_data(fnd_data)
    );
    mux_8x1 U_MUX_4x1_2 (
        .sel(fnd_sel),
        .digit_1(w_min_1),
        .digit_10(w_min_10),
        .digit_100(w_hour_1),
        .digit_1000(w_hour_10),
        .digit_dp_4(4'hf),
        .digit_dp_5(4'hf),
        .digit_dp_6(w_dot),  
        .digit_dp_7(4'hf),
        .bcd(w_bcd_2)
    );
    mux_2X1 U_MUX_2X1(
        .sel(sel),
        .bcd_sec(w_bcd),
        .bcd_min(w_bcd_2),
        .out_bcd(w_out_bcd)
    );
    comp_dot u_dot_comp(
    .msec(msec),
    .comp(w_dot)
    );
endmodule

module clk_div_100hz #(parameter F_count = 1_000_000)(
    input clk,
    input reset,
    output o_clk_100hz
);
    //parameter F_count = 1_000_000;
    reg [$clog2(1000000)-1:0] r_counter;
    reg r_clk;
    assign o_clk_100hz = r_clk;

    always @(posedge clk, posedge reset)begin
        if(reset) begin
            r_counter<=0;
            r_clk <= 0;
        end else begin
            if (r_counter == 1_000_000 -1) begin
                r_counter <=0;
                r_clk <= 1'b1;
            end else if (r_counter >= F_count/2)begin
                r_counter <= r_counter +1;
                r_clk <=1'b0;
            end else begin
                r_counter <= r_counter +1;
            end
        end
    end
endmodule

// clk divider
// 1khz

module clk_div (
    input  clk,
    input  reset,
    output o_clk
);
    // clk 100_000_000, r_count = 100_000
    //reg [16:0] r_counter;
    reg [$clog2(100_000)-1:0] r_counter;
    reg r_clk;

    assign o_clk = r_clk;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            r_clk     <= 1'b0;
        end else begin
            if (r_counter == 100_000 - 1) begin  // 1khz period
                r_counter <= 0;
                r_clk <= 1'b1;
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0;
            end
        end
    end

endmodule
//10000진 카운터터
module counter_10000 (
    input        clk,
    input        reset,
    
    output [13:0] count_data
);
    reg [13:0] r_counter;
    assign count_data = r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end else begin
            if (r_counter == 9999) begin
                r_counter <= 14'b0;
            end else begin
            r_counter <= r_counter + 1;
        end
    end
    end
endmodule
module counter_4 (
    input        clk,
    input        reset,
    output [2:0] fnd_sel
);
    reg [2:0] r_counter;

    assign fnd_sel = r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end else begin
            r_counter <= r_counter + 1;
        end
    end

endmodule


module decoder_2x4 (
    input      [1:0] fnd_sel,
    output reg [3:0] fnd_com
);
    always @(fnd_sel) begin
        case (fnd_sel)
            2'b00:   fnd_com = 4'b1110;  // fnd 1의 자리 On,
            2'b01:   fnd_com = 4'b1101;
            2'b10:   fnd_com = 4'b1011;
            2'b11:   fnd_com = 4'b0111;
            default: fnd_com = 4'b1111;
        endcase
    end
endmodule

module mux_8x1 (
    input  [2:0] sel,
    input  [3:0] digit_1,
    input  [3:0] digit_10,
    input  [3:0] digit_100,
    input  [3:0] digit_1000,
    input  [3:0] digit_dp_4,
    input  [3:0] digit_dp_5,
    input  [3:0] digit_dp_6,
    input  [3:0] digit_dp_7,
    output [3:0] bcd
);

    reg [3:0] r_bcd;
    assign bcd = r_bcd;

    // 4:1 mux , always 
    always @(*) begin
        case (sel)
            3'b000: r_bcd = digit_1;
            3'b001: r_bcd = digit_10;
            3'b010: r_bcd = digit_100;
            3'b011: r_bcd = digit_1000;
            3'b100: r_bcd = digit_dp_4;
            3'b101: r_bcd = digit_dp_5;
            3'b110: r_bcd = digit_dp_6;
            3'b111: r_bcd = digit_dp_7;
        endcase
    end
endmodule
module comp_dot(
    input [6:0] msec,
    output [3:0] comp


);
    assign comp = (msec > (50-1) ? 4'he:4'hf);

endmodule

module mux_2X1(
    input      sel,
    input      [3:0]bcd_sec,
    input      [3:0]bcd_min,
    output     [3:0] out_bcd
);
    reg [3:0] r_bcd;
    assign out_bcd = r_bcd;

    always @(*) begin
        case (sel)
            1'b0: r_bcd = bcd_sec;
            1'b1: r_bcd = bcd_min;
        endcase
    end
endmodule
// msec 7bit sec min 6bit hour 5bit


module digit_splitter #(parameter BIT_WIDTH = 7)( //msec digit splitter
    input  [BIT_WIDTH-1:0] time_data,
    output [ 3:0] digit_1,
    output [ 3:0] digit_10 // 10의 자리까지만 있음 댐댐
);

    assign digit_1    =  time_data % 10;
    assign digit_10   = (time_data / 10) % 10;
endmodule

module bcd (
    input  [3:0] bcd,
    output [7:0] fnd_data
);

    reg [7:0] r_fnd_data;

    assign fnd_data = r_fnd_data;

    // 조합논리 combinational , 행위수준 모델링.

    always @(bcd) begin
        case (bcd)
            4'h00:   r_fnd_data = 8'hc0;
            4'h01:   r_fnd_data = 8'hf9;
            4'h02:   r_fnd_data = 8'ha4;
            4'h03:   r_fnd_data = 8'hb0;
            4'h04:   r_fnd_data = 8'h99;
            4'h05:   r_fnd_data = 8'h92;
            4'h06:   r_fnd_data = 8'h82;
            4'h07:   r_fnd_data = 8'hf8;
            4'h08:   r_fnd_data = 8'h80;
            4'h09:   r_fnd_data = 8'h90;
            4'he:    r_fnd_data = 8'h7f;
            default: r_fnd_data = 8'hff;
        endcase
    end

endmodule
