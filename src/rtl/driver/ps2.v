module ps2(
    input clk,
    input clr_n,
    input ps2_clk,
    input ps2_data,
    output wire [7:0] ps2_scan_out,
    // output wire [7:0] ps2_ascii_out,
    output wire ps2_output_en
    // 调试输出信号
    // output wire [13:0]seg7_ascii,
    // output wire [13:0]seg7_scancode,
    // output wire [13:0]seg7_count
);

    assign ps2_output_en = output_en;

    reg nextdata_n;
    reg [7:0] count;
    wire ready;
    wire overflow;
    reg output_en;
    reg [1:0] f0;
    wire [7:0] ps2_scan_out_real;
    // wire [7:0] ps2_ascii_out_real;

    wire [7:0] ps2_scancode;

    always @ (posedge clk) begin
        if (!clr_n) begin
            count <= 7'b0;
            output_en <= 0;
            f0 <= 0;
            nextdata_n = 0;
        end else if (ready) begin
            if (f0 == 2) begin
                count = count + 1;
                output_en = 1;
                f0 = 0;
            end else if (f0 == 1) begin
                f0 = 2;
            end else if (f0 == 0) begin
                if (ps2_scancode == 8'hf0) begin
                    output_en = 0;
                    f0 = 1;
                end
            end
        end
    end

    ps2_keyboard ps2_kbd(
        .clk(clk),
        .clr_n(clr_n),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .data(ps2_scancode),
        .ready(ready),
        .nextdata_n(nextdata_n),
        .overflow(overflow)
    );

    // scancode p2a(
    //     .address(ps2_scan_out_real),
    //     .q(ps2_ascii_out_real),
    //     .clock(clk)
    // );

    // assign ps2_ascii_out = output_en ? ps2_ascii_out_real : 8'b0;
    assign ps2_scan_out = output_en ? ps2_scan_out_real : 8'b0;

    d_trigger d(
        .en(~output_en),
        .in_data(ps2_scancode),
        .clk(clk),
        .out(ps2_scan_out_real)
    );

    // seg7_h h0(.en(output_en), .in(ps2_scan_out[3:0]), .hex(seg7_scancode[6:0]));
    // seg7_h h1(.en(output_en), .in(ps2_scan_out[7:4]), .hex(seg7_scancode[13:7]));
    // seg7_h h2(.en(output_en), .in(ps2_ascii_out[3:0]), .hex(seg7_ascii[6:0]));
    // seg7_h h3(.en(output_en), .in(ps2_ascii_out[7:4]), .hex(seg7_ascii[13:7]));
    // seg7_h h4(.en(1'b1),      .in(count[3:0]), .hex(seg7_count[6:0]));
    // seg7_h h5(.en(1'b1),      .in(count[7:4]), .hex(seg7_count[13:7]));

endmodule