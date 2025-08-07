`timescale 1ns / 1ps
module tb_power_of_8_hs;
//DUT Port List
reg clk , rstn;
reg 			s_valid;
wire			s_ready;
wire	[31:0] 	s_data;
wire 			m_valid;
reg				m_ready;
wire 	[63:0] 	m_power_of_8;
// clk gen
always
    #5 clk = ~clk;

integer fd;

wire i_hs = s_valid & s_ready;
wire o_hs = m_valid & m_ready;

reg i_run;
wire is_o_done;

reg	[31:0] i_hs_cnt;
reg	[31:0] o_hs_cnt;

/////// Main ////////
initial begin
// dumpfile for iverilog
$dumpfile("out.vvd");
$dumpvars(0, tb_power_of_8_hs);

// initialize value
$display("initialize value [%d]", $time);
    rstn <= 1;
    clk     <= 0;
	i_run <= 0;
	fd <= $fopen("rtl_v.txt","w"); 
// rstn gen
$display("Reset! [%d]", $time);
# 100
    rstn <= 0;
# 10
    rstn <= 1;
# 10
@(posedge clk);

$display("Start! [%d]", $time);
i_run <= 1;
@(posedge clk);
i_run <= 0;

wait(is_o_done); // Stall Initial Block Until Simulation Ends
# 100
$display("Finish! [%d]", $time);
$fclose(fd);
$finish;
end


//////////////////  input model /////////////////   
/////// Local Param. to define state ////////
localparam S_IDLE	= 2'b00;
localparam S_RUN	= 2'b01;
localparam S_DONE  	= 2'b10;

/////// Type ////////
reg [1:0] c_i_state; // Current state  (F/F)
reg [1:0] n_i_state; // Next state (Variable in Combinational Logic)
wire	  is_i_done = (i_hs_cnt == 100) & i_hs;

// Step 1. always block to update state 
always @(posedge clk or negedge rstn) begin
    if(!rstn) c_i_state <= S_IDLE;
		else c_i_state <= n_i_state;
end

// Step 2. always block to compute n_i_state
always @(*) begin
	n_i_state = S_IDLE; // To prevent Latch.
	case(c_i_state)
		S_IDLE: if(i_run) n_i_state = S_RUN;				
		S_RUN : n_i_state = is_i_done ? S_DONE : S_RUN;
		S_DONE: n_i_state = S_IDLE;
	endcase
end 

// s_data gen
always @(posedge clk) begin
	s_valid <= (n_i_state == S_RUN) ? $urandom%2 : 0; 
end 
assign s_data = i_hs_cnt;

always @(posedge clk or negedge rstn) begin
	if(!rstn) i_hs_cnt <= 0;
	else if(i_hs & n_i_state == S_RUN) begin
		i_hs_cnt <= i_hs_cnt + 1;
	end
end


//////////////////  output model /////////////////
/////// Type ////////
reg [1:0] c_o_state; // Current state  (F/F)
reg [1:0] n_o_state; // Next state (Variable in Combinational Logic)

assign is_o_done = (o_hs_cnt == 100) & o_hs;

// Step 1. always block to update state 
always @(posedge clk or negedge rstn) begin
    if(!rstn) c_o_state <= S_IDLE;
		else c_o_state <= n_o_state;
end

// Step 2. always block to compute n_o_state
always @(*) begin
	n_o_state = S_IDLE; // To prevent Latch.
	case(c_o_state)
		S_IDLE: if(i_run) n_o_state = S_RUN;
		S_RUN : n_o_state = is_o_done ? S_DONE : S_RUN;
		S_DONE: n_o_state = S_IDLE;
	endcase
end 

always @(posedge clk) begin
	if(n_o_state == S_RUN) begin
		//m_ready <= 1; // 0~1
		//m_ready <= $urandom%2; // 0~1
		m_ready <= $urandom_range(0,1); // 0~1
	end	else begin
		m_ready <= 0; 
	end
end 
assign o_value = o_hs_cnt;

always @(posedge clk or negedge rstn) begin
	if(!rstn) o_hs_cnt <= 0;
	else if(o_hs & n_o_state == S_RUN) begin
		o_hs_cnt <= o_hs_cnt + 1;
	end
end

// file write
always @(posedge clk) begin
	if(o_hs) begin
		$fwrite(fd,"result = %0d\n", m_power_of_8);
	end
end

// Call DUT
pow8 u_power_of_8_hs(
  .clk (clk),
  .rstn (rstn),
	.s_valid (s_valid),
	.s_ready (s_ready),
  .s_data (s_data),
	.m_valid (m_valid),
	.m_ready (m_ready),
  .m_data (m_power_of_8)
);
endmodule
