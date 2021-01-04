// VerilogA for CiM_65, inputDRAM_ctrl_wDAC, veriloga

`include "constants.vams"
`include "disciplines.vams"

module inputDRAM_ctrl_wDAC_wrefresh_3p3V(start, CLK, ADDR, WR_IO, WR_IO_bar, WE,DRAM_EN, DEC_EN, refresh_finish, start_refresh, requestDatafromDAC, start_DAC, LSB_in, MSB_in, requestData_fromMAV, ADC_finish, release_Va);
input start; electrical start; //1: write; 0: read 
input CLK; electrical CLK;
output [3:0] ADDR; electrical [3:0] ADDR; integer vADDR[3:0];
output [127:0] WR_IO; electrical [127:0] WR_IO; real vWR_IO[127:0];
output [127:0] WR_IO_bar; electrical [127:0] WR_IO_bar; real vWR_IO_bar[127:0];
output WE,DRAM_EN, DEC_EN; electrical WE,DRAM_EN, DEC_EN; real vWE, vDRAM_EN, vDEC_EN;
//output EQ; electrical EQ; real vEQ;
output start_refresh; electrical start_refresh; real vstart_refresh;
input refresh_finish; electrical refresh_finish;
input requestDatafromDAC; electrical requestDatafromDAC;
output start_DAC; electrical start_DAC; real vstart_DAC;
input LSB_in, MSB_in; electrical LSB_in, MSB_in;
input requestData_fromMAV; electrical requestData_fromMAV;
input ADC_finish; electrical ADC_finish;
input release_Va; electrical release_Va;

parameter real vdd =1.2;
parameter real vdd_pad = 3.3;
parameter real rtime=10p;
parameter integer max_row = 16;
parameter integer max_col = 128;
parameter integer ADDR_count = 4;
parameter integer half_array = 8;

parameter integer IDLE = 0;
parameter integer WRITE = 1;
parameter integer RESET = 2;
parameter integer READ = 3;
parameter integer REFRESH = 4;
parameter integer END_OF_WRITE = 5;
parameter integer END_OF_READ = 6;
parameter integer WAIT = 7;

//Refresh
parameter integer max_refreshCounter = 10000;

integer RowValue[max_col-1:0];
integer currentState, nextState;
integer thisRowValue;
integer row_count;
integer i;
integer row_value_count;
integer finishWrite;
integer j;
integer thisRow;
integer refreshCounter;
integer refreshStopThisState;
integer start_refresh_isAsserted;
integer haveRecordRequestData;
integer start_DAC_counter;

analog begin
	@(initial_step) begin
		row_count = 0;
		row_value_count = 2;
		for(i = 0; i<max_col; i=i+1) begin
			vWR_IO[i] = 0;
			vWR_IO_bar[i] = 0;
		
		end
		for(i = 0; i<ADDR_count; i=i+1) begin
			vADDR[i] = 0;
		end
		RowValue[0] = V(LSB_in);
		RowValue[1] = V(MSB_in);
		RowValue[2] = V(LSB_in);
		RowValue[3] = V(MSB_in);
		RowValue[4] = 4+5*16+V(MSB_in)*256+V(MSB_in)*4096+V(MSB_in)*65536+V(MSB_in)*1048576+V(MSB_in)*16777216;
		RowValue[5] = 0+0*16+V(MSB_in)*256+V(MSB_in)*4096+V(MSB_in)*65536+V(MSB_in)*1048576+V(MSB_in)*16777216;
		RowValue[6] = 6+7*16+V(MSB_in)*256+V(MSB_in)*4096+V(MSB_in)*65536+V(MSB_in)*1048576+V(MSB_in)*16777216;
		RowValue[7] = 0+0*16+V(MSB_in)*256+V(MSB_in)*4096+V(MSB_in)*65536+V(MSB_in)*1048576+V(MSB_in)*16777216;

		for(i = 8; i<max_row; i=i+1) begin
			RowValue[i] = row_value_count+13*16+15*128;
			//assign 1 2 3 4 5 6 7 8 as row value for each row -- for test purpose
			row_value_count = row_value_count+3;
		end
		vWE = 0;
		vDRAM_EN = 0;
		vDEC_EN = 0;
		//vEQ = 1;
		refreshCounter = 0;	
		start_DAC_counter = 0;
	end

//define counter	
	@(cross(V(CLK) - 0.5, -1)) begin
		refreshCounter = refreshCounter + 1;
		//if(vstart_refresh == 1) vstart_refresh = 0;
	end

//Reset WL
	@(cross(V(CLK) - 0.5, -1)) begin
		refreshCounter = refreshCounter + 1;
		//if(vstart_refresh == 1) vstart_refresh = 0;
	end

	@(cross(V(CLK) - 0.5, -1)) begin
		case(currentState)
		WRITE: begin
			vDEC_EN = 0;
		end
		//READ: begin
		//	vDEC_EN = 0;
		//end
		WAIT: begin
		if ( nextState == RESET) begin vDEC_EN = 0; end
		end
		endcase

	end

	@(cross(V(CLK) - 0.5, +1)) begin
		currentState = nextState;
		case(currentState)
		IDLE: begin
			for(i = 0; i<max_col; i=i+1) begin
				vWR_IO[i] = 0;
				vWR_IO_bar[i] = 0;
			end
			if(V(start) > 0.5) begin
				//$strobe("EQ = %g", vEQ);
				//vEQ = 0;	
				nextState = WRITE;
			//	vWE = 1;
			//	vDRAM_EN = 1;
			//	vDEC_EN = 1;
				$strobe("idle idle dile dile");
			end
			else nextState = IDLE;
			vWE = 0;
			vDRAM_EN = 0;
			vDEC_EN = 0;
			//vEQ = 1;	
			vstart_refresh = 0;
			vstart_DAC = 0;
			haveRecordRequestData = 0;
			start_DAC_counter = 0;
		end
		WRITE: begin
			vstart_DAC = 0;
			vstart_refresh = 0;
				$strobe("write write write write");
		//	$strobe("row count = %g", row_count);
			vWE = 1;
			vDRAM_EN = 1;
			vDEC_EN = 1;
			//vEQ = 0;	
			thisRowValue = RowValue[row_count];

			thisRow = row_count;
			$strobe("thisRowValue = %g", thisRowValue);
			//generate address
			for(j=0; j<ADDR_count; j=j+1) begin

				vADDR[j] = thisRow%2;
				thisRow = thisRow/2;
		//		$strobe("address %g = %g", j, vADDR[j]);
			end
			//prepare IO data port for write
			for(i = 0; i<max_col; i=i+1) begin	 //i = col
					vWR_IO[i] = thisRowValue % 2;
					if(	vWR_IO[i] == 1) vWR_IO_bar[i] = 0;
					else vWR_IO_bar[i] = 1;
				thisRowValue = thisRowValue/2;
			end	

			if(row_count == max_row-1) begin //reach the last row
				row_count = 0; //reset row count
				if(refreshCounter > max_refreshCounter) begin nextState = REFRESH;	refreshStopThisState = END_OF_WRITE; end
				else nextState = RESET;

			end
			else begin 
				row_count=row_count+1; 
				if(refreshCounter > max_refreshCounter) begin nextState = REFRESH;	refreshStopThisState = WRITE; end
				else nextState = WRITE; 		
			end
		//	end	
		end


		REFRESH: begin
			vWE = 0;
			vDRAM_EN = 0;
			vDEC_EN = 0;
			if(start_refresh_isAsserted == 0) begin vstart_refresh = 1; start_refresh_isAsserted = 1; end
			else vstart_refresh = 0;
			refreshCounter = 0;
			if(V(refresh_finish) > 0.5) 
			begin
				start_refresh_isAsserted = 0;
				if(refreshStopThisState == END_OF_WRITE) nextState = RESET; 
				else if(refreshStopThisState == END_OF_READ) nextState = IDLE;
				else nextState = refreshStopThisState;
			end
		    else nextState = REFRESH;
		end


		RESET: begin
		//	haveRecordRequestData = 0;
			vstart_DAC = 0;
			vstart_refresh = 0;
			vWE = 0;
			vDRAM_EN=0;
			vDEC_EN = 0;
			nextState = READ;
		end

		READ: begin
			//haveRecordRequestData = 0;
			start_DAC_counter = 0;
			vstart_DAC = 0;
			$strobe("read read read");
			//vEQ = 0;	
			vWE = 0;
			vDRAM_EN = 1;
			vDEC_EN = 1;
			//$strobe("row count = %g", row_count);
			thisRow = row_count;

			for(j=0; j<ADDR_count; j=j+1) begin
				vADDR[j] = thisRow%2;
				thisRow = thisRow/2;
		//		$strobe("address %g = %g", j, vADDR[j]);
			end
		
			nextState = WAIT; 		 

		end
		WAIT: begin
			if(start_DAC_counter<2) begin vstart_DAC = 1; start_DAC_counter = start_DAC_counter +1; end
			else vstart_DAC = 0;
			if(row_count == max_row-1) begin //reach the last row
				if (V(release_Va) > 0.5) begin nextState = RESET; row_count = 0; end
				else begin nextState = WAIT; row_count = row_count; end
				
			end
			else begin 
				if(V(requestDatafromDAC) > 0.5 && haveRecordRequestData == 0) begin haveRecordRequestData = 1; row_count=row_count+1; nextState = RESET; end
				else if (V(requestData_fromMAV) > 0.5) begin row_count=row_count+1; nextState = RESET; end
				else begin row_count = row_count; nextState = WAIT; end
				 		 
			end
			if(V(ADC_finish) > 0.5) begin nextState = IDLE; end
		end
		endcase
		
	end
	@(cross(V(requestDatafromDAC) - 0.5, -1)) begin
	haveRecordRequestData = 0;
	end

//	V(EQ) <+ transition(vEQ,0,rtime);
	V(ADDR[0]) <+ transition(vADDR[0],0,rtime)*vdd_pad;
	V(ADDR[1]) <+ transition(vADDR[1],0,rtime)*vdd_pad;
	V(ADDR[2]) <+ transition(vADDR[2],0,rtime)*vdd_pad;
	V(ADDR[3]) <+ transition(vADDR[3],0,rtime)*vdd_pad;

	V(start_refresh) <+ transition(vstart_refresh,0,rtime)*vdd_pad;
	V(start_DAC) <+ transition(vstart_DAC,0,rtime)*vdd_pad;


V(WR_IO[0]) <+ transition(vWR_IO[0],0,rtime)*vdd;
V(WR_IO[1]) <+ transition(vWR_IO[1],0,rtime)*vdd;
V(WR_IO[2]) <+ transition(vWR_IO[2],0,rtime)*vdd;
V(WR_IO[3]) <+ transition(vWR_IO[3],0,rtime)*vdd;
V(WR_IO[4]) <+ transition(vWR_IO[4],0,rtime)*vdd;
V(WR_IO[5]) <+ transition(vWR_IO[5],0,rtime)*vdd;
V(WR_IO[6]) <+ transition(vWR_IO[6],0,rtime)*vdd;
V(WR_IO[7]) <+ transition(vWR_IO[7],0,rtime)*vdd;
V(WR_IO[8]) <+ transition(vWR_IO[8],0,rtime)*vdd;
V(WR_IO[9]) <+ transition(vWR_IO[9],0,rtime)*vdd;

V(WR_IO[10]) <+ transition(vWR_IO[10],0,rtime)*vdd;
V(WR_IO[11]) <+ transition(vWR_IO[11],0,rtime)*vdd;
V(WR_IO[12]) <+ transition(vWR_IO[12],0,rtime)*vdd;
V(WR_IO[13]) <+ transition(vWR_IO[13],0,rtime)*vdd;
V(WR_IO[14]) <+ transition(vWR_IO[14],0,rtime)*vdd;
V(WR_IO[15]) <+ transition(vWR_IO[15],0,rtime)*vdd;
V(WR_IO[16]) <+ transition(vWR_IO[16],0,rtime)*vdd;
V(WR_IO[17]) <+ transition(vWR_IO[17],0,rtime)*vdd;
V(WR_IO[18]) <+ transition(vWR_IO[18],0,rtime)*vdd;
V(WR_IO[19]) <+ transition(vWR_IO[19],0,rtime)*vdd;

V(WR_IO[20]) <+ transition(vWR_IO[20],0,rtime)*vdd;
V(WR_IO[21]) <+ transition(vWR_IO[21],0,rtime)*vdd;
V(WR_IO[22]) <+ transition(vWR_IO[22],0,rtime)*vdd;
V(WR_IO[23]) <+ transition(vWR_IO[23],0,rtime)*vdd;
V(WR_IO[24]) <+ transition(vWR_IO[24],0,rtime)*vdd;
V(WR_IO[25]) <+ transition(vWR_IO[25],0,rtime)*vdd;
V(WR_IO[26]) <+ transition(vWR_IO[26],0,rtime)*vdd;
V(WR_IO[27]) <+ transition(vWR_IO[27],0,rtime)*vdd;
V(WR_IO[28]) <+ transition(vWR_IO[28],0,rtime)*vdd;
V(WR_IO[29]) <+ transition(vWR_IO[29],0,rtime)*vdd;

V(WR_IO[30]) <+ transition(vWR_IO[30],0,rtime)*vdd;
V(WR_IO[31]) <+ transition(vWR_IO[31],0,rtime)*vdd;
V(WR_IO[32]) <+ transition(vWR_IO[32],0,rtime)*vdd;
V(WR_IO[33]) <+ transition(vWR_IO[33],0,rtime)*vdd;
V(WR_IO[34]) <+ transition(vWR_IO[34],0,rtime)*vdd;
V(WR_IO[35]) <+ transition(vWR_IO[35],0,rtime)*vdd;
V(WR_IO[36]) <+ transition(vWR_IO[36],0,rtime)*vdd;
V(WR_IO[37]) <+ transition(vWR_IO[37],0,rtime)*vdd;
V(WR_IO[38]) <+ transition(vWR_IO[38],0,rtime)*vdd;
V(WR_IO[39]) <+ transition(vWR_IO[39],0,rtime)*vdd;

V(WR_IO[40]) <+ transition(vWR_IO[40],0,rtime)*vdd;
V(WR_IO[41]) <+ transition(vWR_IO[41],0,rtime)*vdd;
V(WR_IO[42]) <+ transition(vWR_IO[42],0,rtime)*vdd;
V(WR_IO[43]) <+ transition(vWR_IO[43],0,rtime)*vdd;
V(WR_IO[44]) <+ transition(vWR_IO[44],0,rtime)*vdd;
V(WR_IO[45]) <+ transition(vWR_IO[45],0,rtime)*vdd;
V(WR_IO[46]) <+ transition(vWR_IO[46],0,rtime)*vdd;
V(WR_IO[47]) <+ transition(vWR_IO[47],0,rtime)*vdd;
V(WR_IO[48]) <+ transition(vWR_IO[48],0,rtime)*vdd;
V(WR_IO[49]) <+ transition(vWR_IO[49],0,rtime)*vdd;
                                  
V(WR_IO[50]) <+ transition(vWR_IO[50],0,rtime)*vdd;
V(WR_IO[51]) <+ transition(vWR_IO[51],0,rtime)*vdd;
V(WR_IO[52]) <+ transition(vWR_IO[52],0,rtime)*vdd;
V(WR_IO[53]) <+ transition(vWR_IO[53],0,rtime)*vdd;
V(WR_IO[54]) <+ transition(vWR_IO[54],0,rtime)*vdd;
V(WR_IO[55]) <+ transition(vWR_IO[55],0,rtime)*vdd;
V(WR_IO[56]) <+ transition(vWR_IO[56],0,rtime)*vdd;
V(WR_IO[57]) <+ transition(vWR_IO[57],0,rtime)*vdd;
V(WR_IO[58]) <+ transition(vWR_IO[58],0,rtime)*vdd;
V(WR_IO[59]) <+ transition(vWR_IO[59],0,rtime)*vdd;
                                             
V(WR_IO[60]) <+ transition(vWR_IO[60],0,rtime)*vdd;
V(WR_IO[61]) <+ transition(vWR_IO[61],0,rtime)*vdd;
V(WR_IO[62]) <+ transition(vWR_IO[62],0,rtime)*vdd;
V(WR_IO[63]) <+ transition(vWR_IO[63],0,rtime)*vdd;
V(WR_IO[64]) <+ transition(vWR_IO[64],0,rtime)*vdd;
V(WR_IO[65]) <+ transition(vWR_IO[65],0,rtime)*vdd;
V(WR_IO[66]) <+ transition(vWR_IO[66],0,rtime)*vdd;
V(WR_IO[67]) <+ transition(vWR_IO[67],0,rtime)*vdd;
V(WR_IO[68]) <+ transition(vWR_IO[68],0,rtime)*vdd;
V(WR_IO[69]) <+ transition(vWR_IO[69],0,rtime)*vdd;
                                            
V(WR_IO[70]) <+ transition(vWR_IO[70],0,rtime)*vdd;
V(WR_IO[71]) <+ transition(vWR_IO[71],0,rtime)*vdd;
V(WR_IO[72]) <+ transition(vWR_IO[72],0,rtime)*vdd;
V(WR_IO[73]) <+ transition(vWR_IO[73],0,rtime)*vdd;
V(WR_IO[74]) <+ transition(vWR_IO[74],0,rtime)*vdd;
V(WR_IO[75]) <+ transition(vWR_IO[75],0,rtime)*vdd;
V(WR_IO[76]) <+ transition(vWR_IO[76],0,rtime)*vdd;
V(WR_IO[77]) <+ transition(vWR_IO[77],0,rtime)*vdd;
V(WR_IO[78]) <+ transition(vWR_IO[78],0,rtime)*vdd;
V(WR_IO[79]) <+ transition(vWR_IO[79],0,rtime)*vdd;
                                            
V(WR_IO[80]) <+ transition(vWR_IO[80],0,rtime)*vdd;
V(WR_IO[81]) <+ transition(vWR_IO[81],0,rtime)*vdd;
V(WR_IO[82]) <+ transition(vWR_IO[82],0,rtime)*vdd;
V(WR_IO[83]) <+ transition(vWR_IO[83],0,rtime)*vdd;
V(WR_IO[84]) <+ transition(vWR_IO[84],0,rtime)*vdd;
V(WR_IO[85]) <+ transition(vWR_IO[85],0,rtime)*vdd;
V(WR_IO[86]) <+ transition(vWR_IO[86],0,rtime)*vdd;
V(WR_IO[87]) <+ transition(vWR_IO[87],0,rtime)*vdd;
V(WR_IO[88]) <+ transition(vWR_IO[88],0,rtime)*vdd;
V(WR_IO[89]) <+ transition(vWR_IO[89],0,rtime)*vdd;

V(WR_IO[90]) <+ transition(vWR_IO[90],0,rtime)*vdd;
V(WR_IO[91]) <+ transition(vWR_IO[91],0,rtime)*vdd;
V(WR_IO[92]) <+ transition(vWR_IO[92],0,rtime)*vdd;
V(WR_IO[93]) <+ transition(vWR_IO[93],0,rtime)*vdd;
V(WR_IO[94]) <+ transition(vWR_IO[94],0,rtime)*vdd;
V(WR_IO[95]) <+ transition(vWR_IO[95],0,rtime)*vdd;
V(WR_IO[96]) <+ transition(vWR_IO[96],0,rtime)*vdd;
V(WR_IO[97]) <+ transition(vWR_IO[97],0,rtime)*vdd;
V(WR_IO[98]) <+ transition(vWR_IO[98],0,rtime)*vdd;
V(WR_IO[99]) <+ transition(vWR_IO[99],0,rtime)*vdd;

V(WR_IO[100]) <+ transition(vWR_IO[100],0,rtime)*vdd;
V(WR_IO[101]) <+ transition(vWR_IO[101],0,rtime)*vdd;
V(WR_IO[102]) <+ transition(vWR_IO[102],0,rtime)*vdd;
V(WR_IO[103]) <+ transition(vWR_IO[103],0,rtime)*vdd;
V(WR_IO[104]) <+ transition(vWR_IO[104],0,rtime)*vdd;
V(WR_IO[105]) <+ transition(vWR_IO[105],0,rtime)*vdd;
V(WR_IO[106]) <+ transition(vWR_IO[106],0,rtime)*vdd;
V(WR_IO[107]) <+ transition(vWR_IO[107],0,rtime)*vdd;
V(WR_IO[108]) <+ transition(vWR_IO[108],0,rtime)*vdd;
V(WR_IO[109]) <+ transition(vWR_IO[109],0,rtime)*vdd;
                                                
V(WR_IO[110]) <+ transition(vWR_IO[110],0,rtime)*vdd;
V(WR_IO[111]) <+ transition(vWR_IO[111],0,rtime)*vdd;
V(WR_IO[112]) <+ transition(vWR_IO[112],0,rtime)*vdd;
V(WR_IO[113]) <+ transition(vWR_IO[113],0,rtime)*vdd;
V(WR_IO[114]) <+ transition(vWR_IO[114],0,rtime)*vdd;
V(WR_IO[115]) <+ transition(vWR_IO[115],0,rtime)*vdd;
V(WR_IO[116]) <+ transition(vWR_IO[116],0,rtime)*vdd;
V(WR_IO[117]) <+ transition(vWR_IO[117],0,rtime)*vdd;
V(WR_IO[118]) <+ transition(vWR_IO[118],0,rtime)*vdd;
V(WR_IO[119]) <+ transition(vWR_IO[119],0,rtime)*vdd;
                                                
V(WR_IO[120]) <+ transition(vWR_IO[120],0,rtime)*vdd;
V(WR_IO[121]) <+ transition(vWR_IO[121],0,rtime)*vdd;
V(WR_IO[122]) <+ transition(vWR_IO[122],0,rtime)*vdd;
V(WR_IO[123]) <+ transition(vWR_IO[123],0,rtime)*vdd;
V(WR_IO[124]) <+ transition(vWR_IO[124],0,rtime)*vdd;
V(WR_IO[125]) <+ transition(vWR_IO[125],0,rtime)*vdd;
V(WR_IO[126]) <+ transition(vWR_IO[126],0,rtime)*vdd;
V(WR_IO[127]) <+ transition(vWR_IO[127],0,rtime)*vdd;


V(WR_IO_bar[0]) <+ transition(vWR_IO_bar[0],0,rtime)*vdd;
V(WR_IO_bar[1]) <+ transition(vWR_IO_bar[1],0,rtime)*vdd;
V(WR_IO_bar[2]) <+ transition(vWR_IO_bar[2],0,rtime)*vdd;
V(WR_IO_bar[3]) <+ transition(vWR_IO_bar[3],0,rtime)*vdd;
V(WR_IO_bar[4]) <+ transition(vWR_IO_bar[4],0,rtime)*vdd;
V(WR_IO_bar[5]) <+ transition(vWR_IO_bar[5],0,rtime)*vdd;
V(WR_IO_bar[6]) <+ transition(vWR_IO_bar[6],0,rtime)*vdd;
V(WR_IO_bar[7]) <+ transition(vWR_IO_bar[7],0,rtime)*vdd;
V(WR_IO_bar[8]) <+ transition(vWR_IO_bar[8],0,rtime)*vdd;
V(WR_IO_bar[9]) <+ transition(vWR_IO_bar[9],0,rtime)*vdd;
       
V(WR_IO_bar[10]) <+ transition(vWR_IO_bar[10],0,rtime)*vdd;
V(WR_IO_bar[11]) <+ transition(vWR_IO_bar[11],0,rtime)*vdd;
V(WR_IO_bar[12]) <+ transition(vWR_IO_bar[12],0,rtime)*vdd;
V(WR_IO_bar[13]) <+ transition(vWR_IO_bar[13],0,rtime)*vdd;
V(WR_IO_bar[14]) <+ transition(vWR_IO_bar[14],0,rtime)*vdd;
V(WR_IO_bar[15]) <+ transition(vWR_IO_bar[15],0,rtime)*vdd;
V(WR_IO_bar[16]) <+ transition(vWR_IO_bar[16],0,rtime)*vdd;
V(WR_IO_bar[17]) <+ transition(vWR_IO_bar[17],0,rtime)*vdd;
V(WR_IO_bar[18]) <+ transition(vWR_IO_bar[18],0,rtime)*vdd;
V(WR_IO_bar[19]) <+ transition(vWR_IO_bar[19],0,rtime)*vdd;
                                                    
V(WR_IO_bar[20]) <+ transition(vWR_IO_bar[20],0,rtime)*vdd;
V(WR_IO_bar[21]) <+ transition(vWR_IO_bar[21],0,rtime)*vdd;
V(WR_IO_bar[22]) <+ transition(vWR_IO_bar[22],0,rtime)*vdd;
V(WR_IO_bar[23]) <+ transition(vWR_IO_bar[23],0,rtime)*vdd;
V(WR_IO_bar[24]) <+ transition(vWR_IO_bar[24],0,rtime)*vdd;
V(WR_IO_bar[25]) <+ transition(vWR_IO_bar[25],0,rtime)*vdd;
V(WR_IO_bar[26]) <+ transition(vWR_IO_bar[26],0,rtime)*vdd;
V(WR_IO_bar[27]) <+ transition(vWR_IO_bar[27],0,rtime)*vdd;
V(WR_IO_bar[28]) <+ transition(vWR_IO_bar[28],0,rtime)*vdd;
V(WR_IO_bar[29]) <+ transition(vWR_IO_bar[29],0,rtime)*vdd;
                                                    
V(WR_IO_bar[30]) <+ transition(vWR_IO_bar[30],0,rtime)*vdd;
V(WR_IO_bar[31]) <+ transition(vWR_IO_bar[31],0,rtime)*vdd;
V(WR_IO_bar[32]) <+ transition(vWR_IO_bar[32],0,rtime)*vdd;
V(WR_IO_bar[33]) <+ transition(vWR_IO_bar[33],0,rtime)*vdd;
V(WR_IO_bar[34]) <+ transition(vWR_IO_bar[34],0,rtime)*vdd;
V(WR_IO_bar[35]) <+ transition(vWR_IO_bar[35],0,rtime)*vdd;
V(WR_IO_bar[36]) <+ transition(vWR_IO_bar[36],0,rtime)*vdd;
V(WR_IO_bar[37]) <+ transition(vWR_IO_bar[37],0,rtime)*vdd;
V(WR_IO_bar[38]) <+ transition(vWR_IO_bar[38],0,rtime)*vdd;
V(WR_IO_bar[39]) <+ transition(vWR_IO_bar[39],0,rtime)*vdd;
                                                    
V(WR_IO_bar[40]) <+ transition(vWR_IO_bar[40],0,rtime)*vdd;
V(WR_IO_bar[41]) <+ transition(vWR_IO_bar[41],0,rtime)*vdd;
V(WR_IO_bar[42]) <+ transition(vWR_IO_bar[42],0,rtime)*vdd;
V(WR_IO_bar[43]) <+ transition(vWR_IO_bar[43],0,rtime)*vdd;
V(WR_IO_bar[44]) <+ transition(vWR_IO_bar[44],0,rtime)*vdd;
V(WR_IO_bar[45]) <+ transition(vWR_IO_bar[45],0,rtime)*vdd;
V(WR_IO_bar[46]) <+ transition(vWR_IO_bar[46],0,rtime)*vdd;
V(WR_IO_bar[47]) <+ transition(vWR_IO_bar[47],0,rtime)*vdd;
V(WR_IO_bar[48]) <+ transition(vWR_IO_bar[48],0,rtime)*vdd;
V(WR_IO_bar[49]) <+ transition(vWR_IO_bar[49],0,rtime)*vdd;
                                                     
V(WR_IO_bar[50]) <+ transition(vWR_IO_bar[50],0,rtime)*vdd;
V(WR_IO_bar[51]) <+ transition(vWR_IO_bar[51],0,rtime)*vdd;
V(WR_IO_bar[52]) <+ transition(vWR_IO_bar[52],0,rtime)*vdd;
V(WR_IO_bar[53]) <+ transition(vWR_IO_bar[53],0,rtime)*vdd;
V(WR_IO_bar[54]) <+ transition(vWR_IO_bar[54],0,rtime)*vdd;
V(WR_IO_bar[55]) <+ transition(vWR_IO_bar[55],0,rtime)*vdd;
V(WR_IO_bar[56]) <+ transition(vWR_IO_bar[56],0,rtime)*vdd;
V(WR_IO_bar[57]) <+ transition(vWR_IO_bar[57],0,rtime)*vdd;
V(WR_IO_bar[58]) <+ transition(vWR_IO_bar[58],0,rtime)*vdd;
V(WR_IO_bar[59]) <+ transition(vWR_IO_bar[59],0,rtime)*vdd;
                                                    
V(WR_IO_bar[60]) <+ transition(vWR_IO_bar[60],0,rtime)*vdd;
V(WR_IO_bar[61]) <+ transition(vWR_IO_bar[61],0,rtime)*vdd;
V(WR_IO_bar[62]) <+ transition(vWR_IO_bar[62],0,rtime)*vdd;
V(WR_IO_bar[63]) <+ transition(vWR_IO_bar[63],0,rtime)*vdd;
V(WR_IO_bar[64]) <+ transition(vWR_IO_bar[64],0,rtime)*vdd;
V(WR_IO_bar[65]) <+ transition(vWR_IO_bar[65],0,rtime)*vdd;
V(WR_IO_bar[66]) <+ transition(vWR_IO_bar[66],0,rtime)*vdd;
V(WR_IO_bar[67]) <+ transition(vWR_IO_bar[67],0,rtime)*vdd;
V(WR_IO_bar[68]) <+ transition(vWR_IO_bar[68],0,rtime)*vdd;
V(WR_IO_bar[69]) <+ transition(vWR_IO_bar[69],0,rtime)*vdd;
                                                    
V(WR_IO_bar[70]) <+ transition(vWR_IO_bar[70],0,rtime)*vdd;
V(WR_IO_bar[71]) <+ transition(vWR_IO_bar[71],0,rtime)*vdd;
V(WR_IO_bar[72]) <+ transition(vWR_IO_bar[72],0,rtime)*vdd;
V(WR_IO_bar[73]) <+ transition(vWR_IO_bar[73],0,rtime)*vdd;
V(WR_IO_bar[74]) <+ transition(vWR_IO_bar[74],0,rtime)*vdd;
V(WR_IO_bar[75]) <+ transition(vWR_IO_bar[75],0,rtime)*vdd;
V(WR_IO_bar[76]) <+ transition(vWR_IO_bar[76],0,rtime)*vdd;
V(WR_IO_bar[77]) <+ transition(vWR_IO_bar[77],0,rtime)*vdd;
V(WR_IO_bar[78]) <+ transition(vWR_IO_bar[78],0,rtime)*vdd;
V(WR_IO_bar[79]) <+ transition(vWR_IO_bar[79],0,rtime)*vdd;
                                                    
V(WR_IO_bar[80]) <+ transition(vWR_IO_bar[80],0,rtime)*vdd;
V(WR_IO_bar[81]) <+ transition(vWR_IO_bar[81],0,rtime)*vdd;
V(WR_IO_bar[82]) <+ transition(vWR_IO_bar[82],0,rtime)*vdd;
V(WR_IO_bar[83]) <+ transition(vWR_IO_bar[83],0,rtime)*vdd;
V(WR_IO_bar[84]) <+ transition(vWR_IO_bar[84],0,rtime)*vdd;
V(WR_IO_bar[85]) <+ transition(vWR_IO_bar[85],0,rtime)*vdd;
V(WR_IO_bar[86]) <+ transition(vWR_IO_bar[86],0,rtime)*vdd;
V(WR_IO_bar[87]) <+ transition(vWR_IO_bar[87],0,rtime)*vdd;
V(WR_IO_bar[88]) <+ transition(vWR_IO_bar[88],0,rtime)*vdd;
V(WR_IO_bar[89]) <+ transition(vWR_IO_bar[89],0,rtime)*vdd;
                                                
V(WR_IO_bar[90]) <+ transition(vWR_IO_bar[90],0,rtime)*vdd;
V(WR_IO_bar[91]) <+ transition(vWR_IO_bar[91],0,rtime)*vdd;
V(WR_IO_bar[92]) <+ transition(vWR_IO_bar[92],0,rtime)*vdd;
V(WR_IO_bar[93]) <+ transition(vWR_IO_bar[93],0,rtime)*vdd;
V(WR_IO_bar[94]) <+ transition(vWR_IO_bar[94],0,rtime)*vdd;
V(WR_IO_bar[95]) <+ transition(vWR_IO_bar[95],0,rtime)*vdd;
V(WR_IO_bar[96]) <+ transition(vWR_IO_bar[96],0,rtime)*vdd;
V(WR_IO_bar[97]) <+ transition(vWR_IO_bar[97],0,rtime)*vdd;
V(WR_IO_bar[98]) <+ transition(vWR_IO_bar[98],0,rtime)*vdd;
V(WR_IO_bar[99]) <+ transition(vWR_IO_bar[99],0,rtime)*vdd;
       
V(WR_IO_bar[100]) <+ transition(vWR_IO_bar[100],0,rtime)*vdd;
V(WR_IO_bar[101]) <+ transition(vWR_IO_bar[101],0,rtime)*vdd;
V(WR_IO_bar[102]) <+ transition(vWR_IO_bar[102],0,rtime)*vdd;
V(WR_IO_bar[103]) <+ transition(vWR_IO_bar[103],0,rtime)*vdd;
V(WR_IO_bar[104]) <+ transition(vWR_IO_bar[104],0,rtime)*vdd;
V(WR_IO_bar[105]) <+ transition(vWR_IO_bar[105],0,rtime)*vdd;
V(WR_IO_bar[106]) <+ transition(vWR_IO_bar[106],0,rtime)*vdd;
V(WR_IO_bar[107]) <+ transition(vWR_IO_bar[107],0,rtime)*vdd;
V(WR_IO_bar[108]) <+ transition(vWR_IO_bar[108],0,rtime)*vdd;
V(WR_IO_bar[109]) <+ transition(vWR_IO_bar[109],0,rtime)*vdd;
                                                        
V(WR_IO_bar[110]) <+ transition(vWR_IO_bar[110],0,rtime)*vdd;
V(WR_IO_bar[111]) <+ transition(vWR_IO_bar[111],0,rtime)*vdd;
V(WR_IO_bar[112]) <+ transition(vWR_IO_bar[112],0,rtime)*vdd;
V(WR_IO_bar[113]) <+ transition(vWR_IO_bar[113],0,rtime)*vdd;
V(WR_IO_bar[114]) <+ transition(vWR_IO_bar[114],0,rtime)*vdd;
V(WR_IO_bar[115]) <+ transition(vWR_IO_bar[115],0,rtime)*vdd;
V(WR_IO_bar[116]) <+ transition(vWR_IO_bar[116],0,rtime)*vdd;
V(WR_IO_bar[117]) <+ transition(vWR_IO_bar[117],0,rtime)*vdd;
V(WR_IO_bar[118]) <+ transition(vWR_IO_bar[118],0,rtime)*vdd;
V(WR_IO_bar[119]) <+ transition(vWR_IO_bar[119],0,rtime)*vdd;
                                                    
V(WR_IO_bar[120]) <+ transition(vWR_IO_bar[120],0,rtime)*vdd;
V(WR_IO_bar[121]) <+ transition(vWR_IO_bar[121],0,rtime)*vdd;
V(WR_IO_bar[122]) <+ transition(vWR_IO_bar[122],0,rtime)*vdd;
V(WR_IO_bar[123]) <+ transition(vWR_IO_bar[123],0,rtime)*vdd;
V(WR_IO_bar[124]) <+ transition(vWR_IO_bar[124],0,rtime)*vdd;
V(WR_IO_bar[125]) <+ transition(vWR_IO_bar[125],0,rtime)*vdd;
V(WR_IO_bar[126]) <+ transition(vWR_IO_bar[126],0,rtime)*vdd;
V(WR_IO_bar[127]) <+ transition(vWR_IO_bar[127],0,rtime)*vdd;


V(WE) <+ transition(vWE,0,rtime)*vdd_pad;
V(DRAM_EN) <+ transition(vDRAM_EN,0,rtime)*vdd_pad;
V(DEC_EN) <+ transition(vDEC_EN,0,rtime)*vdd_pad;




/////////SCAN/////////////


// VerilogA for CiM_65, inputDRAM_ctrl_wDAC, veriloga

`include "constants.vams"
`include "disciplines.vams"

module inputDRAM_ctrl_wDAC_wrefresh_wSCAN(start, CLK, ADDR, WR_IO, WE,DRAM_EN, DEC_EN, refresh_finish, start_refresh, requestDatafromDAC, start_DAC, LSB_in, MSB_in, requestData_fromMAV, ADC_finish, release_Va, se, scan_clk, update_clk, scanin, scanclk_out, mav_finish_scan);
input start; electrical start; //1: write; 0: read 
input CLK; electrical CLK;
output [3:0] ADDR; electrical [3:0] ADDR; integer vADDR[3:0];
output [127:0] WR_IO; electrical [127:0] WR_IO; real vWR_IO[127:0];

output WE,DRAM_EN, DEC_EN; electrical WE,DRAM_EN, DEC_EN; real vWE, vDRAM_EN, vDEC_EN;
//output EQ; electrical EQ; real vEQ;
output start_refresh; electrical start_refresh; real vstart_refresh;
input refresh_finish; electrical refresh_finish;
input requestDatafromDAC; electrical requestDatafromDAC;
output start_DAC; electrical start_DAC; real vstart_DAC;
input LSB_in, MSB_in; electrical LSB_in, MSB_in;
input requestData_fromMAV; electrical requestData_fromMAV;
input ADC_finish; electrical ADC_finish;
input release_Va; electrical release_Va;
input scan_clk; electrical scan_clk;
output se, update_clk, scanin; electrical se, update_clk, scanin; real vse, vupdate_clk, vscanin;
output scanclk_out; electrical scanclk_out; real vscanclk_out;
input mav_finish_scan; electrical mav_finish_scan;

parameter real vdd =1.2;
parameter real vdd_pad = 3.3;
parameter real rtime=10p;
parameter integer max_row = 2;
parameter integer max_col_scan = 257;
parameter integer max_col = 128;
parameter integer ADDR_count = 4;
parameter integer half_array = 8;

parameter integer IDLE = 0;
parameter integer WRITE = 1;
parameter integer RESET = 2;
parameter integer READ = 3;
parameter integer REFRESH = 4;
parameter integer END_OF_WRITE = 5;
parameter integer END_OF_READ = 6;
parameter integer WAIT = 7;
parameter integer UPDATE = 8;

//Refresh
parameter integer max_refreshCounter = 10000;

integer RowValue[16-1:0];
integer currentState, nextState;
integer thisRowValue;
integer row_count;
integer i;
integer row_value_count;
integer finishWrite;
integer j;
integer thisRow;
integer refreshCounter;
integer refreshStopThisState;
integer start_refresh_isAsserted;
integer haveRecordRequestData;
integer start_DAC_counter;
integer scanclk_en, scan_done, this_scancol, update_count;

analog begin
	@(initial_step) begin
this_scancol = 0;
update_count = 0;
		scan_done = 0;
		scanclk_en = 0;
		vse = 0;
		vupdate_clk = 0;
	 	vscanin = 0;
		row_count = 0;

		for(i = 0; i<max_col; i=i+1) begin
			vWR_IO[i] = 0;

		
		end
		for(i = 0; i<ADDR_count; i=i+1) begin
			vADDR[i] = 0;
		end

		RowValue[0] = 512*15+0*32+15*2+1;
		RowValue[1] = 512*15+0*32+15*2+0;
		RowValue[2] = V(LSB_in)*2+0;
		RowValue[3] = V(MSB_in)*2+0;
		RowValue[4] = 1;
		RowValue[5] = 2;
		RowValue[6] = 3;
		RowValue[7] = 4;
		RowValue[8] = 5;
		RowValue[9] = 6;
		RowValue[10] = 7;
		RowValue[11] = 8;
		RowValue[12] = 9;
		RowValue[13] = 10;
		RowValue[14] = 11;
		RowValue[15] = 12;

/*
row_value_count = 0;
		for(i = 0; i<max_row; i=i+1) begin
			RowValue[i] = row_value_count;
	//		//assign 1 2 3 4 5 6 7 8 as row value for each row -- for test purpose
			row_value_count = row_value_count + 1;
		end
*/
		vWE = 0;
		vDRAM_EN = 0;
		vDEC_EN = 0;
		//vEQ = 1;
		refreshCounter = 0;	
		start_DAC_counter = 0;
	end

//define counter	
	@(cross(V(CLK) - 0.5, -1)) begin
		refreshCounter = refreshCounter + 1;
		//if(vstart_refresh == 1) vstart_refresh = 0;
	end


	@(cross(V(CLK) - 0.5, -1)) begin

		case(currentState)

		UPDATE: begin
			vDEC_EN = 0;
			vupdate_clk = 0; 
		end
		WAIT: begin
		if ( nextState == RESET) begin vDEC_EN = 0; end
		end
		endcase

	end

	@(cross(V(scan_clk) - 0.5, -1)) begin
		if(scanclk_en == 1) vscanclk_out = 0; 
		else vscanclk_out = 0;
		case(currentState) 
		WRITE: begin
		$strobe("scan scan scan scan write");
		$strobe("scan clk enable = %g", scanclk_en);
		$strobe("scan clk = %g", vscanclk_out);
			scanclk_en = 1;
			if(this_scancol == 0) begin thisRowValue = RowValue[row_count]; end

			if(this_scancol<max_col_scan) begin	 //i = col
				$strobe("thisRowValue = %g", thisRowValue);
				//vWR_IO[this_scancol] = thisRowValue % 2;
				vscanin = thisRowValue % 2;
				thisRowValue = thisRowValue/2;
				this_scancol = this_scancol + 1;

			end	
			else begin scanclk_en = 0; scan_done = 1; end
	
		end
		endcase
	end

	@(cross(V(scan_clk) - 0.5, +1)) begin
		$strobe("scan SCAN SCAN SCAN SCAN rise edge");
		$strobe("scan clk = %g", vscanclk_out);
		$strobe("scan clk enable = %g", scanclk_en);
		if(scanclk_en == 1) vscanclk_out = 1; 
		else vscanclk_out = 0;
	//	case(currentState) 
	//	WRITE: begin
		
	//	end
	//	endcase
	end

	@(cross(V(CLK) - 0.5, +1)) begin
		currentState = nextState;
		case(currentState)
		IDLE: begin
			vse = 0;
			vupdate_clk = 0;
	 		vscanin = 0;
			for(i = 0; i<max_col; i=i+1) begin
				vWR_IO[i] = 0;

			end
			if(V(start) > 0.5) begin
				//$strobe("EQ = %g", vEQ);
				//vEQ = 0;	
				this_scancol = 0;
				nextState = WRITE;
			//	vWE = 1;
			//	vDRAM_EN = 1;
			//	vDEC_EN = 1;
				$strobe("idle idle dile dile");
			end
			else nextState = IDLE;
			vWE = 0;
			vDRAM_EN = 0;
			vDEC_EN = 0;
			//vEQ = 1;	
			vstart_refresh = 0;
			vstart_DAC = 0;
			haveRecordRequestData = 0;
			start_DAC_counter = 0;
		end
		WRITE: begin
 		vse = 1; //select scan propagation

		$strobe("scan_done = %g", scan_done);
$strobe("write write write");
			//wait 
			vstart_DAC = 0;
			vstart_refresh = 0;
	
			//thisRowValue = RowValue[row_count];

			if(scan_done == 1) begin
				this_scancol = 0;
				nextState = UPDATE;
				scan_done = 0;	
			end
			else begin nextState = WRITE; end
			
		end

		UPDATE: begin
			vWE = 1;
			vDRAM_EN = 1;
			vDEC_EN = 1;

			vupdate_clk = 1; 

			thisRow = row_count;

			//generate address
			for(j=0; j<ADDR_count; j=j+1) begin
				vADDR[j] = thisRow%2;
				thisRow = thisRow/2;
			end

			if(update_count < 1) begin //keep update clk for 2 cycles
				nextState = UPDATE;
				update_count = update_count + 1;
			end
			else begin
				update_count = 0;
			$strobe("refresh Counter = %g", refreshCounter);
				//determine if it reach last row
				if(row_count == max_row-1) begin //reach the last row
					row_count = 0; //reset row count
					if(refreshCounter > max_refreshCounter) begin nextState = REFRESH;	refreshStopThisState = END_OF_WRITE; end
					else nextState = RESET;

				end
				else begin 
					row_count=row_count+1; 
					if(refreshCounter > max_refreshCounter) begin nextState = REFRESH;	refreshStopThisState = WRITE; end
					else nextState = WRITE; 	

				end
			end

		end


		REFRESH: begin
			vWE = 0;
			vDRAM_EN = 0;
			vDEC_EN = 0;
			if(start_refresh_isAsserted == 0) begin vstart_refresh = 1; start_refresh_isAsserted = 1; end
			else vstart_refresh = 0;
			refreshCounter = 0;
			if(V(refresh_finish) > 0.5) 
			begin
				start_refresh_isAsserted = 0;
				if(refreshStopThisState == END_OF_WRITE) nextState = RESET; 
				else if(refreshStopThisState == END_OF_READ) nextState = IDLE;
				else nextState = refreshStopThisState;
			end
		    else nextState = REFRESH;
		end


		RESET: begin
		//	haveRecordRequestData = 0;
			vstart_DAC = 0;
			vstart_refresh = 0;
			vWE = 0;
			vDRAM_EN=0;
			vDEC_EN = 0;
			if(V(mav_finish_scan) > 0.5) begin
				nextState = READ;
			end
			else begin nextState = RESET; end
		end

		READ: begin
			//haveRecordRequestData = 0;
			start_DAC_counter = 0;
			vstart_DAC = 0;
			$strobe("read read read");
			//vEQ = 0;	
			vWE = 0;
			vDRAM_EN = 1;
			vDEC_EN = 1;
			//$strobe("row count = %g", row_count);
			thisRow = row_count;

			for(j=0; j<ADDR_count; j=j+1) begin
				vADDR[j] = thisRow%2;
				thisRow = thisRow/2;
		//		$strobe("address %g = %g", j, vADDR[j]);
			end
		
			nextState = WAIT; 		 

		end
		WAIT: begin
			if(start_DAC_counter<2) begin vstart_DAC = 1; start_DAC_counter = start_DAC_counter +1; end
			else vstart_DAC = 0;
			if(row_count == max_row-1) begin //reach the last row
				if (V(release_Va) > 0.5) begin nextState = RESET; row_count = 0; end
				else begin nextState = WAIT; row_count = row_count; end
				
			end
			else begin 
				if(V(requestDatafromDAC) > 0.5 && haveRecordRequestData == 0) begin haveRecordRequestData = 1; row_count=row_count+1; nextState = RESET; end
				else if (V(requestData_fromMAV) > 0.5) begin row_count=row_count+1; nextState = RESET; end
				else begin row_count = row_count; nextState = WAIT; end
				 		 
			end
			if(V(ADC_finish) > 0.5) begin nextState = IDLE; end
		end
		endcase
		
	end
	@(cross(V(requestDatafromDAC) - 0.5, -1)) begin
	haveRecordRequestData = 0;
	end

//	V(EQ) <+ transition(vEQ,0,rtime);
	V(ADDR[0]) <+ transition(vADDR[0],0,rtime)*vdd_pad;
	V(ADDR[1]) <+ transition(vADDR[1],0,rtime)*vdd_pad;
	V(ADDR[2]) <+ transition(vADDR[2],0,rtime)*vdd_pad;
	V(ADDR[3]) <+ transition(vADDR[3],0,rtime)*vdd_pad;

	V(start_refresh) <+ transition(vstart_refresh,0,rtime)*vdd_pad;
	V(start_DAC) <+ transition(vstart_DAC,0,rtime)*vdd_pad;

	V(se) <+ transition(vse,0,rtime)*vdd_pad;
	V(update_clk) <+ transition(vupdate_clk,0,rtime)*vdd_pad;
	V(scanin) <+ transition(vscanin,0,rtime)*vdd_pad;
	V(scanclk_out) <+ transition(vscanclk_out, 0, rtime)*vdd_pad;

V(WR_IO[0]) <+ transition(vWR_IO[0],0,rtime)*vdd;
V(WR_IO[1]) <+ transition(vWR_IO[1],0,rtime)*vdd;
V(WR_IO[2]) <+ transition(vWR_IO[2],0,rtime)*vdd;
V(WR_IO[3]) <+ transition(vWR_IO[3],0,rtime)*vdd;
V(WR_IO[4]) <+ transition(vWR_IO[4],0,rtime)*vdd;
V(WR_IO[5]) <+ transition(vWR_IO[5],0,rtime)*vdd;
V(WR_IO[6]) <+ transition(vWR_IO[6],0,rtime)*vdd;
V(WR_IO[7]) <+ transition(vWR_IO[7],0,rtime)*vdd;
V(WR_IO[8]) <+ transition(vWR_IO[8],0,rtime)*vdd;
V(WR_IO[9]) <+ transition(vWR_IO[9],0,rtime)*vdd;

V(WR_IO[10]) <+ transition(vWR_IO[10],0,rtime)*vdd;
V(WR_IO[11]) <+ transition(vWR_IO[11],0,rtime)*vdd;
V(WR_IO[12]) <+ transition(vWR_IO[12],0,rtime)*vdd;
V(WR_IO[13]) <+ transition(vWR_IO[13],0,rtime)*vdd;
V(WR_IO[14]) <+ transition(vWR_IO[14],0,rtime)*vdd;
V(WR_IO[15]) <+ transition(vWR_IO[15],0,rtime)*vdd;
V(WR_IO[16]) <+ transition(vWR_IO[16],0,rtime)*vdd;
V(WR_IO[17]) <+ transition(vWR_IO[17],0,rtime)*vdd;
V(WR_IO[18]) <+ transition(vWR_IO[18],0,rtime)*vdd;
V(WR_IO[19]) <+ transition(vWR_IO[19],0,rtime)*vdd;

V(WR_IO[20]) <+ transition(vWR_IO[20],0,rtime)*vdd;
V(WR_IO[21]) <+ transition(vWR_IO[21],0,rtime)*vdd;
V(WR_IO[22]) <+ transition(vWR_IO[22],0,rtime)*vdd;
V(WR_IO[23]) <+ transition(vWR_IO[23],0,rtime)*vdd;
V(WR_IO[24]) <+ transition(vWR_IO[24],0,rtime)*vdd;
V(WR_IO[25]) <+ transition(vWR_IO[25],0,rtime)*vdd;
V(WR_IO[26]) <+ transition(vWR_IO[26],0,rtime)*vdd;
V(WR_IO[27]) <+ transition(vWR_IO[27],0,rtime)*vdd;
V(WR_IO[28]) <+ transition(vWR_IO[28],0,rtime)*vdd;
V(WR_IO[29]) <+ transition(vWR_IO[29],0,rtime)*vdd;

V(WR_IO[30]) <+ transition(vWR_IO[30],0,rtime)*vdd;
V(WR_IO[31]) <+ transition(vWR_IO[31],0,rtime)*vdd;
V(WR_IO[32]) <+ transition(vWR_IO[32],0,rtime)*vdd;
V(WR_IO[33]) <+ transition(vWR_IO[33],0,rtime)*vdd;
V(WR_IO[34]) <+ transition(vWR_IO[34],0,rtime)*vdd;
V(WR_IO[35]) <+ transition(vWR_IO[35],0,rtime)*vdd;
V(WR_IO[36]) <+ transition(vWR_IO[36],0,rtime)*vdd;
V(WR_IO[37]) <+ transition(vWR_IO[37],0,rtime)*vdd;
V(WR_IO[38]) <+ transition(vWR_IO[38],0,rtime)*vdd;
V(WR_IO[39]) <+ transition(vWR_IO[39],0,rtime)*vdd;

V(WR_IO[40]) <+ transition(vWR_IO[40],0,rtime)*vdd;
V(WR_IO[41]) <+ transition(vWR_IO[41],0,rtime)*vdd;
V(WR_IO[42]) <+ transition(vWR_IO[42],0,rtime)*vdd;
V(WR_IO[43]) <+ transition(vWR_IO[43],0,rtime)*vdd;
V(WR_IO[44]) <+ transition(vWR_IO[44],0,rtime)*vdd;
V(WR_IO[45]) <+ transition(vWR_IO[45],0,rtime)*vdd;
V(WR_IO[46]) <+ transition(vWR_IO[46],0,rtime)*vdd;
V(WR_IO[47]) <+ transition(vWR_IO[47],0,rtime)*vdd;
V(WR_IO[48]) <+ transition(vWR_IO[48],0,rtime)*vdd;
V(WR_IO[49]) <+ transition(vWR_IO[49],0,rtime)*vdd;
                                  
V(WR_IO[50]) <+ transition(vWR_IO[50],0,rtime)*vdd;
V(WR_IO[51]) <+ transition(vWR_IO[51],0,rtime)*vdd;
V(WR_IO[52]) <+ transition(vWR_IO[52],0,rtime)*vdd;
V(WR_IO[53]) <+ transition(vWR_IO[53],0,rtime)*vdd;
V(WR_IO[54]) <+ transition(vWR_IO[54],0,rtime)*vdd;
V(WR_IO[55]) <+ transition(vWR_IO[55],0,rtime)*vdd;
V(WR_IO[56]) <+ transition(vWR_IO[56],0,rtime)*vdd;
V(WR_IO[57]) <+ transition(vWR_IO[57],0,rtime)*vdd;
V(WR_IO[58]) <+ transition(vWR_IO[58],0,rtime)*vdd;
V(WR_IO[59]) <+ transition(vWR_IO[59],0,rtime)*vdd;
                                             
V(WR_IO[60]) <+ transition(vWR_IO[60],0,rtime)*vdd;
V(WR_IO[61]) <+ transition(vWR_IO[61],0,rtime)*vdd;
V(WR_IO[62]) <+ transition(vWR_IO[62],0,rtime)*vdd;
V(WR_IO[63]) <+ transition(vWR_IO[63],0,rtime)*vdd;
V(WR_IO[64]) <+ transition(vWR_IO[64],0,rtime)*vdd;
V(WR_IO[65]) <+ transition(vWR_IO[65],0,rtime)*vdd;
V(WR_IO[66]) <+ transition(vWR_IO[66],0,rtime)*vdd;
V(WR_IO[67]) <+ transition(vWR_IO[67],0,rtime)*vdd;
V(WR_IO[68]) <+ transition(vWR_IO[68],0,rtime)*vdd;
V(WR_IO[69]) <+ transition(vWR_IO[69],0,rtime)*vdd;
                                            
V(WR_IO[70]) <+ transition(vWR_IO[70],0,rtime)*vdd;
V(WR_IO[71]) <+ transition(vWR_IO[71],0,rtime)*vdd;
V(WR_IO[72]) <+ transition(vWR_IO[72],0,rtime)*vdd;
V(WR_IO[73]) <+ transition(vWR_IO[73],0,rtime)*vdd;
V(WR_IO[74]) <+ transition(vWR_IO[74],0,rtime)*vdd;
V(WR_IO[75]) <+ transition(vWR_IO[75],0,rtime)*vdd;
V(WR_IO[76]) <+ transition(vWR_IO[76],0,rtime)*vdd;
V(WR_IO[77]) <+ transition(vWR_IO[77],0,rtime)*vdd;
V(WR_IO[78]) <+ transition(vWR_IO[78],0,rtime)*vdd;
V(WR_IO[79]) <+ transition(vWR_IO[79],0,rtime)*vdd;
                                            
V(WR_IO[80]) <+ transition(vWR_IO[80],0,rtime)*vdd;
V(WR_IO[81]) <+ transition(vWR_IO[81],0,rtime)*vdd;
V(WR_IO[82]) <+ transition(vWR_IO[82],0,rtime)*vdd;
V(WR_IO[83]) <+ transition(vWR_IO[83],0,rtime)*vdd;
V(WR_IO[84]) <+ transition(vWR_IO[84],0,rtime)*vdd;
V(WR_IO[85]) <+ transition(vWR_IO[85],0,rtime)*vdd;
V(WR_IO[86]) <+ transition(vWR_IO[86],0,rtime)*vdd;
V(WR_IO[87]) <+ transition(vWR_IO[87],0,rtime)*vdd;
V(WR_IO[88]) <+ transition(vWR_IO[88],0,rtime)*vdd;
V(WR_IO[89]) <+ transition(vWR_IO[89],0,rtime)*vdd;

V(WR_IO[90]) <+ transition(vWR_IO[90],0,rtime)*vdd;
V(WR_IO[91]) <+ transition(vWR_IO[91],0,rtime)*vdd;
V(WR_IO[92]) <+ transition(vWR_IO[92],0,rtime)*vdd;
V(WR_IO[93]) <+ transition(vWR_IO[93],0,rtime)*vdd;
V(WR_IO[94]) <+ transition(vWR_IO[94],0,rtime)*vdd;
V(WR_IO[95]) <+ transition(vWR_IO[95],0,rtime)*vdd;
V(WR_IO[96]) <+ transition(vWR_IO[96],0,rtime)*vdd;
V(WR_IO[97]) <+ transition(vWR_IO[97],0,rtime)*vdd;
V(WR_IO[98]) <+ transition(vWR_IO[98],0,rtime)*vdd;
V(WR_IO[99]) <+ transition(vWR_IO[99],0,rtime)*vdd;

V(WR_IO[100]) <+ transition(vWR_IO[100],0,rtime)*vdd;
V(WR_IO[101]) <+ transition(vWR_IO[101],0,rtime)*vdd;
V(WR_IO[102]) <+ transition(vWR_IO[102],0,rtime)*vdd;
V(WR_IO[103]) <+ transition(vWR_IO[103],0,rtime)*vdd;
V(WR_IO[104]) <+ transition(vWR_IO[104],0,rtime)*vdd;
V(WR_IO[105]) <+ transition(vWR_IO[105],0,rtime)*vdd;
V(WR_IO[106]) <+ transition(vWR_IO[106],0,rtime)*vdd;
V(WR_IO[107]) <+ transition(vWR_IO[107],0,rtime)*vdd;
V(WR_IO[108]) <+ transition(vWR_IO[108],0,rtime)*vdd;
V(WR_IO[109]) <+ transition(vWR_IO[109],0,rtime)*vdd;
                                                
V(WR_IO[110]) <+ transition(vWR_IO[110],0,rtime)*vdd;
V(WR_IO[111]) <+ transition(vWR_IO[111],0,rtime)*vdd;
V(WR_IO[112]) <+ transition(vWR_IO[112],0,rtime)*vdd;
V(WR_IO[113]) <+ transition(vWR_IO[113],0,rtime)*vdd;
V(WR_IO[114]) <+ transition(vWR_IO[114],0,rtime)*vdd;
V(WR_IO[115]) <+ transition(vWR_IO[115],0,rtime)*vdd;
V(WR_IO[116]) <+ transition(vWR_IO[116],0,rtime)*vdd;
V(WR_IO[117]) <+ transition(vWR_IO[117],0,rtime)*vdd;
V(WR_IO[118]) <+ transition(vWR_IO[118],0,rtime)*vdd;
V(WR_IO[119]) <+ transition(vWR_IO[119],0,rtime)*vdd;
                                                
V(WR_IO[120]) <+ transition(vWR_IO[120],0,rtime)*vdd;
V(WR_IO[121]) <+ transition(vWR_IO[121],0,rtime)*vdd;
V(WR_IO[122]) <+ transition(vWR_IO[122],0,rtime)*vdd;
V(WR_IO[123]) <+ transition(vWR_IO[123],0,rtime)*vdd;
V(WR_IO[124]) <+ transition(vWR_IO[124],0,rtime)*vdd;
V(WR_IO[125]) <+ transition(vWR_IO[125],0,rtime)*vdd;
V(WR_IO[126]) <+ transition(vWR_IO[126],0,rtime)*vdd;
V(WR_IO[127]) <+ transition(vWR_IO[127],0,rtime)*vdd;




V(WE) <+ transition(vWE,0,rtime)*vdd_pad;
V(DRAM_EN) <+ transition(vDRAM_EN,0,rtime)*vdd_pad;
V(DEC_EN) <+ transition(vDEC_EN,0,rtime)*vdd_pad;




end

endmodule









end

endmodule

