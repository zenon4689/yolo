//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/27 10:55:22
// Design Name: 
// Module Name: PE
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module PE#(
    parameter   DATA_WIDTH  = 32,
    parameter   WEIGHT      = 16
)
(
    input   clk,
    input   rst_n,
    input   [DATA_WIDTH-1:0]    partial_sum,
    input   [DATA_WIDTH-1:0]    bit_32,
    input   [WEIGHT-1:0]        bit_16,
    input   [DATA_WIDTH-1:0]    X0,
    input   [DATA_WIDTH-1:0]    X1,
    input   carry,  //If carry = 0 then conv, else pooling
    input   activation,
    input   [1:0]   operation,
    input   [1:0]   out_data_sel,

    output  [DATA_WIDTH-1:0]    out_data
    );

    localparam MUL_WIDTH = DATA_WIDTH + WEIGHT;

    reg  [DATA_WIDTH-1:0]   c_out_data, n_out_data;
    wire [MUL_WIDTH-1:0]    temp_mul_result;
    wire [DATA_WIDTH-1:0]   mul_bit_32;
    reg  [DATA_WIDTH-1:0]   r_add1, r_add0;
    wire [DATA_WIDTH-1:0]   add_result;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            c_out_data      <= 32'b0;
        end else begin
            c_out_data      <= n_out_data;
        end
    end

    always  @(*)begin
        r_add1      = 32'b0;            // cover full case

        case(operation)
            2'b00:  begin               // pooling 
                r_add1  = X1;
            end
            2'b01:  begin               // conv
                r_add1  = mul_result;
            end
            2'b10:  begin               // bias
                r_add1  = bit_32;
            end
            default: begin              //Intermediate data or Partial sum
                r_add1  = partial_sum;
            end
        endcase
    end

    always @(*) begin
        r_add0      = 32'b0;            // cover full case

        case (carry)
            1'b0:   begin   // conv
                r_add0  = c_out_data;
            end
            default: begin  // pooling
                r_add0  = ~X0;
            end
        endcase
    end

    always @(*) begin
        n_out_data  = 32'b0;

        case (out_data_sel)
            2'b00:  begin               //  data hold???
                n_out_data  = c_out_data;
            end
            2'b01:  begin               //  ???
                n_out_data  = r_add0;
            end
            2'b10:  begin               //  conv
                n_out_data  = add_result;
            end
            default: begin               //  ???
                n_out_data  = r_add1;
            end
        endcase
    end


    assign  mul_bit_32      = activation ? c_out_data : bit_32;
    assign  temp_mul_result = bit_16 * mul_bit_32;
    assign  mul_result      = temp_mul_result[41:8];
    assign  add_result      = (operation == 2'b00) ? r_add0 + r_add1 + carry : r_add0 + r_add1;     // Not consider Overflow

    assign  out_data        = c_out_data;

endmodule
