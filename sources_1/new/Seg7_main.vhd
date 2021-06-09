----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.05.2021 02:34:58
-- Design Name: 
-- Module Name: Seg7_main - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Seg7_main is
    Port (  clk100m : in std_logic;
            data    : in std_logic_vector(31 downto 0);
            D7A     : out std_logic_vector (7 downto 0);
            D71     : out std_logic_vector (7 downto 0);
            manda   : in std_logic );
end Seg7_main;

architecture Behavioral of Seg7_main is
component Seg7 is
    Port(   ck       : in  std_logic;                      -- 100MHz system clock
			number   : in  std_logic_vector (63 downto 0); -- eight digit number to be displayed
			seg      : out  std_logic_vector (7 downto 0); -- display cathodes
			an       : out  std_logic_vector (7 downto 0));-- display anodes (active-low, due to transistor complementing)
end component;

signal d7s : STD_LOGIC_VECTOR (63 downto 0) := (others => '1');
signal aux: std_logic_vector(31 downto 0);

begin

Segm7: Seg7 port map (
    ck      => clk100m, 
    number  => d7s, 
    seg     => D7A, 
    an      => D71);
    
process(clk100m)
begin
    if (manda = '0') then
        aux <= data;
    else
        aux <= (others => '1');
    end if;
    
    case (aux(31 downto 28)) is
        when "0000" => d7s(63 downto 56) <= "11000000"; -- 0
        when "0001" => d7s(63 downto 56) <= "11111001"; -- 1
        when "0010" => d7s(63 downto 56) <= "10100100"; -- 2
        when "0011" => d7s(63 downto 56) <= "10110000"; -- 3
        when "0100" => d7s(63 downto 56) <= "10011001"; -- 4
        when "0101" => d7s(63 downto 56) <= "10010010"; -- 5
        when "0110" => d7s(63 downto 56) <= "10000010"; -- 6
        when "0111" => d7s(63 downto 56) <= "11111000"; -- 7
        when "1000" => d7s(63 downto 56) <= "10000000"; -- 8
        when "1001" => d7s(63 downto 56) <= "10010000"; -- 9
        when others => d7s(63 downto 56) <= "11111111"; -- x
    end case;
    
    case (aux(27 downto 24)) is
        when "0000" => d7s(55 downto 48) <= "11000000";
        when "0001" => d7s(55 downto 48) <= "11111001";
        when "0010" => d7s(55 downto 48) <= "10100100";
        when "0011" => d7s(55 downto 48) <= "10110000";
        when "0100" => d7s(55 downto 48) <= "10011001";
        when "0101" => d7s(55 downto 48) <= "10010010";
        when "0110" => d7s(55 downto 48) <= "10000010";
        when "0111" => d7s(55 downto 48) <= "11111000";
        when "1000" => d7s(55 downto 48) <= "10000000";
        when "1001" => d7s(55 downto 48) <= "10010000";
        when others => d7s(55 downto 48) <= "11111111";
    end case;
    
    case (aux(23 downto 20)) is
        when "0000" => d7s(47 downto 40) <= "11000000";
        when "0001" => d7s(47 downto 40) <= "11111001";
        when "0010" => d7s(47 downto 40) <= "10100100";
        when "0011" => d7s(47 downto 40) <= "10110000";
        when "0100" => d7s(47 downto 40) <= "10011001";
        when "0101" => d7s(47 downto 40) <= "10010010";
        when "0110" => d7s(47 downto 40) <= "10000010";
        when "0111" => d7s(47 downto 40) <= "11111000";
        when "1000" => d7s(47 downto 40) <= "10000000";
        when "1001" => d7s(47 downto 40) <= "10010000";
        when others => d7s(47 downto 40) <= "11111111";
    end case;
    
    case (aux(19 downto 16)) is
        when "0000" => d7s(39 downto 32) <= "11000000";
        when "0001" => d7s(39 downto 32) <= "11111001";
        when "0010" => d7s(39 downto 32) <= "10100100";
        when "0011" => d7s(39 downto 32) <= "10110000";
        when "0100" => d7s(39 downto 32) <= "10011001";
        when "0101" => d7s(39 downto 32) <= "10010010";
        when "0110" => d7s(39 downto 32) <= "10000010";
        when "0111" => d7s(39 downto 32) <= "11111000";
        when "1000" => d7s(39 downto 32) <= "10000000";
        when "1001" => d7s(39 downto 32) <= "10010000";
        when others => d7s(39 downto 32) <= "11111111";
    end case;

    case (aux(15 downto 12)) is
        when "0000" => d7s(31 downto 24) <= "11000000";
        when "0001" => d7s(31 downto 24) <= "11111001";
        when "0010" => d7s(31 downto 24) <= "10100100";
        when "0011" => d7s(31 downto 24) <= "10110000";
        when "0100" => d7s(31 downto 24) <= "10011001";
        when "0101" => d7s(31 downto 24) <= "10010010";
        when "0110" => d7s(31 downto 24) <= "10000010";
        when "0111" => d7s(31 downto 24) <= "11111000";
        when "1000" => d7s(31 downto 24) <= "10000000";
        when "1001" => d7s(31 downto 24) <= "10010000";
        when others => d7s(31 downto 24) <= "11111111";
    end case;

    case (aux(11 downto 8)) is
        when "0000" => d7s(23 downto 16) <= "11000000";
        when "0001" => d7s(23 downto 16) <= "11111001";
        when "0010" => d7s(23 downto 16) <= "10100100";
        when "0011" => d7s(23 downto 16) <= "10110000";
        when "0100" => d7s(23 downto 16) <= "10011001";
        when "0101" => d7s(23 downto 16) <= "10010010";
        when "0110" => d7s(23 downto 16) <= "10000010";
        when "0111" => d7s(23 downto 16) <= "11111000";
        when "1000" => d7s(23 downto 16) <= "10000000";
        when "1001" => d7s(23 downto 16) <= "10010000";
        when others => d7s(23 downto 16) <= "11111111";
    end case;


    case (aux(7 downto 4)) is
        when "0000" => d7s(15 downto 8) <= "11000000";
        when "0001" => d7s(15 downto 8) <= "11111001";
        when "0010" => d7s(15 downto 8) <= "10100100";
        when "0011" => d7s(15 downto 8) <= "10110000";
        when "0100" => d7s(15 downto 8) <= "10011001";
        when "0101" => d7s(15 downto 8) <= "10010010";
        when "0110" => d7s(15 downto 8) <= "10000010";
        when "0111" => d7s(15 downto 8) <= "11111000";
        when "1000" => d7s(15 downto 8) <= "10000000";
        when "1001" => d7s(15 downto 8) <= "10010000";
        when others => d7s(15 downto 8) <= "11111111";
    end case;

    case (aux(3 downto 0)) is
        when "0000" => d7s(7 downto 0) <= "11000000";
        when "0001" => d7s(7 downto 0) <= "11111001";
        when "0010" => d7s(7 downto 0) <= "10100100";
        when "0011" => d7s(7 downto 0) <= "10110000";
        when "0100" => d7s(7 downto 0) <= "10011001";
        when "0101" => d7s(7 downto 0) <= "10010010";
        when "0110" => d7s(7 downto 0) <= "10000010";
        when "0111" => d7s(7 downto 0) <= "11111000";
        when "1000" => d7s(7 downto 0) <= "10000000";
        when "1001" => d7s(7 downto 0) <= "10010000";
        when others => d7s(7 downto 0) <= "11111111";
    end case;
end process;

end Behavioral;
