library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pkg_exp_approx is
    constant DATA_WIDTH : integer := 16;
    subtype data_t is signed(DATA_WIDTH-1 downto 0);

    constant NUM_STAGES : integer := 17;  -- 15 basic + 2 repeats (at 4 and 13)

    type lut_type is array (0 to NUM_STAGES-1) of data_t;
    constant LUT_ATANH : lut_type := (
        to_signed(2250, DATA_WIDTH),  -- stage 0: i=1
        to_signed(1046, DATA_WIDTH),  -- stage 1: i=2
        to_signed(515,  DATA_WIDTH),  -- stage 2: i=3
        to_signed(256,  DATA_WIDTH),  -- stage 3: i=4a
        to_signed(256,  DATA_WIDTH),  -- stage 4: i=4b (repeat)
        to_signed(128,  DATA_WIDTH),  -- stage 5: i=5
        to_signed(64,   DATA_WIDTH),  -- stage 6: i=6
        to_signed(32,   DATA_WIDTH),  -- stage 7: i=7
        to_signed(16,   DATA_WIDTH),  -- stage 8: i=8
        to_signed(8,    DATA_WIDTH),  -- stage 9: i=9
        to_signed(4,    DATA_WIDTH),  -- stage 10: i=10
        to_signed(2,    DATA_WIDTH),  -- stage 11: i=11
        to_signed(1,    DATA_WIDTH),  -- stage 12: i=12
        to_signed(1,    DATA_WIDTH),  -- stage 13: i=13a
        to_signed(1,    DATA_WIDTH),  -- stage 14: i=13b (repeat)
        to_signed(0,    DATA_WIDTH),  -- stage 15: i=14
        to_signed(0,    DATA_WIDTH)   -- stage 16: i=15
    );

    type shift_type is array (0 to NUM_STAGES-1) of integer;
    constant SHIFT_AMOUNTS : shift_type := (
        1, 2, 3, 4, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 13, 14, 15
    );

    constant K_SCALE : data_t := to_signed(4936, DATA_WIDTH);  -- Scaling factor

    -- Ghi chú: Stages ???c index t? 0 ??n 16, v?i repeats duplicate LUT và shift.
end package pkg_exp_approx;
