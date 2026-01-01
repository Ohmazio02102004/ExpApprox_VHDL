library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_exp_approx.all;

entity cordic_stage is
    generic (
        STAGE_IDX : integer := 0  -- Index c?a stage (0 to NUM_STAGES-1)
    );
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        en     : in  std_logic;   -- Enable ?? flow data
        
        X_in   : in  data_t;
        Y_in   : in  data_t;
        Z_in   : in  data_t;
        
        X_out  : out data_t;
        Y_out  : out data_t;
        Z_out  : out data_t
    );
end entity;

architecture rtl of cordic_stage is
    signal z_sign : std_logic;
begin
    z_sign <= Z_in(DATA_WIDTH-1);  -- '1' n?u Z_in < 0

    process(clk, rst)
        variable shift_amount : integer;
        variable delta_z : data_t;
    begin
        if rst = '1' then
            X_out <= (others => '0');
            Y_out <= (others => '0');
            Z_out <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                shift_amount := SHIFT_AMOUNTS(STAGE_IDX);
                delta_z := LUT_ATANH(STAGE_IDX);
                
                if z_sign = '0' then  -- Z >= 0
                    X_out <= X_in + shift_right(Y_in, shift_amount);
                    Y_out <= Y_in + shift_right(X_in, shift_amount);
                    Z_out <= Z_in - delta_z;
                else                  -- Z < 0
                    X_out <= X_in - shift_right(Y_in, shift_amount);
                    Y_out <= Y_in - shift_right(X_in, shift_amount);
                    Z_out <= Z_in + delta_z;
                end if;
            end if;
        end if;
    end process;
end architecture rtl;

