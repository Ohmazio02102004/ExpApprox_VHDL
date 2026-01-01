library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;  -- ?? dùng exp()

entity tb_exp_approx_pipeline is
end entity;

architecture sim of tb_exp_approx_pipeline is

    constant CLK_PERIOD : time := 10 ns;
    constant DATA_WIDTH : integer := 16;
    subtype data_t is signed(DATA_WIDTH-1 downto 0);

    -- Q3.12 format => scale = 2**12 = 4096.0
    constant SCALE : real := 4096.0;

    signal clk    : std_logic := '0';
    signal rst    : std_logic := '1';
    signal start  : std_logic := '0';
    signal x_in   : data_t;
    signal done   : std_logic;
    signal result : data_t;

    -- Hàm chuy?n fixed-point Q3.12 ? real
    function to_real_fixed(d : data_t) return real is
    begin
        return real(to_integer(d)) / SCALE;
    end function;

    -- Hàm chuy?n real ? fixed-point Q3.12 (có saturation)
    function to_fixed_real(r : real) return data_t is
        variable scaled : real;
        variable int_val : integer;
    begin
        scaled := r * SCALE;
        int_val := integer(round(scaled));

        if int_val > 32767 then
            return to_signed(32767, DATA_WIDTH);
        elsif int_val < -32768 then
            return to_signed(-32768, DATA_WIDTH);
        else
            return to_signed(int_val, DATA_WIDTH);
        end if;
    end function;

begin

    -- DUT instantiation
    dut: entity work.ExpApprox_Pipeline
        port map (
            clk    => clk,
            rst    => rst,
            start  => start,
            x_in   => x_in,
            done   => done,
            result => result
        );

    -- Clock generation
    clk <= not clk after CLK_PERIOD/2;

    -- Stimulus process
    stim_proc: process
        type test_vector_t is record
            x_real : real;
            desc   : string(1 to 20);  -- ?? dài c? ??nh 20
        end record;

        type test_array is array (natural range <>) of test_vector_t;
        constant test_vectors : test_array := (
            (0.0,       "x = 0.0             "),
            (0.693147,  "x = ln(2) ? 0.693   "),
            (1.0,       "x = 1.0             "),
            (0.5,       "x = 0.5             "),
            (-0.5,      "x = -0.5            "),
            (0.1,       "x = 0.1             "),
            (-1.0,      "x = -1.0            "),
            (1.1,       "x = 1.1 (near limit)"),
            (0.0,       "x = 0.0 (repeat)    ")
        );

        variable expected_real : real;
        variable result_real   : real;
        variable abs_error     : real;
        variable max_error     : real := 0.0;
    begin
        report "=== Bat dau mo phong ExpApprox Pipeline ===" severity note;

        -- Reset
        rst <= '1';
        wait for 4 * CLK_PERIOD;
        rst <= '0';
        wait for CLK_PERIOD;

        for i in test_vectors'range loop
            x_in  <= to_fixed_real(test_vectors(i).x_real);
            start <= '1';
            wait for CLK_PERIOD;
            start <= '0';

            -- ??i done (latency = 17 cycles)
            wait until done = '1' for 50 * CLK_PERIOD;

            if done = '1' then
                result_real   := to_real_fixed(result);
                expected_real := exp(test_vectors(i).x_real);
                abs_error     := abs(result_real - expected_real);

                if abs_error > max_error then
                    max_error := abs_error;
                end if;

                -- In k?t qu? (tách riêng ?? tránh l?i severity)
                report "Test: " & test_vectors(i).desc severity note;
                report "  x_in (real)     = " & real'image(test_vectors(i).x_real) severity note;
                report "  exp(x) expected = " & real'image(expected_real) severity note;
                report "  HW result       = " & real'image(result_real) severity note;
                report "  Absolute error  = " & real'image(abs_error) severity note;

                if abs_error > 0.01 then
                    report ">>> SAI SO QUA LON!" severity warning;
                end if;

            else
                report "TIMEOUT: Done khong duoc assert!" severity error;
            end if;

            wait for 10 * CLK_PERIOD;  -- Ngh? gi?a các test
        end loop;

        report "=== Ket thuc mo phong ===" severity note;
        report "Sai so lon nhat: " & real'image(max_error) severity note;

        if max_error <= 0.01 then
            report "TEST PASS: Tat ca ket qua trong nguong sai so cho phep!" severity note;
        else
            report "TEST FAIL: Co sai so vuot qua nguong!" severity warning;
        end if;

        wait for 100 ns;
        report "Simulation finished successfully" severity failure;  -- D?ng simulation
    end process;

end architecture sim;
