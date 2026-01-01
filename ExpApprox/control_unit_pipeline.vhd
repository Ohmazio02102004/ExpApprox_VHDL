library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_exp_approx.all;

entity control_unit_pipeline is
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        start    : in  std_logic;
        
        done     : out std_logic;
        en       : out std_logic   -- Enable cho datapath flow
    );
end entity;

architecture rtl of control_unit_pipeline is
    signal shift_reg : std_logic_vector(NUM_STAGES-1 downto 0) := (others => '0');
begin
    process(clk, rst)
    begin
        if rst = '1' then
            shift_reg <= (others => '0');
        elsif rising_edge(clk) then
            shift_reg <= shift_reg(shift_reg'left-1 downto 0) & start;  -- Shift in start signal
        end if;
    end process;

    en   <= '1';  -- Luôn enable (gi? s? continuous flow; n?u c?n stall, thêm logic)
    done <= shift_reg(shift_reg'left);  -- Done sau ?úng NUM_STAGES cycles
end architecture rtl;
