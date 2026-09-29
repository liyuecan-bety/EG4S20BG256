module audio_speak(
    input           sys_clk   ,               // 系统时钟(50MHz)
    input           sys_rst_n ,               // 系统复位
    
	input   [1:0]  volume,                  //音量配置输入
	 
    //es8388 audio interface (master mode)
    input           aud_bclk  ,               // es8388位时钟
    input           aud_lrc   ,               // 对齐信号
    input           aud_adcdat,               // 音频输入
    output          aud_mclk  ,               // es8388的主时钟
    output          aud_dacdat,               // 音频输出
    
    //es8388 control interface
    output          aud_scl   ,               // es8388的SCL信号
    inout           aud_sda ,                  // es8388的SDA信号
    output          led,
    output          ilaclk
);

//wire define
wire [31:0] adc_data;                         // FPGA采集的音频数据                                 
wire rst_n,locked;

//*****************************************************
//**                    main code
//*****************************************************

reg	[7:0]	rst_cnt=0;	

always @(posedge sys_clk)
begin
	if (rst_cnt[7])
		rst_cnt <=  rst_cnt;
	else
		rst_cnt <= rst_cnt+1'b1;
end			  	

//例化PLL，生成es8388主时钟
//12.288MHZ的时钟频率直接就输出到es8388的主时钟引脚上，不用进行例化
//同时也输出到FPGA内部的时钟域，供FPGA内部使用
  clk_wiz_0 u_pll_clk
   (
  
    .refclk(sys_clk),// input clk_50M
    .reset(!rst_cnt[7]),// input resetn
    .stdby(1'b0),
    .extlock(locked),// output locked
    .clk0_out(chipwatcherclk),
    .clk1_out(aud_mclk) // output clk_12M，12.288MHz
   );      


//例化es8388控制模块
es8388_ctrl u_es8388_ctrl(
    .clk                (sys_clk    ),        // 时钟信号
    .rst_n              (locked      ),        // 复位信号

    .aud_bclk           (aud_bclk   ),        // es8388位时钟
    .aud_lrc            (aud_lrc    ),        // 对齐信号
    .aud_adcdat         (aud_adcdat ),        // 音频输入
    .aud_dacdat         (aud_dacdat ),        // 音频输出
    
    .aud_scl            (aud_scl    ),        // es8388的SCL信号
    .aud_sda            (aud_sda    ),        // es8388的SDA信号
    
	 .volume             (volume),              //音量配置输入
	 
    .adc_data           (adc_data   ),        // 输入的音频数据
    .dac_data           (adc_data   ),        // 输出的音频数据
    .rx_done            (),                   // 1次接收完成
    .tx_done            ()                    // 1次发送完成
);

assign led = locked;


endmodule 