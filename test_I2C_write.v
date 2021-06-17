module test_I2C_write();
  reg [7:0]e_bits;
  wire SDA;
  wire SCL;
  wire clk;
  reg rst;
  reg CLOCK_50;
  reg [1:0]sl;
  initial begin
    e_bits = 8'b10101010;
    rst = 1;
    sl = 2'b00;
    CLOCK_50 = 1;
    #100 rst = 0;
  end
  always begin
    #50 CLOCK_50 = ~CLOCK_50;
  end
  clock x1(.CLOCK_50(CLOCK_50), .clk(clk), .rst(rst), .sl(sl));
  I2C_master m1(.clk(clk), .rst(rst), .e_bits(e_bits), .SCL(SCL), .SDA(SDA));
  I2C_slave s1(.SDA(SDA), .SCL(SCL));
endmodule
  
