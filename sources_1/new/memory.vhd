library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is 
    generic (data_width: natural := 120;
             addr_length: natural := 8
	    );
    port(
            clk: in std_logic;
            address: in std_logic_vector(addr_length-1 downto 0);
            dataOut: out std_logic_vector(data_width-1 downto 0);
            banderaDatosListos: in std_logic;
            YesNo: out std_logic
    );
    end memory;



architecture Behavioral of memory is

--constant mem_size: natural := 2**addr_length;
type data_array is array (0 to 255) of std_logic_vector(data_width-1 downto 0);
constant rom: data_array := 
    ( --X"0A0173216600414C454A414E44524F", ------ID: 0, MATRICULA: A01732166, NOMBRE: ALEJANDRO. 
      --X"1A008238330000454A414441464E45", ------ID: 1, MATRICULA: A00823833, NOMBRE: DAFNE.
        0=>x"0A0000000000000000000000000000", --wait
        1=>x"1A01732166414C454A414E44524FA0", -- 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
        2=>x"2A017305574D4152494FA0A0A0A0A0",
        3=>x"3A01410366414C454A414E44524FA0",
        4=>x"4A008238334441464E45A03A29A0A0",
 others => x"0A0000000000000000000000000000"
    );
      --X"2A01732166414C454A414E44524F00",
      --X"3A01732166414C454A414E44524F00",
      --X"4A01732166414C454A414E44524F00",
      --X"5A01732166414C454A414E44524F00",
      --X"6A01732166414C454A414E44524F00",
      --X"7A01732166414C454A414E44524F00",
      --X"8A01732166414C454A414E44524F00",
      --X"9A01732166414C454A414E44524F00",
      --X"AA01732166414C454A414E44524F00",
      --X"BA01732166414C454A414E44524F00",
      --X"CA01732166414C454A414E44524F00",
      --X"DA01732166414C454A414E44524F00",
      --X"EA01732166414C454A414E44524F00",
      --X"FA01732166414C454A414E44524F00",
    --);

begin

rom1: process (clk)
begin
	if(rising_edge(clk)) then
	   if((banderaDatosListos = '0') and not(address = "11111111")) then 
	       dataOut <= rom(to_integer(unsigned(address)));
	       YesNo <= '1';
	   else
	       YesNo <= '0';
	   end if;	       
	end if;
    end process;

end Behavioral;
