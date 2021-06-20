module I2C_slave(SDA, SCL, data_wr);
    inout SDA;
    input SCL;
    output reg [7:0]data_wr = 8'b00000000;
    reg sda_set = 0;
    reg sda;
    reg ack_bit;
    reg [1:0]count_rx = 0;
    reg [3:0]count_slave;
    reg [3:0]state_slave;
    reg [7:0]bit_slave_rc;
    assign SDA = sda_set?sda:1'bZ;
    parameter slave_addr = 7'b1010101;
    parameter data_tx = 8'b11010101;
    always @(negedge SDA)begin
      if(~SDA & SCL)begin
        sda_set <= 0;
        state_slave <= 0;
        count_slave <= 8;
      end
    end
    always @(negedge SCL)begin
        case(state_slave)
            0:begin//start
              sda_set <= 0;
              count_slave <= 7;
              state_slave <= 1;
            end
            1:begin
                bit_slave_rc[count_slave]<=SDA;
                if(count_slave == 0 ) begin
                    if(slave_addr[6:0] == bit_slave_rc[7:1]) begin
                        sda_set <= 1;
                        sda <= 0;
                        ack_bit <= 0;
                        state_slave <= 2;
                    end else begin
                        sda_set <= 1;
                        sda <= 1;
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
                            sda_set <= 0;
                            ack_bit <= 1;
                            count_slave <= 7;
                        end else begin
                            state_slave <= 4;
                            count_rx <= count_rx + 1;
                            sda_set <= 1;
                            ack_bit <= 1;
                            sda <= data_tx[7];
                            count_slave <= 6;
                        end
                    end 
                    else begin
                      sda_set <= 0;
                      state_slave <= 6;
                    end
            end
            3:begin
              data_wr[count_slave] <=  SDA; //Write 8 bits
              if(count_slave == 0)begin
                ack_bit <= 0;
                sda_set <= 1;
                if(count_rx == 1)sda<= 0;
                else sda <= 1;
                state_slave <= 2;
              end else count_slave = count_slave - 1;
            end
            4:begin //Read 8 bits
              sda <= data_tx[count_slave];
              if(count_slave == 0)begin
                if(count_rx == 1)ack_bit <= 0;
                else ack_bit <= 1;
                state_slave <= 7;
              end else count_slave = count_slave - 1;
            end
            5:begin
              sda_set <= 0;
              if(count_rx == 1) begin
                sda_set <= 0;
                state_slave <= 2;
              end
              else begin
                state_slave <= 6;
              end
            end
            7:begin
              if(ack_bit == 0) sda <= 0;
              else sda <= 1;
              state_slave <= 2;
            end
            6:begin
              sda_set <= 0;
              count_slave <= 7;
            end
        endcase
    end
endmodule
