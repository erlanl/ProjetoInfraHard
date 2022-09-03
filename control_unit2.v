module control_unit2 (
    input wire clk,
    input wire reset,
    output reg PCWrite,
    output reg PCWriteCond,
    output reg MemControl,
    output reg IRWrite,
    output reg RegWrite,
    output reg LoadA,
    output reg LoadB,
    output reg ALUSrA,
    output reg LoadALUOUT,
    output reg LoadMDR,
    output reg MultDiv,
    output reg LoadHi,
    output reg LoadLo,
    output reg LoadDiv,
    output reg LoadEPC,

        //flags
    input wire Of,
    input wire Ng,
    input wire Zr,
    input wire Eq,
    input wire Gt,
    input wire Lt,
    input wire DivZero,

        //2 bits
    output reg [1:0] RegDST,
    output reg [1:0] ALUSrB,
    output reg [1:0] RegReadOne,
    output reg [1:0] CondControl,

        //3 bits
    output reg[2:0] IordD,
    output reg[2:0] ALUOp,
    output reg[2:0] PCSource,
    output reg[2:0] MemToReg,

        //Instrucoes
    input wire [5:0] OPCode,
    input wire [5:0] Funct,
    output reg rst_out
);

//Variaveis
    reg [5:0] Counter;
    reg [4:0] State;

//Parametros
    //Estados
    parameter ST_COMMON = 5'd0;
    parameter ST_ADD = 5'd1;
    parameter ST_ADDI = 5'd2;
    parameter ST_AND = 5'd3;
    parameter ST_SUB = 5'd4;
    parameter ST_DIV = 5'd5;
    parameter ST_MULT = 5'd6;
    parameter ST_MFHI = 5'd7;
    parameter ST_MFLO = 5'd8;
    parameter ST_JR = 5'd9;
    parameter ST_RTE = 5'd10;

    parameter ST_BNE = 6'd11;
    parameter ST_BEQ = 6'd12;
    parameter ST_BLE = 6'd13;
    parameter ST_BGT = 6'd14;

    parameter ST_LUI = 6'd15;

    parameter ST_J = 6'd18;

    parameter ST_BREAK = 5'd16; //PENÚLTIMO ESTADO!
    parameter ST_RESET = 5'd17; //ÚLTIMO ESTADO!

    //Opcode
    parameter RESET = 6'b111111;
    //Type R
    parameter Type_R = 6'd0;
        //Funct dos Tipos R
        parameter ADD = 6'h20;
        parameter SUB = 6'h22;
        parameter AND = 6'h24;
        parameter DIV = 6'h1a;
        parameter MULT = 6'h18;
        parameter JR = 6'h8;
        parameter MFHI = 6'h10;
        parameter MFLO = 6'h12;
        parameter SLL = 6'h0;
        parameter SLLV = 6'h4;
        parameter SLT = 6'h2a;
        parameter SRA = 6'h3;
        parameter SRAV = 6'h7;
        parameter SRL = 6'h2;
        parameter BREAK = 6'hd;
        parameter RTE = 6'h13;
        parameter PUSH = 6'h5;
        parameter POP = 6'h6;

    //Type I
    parameter ADDI = 6'h8;
    parameter ADDIU = 6'h9;
    parameter BEQ = 6'h4;
    parameter BNE = 6'h5;
    parameter BLE = 6'h6;
    parameter BGT = 6'h7;
    parameter LB = 6'h20;
    parameter LH = 6'h21;
    parameter LUI = 6'hf;
    parameter LW = 6'h23;
    parameter SB = 6'h28;
    parameter SH = 6'h29;
    parameter SLTI = 6'ha;
    parameter SW = 6'h2b;

    //Type J
    parameter J = 6'h2;
    parameter JAL = 6'h3;

    initial begin
        //Da o reset inicial na maquina
        rst_out = 1'b1;
        State = ST_ADD;
    end

    always @(posedge clk) begin
        if (reset == 1'b1) begin
            if (State != ST_RESET) begin
                State = ST_RESET;

                PCWrite = 1'b0;
                PCWriteCond = 1'b0;
                MemControl = 1'b0;
                IRWrite = 1'b0;
                RegWrite = 1'b0;
                LoadA = 1'b0;
                LoadB = 1'b0;
                ALUSrA = 1'b0;
                LoadALUOUT = 1'b0;
                LoadMDR = 1'b0;
                MultDiv = 1'b0;
                LoadHi = 1'b0;
                LoadLo = 1'b0;
                LoadDiv = 1'b0;

                RegDST = 2'b00;
                ALUSrB = 2'b00;
                RegReadOne = 2'b00;
                CondControl = 2'b00;
                
                IordD = 3'b000;
                ALUOp = 3'b000;
                PCSource = 3'b000;
                MemToReg = 3'b000;

                rst_out = 1'b1;

                Counter = 6'd0;
            end
            else begin
                State = ST_COMMON;

                PCWrite = 1'b0;
                PCWriteCond = 1'b0;
                MemControl = 1'b0;
                IRWrite = 1'b0;
                RegWrite = 1'b0;
                LoadA = 1'b0;
                LoadB = 1'b0;
                ALUSrA = 1'b0;
                LoadALUOUT = 1'b0;
                LoadMDR = 1'b0;
                MultDiv = 1'b0;
                LoadHi = 1'b0;
                LoadLo = 1'b0;
                LoadDiv = 1'b0;

                RegDST = 2'b00;
                ALUSrB = 2'b00;
                RegReadOne = 2'b00;
                CondControl = 2'b00;
                
                IordD = 3'b000;
                ALUOp = 3'b000;
                PCSource = 3'b000;
                MemToReg = 3'b000;

                rst_out = 1'b0;

                Counter = 6'd0;
            end
        end
        else begin
            case(State)
                ST_COMMON: begin
                    if (Counter == 6'd0 || Counter == 6'd1 || Counter == 6'd2) begin
                        //Nesse if acontece parte do estado de busca e waiting
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
                        LoadDiv = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b11;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        
                        IordD = 3'b000;
                        ALUOp = 3'b001;
                        PCSource = 3'b000;
                        MemToReg = 3'b000;

                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd3) begin
                        //Nesse else o PC eh salvo
                        State = ST_COMMON;

                        PCWrite = 1'b1; 
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b1;  
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0; 
                        LoadMDR = 1'b0;
                        MultDiv = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
                        LoadDiv = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b11; //PC+4
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b001; //SOMA
                        PCSource = 3'b000;
                        MemToReg = 3'b000;

                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd4) begin
                        //Nesse else acontece o estado de Decode
                        State = ST_COMMON;

                        PCWrite = 1'b0; 
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b1;
                        LoadB = 1'b1;
                        ALUSrA = 1'b0; //PC
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
                        LoadDiv = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b10; //Immediate
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b001; //Soma
                        PCSource = 3'b000;
                        MemToReg = 3'b000;

                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd5) begin
                        case(OPCode)
                            Type_R: begin
                                case(Funct)
                                    ADD: begin
                                        State = ST_ADD;
                                    end
                                    AND: begin
                                        State = ST_AND;
                                    end
                                    SUB: begin
                                        State = ST_SUB;
                                    end
                                    DIV: begin
                                        State = ST_DIV;
                                    end
                                    MULT: begin
                                        State = ST_MULT;
                                    end
                                    MFHI: begin
                                        State = ST_MFHI;
                                    end
                                    MFLO: begin
                                        State = ST_MFLO;
                                    end
                                    JR: begin
                                        State = ST_JR;
                                    end
                                    RTE: begin
                                        State = ST_RTE;
                                    end
                                    BREAK: begin
                                        State = ST_BREAK;
                                    end
                                endcase
                            end
                            
                            ADDI: begin
                                State = ST_ADDI;
                            end
                            
                            RESET: begin
                                State = ST_RESET;
                            end

                            BNE: begin
                                State = ST_BNE;
                            end

                            BEQ: begin
                                State = ST_BEQ;
                            end

                            BLE: begin
                                State = ST_BLE;
                            end

                            BGT: begin
                                State = ST_BGT;
                            end

                            ST_LUI: begin
                                State = ST_LUI;
                            end

                            ST_J: begin
                                State = ST_J;
                            end

                        endcase

                        PCWrite = 1'b0;   
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b0;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
                        LoadDiv = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        
                        IordD = 3'b000;
                        ALUOp = 3'b000;   
                        PCSource = 3'b000;
                        MemToReg = 3'b000;

                        rst_out = 1'b0;

                        Counter = 6'd0;
                    end
                end
                ST_ADD: begin
                    if(Counter == 6'd0) begin
                        State = ST_ADD;

                        PCWrite = 1'b0;   
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b0;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b1;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
                        LoadDiv = 1'b0;

                        RegDST = 2'b01;   
                        ALUSrB = 2'b00;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b001;   
                        PCSource = 3'b000;
                        MemToReg = 3'b000;

                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;  
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b1;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
                        LoadDiv = 1'b0;

                        RegDST = 2'b01;  
                        ALUSrB = 2'b00;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b001;  
                        PCSource = 3'b000;
                        MemToReg = 3'b000;

                        rst_out = 1'b0;

                        Counter = 6'd0;
                    end
                end
                ST_ADDI: begin
                    if(Counter == 6'd0) begin
                        State = ST_ADDI;

                        PCWrite = 1'b0;   
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b1;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
                        LoadDiv = 1'b0;

                        RegDST = 2'b00;   
                        ALUSrB = 2'b01;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b001;   
                        PCSource = 3'b000;
                        MemToReg = 3'b000;

                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;   
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b1;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
                        LoadDiv = 1'b0;

                        RegDST = 2'b00;   
                        ALUSrB = 2'b01;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b001;   
                        PCSource = 3'b000;
                        MemToReg = 3'b000;

                        rst_out = 1'b0;

                        Counter = 3'b000;
                    end
                end
                ST_AND: begin
                    if(Counter == 6'd0) begin
                        State = ST_AND;

                        PCWrite = 1'b0;   
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;  
                        ALUSrA = 1'b1;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
                        LoadDiv = 1'b0;

                        RegDST = 2'b01;  
                        ALUSrB = 2'b00;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b011;
                        MemToReg = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;   
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b1;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
                        LoadDiv = 1'b0;

                        RegDST = 2'b01;  
                        ALUSrB = 2'b00;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b011;
                        MemToReg = 3'b000;  
                        
                        rst_out = 1'b0;

                        Counter = 6'd0;
                    end
                end
                ST_SUB: begin
                    if(Counter == 6'd0) begin
                        State = ST_SUB;

                        PCWrite = 1'b0;   
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b1;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
                        LoadDiv = 1'b0;

                        RegDST = 2'b01;   
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b010;
                        MemToReg = 3'b000;  
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;   
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b1;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
                        LoadDiv = 1'b0;

                        RegDST = 2'b01;  
                        ALUSrB = 2'b00;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b010;  
                        MemToReg = 3'b000; 
                        
                        rst_out = 1'b0;

                        Counter = 6'd0;
                    end
                end
                ST_DIV: begin
                    if(Counter < 6'd33) begin
                        State = ST_DIV;

                        PCWrite = 1'b0;  
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b0;
                        LoadA = 1'b0;  
                        LoadB = 1'b0;  
                        ALUSrA = 1'b0;
                        MultDiv = 1'b0;
                        LoadDiv = 1'b1;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;

                        RegDST = 2'b00;   
                        ALUSrB = 2'b00;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000; 
                        MemToReg = 3'b000;  
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd33) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;  
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b0;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;  
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        LoadHi = 1'b1; 
                        LoadLo =  1'b1;
                        LoadDiv = 1'b0;

                        RegDST = 2'b00;   
                        ALUSrB = 2'b00;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        MemToReg = 3'b000;   
                        
                        rst_out = 1'b0;

                        Counter = 6'd0;
                    end
                end
                ST_MULT: begin
                    if(Counter < 6'd33) begin
                        State = ST_MULT;

                        PCWrite = 1'b0;  
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b0;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 1'b1;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
                        LoadDiv = 1'b0;

                        RegDST = 2'b00;   
                        ALUSrB = 2'b00;  
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        MemToReg = 3'b000;  
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd33) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;  
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b0;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 1'b1;
                        LoadHi = 1'b1; 
                        LoadLo =  1'b1;
                        LoadDiv = 1'b0;

                        RegDST = 2'b00;   
                        ALUSrB = 2'b00;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        MemToReg = 3'b000;   
                        
                        rst_out = 1'b0;

                        Counter = 6'd0;
                    end
                end
                ST_MFHI: begin
                    if(Counter == 6'd0) begin
                        State = ST_MFHI;

                        PCWrite = 1'b0; 
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b0;
                        LoadA = 1'b0;   
                        LoadB = 1'b0; 
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
                        LoadDiv = 1'b0;

                        RegDST = 2'b01;  
                        ALUSrB = 2'b00;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;   
                        MemToReg = 3'b010;

                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;   
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;  
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo =  1'b0;
                        LoadDiv = 1'b0;

                        RegDST = 2'b01;   
                        ALUSrB = 2'b00;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;  
                        MemToReg = 3'b010;
                        
                        rst_out = 1'b0;

                        Counter = 6'd0;
                    end
                end
                ST_MFLO: begin
                    if(Counter == 6'd0) begin
                        State = ST_MFLO;

                        PCWrite = 1'b0;   
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b0;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
                        LoadDiv = 1'b0;

                        RegDST = 2'b01;  
                        ALUSrB = 2'b00;  
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;  
                        MemToReg = 3'b011;
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;   
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 1'b0;
                        LoadHi = 1'b0; 
                        LoadLo =  1'b0; 
                        LoadDiv = 1'b0;

                        RegDST = 2'b01;  
                        ALUSrB = 2'b00;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;  
                        MemToReg = 3'b011;
                        
                        rst_out = 1'b0;

                        Counter = 6'd0;
                    end
                end
                ST_JR: begin
                    if(Counter == 6'd0) begin
                        State = ST_JR; 

                        PCWrite = 1'b1;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b1;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        
                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        PCSource = 3'b000;
                        MemToReg = 3'b000;

                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 1'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b1;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        
                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        PCSource = 3'b011;
                        MemToReg = 3'b000;

                        rst_out = 1'b0;

                        Counter = 6'd0;
                    end
                end
                ST_BNE: begin
                    State = ST_COMMON;

                    PCWrite = 1'b0;
                    PCWriteCond = 1'b1;
                    MemControl = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1;
                    LoadA = 1'b0;
                    LoadB = 1'b0;
                    ALUSrA = 1'b1;
                    LoadALUOUT = 1'b0;
                    LoadMDR = 1'b0;
                    MemToReg = 3'b011;

                    RegDST = 2'b01;
                    ALUSrB = 2'b00;
                    RegReadOne = 2'b00;
                    CondControl = 2'b00;
                    
                    IordD = 3'b000;
                    ALUOp = 3'b111;
                    PCSource = 3'b011;
                    MemToReg = 3'b000;

                    rst_out = 1'b0;

                    Counter = 6'd0;
                end
                ST_BEQ: begin
                    State = ST_COMMON;

                    PCWrite = 1'b0;
                    PCWriteCond = 1'b1;
                    MemControl = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1;
                    LoadA = 1'b0;
                    LoadB = 1'b0;
                    ALUSrA = 1'b1;
                    LoadALUOUT = 1'b0;
                    LoadMDR = 1'b0;
                    MemToReg = 3'b011;

                    RegDST = 2'b01;
                    ALUSrB = 2'b00;
                    RegReadOne = 2'b00;
                    CondControl = 2'b01;
                    MemToReg = 3'b000;
                    
                    IordD = 3'b000;
                    ALUOp = 3'b111;
                    PCSource = 3'b011;
                    MemToReg = 3'b000;

                    rst_out = 1'b0;

                    Counter = 6'd0;
                end
                ST_BLE: begin
                    State = ST_COMMON;

                    PCWrite = 1'b0;
                    PCWriteCond = 1'b1;
                    MemControl = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1;
                    LoadA = 1'b0;
                    LoadB = 1'b0;
                    ALUSrA = 1'b1;
                    LoadALUOUT = 1'b0;
                    LoadMDR = 1'b0;
                    MemToReg = 3'b011;

                    RegDST = 2'b01;
                    ALUSrB = 2'b00;
                    RegReadOne = 2'b00;
                    CondControl = 2'b10;
                    
                    IordD = 3'b000;
                    ALUOp = 3'b111;
                    PCSource = 3'b011;
                    MemToReg = 3'b000;

                    rst_out = 1'b0;

                    Counter = 6'd0;
                end
                ST_BGT: begin
                    State = ST_COMMON;

                    PCWrite = 1'b0;
                    PCWriteCond = 1'b1;
                    MemControl = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1;
                    LoadA = 1'b0;
                    LoadB = 1'b0;
                    ALUSrA = 1'b1;
                    LoadALUOUT = 1'b0;
                    LoadMDR = 1'b0;
                    MemToReg = 3'b011;

                    RegDST = 2'b01;
                    ALUSrB = 2'b00;
                    RegReadOne = 2'b00;
                    CondControl = 2'b11;
                    
                    IordD = 3'b000;
                    ALUOp = 3'b111;
                    PCSource = 3'b011;
                    MemToReg = 3'b000;

                    rst_out = 1'b0;

                    Counter = 6'd0;
                end
                ST_LUI: begin
                    State = ST_COMMON;

                    PCWrite = 1'b0;
                    PCWriteCond = 1'b0;
                    MemControl = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1;
                    LoadA = 1'b0;
                    LoadB = 1'b0;
                    ALUSrA = 1'b0;
                    LoadALUOUT = 1'b0;
                    LoadMDR = 1'b0;
                    MultDiv = 1'b0;
                    LoadHi = 1'b0;
                    LoadLo = 1'b0;
                    LoadDiv = 1'b0;

                    RegDST = 2'b00;
                    ALUSrB = 2'b00;
                    RegReadOne = 2'b00;
                    CondControl = 2'b00;

                    IordD = 3'b000;
                    ALUOp = 3'b000;
                    PCSource = 3'b000;
                    MemToReg = 3'b110;
                        
                    rst_out = 1'b0;

                    Counter = 6'd0;
                end
                ST_J: begin
                    State = ST_COMMON;

                    PCWrite = 1'b1; //segundo
                    PCWriteCond = 1'b0;
                    MemControl = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    LoadA = 1'b0;
                    LoadB = 1'b0;
                    ALUSrA = 1'b0;
                    LoadALUOUT = 1'b0;
                    LoadMDR = 1'b0;
                    MultDiv = 1'b0;
                    LoadHi = 1'b0;
                    LoadLo = 1'b0;
                    LoadDiv = 1'b0;

                    RegDST = 2'b00;
                    ALUSrB = 2'b00;
                    RegReadOne = 2'b00;
                    CondControl = 2'b00;

                    IordD = 3'b000;
                    ALUOp = 3'b000;
                    PCSource = 3'b001; //primeiro
                    MemToReg = 3'b000;
                        
                    rst_out = 1'b1;

                    Counter = 6'd0;
                end
                ST_BREAK: begin
                    State = ST_BREAK;

                    PCWrite = 1'b1;
                    PCWriteCond = 1'b0;
                    MemControl = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    LoadA = 1'b0;
                    LoadB = 1'b0;
                    ALUSrA = 1'b0;
                    LoadALUOUT = 1'b0;
                    LoadMDR = 1'b0;

                    RegDST = 2'b00;
                    ALUSrB = 2'b00;
                    RegReadOne = 2'b00;
                    CondControl = 2'b00;
                    
                    IordD = 3'b000;
                    ALUOp = 3'b000;
                    PCSource = 3'b000;
                    MemToReg = 3'b000;

                    rst_out = 1'b0;

                    Counter = 6'd0;
                end
                ST_RESET: begin
                    if(Counter == 6'd0) begin
                        State = ST_RESET;

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
                        LoadDiv = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        
                        rst_out = 1'b1;

                        Counter = 6'd0;
                    end
                end
            endcase
        end
    end
    
endmodule