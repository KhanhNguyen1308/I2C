module xung( CLOCK_50,clk,rs, sl);
input CLOCK_50,rs;
input [1:0]sl;
output clk;
reg clk= 1'b0;
integer q=0;
always @(posedge CLOCK_50 or posedge rs) 
begin
if (rs==0) 
	 begin
	    q <=0;
	 end
else //////bat dau chia 
	begin
	  if(sl == 2'b00)
	    begin
	       q<=q+1;
	       if(q==50)
	       begin
	        q<=0;
	        clk <= ~clk;
	       end
	    end
	  else if(sl == 2'b01)
	    begin
	      q<=q+1;
	       if(q==100)
	       begin
	        q<=0;
	        clk <= ~clk;
	       end
	    end 
	   else if(sl == 2'b10)
	    begin
	      q<=q+1;
	       if(q==5)
	       begin
	        q<=0;
	        clk <= ~clk;
	       end
	    end 
	end 
end
endmodule
