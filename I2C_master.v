module I2C_master(clk, rst, e_bits, SCL, SDA);
    input clk;
    inout SDA;
    output SCL;
    input rst;
    input [7:0]e_bits;
    parameter slave_addr = 7'b1010101;
    reg ack_bit = 1;
    reg scl_en;
    reg sda_set = 0;
    reg [3:0]state;
    reg [3:0]state_slave;
    reg [3:0]count, count_slave = 3'b000;
    reg sda;
    reg rc_bit;
    reg [7:0]bit_slave_rc = 8'b00000000;
    reg [7:0]data_rx = 8'b00000000;
    reg [7:0]data_tx = 8'b00000000;
    assign SCL = scl_en?~clk:1;
    assign SDA = sda_set?1'bZ:sda;
    /////////////////////////////////
    always @(negedge SDA)begin
      if(~SDA & SCL)begin
        state_slave <= 0;
        count_slave <= 8;
      end
    end
    always @(negedge SCL)begin
        case(state_slave)
            10:begin
              sda_set <= 1;
            end
            0:begin
                bit_slave_rc[count_slave]<=SDA;
                if(count_slave == 0 ) begin
                    state_slave <= 8;
                    if(slave_addr[6:0] == bit_slave_rc[7:1]) begin
                        ack_bit <= 0;
                        state_slave <= 8;
                    end else begin
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
                            ack_bit <= 1;
                            count_slave <= 7;
                        end else if (bit_slave_rc[0] == 1) begin
                            ack_bit <= 1;
                            state_slave <= 2;
                            count_slave <= 7;
                        end
                    end 
                    else state_slave <= 0;
            end
            1:begin
              data_tx[count_slave] <= SDA;
              if(count_slave == 0)begin
                ack_bit <= 0;
                state_slave <= 3;
              end else count_slave = count_slave - 1;
            end
            2:begin
              if(count_slave == 0)begin
                ack_bit <= 0;
                state_slave <= 4;
              end else count_slave = count_slave - 1;
            end
            3:begin
              ack_bit <= 1;
              state_slave <= 9;
            end
            4:begin
            end
            9:begin
              state_slave <= 10;
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
            sda <= 1;
            sda_set <= 0;
        end
        else begin
            case(state)
                0:begin//idle
                    sda <= 1;
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
                        rc_bit <= SDA;
                        state <= 3;
                    end else count = count - 1;
                end
                3:begin // ack check 
                    sda_set <= 1;
                    state <= 10;
                end
                10:begin
                    if (SDA == 0) begin
                        if (e_bits[0] == 0) begin
                            state <= 4;
                            sda_set <= 0;
                            count <= 7;
                        end else begin
                            state <= 5;
                            sda_set <= 1;
                            count <= 7;
                        end
                    end else state <= 0;
                end
                4:begin//Write 8 bits
                    sda <= e_bits[count];
                    if(count == 0) begin
                        sda_set <= 1;
                        state <= 7;
                    end else count = count - 1;
                end
                5:begin//Read 8 bits
                    data_rx[count] <= SDA;
                    if(count > 0) begin
                        sda_set <= 0;
                        state <= 7;
                    end else count = count - 1;
                end
                7:begin
                    if (SDA == 0) begin
                        sda_set <= 0;
                        state <= 9;
                    end else begin
                        state <= 0;
                    end
                end
                8:begin
                    sda <= 0;
                    state <= 9;
                end
                9:begin
                    sda <= 1;
                    state <= 0;
                end
            endcase
        end
    end
endmodule
