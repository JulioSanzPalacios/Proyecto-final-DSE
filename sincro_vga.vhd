library WORK;
use WORK.VGA_PKG.ALL;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;


entity sincro_vga is
  Port ( 
    clk: in STD_LOGIC;
    rst: in STD_LOGIC;
    columna: out unsigned (9 downto 0);
    fila: out unsigned (9 downto 0);
    visible: out STD_LOGIC;
    hsinc: out STD_LOGIC;
    vsinc: out STD_LOGIC);
end sincro_vga;

architecture Behavioral of sincro_vga is

-- COMPONENTE CONTADOR
component conta_generic 
  generic (
    fin_conta: natural := 10**6;                 -- frecuencia inicial es 100MHz y queremos la f de 1 decima de segundo, la nueva frecuencia ser� de 10*10e6 
    n_bits: natural := 24;                       
    max: unsigned:="1001");
  Port ( 
    clk : in STD_LOGIC;
    rst : in STD_LOGIC;
    enable : in std_logic;                       -- se�al del contador anterior
    up_down: in std_logic;                       --SW OFF = ASCENDENTE, SW ON= DESCENDENTE
    sconta : out STD_LOGIC;                      --emitir� una se�al/pulso cada periodo
    vconta : out unsigned (n_bits-1 downto 0));  -- Ser� de 4 bits porque las cuentas ser�n de 0 a 9 como maximo
end component;

--SE�ALES INTERMEDIAS--
    signal conta_4clk: unsigned (1 downto 0);
    signal new1pxl: std_logic;                   -- acaba la cuenta del primer contador
    signal fincuenta_conta4clk: natural:=4;      -- fin cuenta cuando llega a 4
    
    signal conta_800pxl: unsigned(9 downto 0);   -- cuenta 800 pixeles que son = a 1 linea (columnas)
    signal new1line: std_logic;                  -- cuenta 1 linea, acaba la cuenta del segundo contador
    signal new1line_1: std_logic;                
     
    signal conta_520line: unsigned(9 downto 0);  -- cuenta 520 linea (filas)  = 1 pantalla
    signal visiblepxl: std_logic;                -- indica si esta el pixl en zona visible (linea)
    
    signal s_vsinc: std_logic; 
    signal visibleline: std_logic; 
       
begin

--Contadores

P_conta1pixel: conta_generic
generic map (
    fin_conta=>4,
    n_bits=>2,
    max=>"11")
Port map (
    clk=>clk,
    rst=>rst,
    enable=>'1',
    up_down=>'0',
    sconta=>new1pxl,
    vconta=>conta_4clk);

        
P_conta1linea: conta_generic
generic map (
    fin_conta=>c_pxl_total,
    n_bits=>c_nb_pxls,
    max=>"0000001001")
Port map (
    clk=>clk,
    rst=>rst,
    enable=>new1pxl,
    up_down=>'0',
    sconta=>new1line,
    vconta=>conta_800pxl);
        
new1line_1<=new1line and new1pxl;

     
P_conta1pantalla: conta_generic
generic map (
    fin_conta=>c_line_total,
    n_bits=>c_nb_lines, 
    max=>"0000001001")
Port map (
    clk=>clk,
    rst=>rst,
    enable=>new1line_1,
    up_down=>'0',
    sconta=>s_vsinc,
    vconta=>conta_520line);
    






--Sincronismos

hsinc<='0' when (conta_800pxl>=c_pxl_2_fporch and conta_800pxl< c_pxl_2_synch) else '1';
vsinc<='0' when (conta_520line>=c_line_2_fporch and conta_520line<c_line_2_synch) else '1';


--Zona visible

visiblepxl<='1' when conta_800pxl<c_pxl_visible else '0';
visibleline<='1' when conta_520line<c_line_visible else '0';


--Salida

columna<=conta_800pxl;
fila<=conta_520line;

visible<=visiblepxl and visibleline;

end Behavioral;