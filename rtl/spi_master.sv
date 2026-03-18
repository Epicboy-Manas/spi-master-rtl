// File: design.sv
module spi_master #(
    parameter DATA_WIDTH = 8,
    parameter CLK_DIV = 4
)(
    input  logic clk, rst_n, start,
    input  logic [DATA_WIDTH-1:0] tx_data,
    output logic [DATA_WIDTH-1:0] rx_data,
    output logic busy, done, sclk, cs_n, mosi,
    input  logic miso
);

    typedef enum logic [1:0] {IDLE, LOAD, TRANSFER, DONE} state_t;
    state_t state;
    
    logic [3:0] bit_cnt;
    logic [7:0] clk_cnt;
    logic [DATA_WIDTH-1:0] shift_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; cs_n <= 1'b1; sclk <= 1'b0; mosi <= 1'b0;
            busy <= 1'b0; done <= 1'b0; clk_cnt <= 0; bit_cnt <= 0;
            rx_data <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin 
                        state <= LOAD; 
                        busy <= 1'b1; 
                    end
                end

                LOAD: begin
                    cs_n <= 1'b0;
                    shift_reg <= tx_data;
                    bit_cnt <= 0;
                    clk_cnt <= 0;
                    state <= TRANSFER;
                end

                TRANSFER: begin
                    if (clk_cnt < (CLK_DIV-1)) begin
                        clk_cnt <= clk_cnt + 1;
                    end else begin
                        clk_cnt <= 0;
                        sclk <= ~sclk;
                        if (sclk == 1'b1) begin // Falling edge logic
                            if (bit_cnt < DATA_WIDTH) begin
                                mosi <= shift_reg[DATA_WIDTH-1];
                                shift_reg <= {shift_reg[DATA_WIDTH-2:0], 1'b0};
                                bit_cnt <= bit_cnt + 1;
                            end else begin
                                state <= DONE;
                            end
                        end
                    end
                end

                DONE: begin
                    cs_n <= 1'b1; busy <= 1'b0; done <= 1'b1; mosi <= 1'b0;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
