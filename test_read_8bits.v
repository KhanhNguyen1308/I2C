module test_I2C_read_8bits();
  reg [7:0]e_bits;
  wire SDA;
  wire SCL;
  wire clk;
  wire [7:0]data_wr;
  wire [7:0]data_rd;
  reg rst;
  reg CLOCK_50;
  reg [1:0]sl;
  initial begin
    e_bits = 8'b10101011;
    rst = 1;
    sl = 2'b00;
    CLOCK_50 = 1;
    #100 rst = 0;
  end
  always begin
    #50 CLOCK_50 = ~CLOCK_50;
  end
  xung x1(.CLOCK_50(CLOCK_50), .clk(clk), .rst(rst), .sl(sl));
  I2C_master m1(.clk(clk), .rst(rst), .e_bits(e_bits), .data_rd(data_rd), .SCL(SCL), .SDA(SDA));
  I2C_slave s1(.SDA(SDA), .SCL(SCL), .data_wr(data_wr));
endmodule
  