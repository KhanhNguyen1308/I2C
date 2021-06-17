module I2C_slave_test(SDA, SCL);
    inout SDA;
    input SCL;
    reg sda_set = 0, sda;
    assign SDA = sda_set?sda:1'bZ;
    reg ack_bit;
    reg rd_wr_bit;
    reg [7:0]data_rx;
    parameter slave_addr = 7'b1010101;
    parameter data_tx = 8'b11010101;
    reg [3:0]count_slave;
    reg [3:0]state_slave;
    reg [7:0]bit_slave_rc;
    always @(negedge SDA)begin
      if(~SDA & SCL)begin
        sda_set = 0;
        state_slave <= 0;
        count_slave <= 8;
      end
    end
    always @(negedge SCL)begin
        case(state_slave)
            10:begin
              sda_set <= 0;
            end
            0:begin
                bit_slave_rc[count_slave]<=SDA;
                if(count_slave == 0 ) begin
                    
                    state_slave <= 8;
                    if(slave_addr[6:0] == bit_slave_rc[7:1]) begin
                        sda_set <= 1;
                        sda <= 0;
                        ack_bit <= 0;
                        state_slave <= 8;
                    end else begin
                        sda_set <= 1;
                        sda <= 1;
                        ack_bit <= 1;
                        state_slave <= 8;
                    end
                end
                else count_slave = count_slave - 1;
            end
            8:begin
                if (ack_bit == 0) begin
                        if (bit_slave_rc[0] == 0) begin
                            state_slave <= 1;
                            sda_set <= 0;
                            count_slave <= 7;
                        end else if (bit_slave_rc[0] == 1) begin
                            state_slave <= 2;
                            sda_set <= 1;
                            count_slave <= 7;
                        end
                    end 
                    else state_slave <= 10;
            end
            1:begin
              data_rx[count_slave] <=  SDA;
              if(count_slave == 0)begin
                ack_bit <= 0;
                sda_set <= 1;
                sda<= 0;
                state_slave <= 3;
              end else count_slave = count_slave - 1;
            end
            2:begin
              sda <= data_tx[count_slave];
              if(count_slave == 0)begin
                ack_bit <= 0;
                state_slave <= 4;
              end else count_slave = count_slave - 1;
            end
            3:begin
              sda_set <= 0;
              state_slave <= 9;
            end
            4:begin
            end
            9:begin
              state_slave <= 10;
            end
        endcase
    end
endmodule
