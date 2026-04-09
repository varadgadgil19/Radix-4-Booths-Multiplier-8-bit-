module pp_operation(
  input  [7:0] M,
  input  [2:0] Q,
  output reg [15:0] pp
);

  wire [8:0] M_ext;
  wire [8:0] M_2s;

  assign M_ext = {M[7], M};
  assign M_2s  = ~M_ext + 1;

  always @(*) begin
    case (Q)
      3'b000, 3'b111: pp = 16'd0;
      3'b001, 3'b010: pp = {{7{M_ext[8]}}, M_ext};
      3'b011:         pp = {{6{M_ext[8]}}, M_ext, 1'b0};
      3'b100:         pp = {{6{M_2s[8]}}, M_2s, 1'b0};
      3'b101, 3'b110: pp = {{7{M_2s[8]}}, M_2s};
      default:        pp = 16'd0;
    endcase
  end

endmodule
