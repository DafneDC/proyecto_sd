library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity LCD is
    port (        
        clk: in  std_logic;
        reset: in std_logic;
        banderaDatos: in std_logic;
        bandera_puerta_cerrada: in std_logic;
        dataInMem: in std_logic_vector(119 downto 0); --datos que vienen de la memoria   
        data: inout std_logic_vector(7 downto 0);  --datos de entrada/salida LCD
        RS,RW,E: out std_logic    
    );
end LCD;
 
architecture Behavioral of LCD is

--Estados de la maquina de estados.

  type estados_t is (RST,ST0,ST1,FSET,EMSET,DO,CLD,RETH,SDDRAMA,WRITE_B,WRITE_I,
                     WRITE_E, WRITE_N, WRITE_V, WRITE_E2, WRITE_N2, WRITE_I2, WRITE_D, WRITE_O, estadoEspera, SDDRAMA2,WRITE_LETRA1,
                     WRITE_LETRA2, WRITE_LETRA3, WRITE_LETRA4, WRITE_LETRA5,  WRITE_LETRA6, WRITE_LETRA7, WRITE_LETRA8, WRITE15,WRITE16,
                     WRITE_LETRA9, WRITE_LETRA10,ESTADO_ESPERA_Puerta,WRITE19STOP,RESETLCD,CLD2,RETH2,SDDRAMA3,DO2,DO3);
  
  --Señales 
  signal state, Next_state : estados_t; 
  signal CONT1: std_logic_vector(23 downto 0) := X"000000"; --contador de 0 a 16777216 = 0.33 segundos
  signal CONT2: std_logic_vector(4 downto 0) := "00000"; --contador de 0 a 32, = 0.64 us
  signal reinicio: std_logic :='0';
  signal ready: std_logic := '0';
  signal Bandera_datos: std_logic := '0';

--Letras ASCII
   constant A_S: std_logic_vector(7 downto 0):= x"41"; 
   constant B_S: std_logic_vector(7 downto 0):= x"42";
   constant C_S: std_logic_vector(7 downto 0):= x"43";
   constant D_S: std_logic_vector(7 downto 0):= x"44";
   constant E_S: std_logic_vector(7 downto 0):= x"45";
   constant F_S: std_logic_vector(7 downto 0):= x"46";
   constant G_S: std_logic_vector(7 downto 0):= x"47";
   constant H_S: std_logic_vector(7 downto 0):= x"48";
   constant I_S: std_logic_vector(7 downto 0):= x"49";
   constant J_S: std_logic_vector(7 downto 0):= x"4A";
   constant K_S: std_logic_vector(7 downto 0):= x"4B";
   constant L_S: std_logic_vector(7 downto 0):= x"4C";
   constant M_S: std_logic_vector(7 downto 0):= x"4D";
   constant N_S: std_logic_vector(7 downto 0):= x"4E";
   constant O_S: std_logic_vector(7 downto 0):= x"4F";
   constant P_S: std_logic_vector(7 downto 0):= x"50";
   constant Q_S: std_logic_vector(7 downto 0):= x"51";
   constant R_S: std_logic_vector(7 downto 0):= x"52";
   constant S_S: std_logic_vector(7 downto 0):= x"53";
   constant T_S: std_logic_vector(7 downto 0):= x"54";
   constant U_S: std_logic_vector(7 downto 0):= x"55";
   constant V_S: std_logic_vector(7 downto 0):= x"56";
   constant W_S: std_logic_vector(7 downto 0):= x"57";
   constant X_S: std_logic_vector(7 downto 0):= x"58";
   constant Z_S: std_logic_vector(7 downto 0):= x"59"; 
     
   
   --CONSTANTES DE TIEMPO 
   constant T1: STD_LOGIC_VECTOR(23 DOWNTO 0) := x"000fff"; --espera de 81.9 us
   
  begin
  --CONTADOR DE RETARDOS CONT1 --
  process(clk,reset)
  begin
        if reset='1' then   CONT1 <= (others => '0');
        elsif clk'event and clk='1' then CONT1 <= CONT1 + 1;
        end if;
  end process;

--Contador para Secuencias CONT2--
    process(clk,ready)
    begin
        if clk='1' and clk'event then
            if ready='1' then CONT2 <= CONT2 + 1;
            else CONT2 <= "00000";
            end if;
        end if;
   end process;
   
--Actualizacion de estados
    process (clk,Next_state) 
    begin
    if clk='1' and clk'event then state<=Next_state;
    end if;
  end process;
--maquina de estados
  process(CONT1,CONT2,state,clk,reset)
  begin
    
    if reset = '1' THEN Next_State <= RST;
    elsif clk='0' and clk'event then
    
    case State is
        when RST => -- Estado de reset
               if CONT1=X"000000"then --0s
                   RS<='0';
                   RW<='0';
                   E<='0';
                   DATA<=X"00";
                   Next_State<=ST0;
               else
                   Next_State<=ST0;
               end if;
     
        when ST0 => --Primer estado de espera por 25ms(20ms=0F4240=1000000)(15ms=0B71B0=750000)
               if CONT1=X"1312D0" then -- 1,250,000=25ms
                    READY<='1';
                    DATA<=X"38"; -- FUNCTION SET 8BITS, 2 LINE, 5X7
                    Next_State<=ST0;
               elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
                    E<='1';
               elsif CONT2="1111" then
                    READY<='0';
                    E<='0';
                    Next_State<=ST1;
               else
                    Next_State<=ST0;
               end if;
               reinicio<= CONT2(0)and CONT2(1) and CONT2(2)and CONT2(3); -- CONT1 = 0
               
        when ST1 => --Segundo estado de espera por 100us (5000=x35E8)
               if CONT1=X"0035E8" then -- 13800 = 276us
                   READY<='1';
                   DATA<=X"38"; -- FUNCTION SET
                   Next_State<=ST1;
               elsif CONT2>"00001" and CONT2<"01110" then --rango de 12*20ns=240ns
                   E<='1';
               elsif CONT2="1111" then
                   READY<='0';
                   E<='0';
                   Next_State<=FSET;
               else
                   Next_State<=ST1;
               end if;
               reinicio <= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0 
                 
        when FSET => --FUNCTION SET 0x38 (8bits, 2 lineas, 5x7dots)
               if CONT1=X"0007D0" then --espera por 40us
                   READY<='1';
                   DATA<=X"38"; --001DL-N-F-XX
                   Next_State<=FSET;
               elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
                    E<='1';
               elsif CONT2="1111" then
                   READY<='0';
                   E<='0';
                   Next_State<=EMSET;
               else
                   Next_State<=FSET;
               end if;
               reinicio<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0   
               
        when EMSET => --ENTRY MODE SET 0x06 (1 right-moving cursor and address increment)
               if CONT1=X"0007D0" then --estado de espera por 40us
                   READY<='1';
                   DATA<=X"06"; --000001-I/D-SH
                   Next_State<=EMSET;
               elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
                    E<='1';
               elsif CONT2="1111" then
                   READY<='0';
                   E<='0';
                   Next_State<=DO;
               else
                    Next_State<=EMSET;
               end if;
               reinicio<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
               
        when DO => --DISPLAY ON/OFF 0x0C (DISPLAY-CURSOR-BLINKING on-off)
               if CONT1=X"0007D0" then -- estado de espera por 40us
                   READY<='1';
                   DATA<=X"0C"; --00001-D-C-B,display on, cursor on
                   Next_State<=DO;
               elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
                   E<='1';
               elsif CONT2="1111" then
                   READY<='0';
                   E<='0';
                   Next_State<=CLD;
               else
                   Next_State<=DO;
               end if;
               reinicio<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
                  
        when CLD => --CLEAR DISPLAY 0x01
               if CONT1=X"0007D0" then-- estado de espera por 40us
               
               READY<='1';
               DATA<=X"01"; --00000001
               Next_State<=CLD;
               
               elsif CONT2>"00001" and CONT2<"01110" then
               
               E<='1';
               elsif CONT2="1111" then
               READY<='0';
               E<='0';
               Next_State<=RETH;
               
               else
               
               Next_State<=CLD;
               
               end if;
               reinicio<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
               
        when RETH => --RETURN CURSOR HOME
               if CONT1=X"0007D0" then -- estado de espera por 40us
               
               READY<='1';
               DATA<=X"02"; --0000001X
               Next_State<=RETH;
               
               elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
               
               E<='1';
               elsif CONT2="1111" then
               READY<='0';
               E<='0';
               Next_State<=SDDRAMA;
               
               else
               
               Next_State<=RETH;
               
               end if;
               reinicio<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
               
               ------ ------
        when SDDRAMA => --SET DD RAM ADDRESS posición del display del renglón 1 columna 4
               if CONT1=X"014050" then -- estado de espera por 1.64ms
               
               READY<='1';
               DATA<=X"80"; --1-AC6-AC0, 80(R=1,C=1) 84(R=1,C=5)
               Next_State<=SDDRAMA;
               
               elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
               
               E<='1';
               elsif CONT2="1111" then
               READY<='0';
               E<='0';
               Next_State<=WRITE_B;
               
               else
               
               Next_State<=SDDRAMA;
               
               end if;
               reinicio<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
        ---------------------------------------------------------------------------------------
               --DATOS--DATOS--DATOS--DATOS--DATOS--DATOS--DATOS--DATOS--DATOS--DATOS--DATOS--
               ---------------------------------------------------------------------------------------
        when WRITE_B => --Write Data in DD RAM (S 53)
               if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
               READY<='1';
               RS<='1';
               DATA<=B_S; --DATA<=x"53";
               Next_State<=WRITE_B;
               elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
               E<='1';
               elsif CONT2="1111" then
               READY<='0';
               E<='0';
               Next_State<=WRITE_I;
               else
               Next_State<=WRITE_B;
               end if;
               
               reinicio<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
              
        when WRITE_I => --Write Data in DD RAM (i 69, í A1)
               if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
               READY<='1';
               RS<='1';
               DATA<=I_S; --DATA<=x"69";
               Next_State<=WRITE_I;
               elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
               E<='1';
               elsif CONT2="1111" then
               READY<='0';
               E<='0';
               Next_State<=WRITE_E;
               else
               Next_State<=WRITE_I;
               end if;
               
               REINICIO<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
        when WRITE_E => --Write Data in DD RAM (m 6D)
               if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
               READY<='1';
               RS<='1';
               DATA<=E_S; --DATA<=x"6D";
               Next_State<=WRITE_E;
               elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
               E<='1';
               elsif CONT2="1111" then
               READY<='0';
               E<='0';
               --Next_State<=SDDRAMA2;
               Next_State<=WRITE_N;
               else
               Next_State<=WRITE_E;
               end if;
               
               REINICIO<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
               
        when WRITE_N => --Write Data in DD RAM (m 6D)
               if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
               READY<='1';
               RS<='1';
               DATA<=N_S; -- MISMA LETRA
               Next_State<=WRITE_N; -- MISMA LETRA
               elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
               E<='1';
               elsif CONT2="1111" then
               READY<='0';
               E<='0';
               --Next_State<=SDDRAMA2;
               Next_State<=WRITE_V; --LETRA QUE SIGUE
               else
               Next_State<=WRITE_N;-- MISMA LETRA
               end if;
                       
               REINICIO<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0        
       when WRITE_V => --Write Data in DD RAM (m 6D)
               if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
               READY<='1';
               RS<='1';
               DATA<=V_S; -- MISMA LETRA
               Next_State<=WRITE_V; -- MISMA LETRA
               elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
               E<='1';
               elsif CONT2="1111" then
               READY<='0';
               E<='0';
               --Next_State<=SDDRAMA2;
               Next_State<=WRITE_E2; --LETRA QUE SIGUE
               else
               Next_State<=WRITE_V;-- MISMA LETRA
               end if;
                       
               REINICIO<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
       when WRITE_E2 => --Write Data in DD RAM (m 6D)
               if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
               READY<='1';
               RS<='1';
               DATA<=E_S; -- MISMA LETRA
               Next_State<=WRITE_E2; -- MISMA LETRA
               elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
               E<='1';
               elsif CONT2="1111" then
               READY<='0';
               E<='0';
               --Next_State<=SDDRAMA2;
               Next_State<=WRITE_N2; --LETRA QUE SIGUE
               else
               Next_State<=WRITE_E2;-- MISMA LETRA
               end if;
                       
               REINICIO<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
        when WRITE_N2 => --Write Data in DD RAM (m 6D)
               if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
               READY<='1';
               RS<='1';
               DATA<=N_S; -- MISMA LETRA
               Next_State<=WRITE_N2; -- MISMA LETRA
               elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
               E<='1';
               elsif CONT2="1111" then
               READY<='0';
               E<='0';
               --Next_State<=SDDRAMA2;
               Next_State<=WRITE_I2; --LETRA QUE SIGUE
               else
               Next_State<=WRITE_N2;-- MISMA LETRA
               end if;
                       
               REINICIO<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
        when WRITE_I2 => --Write Data in DD RAM (m 6D)
               if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
               READY<='1';
               RS<='1';
               DATA<=I_S; -- MISMA LETRA
               Next_State<=WRITE_I2; -- MISMA LETRA
               elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
               E<='1';
               elsif CONT2="1111" then
               READY<='0';
               E<='0';
               --Next_State<=SDDRAMA2;
               Next_State<=WRITE_D; --LETRA QUE SIGUE
               else
               Next_State<=WRITE_I2;-- MISMA LETRA
               end if;
                       
               REINICIO<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
       when WRITE_D => --Write Data in DD RAM (m 6D)
               if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
               READY<='1';
               RS<='1';
               DATA<=D_S; -- MISMA LETRA
               Next_State<=WRITE_D; -- MISMA LETRA
               elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
               E<='1';
               elsif CONT2="1111" then
               READY<='0';
               E<='0';
               --Next_State<=SDDRAMA2;
               Next_State<=WRITE_O; --LETRA QUE SIGUE
               else
               Next_State<=WRITE_D;-- MISMA LETRA
               end if;
                       
               REINICIO<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
       when WRITE_O => --Write Data in DD RAM (m 6D)
               if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
               READY<='1';
               RS<='1';
               DATA<=O_S; -- MISMA LETRA
               Next_State<=WRITE_O; -- MISMA LETRA
               elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
               E<='1';
               elsif CONT2="1111" then
               READY<='0';
               E<='0';
               
               if banderaDatos = '0' then
                    Next_State<=estadoEspera;
               elsif banderaDatos='1' then 
                    Next_State<=SDDRAMA2;
               end if;
              
               else
               Next_State<=WRITE_O;-- MISMA LETRA
               end if;
                       
               REINICIO<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
         
         when estadoEspera =>
              if banderaDatos = '0' then
                             Next_State<=estadoEspera;
                        elsif banderaDatos='1' then 
                             Next_State<=SDDRAMA2;
                        end if;
                        
              REINICIO<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
              
         when SDDRAMA2 => --SET DD RAM ADDRESS posición del display renglón 2 columna 1
                 if CONT1=X"014050" then -- estado de espera por 1.64ms
                 READY<='1';
                 RS<='0';
                 DATA<=X"C0"; --1-AC6 - AC0, C0(R=2,C=1)
                 Next_State<=SDDRAMA2;
                 elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
                 E<='1';
                 elsif CONT2="1111" then
                 READY<='0';
                 E<='0';
                 Next_State<=WRITE_LETRA1; --para brincar al segundo renglón
                 else
                 Next_State<=SDDRAMA2;
                 end if;
                 
                 REINICIO<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
               
                    
         
    when WRITE_LETRA1 => 
               
               
               
               if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
               READY<='1';
               RS<='1';      
               DATA<=dataInMem(79 downto 72);     
               Next_State<=WRITE_LETRA1; --MISMA LETRA
               elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
               E<='1';
               elsif CONT2="1111" then
               READY<='0';
               E<='0';
               Next_State<=WRITE_LETRA2; --SIGUIENTE
               else
               Next_State<=WRITE_LETRA1; --MISMO
               end if;
               
               reinicio<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
     when WRITE_LETRA2 =>
      
             
              
              if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
              READY<='1';
              RS<='1';
              DATA<=dataInMem(71 downto 64);  --MISMA LETRA
              Next_State<=WRITE_LETRA2; --MISMA LETRA
              elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
              E<='1';
              elsif CONT2="1111" then
              READY<='0';
              E<='0';
              Next_State<=WRITE_LETRA3; --SIGUIENTE
              else
              Next_State<=WRITE_LETRA2; --MISMO
              end if;
              
              reinicio<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3);
      when WRITE_LETRA3 => 
               
              
               
               if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
               READY<='1';
               RS<='1';
               DATA<=dataInMem(63 downto 56);  --MISMA LETRA
               Next_State<=WRITE_LETRA3; --MISMA LETRA
               elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
               E<='1';
               elsif CONT2="1111" then
               READY<='0';
               E<='0';
               Next_State<=WRITE_LETRA4; --SIGUIENTE
               else
               Next_State<=WRITE_LETRA3; --MISMO
               end if;
               reinicio<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3);
      when WRITE_LETRA4 => 
      
           
                
              if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
              READY<='1';
              RS<='1';
              DATA<=dataInMem(55 downto 48);  --MISMA LETRA
              Next_State<=WRITE_LETRA4; --MISMA LETRA
              elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
              E<='1';
              elsif CONT2="1111" then
              READY<='0';
              E<='0';
              Next_State<=WRITE_LETRA5; --SIGUIENTE
              else
              Next_State<=WRITE_LETRA4; --MISMO
              end if;
              reinicio<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3);
       when WRITE_LETRA5 => 
                
               
                
                if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
                READY<='1';
                RS<='1';
                DATA<=dataInMem(47 downto 40);  --MISMA LETRA
                Next_State<=WRITE_LETRA5; --MISMA LETRA
                elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
                E<='1';
                elsif CONT2="1111" then
                READY<='0';
                E<='0';
                Next_State<=WRITE_LETRA6; --SIGUIENTE
                else
                Next_State<=WRITE_LETRA5; --MISMO
                end if;
                reinicio<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3);
         when WRITE_LETRA6 => 
         
               
               
               if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
               READY<='1';
               RS<='1';
               DATA<=dataInMem(39 downto 32);  --MISMA LETRA
               Next_State<=WRITE_LETRA6; --MISMA LETRA
               elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
               E<='1';
               elsif CONT2="1111" then
               READY<='0';
               E<='0';
               Next_State<=WRITE_LETRA7; --SIGUIENTE
               else
               Next_State<=WRITE_LETRA6; --MISMO
               end if;
               reinicio<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3);
       when WRITE_LETRA7 => 
              
--              if(dataInMem(31 downto 24)=x"11") then
--                    Next_State<=WRITE_LETRA7;
--              end if;
              
              if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
              READY<='1';
              RS<='1';
              DATA<=dataInMem(31 downto 24);  --MISMA LETRA
              Next_State<=WRITE_LETRA7; --MISMA LETRA
              elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
              E<='1';
              elsif CONT2="1111" then
              READY<='0';
              E<='0';
              Next_State<=WRITE_LETRA8; --SIGUIENTE
              else
              Next_State<=WRITE_LETRA7; --MISMO
              end if;
              reinicio<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3);
        when WRITE_LETRA8 => 
               if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
               READY<='1';
               RS<='1';
               DATA<=dataInMem(23 downto 16);  --MISMA LETRA
               Next_State<=WRITE_LETRA8; --MISMA LETRA
               elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
               E<='1';
               elsif CONT2="1111" then
               READY<='0';
               E<='0';
               Next_State<=WRITE_LETRA9; --SIGUIENTE
               else
               Next_State<=WRITE_LETRA8; --MISMO
               end if;
               reinicio<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3);
       when WRITE_LETRA9 => 
                 if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
                 READY<='1';
                 RS<='1';
                 DATA<=dataInMem(15 downto 8);  --MISMA LETRA
                 Next_State<=WRITE_LETRA9; --MISMA LETRA
                 elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
                 E<='1';
                 elsif CONT2="1111" then
                 READY<='0';
                 E<='0';
                 Next_State<=WRITE_LETRA10; --SIGUIENTE
                 else
                 Next_State<=WRITE_LETRA9; --MISMO
                 end if;
                 reinicio<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3);
       when WRITE_LETRA10 => 
                  if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
                  READY<='1';
                  RS<='1';
                  DATA<=dataInMem(7 downto 0);  --MISMA LETRA
                  Next_State<=WRITE_LETRA10; --MISMA LETRA
                  elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
                  E<='1';
                  elsif CONT2="1111" then
                  READY<='0';
                  E<='0';
                  Next_State<=ESTADO_ESPERA_Puerta; --SIGUIENTE
                  else
                  Next_State<=WRITE_LETRA10; --MISMO
                  end if;
                  reinicio<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3);
                  
        when ESTADO_ESPERA_Puerta => 
                    if  bandera_puerta_cerrada='1' then
                    Next_State<=ESTADO_ESPERA_Puerta;
                    else
                    Next_State<=WRITE19STOP; 
                    end if;
                    reinicio<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3);
        when WRITE19STOP => 
                   if bandera_puerta_cerrada='0' then
                   Next_State<=WRITE19STOP;
                   else
                   Next_State<=RESETLCD; 
                   end if;
                   reinicio<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3);
        when RESETLCD => 
                  if bandera_puerta_cerrada='1' then
                  Next_State<=DO2;
                  else
                  Next_State<=RESETLCD; 
                  end if;
                  reinicio<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3);
         when DO2 => --DISPLAY ON/OFF 0x0C (DISPLAY-CURSOR-BLINKING on-off)
                 if CONT1=X"0007D0" then -- estado de espera por 40us
                     READY<='1';
                     RS<='0';
                     DATA<="00001000"; --00001-D-C-B,display OFF
                     Next_State<=DO2;
                 elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
                     E<='1';
                 elsif CONT2="1111" then
                     READY<='0';
                     E<='0';
                     Next_State<=RST;
                 else
                     Next_State<=DO2;
                 end if;
                 reinicio<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
        
        when others => 
            E <= '1';
            state <= state;
        end case;
        
        end if;
end process; --FIN DEL PROCESO DE LA MÁQUINA DE ESTADOS
         
end Behavioral;

