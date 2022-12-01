`timescale 1ns / 1ps
`include "para.v"




module control_unit(
    input clock,
    input reset,
    input [31:0] instr,
    input [53:0] if_instr,
    input [53:0] id_instr,
    input [53:0] ex_instr,
    input [53:0] mem_instr,
    input [53:0] wb_instr,
	input [31:0]C,
	input zero,
	input dm_data,
	output reg [31:0]A,
	output reg [31:0]B,
    output reg [31:0] pc,
    output reg dm_we,
    output reg dm_re,
	output reg dm_addr,
	output reg dm_wdata,
	output reg [3:0] aluc,
	output reg [31:0]id_ir, 
	output reg [31:0]ex_ir, 
	output reg [31:0]mem_ir,
	output reg [31:0]wb_ir
    );
	reg [2:0] current_inst_type,last_inst_type;
	
//	reg [31:0] id_ir, ex_ir, mem_ir, wb_ir;
	reg [31:0] rs, rt, rd ,sa , res,res2,pc_reg,if_ir;
	reg [31:0] rs2,rt2,rd2,sa2;
	reg [31:0] rf[31:0];//¼Ä´æÆ÷¶Ñ
	reg [2:0]i;
    reg z;
    reg [3:0] stall;
	//************ IF ************//
	always @(posedge clock or posedge reset)
		begin
			if (reset)
				begin
					last_inst_type= `FIRSTT;
					id_ir <=`NOP;
					if_ir <=`NOP;
					pc <= 32'h0040_0000;
					stall=0;
				end
			else if(stall!=3)
				begin    
				    
//				   if(z&&if_instr[24]||!z&&if_instr[25])
//					begin
//						if(if_ir[15])begin
//							pc=pc_reg+{14'b11_1111_1111_1111,if_ir[15:0],2'b00};
//							last_inst_type=`FIRSTT;
//							id_ir<=`NOP;
//							ex_ir<=`NOP;
//							mem_ir<=`NOP;
//							wb_ir<=`NOP;
							
//						end
//						else
//						begin
//							pc=pc_reg+{14'b00_0000_0000_0000,if_ir[15:0],2'b00};
//							last_inst_type=`FIRSTT;
//							id_ir=`NOP;
//							ex_ir=`NOP;
//							mem_ir=`NOP;
//							wb_ir=pc_reg;
//						end
//					end
				    
				    
					if (if_instr[0]||if_instr[2]||if_instr[8]||if_instr[17]||if_instr[11]||if_instr[24]||if_instr[25])
					begin
						current_inst_type=`FOURT1;
					end
				    else if(if_instr[23])begin
						current_inst_type=`FOURT2;
					end
				    else if(if_instr[22])begin
						current_inst_type=`FIVET;
					end
					else begin
						current_inst_type=`TWOT;
					end
					if(current_inst_type==last_inst_type||last_inst_type==`FIRSTT)begin
						i=0;
						id_ir <= instr;
						if(if_instr[29])
						begin
							pc <= {pc[31:28],instr[25:0],2'b00};
							last_inst_type=`FIRSTT;
						end
						else
						begin
							pc = pc + 4;	
						end
						
					end
					else if(last_inst_type==`FOURT1||last_inst_type==`FOURT2)
					begin
						i=i+1;
						id_ir <=`NOP;
						if(i>=4)
						begin
							i=0;
							id_ir =instr;
							last_inst_type=current_inst_type;
						end
					end
					else if(last_inst_type==`FIVET)
					begin
						i=i+1;
						id_ir =`NOP;
						if(i>=5)
						begin
							i=0;
							id_ir =instr;
							last_inst_type=current_inst_type;
						end
					end
					
					if(if_instr[24]||if_instr[25])
					begin
					   pc_reg=pc;
					   stall=stall+1;
                   end
				end
		end
		
		reg [31:0]test_rs,test_rs2;
	//************ ID ************//
	always @(posedge clock or posedge reset)
		begin
			if (reset)
				begin
					ex_ir <= `NOP;
					A <= 0;
					B <= 0;
				end
			
			else if(stall!=3)
				begin
//				test_rs=rf[id_ir[25:21]];
                    if(id_instr[24]||id_instr[25])
					begin
					   stall=stall+1;
                   end
                   
					ex_ir <= id_ir;
					
					if(!id_instr[29])
					begin
						if((id_ir[25:21]==wb_ir[15:11]) && ( wb_instr[0] || wb_instr[2] || wb_instr[8] || wb_instr[11] ) 
						|| (id_ir[25:21]==wb_ir[20:16]) && ( wb_instr[22] || wb_instr[17] ))
						begin
							rs=C;
						end
						else 
						begin
							rs=rf[id_ir[25:21]];
						end

						if((id_ir[20:16]==wb_ir[15:11]) && ( wb_instr[0] || wb_instr[2] || wb_instr[8] || wb_instr[11] ) 
						|| (id_ir[20:16]==wb_ir[20:16]) && ( wb_instr[22] || wb_instr[17] ))
						begin
							rt=C;
						end
						else begin
							rt=rf[id_ir[20:16]];
						end

						if((id_ir[15:11]==wb_ir[15:11]) && ( wb_instr[0] || wb_instr[2] || wb_instr[8] || wb_instr[11] ) 
						|| (id_ir[15:11]==wb_ir[20:16]) && ( wb_instr[22] || wb_instr[17] ))
						begin
							rd=C;
						end
						else begin
							rd=rf[id_ir[15:11]];
						end
						
						if((id_ir[10:6]==wb_ir[15:11]) && ( wb_instr[0] || wb_instr[2] || wb_instr[8] || wb_instr[11] ) 
						|| (id_ir[10:6]==wb_ir[20:16]) && ( wb_instr[22] || wb_instr[17] ))
						begin
							sa=C;
						end
						else begin
							sa={17'b0_0000_0000_0000_0000,id_ir[10:6]};
//							sa=1;
						end
					end
//					ex_ir <= id_ir;
					
				end
		end

	//************ EX ************//
    
       
	always @(negedge clock or posedge reset)
		begin
			if (reset)
				begin
					mem_ir <= `NOP;

				end
			
			else if(stall!=3)
				begin 
                    if(ex_instr[24]||ex_instr[25])
					begin
					   stall=stall+1;
                   end
				
					 aluc[3] = ex_instr[9] || ex_instr[10] || ex_instr[11] || ex_instr[12] || ex_instr[13] || ex_instr[14] || ex_instr[15] || ex_instr[26] || ex_instr[27] || ex_instr[28];
    				 aluc[2] = ex_instr[4] || ex_instr[5] || ex_instr[6] || ex_instr[7] || ex_instr[10] || ex_instr[11] || ex_instr[12] || ex_instr[13] || ex_instr[14] || ex_instr[15] || ex_instr[19] || ex_instr[20] || ex_instr[21];
    				 aluc[1] = ex_instr[0] || ex_instr[2] || ex_instr[6] || ex_instr[7] || ex_instr[8] || ex_instr[9] || ex_instr[10] || ex_instr[13] || ex_instr[17] || ex_instr[21] || ex_instr[24] || ex_instr[25] || ex_instr[26] || ex_instr[27] || ex_instr[52] ;
    				 aluc[0] = ex_instr[2] || ex_instr[3] || ex_instr[5] || ex_instr[7] || ex_instr[8] || ex_instr[11] || ex_instr[14] || ex_instr[20] || ex_instr[24] || ex_instr[25] || ex_instr[26] || ex_instr[52];
                    test_rs2=rs;
					if((ex_ir[25:21]==wb_ir[15:11]) && ( wb_instr[0] || wb_instr[2] || wb_instr[8] || wb_instr[11] ) 
					|| (ex_ir[25:21]==wb_ir[20:16]) && ( wb_instr[22] || wb_instr[17] ))
					begin
						rs2=C;
					end
					else
					begin
					   rs2=rs;
					end

					if((ex_ir[20:16]==wb_ir[15:11] )&& ( wb_instr[0] || wb_instr[2] || wb_instr[8] || wb_instr[11] )  
					|| (ex_ir[20:16]==wb_ir[20:16] )&& ( wb_instr[22] || wb_instr[17] ))
					begin
						rt2=C;
					end
					else 
					begin
					   rt2=rt;
					end


					if((ex_ir[15:11]==wb_ir[15:11]) && ( wb_instr[0] || wb_instr[2] || wb_instr[8] || wb_instr[11] ) 
					|| (ex_ir[15:11]==wb_ir[20:16]) && ( wb_instr[22] || wb_instr[17] ))
					begin
						rd2=C;
					end
					else
					begin
					   rd2=rd;
					end

					
					if((ex_ir[10:6]==wb_ir[15:11]) && ( wb_instr[0] || wb_instr[2] || wb_instr[8] || wb_instr[11] ) 
					|| (ex_ir[10:6]==wb_ir[20:16] )&& ( wb_instr[22] || wb_instr[17] ))
					begin
						sa2=C;
					end
					else
					begin
					   sa2=sa;
					end

					//----------ex->ex(lw)-------
//					if(ex_ir[25:21]==mem_ir[20:16] && ( wb_instr[22] ))
//					begin
//						rs2=C;
//					end
//					else
//					begin
//					   rs2=rs;
//					end


//					if(ex_ir[20:16]==mem_ir[20:16] && ( wb_instr[22] ))
//					begin
//						rt2=C;
//					end
//					else
//					begin
//					   rt2=rt;
//					end


//					if(ex_ir[15:11]==mem_ir[20:16] && ( wb_instr[22] ))
//					begin
//						rd2=C;
//					end
//					else
//					begin
//					   rd2=rd;
//					end

					
//					if(ex_ir[10:6]==mem_ir[20:16] && ( wb_instr[22] ))
//					begin
//						sa2=C;
//					end
//					else
//					begin
//					   sa2=sa;
//					end

					//--------------------
					if(ex_instr[22]||ex_instr[23])
						mem_ir <= ex_ir;
//					else if(ex_instr[24]||ex_instr[25])
//					   if_ir=ex_ir;
					else
						wb_ir <= ex_ir;
					
					if(ex_instr[0]||ex_instr[17]||ex_instr[2]||ex_instr[8]||ex_instr[22]||ex_instr[24]||ex_instr[25]||ex_instr[23])begin
						A=rs2;
					end
					else if(ex_instr[11])begin
						A=sa2;
					end

					if(ex_instr[0]||ex_instr[2]||ex_instr[8]||ex_instr[24]||ex_instr[25]||ex_instr[11])begin
						B=rt2;
					end
					else if(ex_instr[17]||ex_instr[22]||ex_instr[23])begin
						if(ex_ir[15])
						begin
							B={16'b1111_1111_1111_1111,ex_ir[15:0]};
						end
						else
						begin
							B={16'b0000_0000_0000_0000,ex_ir[15:0]};
						end
					end
					
                   
				end
					
		end


	//************ MEM ************//

	always @(posedge clock or posedge reset)
		begin
			if (reset)
				begin
					wb_ir <= `NOP;
					dm_re=0;
				end
			
			else 
				begin
					if(mem_instr[22]||mem_instr[23])
						wb_ir <= mem_ir;
					if (mem_instr[22])
					begin
						dm_re=1;
						dm_addr=res[10:0];
						res=dm_data;
					end
					else if(mem_instr[23])
					begin
						dm_we=1;
						dm_addr=res[10:0];
						dm_wdata=rt;
					end
				end
		end
			
	//************ WB ************//
	always @(posedge clock or posedge reset)
		begin
			if (reset)
				begin
					rf[0] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[1] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[2] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[3] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[4] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[5] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[6] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[7] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[8] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[9] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[10] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[11] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[12] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[13] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[14] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[15] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[16] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[17] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[18] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[19] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[20] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[21] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[22] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[23] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[24] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[25] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[26] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[27] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[28] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[29] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[30] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
					rf[31] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
				end
			
			else 
				begin
				    z=zero;
				    
				    res=C;
				    
					if(wb_instr[0]||wb_instr[2]||wb_instr[22]||wb_instr[17]||wb_instr[11])begin
						res=C;
					end
					else if(wb_instr[8])
					begin
						if(res[31])
							res=1;
						else
							res=0;
					end

					if (wb_instr[0]||wb_instr[2]||wb_instr[8]||wb_instr[11])
						rf[wb_ir[15:11]] <= res;
					else if(wb_instr[17]||wb_instr[22])
						rf[wb_ir[20:16]] <= res;
					else if(z&&wb_instr[24]||!z&&wb_instr[25])
					begin
					
						if(wb_ir[15])begin
							pc=pc_reg+{14'b11_1111_1111_1111,wb_ir[15:0],2'b00};
							last_inst_type=`FIRSTT;
							id_ir<=`NOP;
							ex_ir<=`NOP;
							mem_ir<=`NOP;
							wb_ir<=`NOP;
							stall=0;
						end
						else
						begin
							pc=pc_reg+{14'b00_0000_0000_0000,wb_ir[15:0],2'b00};
							last_inst_type=`FIRSTT;
							id_ir<=`NOP;
							ex_ir<=`NOP;
							mem_ir<=`NOP;
							wb_ir<=`NOP;
							stall=0;
						end
						
					end
                    stall=0;    
				end
		end

endmodule
