//- converts 7-bit binary to 2 digit decimal
module cnt_convert_7b(
    input [6:0] cnt,
    output reg [3:0] c2_d1,
    output reg [3:0] c2_d0
    );
    
    reg [7:0] cnt_new;      // working value  
    reg [7:0] cnt_new_w;    // working value 
   
    // BCD intermediates   
    reg [3:0] d1;     // 10's digit
    reg [3:0] d0;     // 1's digit
      
    //- decimal (2 digit) to BCD conversion 
    always @ (cnt_new)
    begin
       d1=0;  d0=0; 
        
       cnt_new_w = cnt; 

       // handle 10's digit
       if      (cnt_new_w > 89) begin   d1=9;   cnt_new_w = cnt_new_w - 90;  end
       else if (cnt_new_w > 79) begin   d1=8;   cnt_new_w = cnt_new_w - 80;  end 
       else if (cnt_new_w > 69) begin   d1=7;   cnt_new_w = cnt_new_w - 70;  end 
       else if (cnt_new_w > 59) begin   d1=6;   cnt_new_w = cnt_new_w - 60;  end 
       else if (cnt_new_w > 49) begin   d1=5;   cnt_new_w = cnt_new_w - 50;  end 
       else if (cnt_new_w > 39) begin   d1=4;   cnt_new_w = cnt_new_w - 40;  end 
       else if (cnt_new_w > 29) begin   d1=3;   cnt_new_w = cnt_new_w - 30;  end 
       else if (cnt_new_w > 19) begin   d1=2;   cnt_new_w = cnt_new_w - 20;  end 
       else if (cnt_new_w > 9)  begin   d1=1;   cnt_new_w = cnt_new_w - 10;  end 
       else                     begin   d1=0;   end 

       // handle 1's digit 
       d0 = cnt_new_w[3:0]; 
    end
    

    // handles the lead zero blanking
    always @ (cnt, d1, d0)
    begin
       if (cnt < 10)  // 10's digit
          c2_d1 = 'hF; 
       else 
          c2_d1 = d1;
          
       c2_d0 = d0;       // 1's digit never blank
    end 
    
endmodule
