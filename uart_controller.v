`timescale 1ns / 1ps


module uart_controller(
    input   clk,
    input   rst,
    input   btn_start,
    input   rx,
    input   [7:0] tx_din,
    output  tx_busy,
    output  tx,
    output  [7:0] rx_data,
    output  rx_done,
    output  tx_done
    );
        wire w_baud_tick; 
        wire w_start;
        wire w_tx_done, w_tx_busy;
        wire [7:0] w_dout;
        wire w_rx_done;
        wire [7:0] w_rx_data, w_rx_pop_data, w_tx_pop_data;
        wire w_tx_full;
        wire w_rx_empty;
        wire w_tx_start;


        assign rx_done = w_rx_done;
        assign rx_data = w_rx_data;
    button_btn U_BTN_DB_START(
        .clk(clk),
        .rst(rst),
        .i_btn(btn_start),
        .o_btn(w_start)
        );

    uart_txx U_UART_TX (
        .clk(clk),
        .rst(rst),
        .baud_tick(w_baud_tick),
        .start(w_start|~w_tx_start),
        .din(w_tx_pop_data),
        .o_tx(tx),
        .o_tx_done(tx_done),
        .o_tx_busy(w_tx_busy)
    );
    fifo RX_fifo(
    .clk(clk),
    .rst(rst), // controller 리셋용
    .push(w_rx_done),
    .pop(~w_tx_full),
    .push_Data(w_rx_data),
    .full(),
    .empty(w_rx_empty),
    .pop_data(w_rx_pop_data)
    );
    fifo TX_fifo(
    .clk(clk),
    .rst(rst), // controller 리셋용
    .push(~w_rx_empty),
    .pop(~w_tx_busy),
    .push_Data(w_rx_pop_data),
    .full(w_tx_full),
    .empty(w_tx_start),
    .pop_data(w_tx_pop_data)
    );
    uart_rx U_UART_RX(
        .clk(clk),
        .rst(rst),
        .b_tick(w_baud_tick),
        .rx(rx), 
        .o_dout(w_rx_data),
        .o_rx_done(w_rx_done) 
    );
    baudrate U_BR(
        .clk(clk),
        .rst(rst),
        .baud_tick(w_baud_tick)
        
    );


endmodule
