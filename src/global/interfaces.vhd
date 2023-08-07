----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/31/2023 01:40:39 PM
-- Design Name: 
-- Module Name: interfaces - 
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
use work.constants.all;

package interfaces is
    
    type writeback is record
        enable : std_logic;
        addr : std_logic_vector (2 downto 0);
        value : std_logic_vector ( word_width - 1 downto 0);
    end record writeback;

    type regfile_iface is record
        inst_ptr : std_logic_vector (word_width - 1 downto 0);
        read1a, read2a : std_logic_vector (2 downto 0);
        write : writeback;
        write_carry : writeback;
    end record;
    
    type exec_iface is record
        read1, read2 : std_logic_vector (word_width - 1 downto 0);
        write : writeback;
    end  record;

end package interfaces;