library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity main is
    Port (  clock100MHZ : in std_logic;--
    
            reset       : in std_logic;
            reset_i2c   : in std_logic;--
            
            -------Motor--------
            door_btn    : in std_logic;--
            door_mtr    : out std_logic;--
            
            -------I2C--------
            SDA_IN      : in std_logic;--
            SCL_IN      : in std_logic;--
            SDA_OUT     : out std_logic;--
            SCL_OUT     : out std_logic;--
            
            -------LCD--------
            dataInOutLCD: inout std_logic_vector(7 downto 0);--
            RS          : out std_logic;--
            RW          : out std_logic;--
            E           : out std_logic;--
            
            -------Seg7--------
            D7A         : out std_logic_vector (7 downto 0);--
            D71         : out std_logic_vector (7 downto 0);--
            
            leds        : out std_logic_vector(1 downto 0);--
            
            conf        : out std_logic;--
            DATA        : out std_logic_vector(7 downto 0));--
end main;

architecture Behavioral of main is

---------- Comunicación I2C ----------
component I2CSLAVE is
	generic(
		DEVICE 		: std_logic_vector(7 downto 0) := x"38"
	);
	port(
		MCLK		: in	std_logic;
		nRST		: in	std_logic;
		SDA_IN		: in	std_logic;
		SCL_IN		: in	std_logic;
		SDA_OUT		: out	std_logic;
		SCL_OUT		: out	std_logic;
		ADDRESS		: out	std_logic_vector(7 downto 0);
		DATA_OUT	: out	std_logic_vector(7 downto 0);
		DATA_IN		: in	std_logic_vector(7 downto 0);
		WR			: out	std_logic;
		RD			: out	std_logic
	);
end component;

---------- Controlador del motor ----------
component pwm is
    Port (  clk100m :   in std_logic;
            btn_in  :   in std_logic;
            timer   :   in std_logic;
            pwm_out :   out std_logic);
end component;

---------- Memoria de la info del alumno ----------
component memory is 
    generic (data_width         : natural := 120;
             addr_length        : natural := 8
	    );
    port(
            clk                 : in std_logic;
            address             : in std_logic_vector(addr_length-1 downto 0);
            dataOut             : out std_logic_vector(data_width-1 downto 0);
            banderaDatosListos  : in std_logic;
            YesNo               : out std_logic
    );
end component;

---------- Controlador de la LCD ----------
component LCD is
    port (        
        clk                     : in  std_logic;
        reset                   : in std_logic; 
        banderaDatos            : in std_logic;
        bandera_puerta_cerrada  : in std_logic;
        dataInMem               : in std_logic_vector(119 downto 0); --datos que vienen de la memoria   
        data                    : inout std_logic_vector(7 downto 0);  --datos de entrada/salida LCD
        RS,RW,E                 : out std_logic    
    );
end component;

---------- Controlados de los Displays ----------
component Seg7_main is
    Port (  clk100m     : in std_logic;
            data        : in std_logic_vector(31 downto 0);
            D7A         : out std_logic_vector (7 downto 0);
            D71         : out std_logic_vector (7 downto 0);
            manda       : in std_logic);
end component;

---------- Señales auxiliares ----------
-- Para I2C
signal DATA_OUT_aux	:std_logic_vector(7 downto 0);
signal DATA_IN_aux: std_logic_vector(7 downto 0);
signal WR_aux:std_logic;
signal RD_aux:std_logic;
-- Para datos del alumno
signal I2CtoMemory: std_logic_vector(7 downto 0) := "00000000";
signal alumno_confirmado: std_logic;
-- Reloj de 50 MHZ
signal clkdiv1: std_logic := '0';
-- LCD
signal reset1: std_logic := '0'; --switch?
signal YesNoaux: std_logic;
-- Memoria
signal dataOutMemory: std_logic_vector(119 downto 0) := (others => '0');

---------- Inicio del programa ----------
begin

--50mhz
process(clock100MHz)
begin 
    if(clock100MHz = '1' and clock100MHz'EVENT) then
        clkdiv1 <= not clkdiv1;
    end if;
end process;
-- 50 Mhz

i2c: I2CSLAVE port map(
		MCLK      => clock100MHZ,
		nRST      => reset_i2c,
		SDA_IN    => SDA_IN,
		SCL_IN    => SCL_IN,
		SDA_OUT   => SDA_OUT ,
		SCL_OUT   => SCL_OUT,
		ADDRESS   => I2CtoMemory,
		DATA_OUT  => DATA_OUT_aux,
		DATA_IN   => DATA_IN_aux ,
		WR        => WR_aux,
		RD        => RD_aux
	);
	
pwm_c: pwm port map (   
        clk100m => clock100MHZ,
        btn_in  => door_btn,
        timer   => alumno_confirmado,
        pwm_out => door_mtr
    );
    
seg: Seg7_main port map (  
        clk100m  => clock100MHZ,
        data     => dataOutMemory(111 downto 80),
        D7A      => D7A,
        D71      => D71,
        manda    => alumno_confirmado);

memoria: memory port map(
        clk                 => clock100MHz, 
        address             => I2CtoMemory, 
        dataOut             => dataOutMemory,
        banderaDatosListos  => alumno_confirmado,
        YesNo               => YesNoaux );
        
displayLCD: LCD port map(
        clk                     => clock100MHz,
        reset                   => reset1,
        banderaDatos            => YesNoaux,
        bandera_puerta_cerrada  => alumno_confirmado,
        dataInMem               => dataOutMemory,
        data                    => dataInOutLCD,
        RS                      => RS,
        RW                      => RW,
        E                       => E);

----------- Confirmar que es el alumno ---------
-- 0000 0000 -> espera información del alumno
-- xxxx xxxx -> indice del alumno
-- 1111 1111 -> alumno no identificado

confirmar_alumno: process (I2CtoMemory)
begin
    if(I2CtoMemory = "00000000") then
        alumno_confirmado <= '1';
    else
        alumno_confirmado <= '0';
    end if;        
end process;

---------- Pruebas ----------
DATA <= I2CtoMemory;
conf <= alumno_confirmado;

end Behavioral;
