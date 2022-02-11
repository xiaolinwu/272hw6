module sram_256_32_1w1r#(
  parameter NUM_WMASKS = 4,
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 8,
  parameter RAM_DEPTH = 256,
  parameter DELAY = 0
)(
  input  clk0, // clock
  input   csb0, // active low chip select
  input  web0, // active low write control
  input [8-1:0]  addr0,
  input [32-1:0]  din0,
  input  clk1, // clock
  input   csb1, // active low chip select
  input [8-1:0]  addr1,
  output [32-1:0] dout1
);

  wire [32-1:0] dout0;

  sky130_sram_1kbyte_1rw1r_32x256_8   #(.NUM_WMASKS(NUM_WMASKS),
                                        .DATA_WIDTH(DATA_WIDTH),
                                        .ADDR_WIDTH(ADDR_WIDTH),
                                        .RAM_DEPTH(RAM_DEPTH),
                                        .DELAY(DELAY)) sram_macro (
      .clk0(clk0),.csb0(csb0),.web0(web0),.wmask0(4'hF),.addr0(addr0),.din0(din0), .dout0(dout0),
      .clk1(clk1),.csb1(csb1),.addr1(addr1),.dout1(dout1)
    );

endmodule

// OpenRAM SRAM model
// Words: 256
// Word size: 32
// Write size: 8
// synopsys translate_off
module sky130_sram_1kbyte_1rw1r_32x256_8#(
  parameter NUM_WMASKS = 4,
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 8,
  parameter RAM_DEPTH = 256,
  parameter DELAY = 0
)(
  input  clk0, // clock
  input   csb0, // active low chip select
  input  web0, // active low write control
  input [NUM_WMASKS-1:0]   wmask0, // write mask
  input [ADDR_WIDTH-1:0]  addr0,
  input [DATA_WIDTH-1:0]  din0,
  output reg [DATA_WIDTH-1:0] dout0,
  input  clk1, // clock
  input   csb1, // active low chip select
  input [ADDR_WIDTH-1:0]  addr1,
  output reg [DATA_WIDTH-1:0] dout1
);

  reg  csb0_reg;
  reg  web0_reg;
  reg [NUM_WMASKS-1:0]   wmask0_reg;
  reg [ADDR_WIDTH-1:0]  addr0_reg;
  reg [DATA_WIDTH-1:0]  din0_reg;

  reg  csb1_reg;
  reg [ADDR_WIDTH-1:0]  addr1_reg;
reg [DATA_WIDTH-1:0]    mem [0:RAM_DEPTH-1];

  // All inputs are registers
  always @(posedge clk0)
  begin
    csb0_reg = csb0;
    web0_reg = web0;
    wmask0_reg = wmask0;
    addr0_reg = addr0;
    din0_reg = din0;
    dout0 = 32'bx;
    if ( !csb0_reg && web0_reg ) 
      $display($time," Reading %m addr0=%b dout0=%b",addr0_reg,mem[addr0_reg]);
    if ( !csb0_reg && !web0_reg )
      $display($time," Writing %m addr0=%b din0=%b wmask0=%b",addr0_reg,din0_reg,wmask0_reg);
  end

  // All inputs are registers
  always @(posedge clk1)
  begin
    csb1_reg = csb1;
    addr1_reg = addr1;
    if (!csb0 && !web0 && !csb1 && (addr0 == addr1))
         $display($time," WARNING: Writing and reading addr0=%b and addr1=%b simultaneously!",addr0,addr1);
    dout1 = 32'bx;
    if ( !csb1_reg ) 
      $display($time," Reading %m addr1=%b dout1=%b",addr1_reg,mem[addr1_reg]);
  end


  // Memory Write Block Port 0
  // Write Operation : When web0 = 0, csb0 = 0
  always @ (negedge clk0)
  begin : MEM_WRITE0
    if ( !csb0_reg && !web0_reg ) begin
        if (wmask0_reg[0])
                mem[addr0_reg][7:0] = din0_reg[7:0];
        if (wmask0_reg[1])
                mem[addr0_reg][15:8] = din0_reg[15:8];
        if (wmask0_reg[2])
                mem[addr0_reg][23:16] = din0_reg[23:16];
        if (wmask0_reg[3])
                mem[addr0_reg][31:24] = din0_reg[31:24];
    end
  end

  // Memory Read Block Port 0
  // Read Operation : When web0 = 1, csb0 = 0
  always @ (negedge clk0)
  begin : MEM_READ0
    if (!csb0_reg && web0_reg)
       dout0 <= #(DELAY) mem[addr0_reg];
  end

  // Memory Read Block Port 1
  // Read Operation : When web1 = 1, csb1 = 0
  always @ (negedge clk1)
  begin : MEM_READ1
    if (!csb1_reg)
       dout1 <= #(DELAY) mem[addr1_reg];
  end

endmodule
// synopsys translate_on
