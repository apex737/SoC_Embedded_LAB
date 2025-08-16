`timescale 1ns / 1ps
module tb_power_of_8_hs;
// DUT Port List
reg clk , reset;
reg 			s_valid;
wire			s_ready;
wire	[31:0] 	s_value;
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
$dumpfile("out.vvp");
$dumpvars(0, tb_power_of_8_hs);
//initialize value
$display("initialize value [%d]", $time);
    reset <= 0;
    clk   <= 0;
	i_run <= 0;
	fd <= $fopen("rtl_v.txt","w"); 
// reset gen
$display("Reset! [%d]", $time);
# 100
    reset <= 1;
# 10
    reset <= 0;
# 10
@(posedge clk);
$display("Start! [%d]", $time);
i_run <= 1;
@(posedge clk);
i_run <= 0;
wait(is_o_done);
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
wire	  is_i_done = (i_hs_cnt == 99) & i_hs;

// Step 1. always block to update state 
always @(posedge clk) begin
    if(reset) begin
		c_i_state <= S_IDLE;
    end else begin
		c_i_state <= n_i_state;
    end
end

// Step 2. always block to compute n_i_state
always @(*) 
begin
	n_i_state = S_IDLE; // To prevent Latch.
	case(c_i_state)
	S_IDLE: if(i_run)
				n_i_state = S_RUN;
	S_RUN : if(is_i_done)
				n_i_state = S_DONE;
			else 
				n_i_state = S_RUN;
	S_DONE: n_i_state = S_IDLE;
	endcase
end 


// s_value gen
always @(posedge clk) begin
	if(n_i_state == S_RUN) begin
		//s_valid <= 1; // 0~1
		s_valid <= $urandom%2; // 0~1
	end	else begin
		s_valid <= 0; 
	end
end 
assign s_value = i_hs_cnt;

always @(posedge clk) begin
	if(reset) begin
		i_hs_cnt <= 0;
	end
	else if(i_hs & n_i_state == S_RUN) begin
		i_hs_cnt <= i_hs_cnt + 1;
	end
end


//////////////////  output model /////////////////
/////// Type ////////
reg [1:0] c_o_state; // Current state  (F/F)
reg [1:0] n_o_state; // Next state (Variable in Combinational Logic)

assign is_o_done = (o_hs_cnt == 99) & o_hs;

// Step 1. always block to update state 
always @(posedge clk) begin
    if(reset) begin
		c_o_state <= S_IDLE;
    end else begin
		c_o_state <= n_o_state;
    end
end

// Step 2. always block to compute n_o_state
always @(*) 
begin
	n_o_state = S_IDLE; // To prevent Latch.
	case(c_o_state)
	S_IDLE: if(i_run)
				n_o_state = S_RUN;
	S_RUN : if(is_o_done)
				n_o_state = S_DONE;
			else 
				n_o_state = S_RUN; 
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

always @(posedge clk) begin
	if(reset) begin
		o_hs_cnt <= 0;
	end
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
  .reset_n (~reset), // rst connect
	.s_valid (s_valid),
	.s_ready (s_ready),
  .s_data (s_value),
	.m_valid (m_valid),
	.m_ready (m_ready),
  .m_data (m_power_of_8)
    );
endmodule
