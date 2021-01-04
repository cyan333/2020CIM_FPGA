// VerilogA for CiM_65, mav_ctrl_wCompute, veriloga

`include "constants.vams"
`include "disciplines.vams"

module mav_ctrl_wCompute_256x32_6(start, CLK, ADDR, WR_IO, WE,DRAM_EN, DEC_EN, refresh_finish, start_refresh, finish_loading, requestDatafromMAV, start_mav, MSB, LSB, start_ADC_fromchip, start_ADC_fromOutside);
input start; electrical start; //1: write; 0: read 
input CLK; electrical CLK;
output [4:0] ADDR; electrical [4:0] ADDR; integer vADDR[4:0];
output [255:0] WR_IO; electrical [255:0] WR_IO; real vWR_IO[255:0];

output WE,DRAM_EN, DEC_EN; electrical WE,DRAM_EN, DEC_EN; real vWE, vDRAM_EN, vDEC_EN;
//output EQ; electrical EQ; real vEQ;
output start_refresh; electrical start_refresh; real vstart_refresh;
input refresh_finish; electrical refresh_finish;
output finish_loading; electrical finish_loading; real vfinish_loading;
input  requestDatafromMAV; electrical requestDatafromMAV;
output start_mav; electrical start_mav; real vstart_mav;
input MSB, LSB; electrical MSB, LSB;
input start_ADC_fromchip; electrical start_ADC_fromchip;
output start_ADC_fromOutside; electrical start_ADC_fromOutside; real vstart_ADC_fromOutside;


parameter real vdd = 1.2;
parameter real vdd_pad = 3.3;
parameter real rtime=10p;
parameter integer max_row = 32;
parameter integer max_col = 256;
parameter integer ADDR_count = 5;

parameter integer IDLE = 0;
parameter integer WRITE = 1;
parameter integer RESET = 2;
parameter integer READ = 3;
parameter integer REFRESH = 4;
parameter integer END_OF_WRITE = 5;
parameter integer END_OF_READ = 6;
parameter integer WAIT = 7;


//Refresh
parameter integer max_refreshCounter = 25;

integer start_ADC_counter;
integer RowValue[max_col-1:0];
integer currentState;
integer nextState;
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

integer rand;
integer seed;
integer haveRecordRequestData;
integer finish_loading_counter;

parameter integer start_range = 129;
integer stop_range;

analog begin
	@(initial_step) begin
		start_ADC_counter = 0;
		seed = 23;
		stop_range = 255;
		row_count = 0;
		for(i = 0; i<max_col; i=i+1) begin
			vWR_IO[i] = 0;

		
		end
		for(i = 0; i<ADDR_count; i=i+1) begin
			vADDR[i] = 0;
		end

		RowValue[0] = V(LSB);
		//RowValue[0] = 130 + 256*127;
		RowValue[1] = 10 + 256*1;
		RowValue[2] = 130 + 256*140;
		RowValue[3] = 0 + 256*16;
		RowValue[4] = 131 + 256*131;
		RowValue[5] = 3 + 256*3;
		RowValue[6] = 2 + 256*2;
		RowValue[7] = 1 + 256*1;

/*
		RowValue[0] = 0;
		RowValue[1] = 0;
		RowValue[2] = 0;
		RowValue[3] = 0;
		RowValue[4] = 0;
		RowValue[5] = 0;
		RowValue[6] = 0;
		RowValue[7] = 0;
*/
		for(i = 8; i<max_row; i=i+1) begin
			rand = $dist_uniform(seed, start_range, stop_range);
			$strobe("row value = %g", rand);
/*
			if(i==0) RowValue[i] = V(MSB)+14*16+13*16**2+13*16**63;
			else if(i==1) RowValue[i] = V(LSB)+10*16;
			else if(i==2) RowValue[i] = 7+11*16;
			else if(i==3) RowValue[i] = 9+3*16;
			else if(i==4) RowValue[i] = 9;
			else if(i==5) RowValue[i] = 1;
			else if(i==6) RowValue[i] = 9;
			else if(i==7) RowValue[i] = 2;
*/
			RowValue[i] = 0; 
			//assign 1 2 3 4 5 6 7 8 as row value for each row -- for test purpose
			//row_value_count = row_value_count+1;

		end
		vWE = 0;
		vDRAM_EN = 0;
		vDEC_EN = 0;
		//vEQ = 1;
		refreshCounter = 0;	
		vfinish_loading = 0;
		finish_loading_counter = 0;
		haveRecordRequestData = 0;
		vstart_mav = 0;
	end

	@(cross(V(CLK) - 0.5, +1)) begin
		if (V(start_ADC_fromchip) > 1) begin
			if (start_ADC_counter < 8) begin vstart_ADC_fromOutside = 0; start_ADC_counter = start_ADC_counter+1; end
			else begin vstart_ADC_fromOutside = 1; end
		end
		else begin vstart_ADC_fromOutside = 0; start_ADC_counter = 0; end

	end

//define counter	
	@(cross(V(CLK) - 0.5, -1)) begin
		refreshCounter = refreshCounter + 1;
	end

	@(cross(V(CLK) - 0.5, -1)) begin
		case(currentState)
		WRITE: begin
			vDEC_EN = 0;
		end
		//READ: begin
		//	vDEC_EN = 0;
		//end
		READ: begin
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

			end
			if(V(start) > 0.5) begin
				//$strobe("EQ = %g", vEQ);
				//vEQ = 0;	
				nextState = WRITE;
			//	$strobe("idle idle dile dile");
			end
			else nextState = IDLE;
			vWE = 0;
			vDRAM_EN = 0;
			vDEC_EN = 0;
			//vEQ = 1;	
			vstart_refresh = 0;
			vfinish_loading = 0;
			finish_loading_counter = 0;
			haveRecordRequestData = 0;
			vstart_mav = 0;
		end
		WRITE: begin
			vstart_mav = 0;
			vfinish_loading = 0;
			vstart_refresh = 0;
			//$strobe("write write write write");
			vWE = 1;
			vDRAM_EN = 1;
			vDEC_EN = 1;
			//vEQ = 0;	
			thisRowValue = RowValue[row_count];
			$strobe("thisRowValue = %g", thisRowValue);
			thisRow = row_count;
			//generate address
			for(j=0; j<ADDR_count; j=j+1) begin
				vADDR[j] = thisRow%2;
				thisRow = thisRow/2;
			end
			//prepare IO data port for write
			//for(i = 0; i<max_col; i=i+1) begin	 //i = col
			for(i = 0; i<max_col; i=i+1) begin	 //i = col
				vWR_IO[i] = thisRowValue % 2;
			//	if((i+1)%8 == 0) vWR_IO[i] = 0;
			//	else vWR_IO[i] = 1;
				thisRowValue = thisRowValue/2;
			end	

			if(row_count == max_row-1) begin //reach the last row
			//if(row_count == 5-1) begin //reach the last row
				row_count = 0; //reset row count
				nextState = WAIT;

			end
			else begin 
				row_count=row_count+1; 
				nextState = WRITE; 		
			end
		//	end	
		end

/*
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
*/

		WAIT: begin
			vstart_mav = 1;
			vfinish_loading = 0;
			vstart_refresh = 0;
			//vEQ = 1;	
			vWE = 0;
			vDRAM_EN=0;
			vDEC_EN = 0;

			if(V(requestDatafromMAV) > 0.5) begin haveRecordRequestData = 1; nextState = READ; end
			else nextState = WAIT;
		end		

		RESET: begin
			vstart_mav = 1;
			finish_loading_counter = 0;
			vfinish_loading = 0;
			vstart_refresh = 0;
			//vEQ = 1;	
			vWE = 0;
			vDRAM_EN=0;
			vDEC_EN = 0;
			nextState = READ;
		end

		READ: begin
			if(finish_loading_counter<2) begin vfinish_loading = 1; finish_loading_counter = finish_loading_counter +1; end
			else vfinish_loading = 0;
			//$strobe("MAV read read read");
			vWE = 0;
			vDRAM_EN = 1;
			vDEC_EN = 1;

			thisRow = row_count;

			for(j=0; j<ADDR_count; j=j+1) begin
				vADDR[j] = thisRow%2;
				thisRow = thisRow/2;
		//		$strobe("address %g = %g", j, vADDR[j]);
			end
			//nextState = WAIT;
			if(row_count == max_row-1) begin nextState = IDLE; end
			else begin 
				if(V(requestDatafromMAV) > 0.5 && haveRecordRequestData == 0) begin 
					haveRecordRequestData = 1; 
					row_count=row_count+1; 
					nextState = RESET;
				end
				else begin row_count = row_count; nextState = READ; end
			end
		end

/*
		WAIT: begin
		//	if(finish_loading_counter<2) begin vfinish_loading = 1; finish_loading_counter = finish_loading_counter +1; end
		//	else vfinish_loading = 1;

			if(row_count == max_row-1) begin nextState = IDLE; end
			else begin 
				if(V(requestDatafromMAV) > 0.5 && haveRecordRequestData == 0) begin 
					haveRecordRequestData = 1; 
					row_count=row_count+1; 
					nextState = READ;
					vfinish_loading = 0;
					vstart_refresh = 0;
					vWE = 0;
					vDRAM_EN=0;
					vDEC_EN = 0;
				 end
				else begin row_count = row_count; nextState = WAIT; end
			end
		end
*/
		endcase
		
	end
	
	@(cross(V(requestDatafromMAV) - 0.5, -1)) begin
	haveRecordRequestData = 0;
	end

	V(start_ADC_fromOutside) <+ transition(vstart_ADC_fromOutside,0,rtime)*vdd_pad;
    V(ADDR[0]) <+ transition(vADDR[0],0,rtime)*vdd_pad;
    V(ADDR[1]) <+ transition(vADDR[1],0,rtime)*vdd_pad;
    V(ADDR[2]) <+ transition(vADDR[2],0,rtime)*vdd_pad;
    V(ADDR[3]) <+ transition(vADDR[3],0,rtime)*vdd_pad;
    V(ADDR[4]) <+ transition(vADDR[4],0,rtime)*vdd_pad;


    V(start_mav) <+ transition(vstart_mav, 0, rtime)*vdd_pad;
    V(finish_loading) <+ transition(vfinish_loading, 0, rtime)*vdd_pad;
    V(start_refresh) <+ transition(vstart_refresh,0,rtime)*vdd_pad;


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
V(WR_IO[128]) <+ transition(vWR_IO[128],0,rtime)*vdd;
V(WR_IO[129]) <+ transition(vWR_IO[129],0,rtime)*vdd;

                            
V(WR_IO[130]) <+ transition(vWR_IO[130],0,rtime)*vdd;
V(WR_IO[131]) <+ transition(vWR_IO[131],0,rtime)*vdd;
V(WR_IO[132]) <+ transition(vWR_IO[132],0,rtime)*vdd;
V(WR_IO[133]) <+ transition(vWR_IO[133],0,rtime)*vdd;
V(WR_IO[134]) <+ transition(vWR_IO[134],0,rtime)*vdd;
V(WR_IO[135]) <+ transition(vWR_IO[135],0,rtime)*vdd;
V(WR_IO[136]) <+ transition(vWR_IO[136],0,rtime)*vdd;
V(WR_IO[137]) <+ transition(vWR_IO[137],0,rtime)*vdd;
V(WR_IO[138]) <+ transition(vWR_IO[138],0,rtime)*vdd;
V(WR_IO[139]) <+ transition(vWR_IO[139],0,rtime)*vdd;
                                                
V(WR_IO[140]) <+ transition(vWR_IO[140],0,rtime)*vdd;
V(WR_IO[141]) <+ transition(vWR_IO[141],0,rtime)*vdd;
V(WR_IO[142]) <+ transition(vWR_IO[142],0,rtime)*vdd;
V(WR_IO[143]) <+ transition(vWR_IO[143],0,rtime)*vdd;
V(WR_IO[144]) <+ transition(vWR_IO[144],0,rtime)*vdd;
V(WR_IO[145]) <+ transition(vWR_IO[145],0,rtime)*vdd;
V(WR_IO[146]) <+ transition(vWR_IO[146],0,rtime)*vdd;
V(WR_IO[147]) <+ transition(vWR_IO[147],0,rtime)*vdd;
V(WR_IO[148]) <+ transition(vWR_IO[148],0,rtime)*vdd;
V(WR_IO[149]) <+ transition(vWR_IO[149],0,rtime)*vdd;
                                                
V(WR_IO[150]) <+ transition(vWR_IO[150],0,rtime)*vdd;
V(WR_IO[151]) <+ transition(vWR_IO[151],0,rtime)*vdd;
V(WR_IO[152]) <+ transition(vWR_IO[152],0,rtime)*vdd;
V(WR_IO[153]) <+ transition(vWR_IO[153],0,rtime)*vdd;
V(WR_IO[154]) <+ transition(vWR_IO[154],0,rtime)*vdd;
V(WR_IO[155]) <+ transition(vWR_IO[155],0,rtime)*vdd;
V(WR_IO[156]) <+ transition(vWR_IO[156],0,rtime)*vdd;
V(WR_IO[157]) <+ transition(vWR_IO[157],0,rtime)*vdd;
V(WR_IO[158]) <+ transition(vWR_IO[158],0,rtime)*vdd;
V(WR_IO[159]) <+ transition(vWR_IO[159],0,rtime)*vdd;
                                                
V(WR_IO[160]) <+ transition(vWR_IO[160],0,rtime)*vdd;
V(WR_IO[161]) <+ transition(vWR_IO[161],0,rtime)*vdd;
V(WR_IO[162]) <+ transition(vWR_IO[162],0,rtime)*vdd;
V(WR_IO[163]) <+ transition(vWR_IO[163],0,rtime)*vdd;
V(WR_IO[164]) <+ transition(vWR_IO[164],0,rtime)*vdd;
V(WR_IO[165]) <+ transition(vWR_IO[165],0,rtime)*vdd;
V(WR_IO[166]) <+ transition(vWR_IO[166],0,rtime)*vdd;
V(WR_IO[167]) <+ transition(vWR_IO[167],0,rtime)*vdd;
V(WR_IO[168]) <+ transition(vWR_IO[168],0,rtime)*vdd;
V(WR_IO[169]) <+ transition(vWR_IO[169],0,rtime)*vdd;
                                                
V(WR_IO[170]) <+ transition(vWR_IO[170],0,rtime)*vdd;
V(WR_IO[171]) <+ transition(vWR_IO[171],0,rtime)*vdd;
V(WR_IO[172]) <+ transition(vWR_IO[172],0,rtime)*vdd;
V(WR_IO[173]) <+ transition(vWR_IO[173],0,rtime)*vdd;
V(WR_IO[174]) <+ transition(vWR_IO[174],0,rtime)*vdd;
V(WR_IO[175]) <+ transition(vWR_IO[175],0,rtime)*vdd;
V(WR_IO[176]) <+ transition(vWR_IO[176],0,rtime)*vdd;
V(WR_IO[177]) <+ transition(vWR_IO[177],0,rtime)*vdd;
V(WR_IO[178]) <+ transition(vWR_IO[178],0,rtime)*vdd;
V(WR_IO[179]) <+ transition(vWR_IO[179],0,rtime)*vdd;
                                                
V(WR_IO[180]) <+ transition(vWR_IO[180],0,rtime)*vdd;
V(WR_IO[181]) <+ transition(vWR_IO[181],0,rtime)*vdd;
V(WR_IO[182]) <+ transition(vWR_IO[182],0,rtime)*vdd;
V(WR_IO[183]) <+ transition(vWR_IO[183],0,rtime)*vdd;
V(WR_IO[184]) <+ transition(vWR_IO[184],0,rtime)*vdd;
V(WR_IO[185]) <+ transition(vWR_IO[185],0,rtime)*vdd;
V(WR_IO[186]) <+ transition(vWR_IO[186],0,rtime)*vdd;
V(WR_IO[187]) <+ transition(vWR_IO[187],0,rtime)*vdd;
V(WR_IO[188]) <+ transition(vWR_IO[188],0,rtime)*vdd;
V(WR_IO[189]) <+ transition(vWR_IO[189],0,rtime)*vdd;
                                                
V(WR_IO[190]) <+ transition(vWR_IO[190],0,rtime)*vdd;
V(WR_IO[191]) <+ transition(vWR_IO[191],0,rtime)*vdd;
V(WR_IO[192]) <+ transition(vWR_IO[192],0,rtime)*vdd;
V(WR_IO[193]) <+ transition(vWR_IO[193],0,rtime)*vdd;
V(WR_IO[194]) <+ transition(vWR_IO[194],0,rtime)*vdd;
V(WR_IO[195]) <+ transition(vWR_IO[195],0,rtime)*vdd;
V(WR_IO[196]) <+ transition(vWR_IO[196],0,rtime)*vdd;
V(WR_IO[197]) <+ transition(vWR_IO[197],0,rtime)*vdd;
V(WR_IO[198]) <+ transition(vWR_IO[198],0,rtime)*vdd;
V(WR_IO[199]) <+ transition(vWR_IO[199],0,rtime)*vdd;
                                                
V(WR_IO[200]) <+ transition(vWR_IO[200],0,rtime)*vdd;
V(WR_IO[201]) <+ transition(vWR_IO[201],0,rtime)*vdd;
V(WR_IO[202]) <+ transition(vWR_IO[202],0,rtime)*vdd;
V(WR_IO[203]) <+ transition(vWR_IO[203],0,rtime)*vdd;
V(WR_IO[204]) <+ transition(vWR_IO[204],0,rtime)*vdd;
V(WR_IO[205]) <+ transition(vWR_IO[205],0,rtime)*vdd;
V(WR_IO[206]) <+ transition(vWR_IO[206],0,rtime)*vdd;
V(WR_IO[207]) <+ transition(vWR_IO[207],0,rtime)*vdd;
V(WR_IO[208]) <+ transition(vWR_IO[208],0,rtime)*vdd;
V(WR_IO[209]) <+ transition(vWR_IO[209],0,rtime)*vdd;
                                                
V(WR_IO[210]) <+ transition(vWR_IO[210],0,rtime)*vdd;
V(WR_IO[211]) <+ transition(vWR_IO[211],0,rtime)*vdd;
V(WR_IO[212]) <+ transition(vWR_IO[212],0,rtime)*vdd;
V(WR_IO[213]) <+ transition(vWR_IO[213],0,rtime)*vdd;
V(WR_IO[214]) <+ transition(vWR_IO[214],0,rtime)*vdd;
V(WR_IO[215]) <+ transition(vWR_IO[215],0,rtime)*vdd;
V(WR_IO[216]) <+ transition(vWR_IO[216],0,rtime)*vdd;
V(WR_IO[217]) <+ transition(vWR_IO[217],0,rtime)*vdd;
V(WR_IO[218]) <+ transition(vWR_IO[218],0,rtime)*vdd;
V(WR_IO[219]) <+ transition(vWR_IO[219],0,rtime)*vdd;
                                                
V(WR_IO[220]) <+ transition(vWR_IO[220],0,rtime)*vdd;
V(WR_IO[221]) <+ transition(vWR_IO[221],0,rtime)*vdd;
V(WR_IO[222]) <+ transition(vWR_IO[222],0,rtime)*vdd;
V(WR_IO[223]) <+ transition(vWR_IO[223],0,rtime)*vdd;
V(WR_IO[224]) <+ transition(vWR_IO[224],0,rtime)*vdd;
V(WR_IO[225]) <+ transition(vWR_IO[225],0,rtime)*vdd;
V(WR_IO[226]) <+ transition(vWR_IO[226],0,rtime)*vdd;
V(WR_IO[227]) <+ transition(vWR_IO[227],0,rtime)*vdd;
V(WR_IO[228]) <+ transition(vWR_IO[228],0,rtime)*vdd;
V(WR_IO[229]) <+ transition(vWR_IO[229],0,rtime)*vdd;
                                                
V(WR_IO[230]) <+ transition(vWR_IO[230],0,rtime)*vdd;
V(WR_IO[231]) <+ transition(vWR_IO[231],0,rtime)*vdd;
V(WR_IO[232]) <+ transition(vWR_IO[232],0,rtime)*vdd;
V(WR_IO[233]) <+ transition(vWR_IO[233],0,rtime)*vdd;
V(WR_IO[234]) <+ transition(vWR_IO[234],0,rtime)*vdd;
V(WR_IO[235]) <+ transition(vWR_IO[235],0,rtime)*vdd;
V(WR_IO[236]) <+ transition(vWR_IO[236],0,rtime)*vdd;
V(WR_IO[237]) <+ transition(vWR_IO[237],0,rtime)*vdd;
V(WR_IO[238]) <+ transition(vWR_IO[238],0,rtime)*vdd;
V(WR_IO[239]) <+ transition(vWR_IO[239],0,rtime)*vdd;
                                                
V(WR_IO[240]) <+ transition(vWR_IO[240],0,rtime)*vdd;
V(WR_IO[241]) <+ transition(vWR_IO[241],0,rtime)*vdd;
V(WR_IO[242]) <+ transition(vWR_IO[242],0,rtime)*vdd;
V(WR_IO[243]) <+ transition(vWR_IO[243],0,rtime)*vdd;
V(WR_IO[244]) <+ transition(vWR_IO[244],0,rtime)*vdd;
V(WR_IO[245]) <+ transition(vWR_IO[245],0,rtime)*vdd;
V(WR_IO[246]) <+ transition(vWR_IO[246],0,rtime)*vdd;
V(WR_IO[247]) <+ transition(vWR_IO[247],0,rtime)*vdd;
V(WR_IO[248]) <+ transition(vWR_IO[248],0,rtime)*vdd;
V(WR_IO[249]) <+ transition(vWR_IO[249],0,rtime)*vdd;
                                                
V(WR_IO[250]) <+ transition(vWR_IO[250],0,rtime)*vdd;
V(WR_IO[251]) <+ transition(vWR_IO[251],0,rtime)*vdd;
V(WR_IO[252]) <+ transition(vWR_IO[252],0,rtime)*vdd;
V(WR_IO[253]) <+ transition(vWR_IO[253],0,rtime)*vdd;
V(WR_IO[254]) <+ transition(vWR_IO[254],0,rtime)*vdd;
V(WR_IO[255]) <+ transition(vWR_IO[255],0,rtime)*vdd;



	V(WE) <+ transition(vWE,0,rtime)*vdd_pad;
	V(DRAM_EN) <+ transition(vDRAM_EN,0,rtime)*vdd_pad;
	V(DEC_EN) <+ transition(vDEC_EN,0,rtime)*vdd_pad;


end

endmodule





////scan/////






// VerilogA for CiM_65, mav_ctrl_wCompute, veriloga

`include "constants.vams"
`include "disciplines.vams"

module mav_ctrl_wCompute_256x32_wSCAN(start, CLK, ADDR, WR_IO, WE,DRAM_EN, DEC_EN, refresh_finish, start_refresh, finish_loading, requestDatafromMAV, start_mav, MSB, LSB, se, scan_clk, update_clk, scanin, scanclk_out, mav_finish_scan, start_ADC_fromchip, start_ADC_fromOutside,RSTn);
input start; electrical start; //1: write; 0: read 
input CLK; electrical CLK;
output [4:0] ADDR; electrical [4:0] ADDR; integer vADDR[4:0];
output [255:0] WR_IO; electrical [255:0] WR_IO; real vWR_IO[255:0];

output WE,DRAM_EN, DEC_EN; electrical WE,DRAM_EN, DEC_EN; real vWE, vDRAM_EN, vDEC_EN;
//output EQ; electrical EQ; real vEQ;
output start_refresh; electrical start_refresh; real vstart_refresh;
input refresh_finish; electrical refresh_finish;
output finish_loading; electrical finish_loading; real vfinish_loading;
input  requestDatafromMAV; electrical requestDatafromMAV;
output start_mav; electrical start_mav; real vstart_mav;
input MSB, LSB; electrical MSB, LSB;

input scan_clk; electrical scan_clk;
output se, update_clk, scanin; electrical se, update_clk, scanin; real vse, vupdate_clk, vscanin;
output scanclk_out; electrical scanclk_out; real vscanclk_out;
output mav_finish_scan; electrical mav_finish_scan; real vmav_finish_scan;

input start_ADC_fromchip; electrical start_ADC_fromchip;
output start_ADC_fromOutside; electrical start_ADC_fromOutside; real vstart_ADC_fromOutside;
output RSTn; electrical RSTn; real vRSTn;

parameter real vdd = 1.2;
parameter real vdd_pad = 3.3;
parameter real rtime=10p;
parameter integer max_row = 1;
parameter integer max_col = 550; //only input 16 bits data for time saving
parameter integer ADDR_count = 5;

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
parameter integer max_refreshCounter = 100000;

integer RowValue[32-1:0];
integer currentState;
integer nextState;
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

integer rand;
integer seed;
integer haveRecordRequestData;
integer finish_loading_counter;
integer scanclk_en, scan_done, this_scancol, update_count;
integer start_ADC_counter;

parameter integer start_range = 129;
integer stop_range;

analog begin
	@(initial_step) begin
		vRSTn = 1;;
start_ADC_counter = 0;
		this_scancol = 0;
		update_count = 0;
		scan_done = 0;
		scanclk_en = 0;
		vse = 0;
		vupdate_clk = 0;
	 	vscanin = 0;

		seed = 23;
		stop_range = 255;
		row_count = 0;
		//for(i = 0; i<max_col; i=i+1) begin
			//vWR_IO[i] = 0;

		
	//	end
		for(i = 0; i<ADDR_count; i=i+1) begin
			vADDR[i] = 0;
		end




		///RowValue[0] = 4398314947578;
		RowValue[0] = 4398315078651;
		RowValue[1] = 0;
		RowValue[2] = 0;
		RowValue[3] = 0;
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
		RowValue[0] = 130 + 256*127;
		RowValue[1] = 30 + 256*50;
		RowValue[2] = 200 + 256*200;
		RowValue[3] = 20 + 256*60;
		RowValue[4] = 131 + 256*131;
		RowValue[5] = 3 + 256*3;
		RowValue[6] = 2 + 256*2;
		RowValue[7] = 1 + 256*1;
*/
/*
		RowValue[0] = 0;
		RowValue[1] = 0;
		RowValue[2] = 0;
		RowValue[3] = 0;
		RowValue[4] = 0;
		RowValue[5] = 0;
		RowValue[6] = 0;
		RowValue[7] = 0;


		for(i = 0; i<max_row; i=i+1) begin
		
			rand = $dist_uniform(seed, start_range, stop_range);
			$strobe("row value = %g", rand);
			RowValue[i] = rand; 
			//assign 1 2 3 4 5 6 7 8 as row value for each row -- for test purpose
			RowValue[i] = row_value_count;
			row_value_count = row_value_count+1;

		end
*/
		vWE = 0;
		vDRAM_EN = 0;
		vDEC_EN = 0;
		//vEQ = 1;
		refreshCounter = 0;	
		vfinish_loading = 0;
		finish_loading_counter = 0;
		haveRecordRequestData = 0;
		vstart_mav = 0;
	end

	@(cross(V(CLK) - 0.5, +1)) begin
		if (V(start_ADC_fromchip) > 1) begin
			if (start_ADC_counter < 8) begin vstart_ADC_fromOutside = 0; start_ADC_counter = start_ADC_counter+1; end
			else vstart_ADC_fromOutside = 1;
		end
		else begin vstart_ADC_fromOutside = 0; start_ADC_counter=0; end

	end

//define counter	
	@(cross(V(CLK) - 0.5, -1)) begin
		refreshCounter = refreshCounter + 1;
	end

	@(cross(V(CLK) - 0.5, -1)) begin
		case(currentState)
		UPDATE: begin
			vDEC_EN = 0;
			vupdate_clk = 0; 
			vRSTn = 1;
		end
		//READ: begin
		//	vDEC_EN = 0;
		//end
		READ: begin
		if ( nextState == RESET) begin vDEC_EN = 0; end
		end
		endcase

	end
//scan
	@(cross(V(scan_clk) - 0.5, -1)) begin
		if(scanclk_en == 1) vscanclk_out = 0; 
		else vscanclk_out = 0;
		case(currentState) 
		WRITE: begin
		//$strobe("scan scan scan scan write");
		//$strobe("scan clk enable = %g", scanclk_en);
		//$strobe("scan clk = %g", vscanclk_out);
			scanclk_en = 1;
			if(this_scancol == 0) begin thisRowValue = RowValue[row_count]; end

			if(this_scancol<max_col) begin	 //i = col
				$strobe("thisRowValue = %g", thisRowValue);
				$strobe("this_scancol = %g", this_scancol);
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
		//$strobe("scan SCAN SCAN SCAN SCAN rise edge");
		//$strobe("scan clk = %g", vscanclk_out);
		//$strobe("scan clk enable = %g", scanclk_en);
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
			vmav_finish_scan = 0;
			vse = 0;
			vupdate_clk = 0;
	 		vscanin = 0;
			for(i = 0; i<max_col; i=i+1) begin
				//vWR_IO[i] = 0;

			end
			if(V(start) > 0.5) begin
				//$strobe("EQ = %g", vEQ);
				//vEQ = 0;	
				nextState = WRITE;
			//	$strobe("idle idle dile dile");
			end
			else nextState = IDLE;
			vWE = 0;
			vDRAM_EN = 0;
			vDEC_EN = 0;
			//vEQ = 1;	
			vstart_refresh = 0;
			vfinish_loading = 0;
			finish_loading_counter = 0;
			haveRecordRequestData = 0;
			vstart_mav = 0;
		end
		WRITE: begin
			vstart_mav = 0;
			vfinish_loading = 0;
			vstart_refresh = 0;
			vse = 1; //select scan propagation

			if(scan_done == 1) begin
				this_scancol = 0;
				nextState = UPDATE;
				scan_done = 0;	
			end
			else begin nextState = WRITE; end

		end
		UPDATE: begin
		
			$strobe("update update update");
			vWE = 1;
			vDRAM_EN = 1;
			vDEC_EN = 1;
			vupdate_clk = 1; 
			vRSTn = 0;
			//strobe("thisRowValue = %g", thisRowValue);
			thisRow = row_count;
			//generate address
			for(j=0; j<ADDR_count; j=j+1) begin
				vADDR[j] = thisRow%2;
				thisRow = thisRow/2;
			end
				$strobe("update_count = %g", update_count);
			if(update_count < 1) begin //keep update clk for 2 cycles
		
				nextState = UPDATE;
				update_count = update_count + 1;
			end
			else begin
				update_count = 0;

				//determine if it reach last row
				if(row_count == max_row-1) begin //reach the last row
					
					row_count = 0; //reset row count
					if(refreshCounter > max_refreshCounter) begin nextState = REFRESH;	refreshStopThisState = END_OF_WRITE; end
					else nextState = WAIT;

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
				if(refreshStopThisState == END_OF_WRITE) nextState = WAIT; 
				else if(refreshStopThisState == END_OF_READ) nextState = IDLE;
				else nextState = refreshStopThisState;
			end
		    else nextState = REFRESH;
		end


		WAIT: begin
			vmav_finish_scan = 1;
			vstart_mav = 1;
			vfinish_loading = 0;
			vstart_refresh = 0;
			//vEQ = 1;	
			vWE = 0;
			vDRAM_EN=0;
			vDEC_EN = 0;

			if(V(requestDatafromMAV) > 0.5) begin haveRecordRequestData = 1; nextState = READ; end
			else nextState = WAIT;
		end		

		RESET: begin
			vstart_mav = 1;
			finish_loading_counter = 0;
			vfinish_loading = 0;
			vstart_refresh = 0;
			//vEQ = 1;	
			vWE = 0;
			vDRAM_EN=0;
			vDEC_EN = 0;
			nextState = READ;
		end

		READ: begin
			if(finish_loading_counter<2) begin vfinish_loading = 1; finish_loading_counter = finish_loading_counter +1; end
			else vfinish_loading = 0;
			//$strobe("MAV read read read");
			vWE = 0;
			vDRAM_EN = 1;
			vDEC_EN = 1;

			thisRow = row_count;

			for(j=0; j<ADDR_count; j=j+1) begin
				vADDR[j] = thisRow%2;
				thisRow = thisRow/2;
		//		$strobe("address %g = %g", j, vADDR[j]);
			end
			//nextState = WAIT;
			if(row_count == max_row-1) begin nextState = IDLE; end
			else begin 
				if(V(requestDatafromMAV) > 0.5 && haveRecordRequestData == 0) begin 
					haveRecordRequestData = 1; 
					row_count=row_count+1; 
					nextState = RESET;
				end
				else begin row_count = row_count; nextState = READ; end
			end
		end

/*
		WAIT: begin
		//	if(finish_loading_counter<2) begin vfinish_loading = 1; finish_loading_counter = finish_loading_counter +1; end
		//	else vfinish_loading = 1;

			if(row_count == max_row-1) begin nextState = IDLE; end
			else begin 
				if(V(requestDatafromMAV) > 0.5 && haveRecordRequestData == 0) begin 
					haveRecordRequestData = 1; 
					row_count=row_count+1; 
					nextState = READ;
					vfinish_loading = 0;
					vstart_refresh = 0;
					vWE = 0;
					vDRAM_EN=0;
					vDEC_EN = 0;
				 end
				else begin row_count = row_count; nextState = WAIT; end
			end
		end
*/
		endcase
		
	end
	
	@(cross(V(requestDatafromMAV) - 0.5, -1)) begin
	haveRecordRequestData = 0;
	end

	V(start_ADC_fromOutside) <+ transition(vstart_ADC_fromOutside,0,rtime)*vdd_pad;
    V(mav_finish_scan) <+ transition(vmav_finish_scan, 0, rtime)*vdd_pad;

    V(ADDR[0]) <+ transition(vADDR[0],0,rtime)*vdd_pad;
    V(ADDR[1]) <+ transition(vADDR[1],0,rtime)*vdd_pad;
    V(ADDR[2]) <+ transition(vADDR[2],0,rtime)*vdd_pad;
    V(ADDR[3]) <+ transition(vADDR[3],0,rtime)*vdd_pad;
    V(ADDR[4]) <+ transition(vADDR[4],0,rtime)*vdd_pad;


    V(start_mav) <+ transition(vstart_mav, 0, rtime)*vdd_pad;
    V(finish_loading) <+ transition(vfinish_loading, 0, rtime)*vdd_pad;
    V(start_refresh) <+ transition(vstart_refresh,0,rtime)*vdd_pad;

	V(se) <+ transition(vse,0,rtime)*vdd_pad;
	V(update_clk) <+ transition(vupdate_clk,0,rtime)*vdd_pad;
	V(scanin) <+ transition(vscanin,0,rtime)*vdd_pad;
	V(scanclk_out) <+ transition(vscanclk_out, 0, rtime)*vdd_pad;
	V(RSTn) <+ transition(vRSTn, 0, rtime)*vdd_pad;


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
V(WR_IO[128]) <+ transition(vWR_IO[128],0,rtime)*vdd;
V(WR_IO[129]) <+ transition(vWR_IO[129],0,rtime)*vdd;

                            
V(WR_IO[130]) <+ transition(vWR_IO[130],0,rtime)*vdd;
V(WR_IO[131]) <+ transition(vWR_IO[131],0,rtime)*vdd;
V(WR_IO[132]) <+ transition(vWR_IO[132],0,rtime)*vdd;
V(WR_IO[133]) <+ transition(vWR_IO[133],0,rtime)*vdd;
V(WR_IO[134]) <+ transition(vWR_IO[134],0,rtime)*vdd;
V(WR_IO[135]) <+ transition(vWR_IO[135],0,rtime)*vdd;
V(WR_IO[136]) <+ transition(vWR_IO[136],0,rtime)*vdd;
V(WR_IO[137]) <+ transition(vWR_IO[137],0,rtime)*vdd;
V(WR_IO[138]) <+ transition(vWR_IO[138],0,rtime)*vdd;
V(WR_IO[139]) <+ transition(vWR_IO[139],0,rtime)*vdd;
                                                
V(WR_IO[140]) <+ transition(vWR_IO[140],0,rtime)*vdd;
V(WR_IO[141]) <+ transition(vWR_IO[141],0,rtime)*vdd;
V(WR_IO[142]) <+ transition(vWR_IO[142],0,rtime)*vdd;
V(WR_IO[143]) <+ transition(vWR_IO[143],0,rtime)*vdd;
V(WR_IO[144]) <+ transition(vWR_IO[144],0,rtime)*vdd;
V(WR_IO[145]) <+ transition(vWR_IO[145],0,rtime)*vdd;
V(WR_IO[146]) <+ transition(vWR_IO[146],0,rtime)*vdd;
V(WR_IO[147]) <+ transition(vWR_IO[147],0,rtime)*vdd;
V(WR_IO[148]) <+ transition(vWR_IO[148],0,rtime)*vdd;
V(WR_IO[149]) <+ transition(vWR_IO[149],0,rtime)*vdd;
                                                
V(WR_IO[150]) <+ transition(vWR_IO[150],0,rtime)*vdd;
V(WR_IO[151]) <+ transition(vWR_IO[151],0,rtime)*vdd;
V(WR_IO[152]) <+ transition(vWR_IO[152],0,rtime)*vdd;
V(WR_IO[153]) <+ transition(vWR_IO[153],0,rtime)*vdd;
V(WR_IO[154]) <+ transition(vWR_IO[154],0,rtime)*vdd;
V(WR_IO[155]) <+ transition(vWR_IO[155],0,rtime)*vdd;
V(WR_IO[156]) <+ transition(vWR_IO[156],0,rtime)*vdd;
V(WR_IO[157]) <+ transition(vWR_IO[157],0,rtime)*vdd;
V(WR_IO[158]) <+ transition(vWR_IO[158],0,rtime)*vdd;
V(WR_IO[159]) <+ transition(vWR_IO[159],0,rtime)*vdd;
                                                
V(WR_IO[160]) <+ transition(vWR_IO[160],0,rtime)*vdd;
V(WR_IO[161]) <+ transition(vWR_IO[161],0,rtime)*vdd;
V(WR_IO[162]) <+ transition(vWR_IO[162],0,rtime)*vdd;
V(WR_IO[163]) <+ transition(vWR_IO[163],0,rtime)*vdd;
V(WR_IO[164]) <+ transition(vWR_IO[164],0,rtime)*vdd;
V(WR_IO[165]) <+ transition(vWR_IO[165],0,rtime)*vdd;
V(WR_IO[166]) <+ transition(vWR_IO[166],0,rtime)*vdd;
V(WR_IO[167]) <+ transition(vWR_IO[167],0,rtime)*vdd;
V(WR_IO[168]) <+ transition(vWR_IO[168],0,rtime)*vdd;
V(WR_IO[169]) <+ transition(vWR_IO[169],0,rtime)*vdd;
                                                
V(WR_IO[170]) <+ transition(vWR_IO[170],0,rtime)*vdd;
V(WR_IO[171]) <+ transition(vWR_IO[171],0,rtime)*vdd;
V(WR_IO[172]) <+ transition(vWR_IO[172],0,rtime)*vdd;
V(WR_IO[173]) <+ transition(vWR_IO[173],0,rtime)*vdd;
V(WR_IO[174]) <+ transition(vWR_IO[174],0,rtime)*vdd;
V(WR_IO[175]) <+ transition(vWR_IO[175],0,rtime)*vdd;
V(WR_IO[176]) <+ transition(vWR_IO[176],0,rtime)*vdd;
V(WR_IO[177]) <+ transition(vWR_IO[177],0,rtime)*vdd;
V(WR_IO[178]) <+ transition(vWR_IO[178],0,rtime)*vdd;
V(WR_IO[179]) <+ transition(vWR_IO[179],0,rtime)*vdd;
                                                
V(WR_IO[180]) <+ transition(vWR_IO[180],0,rtime)*vdd;
V(WR_IO[181]) <+ transition(vWR_IO[181],0,rtime)*vdd;
V(WR_IO[182]) <+ transition(vWR_IO[182],0,rtime)*vdd;
V(WR_IO[183]) <+ transition(vWR_IO[183],0,rtime)*vdd;
V(WR_IO[184]) <+ transition(vWR_IO[184],0,rtime)*vdd;
V(WR_IO[185]) <+ transition(vWR_IO[185],0,rtime)*vdd;
V(WR_IO[186]) <+ transition(vWR_IO[186],0,rtime)*vdd;
V(WR_IO[187]) <+ transition(vWR_IO[187],0,rtime)*vdd;
V(WR_IO[188]) <+ transition(vWR_IO[188],0,rtime)*vdd;
V(WR_IO[189]) <+ transition(vWR_IO[189],0,rtime)*vdd;
                                                
V(WR_IO[190]) <+ transition(vWR_IO[190],0,rtime)*vdd;
V(WR_IO[191]) <+ transition(vWR_IO[191],0,rtime)*vdd;
V(WR_IO[192]) <+ transition(vWR_IO[192],0,rtime)*vdd;
V(WR_IO[193]) <+ transition(vWR_IO[193],0,rtime)*vdd;
V(WR_IO[194]) <+ transition(vWR_IO[194],0,rtime)*vdd;
V(WR_IO[195]) <+ transition(vWR_IO[195],0,rtime)*vdd;
V(WR_IO[196]) <+ transition(vWR_IO[196],0,rtime)*vdd;
V(WR_IO[197]) <+ transition(vWR_IO[197],0,rtime)*vdd;
V(WR_IO[198]) <+ transition(vWR_IO[198],0,rtime)*vdd;
V(WR_IO[199]) <+ transition(vWR_IO[199],0,rtime)*vdd;
                                                
V(WR_IO[200]) <+ transition(vWR_IO[200],0,rtime)*vdd;
V(WR_IO[201]) <+ transition(vWR_IO[201],0,rtime)*vdd;
V(WR_IO[202]) <+ transition(vWR_IO[202],0,rtime)*vdd;
V(WR_IO[203]) <+ transition(vWR_IO[203],0,rtime)*vdd;
V(WR_IO[204]) <+ transition(vWR_IO[204],0,rtime)*vdd;
V(WR_IO[205]) <+ transition(vWR_IO[205],0,rtime)*vdd;
V(WR_IO[206]) <+ transition(vWR_IO[206],0,rtime)*vdd;
V(WR_IO[207]) <+ transition(vWR_IO[207],0,rtime)*vdd;
V(WR_IO[208]) <+ transition(vWR_IO[208],0,rtime)*vdd;
V(WR_IO[209]) <+ transition(vWR_IO[209],0,rtime)*vdd;
                                                
V(WR_IO[210]) <+ transition(vWR_IO[210],0,rtime)*vdd;
V(WR_IO[211]) <+ transition(vWR_IO[211],0,rtime)*vdd;
V(WR_IO[212]) <+ transition(vWR_IO[212],0,rtime)*vdd;
V(WR_IO[213]) <+ transition(vWR_IO[213],0,rtime)*vdd;
V(WR_IO[214]) <+ transition(vWR_IO[214],0,rtime)*vdd;
V(WR_IO[215]) <+ transition(vWR_IO[215],0,rtime)*vdd;
V(WR_IO[216]) <+ transition(vWR_IO[216],0,rtime)*vdd;
V(WR_IO[217]) <+ transition(vWR_IO[217],0,rtime)*vdd;
V(WR_IO[218]) <+ transition(vWR_IO[218],0,rtime)*vdd;
V(WR_IO[219]) <+ transition(vWR_IO[219],0,rtime)*vdd;
                                                
V(WR_IO[220]) <+ transition(vWR_IO[220],0,rtime)*vdd;
V(WR_IO[221]) <+ transition(vWR_IO[221],0,rtime)*vdd;
V(WR_IO[222]) <+ transition(vWR_IO[222],0,rtime)*vdd;
V(WR_IO[223]) <+ transition(vWR_IO[223],0,rtime)*vdd;
V(WR_IO[224]) <+ transition(vWR_IO[224],0,rtime)*vdd;
V(WR_IO[225]) <+ transition(vWR_IO[225],0,rtime)*vdd;
V(WR_IO[226]) <+ transition(vWR_IO[226],0,rtime)*vdd;
V(WR_IO[227]) <+ transition(vWR_IO[227],0,rtime)*vdd;
V(WR_IO[228]) <+ transition(vWR_IO[228],0,rtime)*vdd;
V(WR_IO[229]) <+ transition(vWR_IO[229],0,rtime)*vdd;
                                                
V(WR_IO[230]) <+ transition(vWR_IO[230],0,rtime)*vdd;
V(WR_IO[231]) <+ transition(vWR_IO[231],0,rtime)*vdd;
V(WR_IO[232]) <+ transition(vWR_IO[232],0,rtime)*vdd;
V(WR_IO[233]) <+ transition(vWR_IO[233],0,rtime)*vdd;
V(WR_IO[234]) <+ transition(vWR_IO[234],0,rtime)*vdd;
V(WR_IO[235]) <+ transition(vWR_IO[235],0,rtime)*vdd;
V(WR_IO[236]) <+ transition(vWR_IO[236],0,rtime)*vdd;
V(WR_IO[237]) <+ transition(vWR_IO[237],0,rtime)*vdd;
V(WR_IO[238]) <+ transition(vWR_IO[238],0,rtime)*vdd;
V(WR_IO[239]) <+ transition(vWR_IO[239],0,rtime)*vdd;
                                                
V(WR_IO[240]) <+ transition(vWR_IO[240],0,rtime)*vdd;
V(WR_IO[241]) <+ transition(vWR_IO[241],0,rtime)*vdd;
V(WR_IO[242]) <+ transition(vWR_IO[242],0,rtime)*vdd;
V(WR_IO[243]) <+ transition(vWR_IO[243],0,rtime)*vdd;
V(WR_IO[244]) <+ transition(vWR_IO[244],0,rtime)*vdd;
V(WR_IO[245]) <+ transition(vWR_IO[245],0,rtime)*vdd;
V(WR_IO[246]) <+ transition(vWR_IO[246],0,rtime)*vdd;
V(WR_IO[247]) <+ transition(vWR_IO[247],0,rtime)*vdd;
V(WR_IO[248]) <+ transition(vWR_IO[248],0,rtime)*vdd;
V(WR_IO[249]) <+ transition(vWR_IO[249],0,rtime)*vdd;
                                                
V(WR_IO[250]) <+ transition(vWR_IO[250],0,rtime)*vdd;
V(WR_IO[251]) <+ transition(vWR_IO[251],0,rtime)*vdd;
V(WR_IO[252]) <+ transition(vWR_IO[252],0,rtime)*vdd;
V(WR_IO[253]) <+ transition(vWR_IO[253],0,rtime)*vdd;
V(WR_IO[254]) <+ transition(vWR_IO[254],0,rtime)*vdd;
V(WR_IO[255]) <+ transition(vWR_IO[255],0,rtime)*vdd;



	V(WE) <+ transition(vWE,0,rtime)*vdd_pad;
	V(DRAM_EN) <+ transition(vDRAM_EN,0,rtime)*vdd_pad;
	V(DEC_EN) <+ transition(vDEC_EN,0,rtime)*vdd_pad;


end

endmodule


















