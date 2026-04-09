module cla16(
  input  [15:0] A, B,
  input  cin,
  output [15:0] sum,
  output cout
);

  wire [3:0] Gg, Pg;
  wire [4:0] C;

  assign C[0] = cin;

  assign C[1] = Gg[0] | (Pg[0] & C[0]);
  assign C[2] = Gg[1] | (Pg[1] & Gg[0]) | (Pg[1] & Pg[0] & C[0]);
  assign C[3] = Gg[2] | (Pg[2] & Gg[1]) | (Pg[2] & Pg[1] & Gg[0]) 
                         | (Pg[2] & Pg[1] & Pg[0] & C[0]);
  assign C[4] = Gg[3] | (Pg[3] & Gg[2]) | (Pg[3] & Pg[2] & Gg[1])
                         | (Pg[3] & Pg[2] & Pg[1] & Gg[0])
                         | (Pg[3] & Pg[2] & Pg[1] & Pg[0] & C[0]);

  cla4 u0 (A[3:0],   B[3:0],   C[0], sum[3:0],   Gg[0], Pg[0]);
  cla4 u1 (A[7:4],   B[7:4],   C[1], sum[7:4],   Gg[1], Pg[1]);
  cla4 u2 (A[11:8],  B[11:8],  C[2], sum[11:8],  Gg[2], Pg[2]);
  cla4 u3 (A[15:12], B[15:12], C[3], sum[15:12], Gg[3], Pg[3]);

  assign cout = C[4];

endmodule
