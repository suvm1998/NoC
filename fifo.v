module fifo( input[15:0] data,input clk,rst,read, write, output[5:0] out, output full, empty);
	reg[15:0] memory[3:0];
	reg[1:0] rdptr, wrptr, test ;
	reg full_status;
	reg empty_status;
	reg[15:0] outp;
	wire eqlptr, testptr;
	assign eqlptr = (rdptr-wrptr) ?1:0;
	assign testptr = (rdptr-test) ?1:0;
	assign full = full_status;
	assign empty = empty_status;
	assign out = outp;
	//read Pointer
	always@(posedge clk or rst) begin
	if(rst) rdptr<=2'b00;
	else begin
		if(read)rdptr<=rdptr+2'b01;
		else rdptr<=rdptr;
		end
	end
	//Write Pointer
	always@(posedge clk or rst) begin
		if(rst) wrptr<=2'b00;
		else begin
			if(write) wrptr<=wrptr+2'b01;
			else wrptr<=wrptr;
		end
	end
	//Status Signals
	always@(posedge clk or rst) begin
		if(rst) begin 
			full_status<=1'b0;
			empty_status<=1'b1;
		end
		else begin
			test<= wrptr+2'b01;
			if((rdptr & test)) full_status<=1'b1;
			else full_status<=1'b0;
			if(eqlptr) empty_status<=1'b1;
			else empty_status<=1'b0;
		end
	end
	always@(posedge clk) begin
		if(read && ~full_status) begin 
			memory[wrptr[3:0]]<=data;
		end
	 outp <= memory[rdptr[1:0]];
	end
		
endmodule
		
		
	
		
			
