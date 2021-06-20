module I2C_master(clk, rst, e_bits, data_rd,SCL, SDA);
    input clk;
    inout SDA;
    output SCL;
    output reg [7:0]data_rd = 8'b00000000;
    input rst;
    input [7:0]e_bits;
    parameter slave_addr = 7'b1010101;
    reg ack_bit = 1;
    reg scl_en;
    reg sda_set = 0;
    reg [3:0]state = 0;
    reg [3:0]state_slave = 0;
    reg [3:0]count = 0, count_slave = 0;
    reg sda;
    reg [1:0]count_rx = 0;
    reg [7:0]data_wr = 8'b00000000;
    reg [7:0]bit_slave_rc = 8'b00000000;
    reg [7:0]data_tx = 8'b00000000;
    assign SCL = scl_en?~clk:1;
    assign SDA = sda_set?1'bZ:sda;
    I2C_slave s1(SDA,SCL);
    /////////////////////////////////
    always @(negedge SDA)begin
      if(~SDA & SCL)begin
        state_slave <= 0;//start
      end
    end
    always @(negedge SCL)begin
        case(state_slave)
            0:begin//start
              count_slave <= 7;
              state_slave <= 1;
            end
            1:begin
                bit_slave_rc[count_slave]<=SDA;
                if(count_slave == 0 ) begin
                    if(slave_addr[6:0] == bit_slave_rc[7:1]) begin
                        ack_bit <= 0;
                        state_slave <= 2;
                    end else begin
                        ack_bit <= 1;
                        state_slave <= 2;
                    end
                end
                else count_slave = count_slave - 1;
            end
            2:begin
                if (ack_bit == 0) begin
                        if (bit_slave_rc[0] == 0) begin
                            state_slave <= 3;
                            count_rx <= count_rx + 1;
                            ack_bit <= 1;
                            count_slave <= 7;
                        end else begin
                            state_slave <= 4;
                            count_rx <= count_rx + 1;
                            ack_bit <= 1;
                            count_slave <= 6;
                        end
                    end else begin
                      state_slave <= 6;
                    end
            end
            3:begin
              data_wr[count_slave] <=  SDA;
              if(count_slave == 0)begin
                ack_bit <= 0;
                if(count_rx == 1)begin
                  ack_bit <= 1;
                  state_slave <= 2;
                end else begin
                  ack_bit <= 1;
                  state_slave <= 2;
                end
              end else count_slave = count_slave - 1;
            end
            4:begin
              sda <= data_tx[count_slave];
              if(count_slave == 0)begin
                if(count_rx == 1)state_slave <= 7;
                else begin
                  ack_bit <= 1;
                  state_slave <= 6;
                end
              end else count_slave = count_slave - 1;
            end
            5:begin
              if(count_rx == 1) begin
                if (bit_slave_rc[0] == 0)state_slave <= 2;
                else state_slave <= 4;
              end
              else begin
                state_slave <= 6;
              end
            end
            7:begin
              ack_bit <= 0;
              state_slave <= 2;
            end
            6:begin
              count_slave <= 7;
            end
        endcase
    end
    /////////////////////////////////
    
    always@(negedge clk or posedge rst) begin
        if (rst==1)begin
            scl_en <= 0;
            sda_set <= 0;
        end else begin
            if((state == 0) || (state == 1) || (state == 9)) begin
                scl_en <= 0;
            end
            else begin
                scl_en <= 1;
            end
        end
    end
    
    always @(posedge rst or posedge clk) begin
        if(rst==1)begin
            state <= 0;
            count_rx <= 0;
            sda <= 1;
            sda_set <= 0;
        end
        else begin
            case(state)
                0:begin//idle
                    sda <= 1;
                    count_rx <= 0;
                    sda_set <= 0;
                    state <= 1;
                end
                1:begin//Start
                    sda <= 0;
                    state <= 2;
                    count <= 7;
                end
                2:begin//Write_slave_addr
                    sda <= e_bits[count];
                    if(count == 0) begin
                        state <= 3;
                    end else count = count - 1;
                end
                3:begin // ack check 
                    sda_set <= 1;
                    state <= 4;
                end
                4:begin //Ack/NAck
                    if (SDA == 0) begin
                        if (e_bits[0] == 0) begin
                            state <= 5;
                            sda_set <= 0;
                            count <= 6;
                            sda <= e_bits[7];
                        end else begin
                            state <= 6;
                            sda_set <= 1;
                            count <= 7;
                        end
                    end else begin
                      state <= 9;
                      sda_set <= 0;
                      sda <= 1;
                    end
                end
                5:begin//Write 8 bits
                    sda <= e_bits[count];
                    if(count == 0) begin
                        state <= 3;
                    end else count = count - 1;
                end
                6:begin//Read 8 bits
                    data_rd[count] <= SDA;
                    if(count == 0) begin
                        state <= 4;
                    end else count = count - 1;
                end
                7:begin
                  state <= 8;
                  sda_set <= 1;
                end
                8:begin
                    if (SDA == 0) begin
                        sda_set <= 0;
                        state <= 4;
                    end else begin
                        sda_set <= 0;
                        state <= 9;
                    end
                end
                9:begin
                    sda <= 1;
                    state <= 0;
                end
            endcase
        end
    end
endmodule
