module bits (clock, reset, pushin, datain, reqin, reqlen, pushout, lenout, dataout);

	input clock, reset;
	input pushin;
	input [INWIDTH-1:0] datain;
	input reqin;
	input [OUTADDRESSWIDTH-1:0] reqlen;
	output pushout;
	output [OUTADDRESSWIDTH-1:0] lenout;
	output [OUTWIDTH-1:0] dataout;

	parameter INWIDTH = 32;
	parameter OUTWIDTH = 15;
	parameter OUTADDRESSWIDTH = 4;

	reg fifofull;
	reg [INWIDTH-1:0] dataInput;
	reg pushout;

	fifo mainFIFO(clock, reset, dataInput, pushin, pushout, dataout, fifofull);

	always@(posedge clock)
	begin
		if(pushin)
		begin
			dataInput = datain;
		end
	end

	always@(posedge clock)
	begin
		pushout <= 0;
	end



endmodule

///////////////////
//FIFO Contoller //
///////////////////
module fifo(clock, reset, inData, new_data, out_data, outData, full);
	
	input clock, reset;
	input [WIDTH-1:0] inData;
	input new_data;
	input out_data;

	parameter WIDTH = 32;
	parameter DEPTH = 32;
	parameter ADDRESSWIDTH = 5;

	integer k;

	output [WIDTH-1:0] outData;
	output full;

	reg full;
	wire fullD;

	reg [ADDRESSWIDTH-1:0] rear;
	reg [ADDRESSWIDTH-1:0] front;

	//Rear Pointer Holder Flops
	always@(posedge clock)
	begin
		if(!reset) rear <= 0;
		else if (new_data)
		begin
			if(rear == DEPTH) rear <= 0;
			else rear <= rear + 1;
		end
	end

	//Front Pointer Holder Flops
	always@(posedge clock)
	begin
		if(!reset) front <= 0;
		else if(out_data)
		begin
			if(front == DEPTH) front <= 0;
			else front <= front + 1;
		end
	end

	//Full Signal Flop
	always@(posedge clock)
	begin
		if(!reset) full <= 0;
		else full <= fullD;
	end

	assign fullD = (front == ((rear == DEPTH) ? 0: (rear + 1)));

	regfile u1(clock, reset, new_data, rear, front, inData, outData);

endmodule



///////////////////////////////////
//Memory array for use with FIFO //
///////////////////////////////////
module regfile(clock, reset, writeEnable, dest, source, dataIn, dataOut);
	
	parameter WIDTH = 32;
	parameter DEPTH = 32;
	parameter ADDRESSWIDTH = 5;
	integer i,j;

	input clock, reset, writeEnable;
	input [ADDRESSWIDTH-1 : 0] dest; 
	input [ADDRESSWIDTH-1 : 0] source; 
	input [WIDTH-1 : 0] dataIn; 
	output [WIDTH-1 : 0] dataOut;

	reg [WIDTH-1 : 0] dataOut; // registered output
	reg [WIDTH-1 : 0] rf [DEPTH-1 : 0]; 
	wire [DEPTH-1 : 0] writeEnableDecoded;

	assign writeEnableDecoded = (writeEnable << dest);

	// flip-flop for data-out 
	always@(posedge clock)
		begin
			if(!reset) dataOut <= 0;
			else dataOut <= rf[source]; 
		end

	//memory array
	always@(posedge clock)
	begin
		if(!reset)
		begin
			for(i = 0; i<DEPTH; i = i+1)
				rf[i] <= 0;
		end 
		else
		begin
			for(j = 0; j<DEPTH; j = j+1)
				if(writeEnableDecoded[j]) rf[j] <= dataIn;
		end
	end



endmodule