`timescale 1ns/1ps

module tb_mul_op;

  reg clk;
  reg rst;
  reg start;
  reg signed [7:0] M, Q;
  wire signed [15:0] P;
  wire done;

  // DUT
  mul_op uut (
    .clk(clk),
    .rst(rst),
    .M(M),
    .Q(Q),
    .start(start),
    .P(P),
    .done(done)
  );

  // Clock (10ns period)
  always #5 clk = ~clk;

  // Dump file
  initial begin
    $dumpfile("mul_op.vcd");
    $dumpvars(0, tb_mul_op);
  end

  integer i;
  reg signed [15:0] expected;

  // -----------------------------
  // Task: single transaction
  // -----------------------------
  task run_test(input signed [7:0] a, input signed [7:0] b);
  begin
    // Wait until DUT is idle
    @(posedge clk);
    while (uut.busy == 1'b1)
      @(posedge clk);

    // Apply inputs
    M <= a;
    Q <= b;
    expected = a * b;

    // Start pulse (exactly 1 cycle)
    start <= 1'b1;
    @(posedge clk);
    start <= 1'b0;

    // Wait for result
    wait(done == 1'b1);

    // Check result
    if (P !== expected) begin
      $display("ERROR at %0t | M=%0d Q=%0d | expected=%0d got=%0d",
                $time, a, b, expected, P);
    end
    else begin
      $display("PASS  at %0t | M=%0d Q=%0d | Result=%0d",
                $time, a, b, P);
    end

    // Ensure DUT returns to idle before next test
    @(posedge clk);
    while (uut.busy == 1'b1)
      @(posedge clk);
  end
  endtask

  // -----------------------------
  // Stimulus
  // -----------------------------
  initial begin
    clk = 0;
    rst = 0;
    start = 0;
    M = 0;
    Q = 0;

    // Reset
    #10 rst = 1;

    // Directed tests
    run_test(5, 3);
    run_test(10, 4);
    run_test(-5, 6);
    run_test(-8, -8);

    // Random tests
    for (i = 0; i < 50; i = i + 1) begin
      run_test($random, $random);
    end

    $display("TEST COMPLETED");
    $finish;
  end

endmodule
