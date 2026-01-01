library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_exp_approx.all;

entity ExpApprox_Pipeline is
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        start  : in  std_logic;
        x_in   : in  data_t;      -- Q3.12
        done   : out std_logic;
        result : out data_t       -- exp(x) in Q3.12
    );
end entity;

architecture structural of ExpApprox_Pipeline is
    signal en : std_logic;

    component datapath_pipeline
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            en       : in  std_logic;
            x_in     : in  data_t;
            result   : out data_t
        );
    end component;

    component control_unit_pipeline
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            start    : in  std_logic;
            done     : out std_logic;
            en       : out std_logic
        );
    end component;

begin
    dp: datapath_pipeline
        port map (
            clk    => clk,
            rst    => rst,
            en     => en,
            x_in   => x_in,
            result => result
        );

    cu: control_unit_pipeline
        port map (
            clk    => clk,
            rst    => rst,
            start  => start,
            done   => done,
            en     => en
        );
end architecture structural;
