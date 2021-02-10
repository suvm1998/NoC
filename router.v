module router(input[15:0] north, south, east, west, center,
	      input n_empty, s_empty,e_empty,w_empty, c_empty,n_full,s_full,e_full, w_full, c_full,clk,rst ,
	      output[15:0] north_out, south_out, east_out, west_out, center_out,
	      output north_write, south_write, east_write, west_write, center_write,
	      output north_read, south_read,east_read,west_read, center_read);
	
	parameter S0 = 3'd0, S1 = 3'd1, S2 = 3'd2, S3= 3'd3, S4= 3'd4;
	parameter r_addr= 4'b0011;
	reg[2:0] prev,current, next;
	reg[2:0] inputFrom,outputTo;
	reg[15:0] flit;
	reg[2:0] channel_occupancy[4:0];
	reg[15:0] nout, sout, eout, wout, cout;
	reg n_write, s_write, e_write, w_write, c_write, n_read, s_read, e_read, w_read, c_read;
	assign north_read=n_read;
	assign south_read=s_read;
	assign east_read=e_read;
	assign west_read=w_read;
	assign center_read = c_read;
	assign north_write=n_write;
	assign south_write=s_write;
	assign east_write=e_write;
	assign west_write=w_write;
	assign center_write=c_write;
	assign north_out = nout;
	assign south_out = sout;
	assign east_out = eout;
	assign west_out = wout;
	assign center_out = cout;
	always@(posedge clk or rst) begin 
		if(rst) begin 
			current<=S0;next<=S1;
			channel_occupancy[4]<=3'bxxx;
			channel_occupancy[3]<=3'bxxx;
			channel_occupancy[2]<=3'bxxx;
			channel_occupancy[1]<=3'bxxx;
			channel_occupancy[0]<=3'bxxx;
			end
		else begin//5 input multiplexing
		//Check if channel is allocated or not. If yes->do not read. If no->read.
		case (current)
			S0: begin 
				if((~n_empty)) begin
				
				flit<=north;
				prev<=current;
				current<=next;
				next<=S1;
				end
			end
			S1: begin 
				if((~s_empty)) begin
				flit<=south;
				prev<=current;
				current<=next;
				next<=S2;
				end
			end
			S2:begin 
				if((~e_empty)) begin
				flit<=east;
				prev<=current;
				current<=next;
				next<=S3;
				end
			end
			S3:begin 
				if((~w_empty)) begin
				flit<=west;
				prev<=current;
				current<=next;
				next<=S4;
				end
			end
			S4:begin 
				if((~c_empty)) begin
				flit<=center;
				prev<=current;
				current<=next;
				next<=S1;
				end
			end
			default:begin 
				current<=S0;next<=S1;
				end
			endcase
		end
	end	
	always@(posedge clk) begin
	//Identify Head and configure the channel
		if(flit[15:14]==2'b11) begin
			//flit[13:10]->Destination Address
			//Using X Y routing
			if(flit[13:12]==r_addr[3:2]) begin
				if(channel_occupancy[prev]==3'bxxx)begin//If channel is not free or any buffer is filled to limit , The value is not sampled from buffer
					if((flit[11:10]>r_addr[1:0])&(~w_full))begin
						case(prev)
							S0: begin s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b1;end
							S1: begin e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b1;end
							S2: begin w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b1;end
							S3: begin c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b1;end
							S4: begin n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b1;end
						endcase
						w_write<=1'b1;
						wout<=flit;
						
						channel_occupancy[prev]<=3'b011;
					end else if((flit[11:10]<r_addr[1:0])&(~e_full))begin
						case(prev)
							S0: begin s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b1;end
							S1: begin e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b1;end
							S2: begin w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b1;end
							S3: begin c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b1;end
							S4: begin n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b1;end
						endcase
						e_write<=1'b1;
						eout<=flit;
						channel_occupancy[prev]<=3'b010;
					end else if ((channel_occupancy[prev]==3'bxxx)&(~c_full)) begin 
						case(prev)
							S0: begin s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b1;end
							S1: begin e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b1;end
							S2: begin w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b1;end
							S3: begin c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b1;end
							S4: begin n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b1;end
						endcase
						c_write<=1'b1;
						cout<=flit;
						channel_occupancy[prev]<=3'b100;
					end	
				end else if(flit[13:12]!=r_addr[3:2]) begin//Will Go Up or Down
					if((flit[13:12]>r_addr[3:2])&(~s_full))begin
						case(prev)
							S0: begin s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b1;end
							S1: begin e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b1;end
							S2: begin w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b1;end
							S3: begin c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b1;end
							S4: begin n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b1;end
						endcase
						s_write<=1'b1;
						channel_occupancy[prev]<=3'b001;
						sout<=flit;
					end else if(~n_full)begin
						case(prev)
							S0: begin s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b1;end
							S1: begin e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b1;end
							S2: begin w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b1;end
							S3: begin c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b1;end
							S4: begin n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b1;end
						endcase
						n_write<=1'b1;
						channel_occupancy[prev]<=3'b000;
						nout<=flit;
					end
				end
			end
		end 
	end
	always@(posedge clk) begin
	if(flit[15:14]==2'b01) begin//Body Flit 
			case (channel_occupancy[prev]) 
				3'b000: begin if(~n_full) begin
					case(prev)
							S0: begin s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b1;end
							S1: begin e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b1;end
							S2: begin w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b1;end
							S3: begin c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b1;end
							S4: begin n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b1;end
					endcase
					n_write<=1'b1;
					nout<=flit; end
				end
				3'b001: begin if(~s_full) begin
					case(prev)
							S0: begin s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b1;end
							S1: begin e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b1;end
							S2: begin w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b1;end
							S3: begin c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b1;end
							S4: begin n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b1;end
					endcase
					s_write<=1'b1;
					sout<=flit;end
				end
				3'b010: begin if(~e_full) begin
					case(prev)
							S0: begin s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b1;end
							S1: begin e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b1;end
							S2: begin w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b1;end
							S3: begin c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b1;end
							S4: begin n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b1;end
					endcase
					e_write<=1'b1;
					eout<=flit;end
				end
				3'b011: begin if(~w_full) begin
					case(prev)
							S0: begin s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b1;end
							S1: begin e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b1;end
							S2: begin w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b1;end
							S3: begin c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b1;end
							S4: begin n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b1;end
					endcase
					w_write<=1'b1;
					wout<=flit;end
				end
				3'b100: begin if(~c_full) begin
					case(prev)
							S0: begin s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b1;end
							S1: begin e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b1;end
							S2: begin w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b1;end
							S3: begin c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b1;end
							S4: begin n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b1;end
					endcase
					c_write<=1'b1;
					cout<=flit;end
				end
			endcase
		end 
	end
	always@(posedge clk) begin
		if(flit[15:14]==2'b10) begin//Tail Flit
			case (channel_occupancy[prev]) 
				3'b000: begin
					case(prev)
							S0: begin s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b1;end
							S1: begin e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b1;end
							S2: begin w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b1;end
							S3: begin c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b1;end
							S4: begin n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b1;end
					endcase
					n_write<=1'b1;
					nout<=flit;
					channel_occupancy[prev]<=3'bxxx;
				end
				3'b001: begin
					case(prev)
							S0: begin s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b1;end
							S1: begin e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b1;end
							S2: begin w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b1;end
							S3: begin c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b1;end
							S4: begin n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b1;end
					endcase
					s_write<=1'b1;
					sout<=flit;
					channel_occupancy[prev]<=3'bxxx;
				end
				3'b010: begin
					case(prev)
							S0: begin s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b1;end
							S1: begin e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b1;end
							S2: begin w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b1;end
							S3: begin c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b1;end
							S4: begin n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b1;end
					endcase
					e_write<=1'b1;
					eout<=flit;
					channel_occupancy[prev]<=3'bxxx;
				end
				3'b011: begin
					case(prev)
							S0: begin s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b1;end
							S1: begin e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b1;end
							S2: begin w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b1;end
							S3: begin c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b1;end
							S4: begin n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b1;end
					endcase
					w_write<=1'b1;
					wout<=flit;
					channel_occupancy[prev]<=3'bxxx;
				end
				3'b100: begin
					case(prev)
							S0: begin s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b1;end
							S1: begin e_read<=1'b0;w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b1;end
							S2: begin w_read<=1'b0;c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b1;end
							S3: begin c_read<=1'b0;n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b1;end
							S4: begin n_read<=1'b0;s_read<=1'b0;e_read<=1'b0;w_read<=1'b0;c_read<=1'b1;end
					endcase
					c_write<=1'b1;
					cout<=flit;
					channel_occupancy[prev]<=3'bxxx;
				end
			endcase
		end
	end	

	end
endmodule
