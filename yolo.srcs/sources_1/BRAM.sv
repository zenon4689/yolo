module bram_counter#(   //각 layer의 데이터 개수만큼 counter, read/write에서 모두 사용
    parameter LAYER_NUM = 1     //들어오는 layer(controller에서 결정될듯)
    parameter  CONV = 196,  //각 layer의 데이터 개수 parameter(미정)
    parameter  POOLING = 196 //
)
(
    input   clk,
    input   rst_n,
    output   [17:0] counter_num, //최대 408X408 = 166464(18bit)
);

reg [17:0] count;

assign cnt = count;

always@(posedge clk or negedege rst_n) begin
    if(!rst_n)begin
        count <=18'b0;
    end
    else begin
        count <= count + 18'b1;
    end
end
endmodule

module bram#(

    parameter  
)

