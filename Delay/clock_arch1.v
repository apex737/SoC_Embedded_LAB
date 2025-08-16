module clock_arch1 (
  input clk, rst, en,
  output reg [5:0] sec_cnt, // clog2(60)
  output reg [5:0] min_cnt, // clog2(60)
  output reg [4:0] hour_cnt // clog2(24)
);

wire w_sec_tick;
gen_sec u_gen_sec (
  clk, rst, en, w_sec_tick
);

wire sec_th = sec_cnt == 60-1;
wire min_th = min_cnt == 60-1;
wire hour_th = hour_cnt == 24-1;

always@(posedge clk) begin
  if(rst) begin
    sec_cnt <= 0;
    min_cnt <= 0;
    hour_cnt <= 0;
  end
  else if (w_sec_tick) begin
    if(sec_th) begin
      sec_cnt <= 0;
      if(min_th) begin
          min_cnt <= 0;
          hour_cnt <= hour_th ? 0 : hour_cnt + 1;
      end else begin
          min_cnt <= min_cnt + 1;
      end 
    end else begin
        sec_cnt <= sec_cnt + 1;
    end
  end
end
  
endmodule