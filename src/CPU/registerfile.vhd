----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/01/2023 01:08:29 PM
-- Design Name: 
-- Module Name: regfile - twoproc
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
use ieee.numeric_std.all;
use work.interfaces.all;
use work.constants.all;

entity regfile is
    Port ( clk, reset : in std_logic;
           input : in regfile_iface;
           output : out exec_iface;
           stallback : out std_logic);
end regfile;

architecture twoproc of regfile is
    -- Blocker is active when waiting for a write, creates a stall if hit
    type blocker_t is array (0 to 7) of std_logic;

    type register_t is array (0 to 7) of std_logic_vector (word_width - 1 downto 0);
    -- "000" Instruction Pointer
    -- "001" Stack Pointer
    -- "010" Return Address
    -- "011" Accumulator (add stuff up into)
    -- "100" Beta (general purpose)
    -- "101" Counter (loops)
    -- "110" Data (pointers)
    -- "111" Extraneous (whatever else)
    
    signal master : regfile_iface;
    signal slave : exec_iface;
    
    signal registers : register_t;
    signal blockers : blocker_t;
begin
        
    update : process(clk) is
    begin
        if rising_edge(clk) then
            if reset = '1' then
                registers <= (others => (others => '0'));
                blockers <= (others => '0');
            else
                if input.write.enable = '1' then
                    registers(to_integer(unsigned(input.write.addr))) <= input.write.value;
                    if input.write_carry.enable = '1' then
                        if input.write.addr = input.write_carry.addr then
                            blockers(to_integer(unsigned(input.write_carry.addr))) <= '1';
                        else
                            blockers(to_integer(unsigned(input.write.addr))) <= '0';
                            blockers(to_integer(unsigned(input.write_carry.addr))) <= '1';
                        end if;
                    end if;
                end if;
            end if;
            master <= input;
        end if;
    end process update;
    
    resolve : process(master, registers, blockers) is
    begin
                
        -- If either read address is being blocked trigger a stall        
        if blockers(to_integer(unsigned(master.read1a))) = '1' then
            if master.write.enable = '0' or master.write.addr /= master.read1a then
                stallback <= '1';
            else
                stallback <= '0';
            end if;
        elsif blockers(to_integer(unsigned(master.read2a))) = '1' then
            if master.write.enable = '0' or master.write.addr /= master.read2a then
                stallback <= '1';
            else
                stallback <= '0';
            end if;
        else
            stallback <= '0';
        end if;

        if master.read1a = "000" then
            slave.read1 <= master.inst_ptr;
        else
            slave.read1 <= registers(to_integer(unsigned(master.read1a)));
        end if;
        
        if master.read2a = "000" then
            slave.read2 <= master.inst_ptr;
        else
            slave.read2 <= registers(to_integer(unsigned(master.read2a)));        
        end if;
        slave.write <= master.write_carry;
    end process resolve;
    
    output <= slave;

end twoproc;
