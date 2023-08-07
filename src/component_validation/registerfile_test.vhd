----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/02/2023 07:19:39 PM
-- Design Name: 
-- Module Name: registerfile_test - 
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
use work.interfaces.all;
use work.constants.all;

entity registerfile_test is
--  Port ( );
end registerfile_test;

architecture tb of registerfile_test is
    constant T : time := 20 ns;
    
    type test_vector is record
        control : regfile_iface;
    end record;
    
    constant num_tests : integer := 3;
    
    type test_array is array (0 to num_tests-1) of test_vector;
    
    constant test_vector_array : test_array := (
        (control => (inst_ptr => x"00000000", read1a => "001", read2a => "000",
        write => (enable => '1', addr => "001", value => x"0000FFFF"),
        write_carry => (enable => '1', addr => "010", value => x"FFFF0000"))),
        
        (control => (inst_ptr => x"00000001", read1a => "010", read2a => "000",
        write => (enable => '1', addr => "010", value => x"FFFF0000"),
        write_carry => (enable => '1', addr => "011", value => x"FFFFFFFF"))),
        
        (control => (inst_ptr => x"00000002", read1a => "011", read2a => "000",
        write => (enable => '1', addr => "011", value => x"FFFFFFFF"),
        write_carry => (enable => '1', addr => "011", value => x"FFFFFFFF")))
    );

    signal clk, reset : std_logic;
    signal input : regfile_iface := test_vector_array(0).control;
    signal output : exec_iface;
    signal stalling : std_logic;
     
begin

    rf_inst : entity work.regfile
        port map ( clk => clk, reset => reset, input => input, stallback => stalling, output => output);

    clock : process
    begin
        clk <= '0';
        wait for T/2;
        clk <= '1';
        wait for T/2;
    end process clock;
    
    reset <= '1', '0' after T;
    
    stim : process
    begin
        wait for T;
        
        for i in 0 to num_tests - 1 loop
            input <= test_vector_array(i).control;
            wait for T;
        end loop;
        
        wait for T;
        
        assert false
            report "Testbench Concluded"
            severity failure;
    end process;

end tb;
