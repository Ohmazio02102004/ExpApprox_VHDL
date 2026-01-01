library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_exp_approx.all;

entity datapath_pipeline is
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        en       : in  std_logic;  -- Enable flow t? control
        
        x_in     : in  data_t;
        
        result   : out data_t      -- exp(x) = X_final + Y_final
    );
end entity;

architecture rtl of datapath_pipeline is
    type xyz_array is array (0 to NUM_STAGES) of data_t;  -- 0: input, NUM_STAGES: output
    signal X : xyz_array;
    signal Y : xyz_array;
    signal Z : xyz_array;

    component cordic_stage
        generic (
            STAGE_IDX : integer
        );
        port (
            clk    : in  std_logic;
            rst    : in  std_logic;
            en     : in  std_logic;
            X_in   : in  data_t;
            Y_in   : in  data_t;
            Z_in   : in  data_t;
            X_out  : out data_t;
            Y_out  : out data_t;
            Z_out  : out data_t
        );
    end component;
begin
    -- Init stage 0
    X(0) <= K_SCALE;
    Y(0) <= (others => '0');
    Z(0) <= x_in;

    -- Chain các stages
    gen_stages: for i in 0 to NUM_STAGES-1 generate
        stage_inst: cordic_stage
            generic map (
                STAGE_IDX => i
            )
            port map (
                clk   => clk,
                rst   => rst,
                en    => en,
                X_in  => X(i),
                Y_in  => Y(i),
                Z_in  => Z(i),
                X_out => X(i+1),
                Y_out => Y(i+1),
                Z_out => Z(i+1)
            );
    end generate;

    result <= X(NUM_STAGES) + Y(NUM_STAGES);
end architecture rtl;
