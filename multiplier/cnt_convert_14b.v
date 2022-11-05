//- converts 14-bit binary to 4 digit decimal
module cnt_convert_14b(
    input [13:0] cnt,
    input [1:0] sel,
    output reg [3:0] c1_d3,
    output reg [3:0] c1_d2,
    output reg [3:0] c1_d1,
    output reg [3:0] c1_d0
    );
    reg [13:0] cnt_new;      // working value  
    reg [13:0] cnt_new_w;    // working value 
   
    //- BCD intermediates for digits  
    reg [3:0] d3;     // 1000's digit  
    reg [3:0] d2;     // 100's digit
    reg [3:0] d1;     // 10's digit
    reg [3:0] d0;     // 1's digit
    
    //- clear unused bits on per mode basis
    always @ (cnt,sel)
       case(sel)
          0: cnt_new = {6'b000000,cnt[7:0]};   // clear zeros for [0,255] mode
          1: cnt_new = {7'b00000000,cnt[6:0]}; // clear zeros for [0,99] mode  
          2: cnt_new = cnt;                    // 14-bit mode
          3: cnt_new = cnt;                    // unused mode
          default cnt_new = cnt; 
       endcase
    
    always @ (cnt_new)
    begin
       d3=0;  d2=0;  d1=0;  d0=0;    // pre-assign digits 
       cnt_new_w = cnt_new;          // copy value
       
       //- find 1000's digit
       if      (cnt_new_w > 8999) begin   d3=9;   cnt_new_w = cnt_new_w - 9000;  end
       else if (cnt_new_w > 7999) begin   d3=8;   cnt_new_w = cnt_new_w - 8000;  end 
       else if (cnt_new_w > 6999) begin   d3=7;   cnt_new_w = cnt_new_w - 7000;  end 
       else if (cnt_new_w > 5999) begin   d3=6;   cnt_new_w = cnt_new_w - 6000;  end 
       else if (cnt_new_w > 4999) begin   d3=5;   cnt_new_w = cnt_new_w - 5000;  end 
       else if (cnt_new_w > 3999) begin   d3=4;   cnt_new_w = cnt_new_w - 4000;  end 
       else if (cnt_new_w > 2999) begin   d3=3;   cnt_new_w = cnt_new_w - 3000;  end 
       else if (cnt_new_w > 1999) begin   d3=2;   cnt_new_w = cnt_new_w - 2000;  end 
       else if (cnt_new_w > 999)  begin   d3=1;   cnt_new_w = cnt_new_w - 1000;  end 
       else                       begin   d3=0;   end 

       //- find 100's digit
       if      (cnt_new_w > 899) begin   d2=9;   cnt_new_w = cnt_new_w - 900;  end
       else if (cnt_new_w > 799) begin   d2=8;   cnt_new_w = cnt_new_w - 800;  end 
       else if (cnt_new_w > 699) begin   d2=7;   cnt_new_w = cnt_new_w - 700;  end 
       else if (cnt_new_w > 599) begin   d2=6;   cnt_new_w = cnt_new_w - 600;  end 
       else if (cnt_new_w > 499) begin   d2=5;   cnt_new_w = cnt_new_w - 500;  end 
       else if (cnt_new_w > 399) begin   d2=4;   cnt_new_w = cnt_new_w - 400;  end 
       else if (cnt_new_w > 299) begin   d2=3;   cnt_new_w = cnt_new_w - 300;  end 
       else if (cnt_new_w > 199) begin   d2=2;   cnt_new_w = cnt_new_w - 200;  end 
       else if (cnt_new_w > 99)  begin   d2=1;   cnt_new_w = cnt_new_w - 100;  end 
       else                      begin   d2=0;   end 

       //- find 10's digit
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

       //- assign 1's digit 
       d0 = cnt_new_w[3:0]; 

    end
    
    //- handles the lead zero blanking
    always @ (cnt_new, d3,d2,d1,d0)
    begin
       if (cnt_new < 1000) // 1000's digit 
          c1_d3 = 'hF; 
       else 
          c1_d3 = d3; 
 
       if (cnt_new < 100)  // 100's digit
          c1_d2 = 'hF; 
       else 
          c1_d2 = d2; 

       if (cnt_new < 10)  // 10's digit
          c1_d1 = 'hF; 
       else 
          c1_d1 = d1;
          
       c1_d0 = d0;        // 1's digit never blank
    end 
    
endmodule