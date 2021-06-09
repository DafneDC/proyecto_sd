----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.05.2021 17:12:09
-- Design Name: 
-- Module Name: pwm - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity pwm is
    Port (  clk100m :   in std_logic;
            btn_in  :   in std_logic;
            timer   :   in std_logic;
            pwm_out :   out std_logic);
end pwm;

architecture Behavioral of pwm is

subtype u20 is unsigned(19 downto 0);
signal counter      : u20 := x"00000";

constant clk_freq   : integer := 100_000_000;       -- Clock frequency in Hz (10 ns)
constant pwm_freq   : integer := 50;                -- PWM signal frequency in Hz (20 ms)
constant period     : integer := clk_freq/pwm_freq; -- Clock cycle count per PWM period
signal duty_cycle : integer := 50_000;            -- Clock cycle count per PWM duty cycle

signal pwm_counter  : std_logic := '0';
signal stateHigh    : std_logic := '1';

begin
pwm_generator : process(clk100m, btn_in, timer) is
variable cur : u20 := counter;
begin       
         
    if((btn_in = '1' and btn_in'event)) then
        if(timer = '0') then
            duty_cycle <= 250_000;
        end if;
    end if;
    
    if(timer = '1') then
        duty_cycle <= 50_000;
    end if;
    
    if ((clk100m = '1' and clk100m'event) ) then
        cur := cur + 1;  
        counter <= cur;
        if (cur <= duty_cycle) then
            pwm_counter <= '1'; 
        elsif (cur > duty_cycle) then
            pwm_counter <= '0';
        elsif (cur = period) then
            cur := x"00000";
        end if;  
    end if;
end process pwm_generator;

    pwm_out <= pwm_counter;

end Behavioral;