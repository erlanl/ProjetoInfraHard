`include "Criados/control_unit.v"
`include "Criados/mult_div.v"
`include "Criados/demux_1to2.v"
`include "Criados/mux_2to1.v"
`include "Criados/mux_alusrb.v"
`include "Criados/mux_iord.v"
`include "Criados/mux_memtoreg.v"
`include "Criados/mux_numbershift.v"
`include "Criados/mux_pcsource.v"
`include "Criados/mux_regdest.v"
`include "Criados/mux_regreadone.v"
`include "Criados/sign_extend_16.v"
`include "Criados/zero_extender_1.v"
`include "Criados/mux_condcontrol.v"


module integracao_copy (
    input wire clk,
    input wire reset
);


    // Control Wires 1 bit
    wire load;
    wire sel_lscontrol;
    wire sel_alusra;
    wire sel_regwrite;
    wire sel_ltout;
    wire sel_memdata;
    wire sel_inputshift;
    wire sel_numbershift;
    wire sel_memcontrol;
    wire sel_pcwrite;
    wire sel_pcwritecond;
    wire sel_irwrite;
    wire sel_div_mult;

    // Flags de load
    wire load_alu;
    wire load_PC;
    wire load_regA;
    wire load_regB;
    wire load_regHi;
    wire load_regLo;
    wire load_epc;
    wire load_MDR;

    //Control wires 2 bits
    wire [1:0] sel_alusrb;
    wire [1:0] sel_condcontrol;
    wire [1:0] sel_regdest;
    wire [1:0] sel_lscontrol_signal;
    wire [1:0] sel_reg_read_one;
    
    //Control wires 3bits
    wire [2:0] sel_aluop;
    wire [2:0] sel_memtoreg;
    wire [2:0] sel_iord;
    wire [2:0] sel_pcsource;
    wire [2:0] sel_shiftcontrol;

    //Data Wires 1 bit
    wire output_mux_condcontrol;
    wire output_zero_div;

    // Data Wires 5 bits
    wire [4:0] output_mux_numbershift;
    wire [15:0] output_instruction_15_0;
    wire [4:0] output_instruction_20_16;
    wire [4:0] output_instruction_15_11;
    wire [4:0] output_instruction_25_21;
    wire [5:0] output_instruction_31_26;
    wire [4:0] output_mux_RegReadOne;
    wire [4:0] input_n;
    wire [4:0] output_mux_regdest;

    // Data Wires 32 bits
    wire [31:0] output_aluout;
    wire [31:0] output_alu;
    wire [31:0] output_PCSource;
    wire [31:0] input_a;
    wire [31:0] input_b;
    wire [31:0] input_regHi;
    wire [31:0] output_regHi;
    wire [31:0] input_regLo;
    wire [31:0] output_regLo;
    wire [31:0] output_PC;
    wire [31:0] output_regA;
    wire [31:0] output_regB;
    wire [31:0] output_mux_iord;
    wire [31:0] output_1_demux;
    wire [31:0] output_2_demux;
    wire [31:0] output_mux_alusra;
    wire [31:0] output_mux_alusrb;
    wire [31:0] output_mux_memtoreg;
    wire [31:0] output_shift_left_16;
    wire [31:0] output_register_shift;
    wire [31:0] memory_data_register;
    wire [31:0] output_sign_extend_16;
    wire [31:0] output_shift_left_2;
    wire [31:0] output_mux_srb;
    wire [31:0] output_mux_pcsource;
    wire [31:0] jump_address_31_0;
    wire [31:0] memData;
    wire [31:0] output_menor_extended;
    wire [31:0] output_mux_ltout;
    wire [31:0] output_MDR;
    wire [31:0] output_mux_information_lscontrol;
    wire [31:0] output_mux_addres_lscontrol;
    wire [31:0] output_mux_inputshift;
    wire [31:0] output_ls_control_block;
    wire [31:0] output_memory;
    wire [31:0] output_mux_memdata;
    wire [31:0] output_epc;

    // Flags
    wire overflow;
    wire negativo;
    wire zero;
    wire igual;
    wire maior;
    wire menor;

    wire sel_pcwrite_logico = (sel_pcwritecond && output_mux_condcontrol) || sel_pcwrite;

    // Registers
    Registrador aluOut (
        .Clk(clk), 
        .Reset(reset), 
        .Load(load_aluout), 
        .Entrada(output_alu), 
        .Saida(output_aluout) 
    );

    Registrador PC (
        .Clk(clk), 
        .Reset(reset), 
        .Load(sel_pcwrite_logico), 
        .Entrada(output_PCSource), 
        .Saida(output_PC)
    );

    Registrador A (
        .Clk(clk), 
        .Reset(reset), 
        .Load(load_regA), 
        .Entrada(input_a), 
        .Saida(output_regA) 
    );

    Registrador B (
        .Clk(clk), 
        .Reset(reset), 
        .Load(load_regB), 
        .Entrada(input_b), 
        .Saida(output_regB) 
    );

    Registrador Hi (
        .Clk(clk), 
        .Reset(reset), 
        .Load(load_regHi), 
        .Entrada(input_regHi), 
        .Saida(output_regHi) 
    );

    Registrador Lo (
        .Clk(clk), 
        .Reset(reset), 
        .Load(load_regLo), 
        .Entrada(input_regLo), 
        .Saida(output_regLo) 
    );

    Registrador epc (
        .Clk(clk), 
        .Reset(reset), 
        .Load(load_epc), 
        .Entrada(output_alu), 
        .Saida(output_epc) 
    );

    Registrador memoryDataRegister (
        .Clk(clk), 
        .Reset(reset), 
        .Load(load_MDR), 
        .Entrada(output_memory), 
        .Saida(output_MDR) 
    );

    // Blocos Fornecidos
    ula32 alu (
        .A(output_mux_alusra),  
        .B(output_mux_alusrb), 
        .Seletor(sel_aluop), 
        .S(output_alu), 
        .Overflow(overflow), 
        .Negativo(negativo), 
        .z(zero), 
        .Igual(igual), 
        .Maior(maior), 
        .Menor(menor) 
    );

    Banco_reg bancoReg (
        .Clk(clk),
        .Reset(reset),
        .RegWrite(sel_regwrite),
        .ReadReg1(output_mux_RegReadOne),
        .ReadReg2(output_instruction_20_16),
        .WriteReg(output_mux_regdest),
        .WriteData(output_mux_memtoreg),
        .ReadData1(input_a),
        .ReadData2(input_b)
    );

    //mudar essa parte do sel no controle
    Memoria memory (
        .Clock(clk),
        .Address(output_mux_iord), 
        .Wr(sel_memcontrol), 
        .Datain(output_mux_memdata), 
        .Dataout(output_memory) 
    );

    Instr_Reg IR(
    .Clk(clk),
    .Reset(reset),
    .Load_ir(sel_irwrite),
    .Entrada(output_memory),
    .Instr31_26(output_instruction_31_26),
    .Instr25_21(output_instruction_25_21),
    .Instr20_16(output_instruction_20_16),
    .Instr15_0(output_instruction_15_0)
    );

    // Blocos criados
    LScontrol ls_Control (
        .clock(clk),
        .reset(reset),
        .value(output_mux_information_lscontrol),
        .instruction(output_mux_addres_lscontrol),
        .control(sel_lscontrol_signal),
        .out(output_ls_control_block)
    );

    RegDesloc shift (
        .Clk(clk),
        .Reset(reset),
        .Shift(sel_shiftcontrol),
        .N(output_mux_numbershift),
        .Entrada(output_mux_inputshift),
        .Saida(output_register_shift)
        
    );
    /*
    mult mult (
        .M(output_regA),
        .Q(output_regB),
        .clk(clk),
        .reset(reset),
        .mflo(input_regLo), 
        .mfhi(input_regHi)
    );

    div div (
        .clk(clk),
        .reset(reset),
        .a(output_regA),
        .b(output_regB),
        .high(input_regHi), 
        .low(input_regLo),
        .div_zero(output_zero_div)
    );*/

    mult_div div_mult(
        .clk(clk),
        .mult_div_control(sel_div_mult),
        .reset(reset),
        .a(output_regA),
        .b(output_regB),
        .high(input_regHi),
        .low(input_regLo),
        .div_zero(output_zero_div)
    );

    crntl Controlador(
    //Inputs
        .clk(clk),
        .reset(reset),
        .opcode(output_instruction_31_26),
        .funct(output_instruction_31_26[5:0]),
        .OF(overflow),
        .ZERO(zero),

    //Outputs
        //PC
            .PCWriteCond(sel_pcwritecond),
            .PCWrite(sel_pcwrite),
            .CondControl(sel_condcontrol),
        
        //Memory
            //sel_memcontrol 
            .MemControl(sel_memcontrol),

        //Registers
            .RegWrite(sel_regwrite),
            .load_A(load_regA),
            .load_B(load_regB),
            .IRWrite(sel_irwrite),

        //ALU
            .ALUOp(sel_aluop),

            .alu_out(load_aluout),

        //MUX
            .IorD(sel_iord),
            .RegReadOne(sel_reg_read_one),
            .RegDst(sel_regdest),
            .MemToReg(sel_memtoreg),
            .ALUSrcA(sel_alusra),
            .ALUSrcB(sel_alusrb),
            .PCSource(sel_pcsource)

        //RESET
            //.reset_out()
    );

    // Mux's
    mux_2to1 mux_alusra (
        .a(output_PC), 
        .b(output_regA), 
        .sel(sel_alusra), 
        .out(output_mux_alusra) 
    );

    mux_2to1 mux_ltout (
        .a(output_menor_extended),
        .b(output_aluout),
        .sel(sel_ltout),
        .out(output_mux_ltout)
    );

    mux_alusrb mux_alusrb (
        .reg_B(output_regB), 
        .instruction_15_11(output_sign_extend_16), 
        .c(output_shift_left_2), 
        .sel(sel_alusrb), 
        .out(output_mux_srb) 
    );

    mux_iord mux_iord (
        .PC(output_PC), 
        .b(output_mux_ltout), 
        .sel(sel_iord), 
        .out(output_mux_iord) 
    );

    mux_condcontrol mux_condcontrol (
        .zero(zero),
        .gt(maior),
        .sel(sel_condcontrol),
        .out(output_mux_condcontrol)
    );

    mux_memtoreg mux_memtoreg (
        .a(output_aluout), 
        .b(memory_data_register), 
        .c(output_regHi), 
        .d(output_regLo), 
        .e(output_register_shift), 
        .f(output_2_demux), 
        .g(output_shift_left_16), 
        .sel(sel_memtoreg), 
        .out(output_mux_memtoreg) 
    );

    mux_numbershift mux_numbershift (
        .reg_B(output_regB),
        .instruction_15_0(output_instruction_15_0[4:0]),
        .sel(sel_numbershift),
        .out(output_mux_numbershift)
    );

    mux_2to1 mux_inputshift (
        .a(output_regA),
        .b(output_regB),
        .sel(sel_inputshift),
        .out(output_mux_inputshift)
    );

    mux_pcsource mux_pcsource (
        .aluResult(output_aluout),
        .PC(output_PC),
        .output_shift_left_2(output_shift_left_2),
        .memData(output_memory),
        .aluOut(output_aluout),
        .epc(output_epc),
        .sel(sel_pcsource),
        .out(output_mux_pcsource)
    );

    mux_regdest mux_regdest (
        .instruction_20_16(output_instruction_20_16),
        .instruction_15_11(output_instruction_15_11),
        .sel(sel_regdest),
        .out(output_mux_regdest)
    );

    mux_regreadone mux_regreadone (
        .instrucion_25_21(output_instruction_25_21),
        .sel(sel_reg_read_one),
        .out(output_mux_RegReadOne)
    );

    mux_2to1 mux_information_lscontrol (
        .a(output_MDR),
        .b(output_regB),
        .sel(sel_lscontrol),
        .out(output_mux_information_lscontrol)
    );

    mux_2to1 mux_addres_lscontrol (
        .a(output_regB),
        .b(output_MDR),
        .sel(sel_lscontrol),
        .out(output_mux_addres_lscontrol)
    );

    mux_2to1 mux_memdata (
        .a(output_2_demux),
        .b(output_regB),
        .sel(sel_memdata),
        .out(output_mux_memdata)
    );

    demux_1to2 demux (
        .a(output_ls_control_block), 
        .sel(sel_lscontrol), 
        .out_1(output_1_demux), 
        .out_2(output_2_demux) 
    );

    zero_extender_1 zero_extend_1 (
        .Data_in(menor),
        .Data_out(output_menor_extended)
    );

    sign_extend_16 sign_extend_16 (
        .Data_in(output_instruction_15_0),
        .Data_out(output_sign_extend_16)
    );

    shift_left_2 shift_left_2 (
        .data_in(output_sign_extend_16),
        .data_out(output_shift_left_2)
    );

    shift_left_16 shift_left_16 (
        .data_in(output_instruction_15_0),
        .data_out(output_shift_left_16)
    );

endmodule