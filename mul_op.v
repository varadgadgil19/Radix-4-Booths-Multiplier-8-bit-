module mul_op(
  input clk, rst,
  input  [7:0] M, Q,
  input start,
  output reg [15:0] P,
  output reg done
);

  wire [15:0] pp1, pp2, pp3, pp4;
  wire cr1, cr2, cr3;

  //  Append Q-1 = 0
  wire [8:0] Qn;
  wire [15:0] odd_sum, even_sum, final_sum;
  wire [15:0] odd_in2, even_in2;
  reg [15:0] even_acc, odd_acc;
  reg [1:0] count;
  reg busy;
  assign Qn = {Q, 1'b0};
	
  pp_operation p1 (M, Qn[2:0], pp1);
  pp_operation p2 (M, Qn[4:2], pp2);
  pp_operation p3 (M, Qn[6:4], pp3);
  pp_operation p4 (M, Qn[8:6], pp4);
  
  always@(posedge clk or negedge rst)begin
    if(!rst)begin
      count <= 2'd0;
      busy <= 1'b0;
    end
    else if(start && !busy)begin
      count <= 2'd0;
      busy <= 1'b1;
    end
    else if(count == 2'd2)begin
      count <= 2'd0;
      busy <= 1'b0;
    end
    else
      count <= count + 1'b1;
  end

  
  assign odd_in2 = (count == 2'd1) ? (pp3<<4) : 16'd0;
  assign even_in2 = (count == 2'd1) ? (pp4<<6) : 16'd0;

  cla16 odd_add (odd_acc, odd_in2, 1'b0, odd_sum, c1);
  cla16 even_add (even_acc, even_in2, 1'b0, even_sum, c2);
  cla16 final_add (odd_acc, even_acc, 1'b0, final_sum, c3);
  
  always@(posedge clk or negedge rst)begin
    if(!rst)begin
      odd_acc <= 16'd0;
      even_acc <= 16'd0;
    end
    else if (busy)begin
      case(count)
        2'd0 : begin 
          odd_acc <= pp1; 
          even_acc <= (pp2 << 2); 
        end
        2'd1 : begin 
          odd_acc <= odd_sum; 
          even_acc <= even_sum; 
        end
      endcase
    end
  end
  
  always@(posedge clk or negedge rst)begin
    if(!rst)begin
      P <= 16'd0;
      done <= 1'd0;
    end
    else  begin
      done <= 1'd0;
      
      if(busy && count == 2'd2)begin
        P <= final_sum;
        done <= 1'd1;
      end
    end
  end


endmodule
