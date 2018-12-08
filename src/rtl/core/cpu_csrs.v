// `include "cpu_define.v"
// `include "cpu_csrs_define.v"

// module cpu_csrs(
//     input clk,
//     input rd_wen,
//     input reset_n,

//     input [`CPU_GREGIDX_WIDTH-1:0] rs1_idx,
//     input [`CPU_GREGIDX_WIDTH-1:0] rs2_idx,
//     input [`CPU_GREGIDX_WIDTH-1:0] rd_idx,

//     output reg [`CPU_XLEN-1:0] rs1_dat,
//     output reg [`CPU_XLEN-1:0] rs2_dat,
//     input [`CPU_XLEN-1:0] rd_dat
//     );
//     reg [`CPU_XLEN-1:0] rx [`CPU_GREG_COUNT-1:0];

//     always @(posedge clk)
//     begin
//         if(!reset_n)
//             rx[0] = `CPU_XLEN'b0;
//         else
//         begin
//             rs1_dat = rx[rs1_idx];
//             rs2_dat = rx[rs2_idx];
//             if(rd_wen && rd_idx!=`CPU_GREGIDX_WIDTH'b0)
//             begin
//                 rx[rd_idx] = rd_dat;
//             end
//         end
//     end
// endmodule