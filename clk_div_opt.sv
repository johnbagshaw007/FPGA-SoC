// Company: Jotshaw Electronics
// Engineer: John Bagshaw
// Create Date: 12/18/2023 11:43:39 AM
// Design Name: Optimized Clock Divider
// Module Name: clk_div_opt
// Project Name: Optimized Clock Divider
// Target Devices: Basys3 (Artix 7)
// Tool Versions: Synopsys VCS
// Description: A versatile, parameterized clock divider design

class generator;
  transaction tr;
  mailbox #(transaction) mbx;
  event done;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
    tr = new();
  endfunction

  task run(int count);
    for (int i = 0; i < count; i++) begin
      assert(tr.randomize()) else $error("Randomization Failed");
      mbx.put(tr.copy());
      tr.display("GEN");
      #10; // Add a delay or synchronize with the clock
    end
    -> done;
  endtask
endclass;

class driver;
  transaction tr;
  mailbox #(transaction) mbx;
  virtual ClkDiv_if vif;

  function new(mailbox #(transaction) mbx, virtual ClkDiv_if vif);
    this.mbx = mbx;
    this.vif = vif;
  endfunction

  task reset();
    vif.rst <= 1;
    @(posedge vif.clk);
    vif.rst <= 0;
    $display("DRV: Reset Done");
  endtask

  task run();
    forever begin
      mbx.get(tr);
      vif.en <= tr.en;
      tr.display("DRV");
      @(posedge vif.clk);
    end
  endtask
endclass;
class monitor;
  transaction tr;
  mailbox #(transaction) mbx;
  virtual ClkDiv_if vif;

  function new(mailbox #(transaction) mbx, virtual ClkDiv_if vif);
    this.mbx = mbx;
    this.vif = vif;
    tr = new();
  endfunction

  task run();
    forever begin
      @(posedge vif.clk);
      tr.div2 = vif.div2;
      tr.div4 = vif.div4;
      tr.div8 = vif.div8;
      tr.div16 = vif.div16;
      mbx.put(tr);
      tr.display("MON");
    end
  endtask
endclass;

class scoreboard;
  transaction tr;
  mailbox #(transaction) mbx;
  mailbox #(transaction) mbxref;
  event sconext;

  function new(mailbox #(transaction) mbx, mailbox #(transaction) mbxref);
    this.mbx = mbx;
    this.mbxref = mbxref;
  endfunction

  task run();
    forever begin
      mbx.get(tr);
      transaction tr_ref;
      mbxref.get(tr_ref);
      if (!(tr.div2 == tr_ref.div2 && tr.div4 == tr_ref.div4 && 
            tr.div8 == tr_ref.div8 && tr.div16 == tr_ref.div16)) begin
        $display("SCO: DATA MISMATCHED");
      end else begin
        $display("SCO: DATA MATCHED");
      end
      -> sconext; // Notify the environment of the comparison result
    end
  endtask
endclass;

class environment;
  generator gen;
  driver drv;
  monitor mon;
  scoreboard sco;
  virtual ClkDiv_if vif;

  function new(virtual ClkDiv_if vif);
    this.vif = vif;
    gen = new(mbx);
    drv = new(mbx, vif);
    mon = new(mbx, vif);
    sco = new(mbx, mbxref);
  endfunction

  task run();
    fork
      gen.run(10); // Set the number of transactions to generate
      drv.run();
      mon.run();
      sco.run();
    join
  endtask
endclass;
