library WORK;
use WORK.VGA_PKG.ALL; 

use WORK.RACETRACK_PKG.ALL;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;


entity circuito_general is
  Port ( 
    clk: in std_logic;
    rst: in std_logic;
    btnu: in std_logic;
    btnd: in std_logic;
    btnr: in std_logic;
    btnl: in std_logic;
    rojo: out std_logic_vector (3 downto 0);  --Colores para la pantalla VGA
    verde: out std_logic_vector (3 downto 0);
    azul: out std_logic_vector (3 downto 0);
    hsinc: out std_logic; --señaes de sincronización para la pantalla VGA
    vsinc: out std_logic);
end circuito_general;

architecture Estructural of circuito_general is

component pinta_barras
  Port ( 
    clk: in std_logic;  
    rst: in std_logic;  
    visible: in std_logic;
    col: in unsigned(10-1 downto 0);
    fila: in unsigned(10-1 downto 0);
    dato_memo_red: in std_logic_vector (15 downto 0);         
    dato_memo_blue: in std_logic_vector (15 downto 0);         
    dato_memo_green: in std_logic_vector (15 downto 0);        
    dato_memo3_red: in std_logic_vector (15 downto 0);         
    dato_memo3_blue: in std_logic_vector (15 downto 0);       
    dato_memo3_green: in std_logic_vector (15 downto 0);       
    dato_memo2_verde: in std_logic_vector (31 downto 0);       
    dato_memo2_azul: in std_logic_vector (31 downto 0);        
    btn_sube: in std_logic;
    btn_baja: in std_logic;
    btn_dcha: in std_logic;
    btn_izq: in std_logic;
    addr_memo_red: out std_logic_vector (9-1 downto 0);        
    addr_memo_blue: out std_logic_vector (9-1 downto 0);       
    addr_memo_green: out std_logic_vector (9-1 downto 0);       
    addr_memo3_red: out std_logic_vector (9-1 downto 0);       
    addr_memo3_blue: out std_logic_vector (9-1 downto 0);      
    addr_memo3_green: out std_logic_vector (9-1 downto 0);     
    addr_memo2_verde: out std_logic_vector (5-1 downto 0);     
    addr_memo2_azul: out std_logic_vector (5-1 downto 0);      
    rojo: out std_logic_vector(c_nb_red-1 downto 0);
    verde: out std_logic_vector(c_nb_green-1 downto 0);
    azul: out std_logic_vector(c_nb_blue-1 downto 0));
end component; 

component sincro_vga
  Port ( 
    clk: in std_logic;  
    rst: in std_logic;
    columna: out unsigned (9 downto 0);
    fila: out unsigned (9 downto 0);
    visible: out std_logic;
    hsinc: out std_logic;
    vsinc: out std_logic);
end component;

component memo_red_16x16 is
  port (
    clk  : in  std_logic;
    addr : in  std_logic_vector(9-1 downto 0);
    dout : out std_logic_vector(16-1 downto 0));
end component;

component memo_blue_16x16 is
  port (
    clk  : in  std_logic;
    addr : in  std_logic_vector(9-1 downto 0);
    dout : out std_logic_vector(16-1 downto 0));
end component;

component memo_green_16x16 is
  port (
    clk  : in  std_logic;
    addr : in  std_logic_vector(9-1 downto 0);
    dout : out std_logic_vector(16-1 downto 0));
end component;

component memo2_red_16x16 is
  port (
    clk  : in  std_logic;
    addr : in  std_logic_vector(9-1 downto 0);
    dout : out std_logic_vector(16-1 downto 0));
end component;

component memo2_blue_16x16 is
  port (
    clk  : in  std_logic; 
    addr : in  std_logic_vector(9-1 downto 0);
    dout : out std_logic_vector(16-1 downto 0));
end component;

component memo2_green_16x16 is
  port (
    clk  : in  std_logic;
    addr : in  std_logic_vector(9-1 downto 0);
    dout : out std_logic_vector(16-1 downto 0));
end component;

component pista_carreras_verde
  port (
    clk: in std_logic;
    addr: in std_logic_vector(5-1 downto 0);
    dout: out std_logic_vector(32-1 downto 0));
end component;

component pista_carreras_azul
  port (
    clk: in std_logic;
    addr: in std_logic_vector(5-1 downto 0);
    dout: out std_logic_vector(32-1 downto 0));
end component;

--SEÑALES INTERMEDIAS--
--sincro --> pinta_barras
    signal sincro_columna: unsigned (9 downto 0);
    signal sincro_fila: unsigned (9 downto 0);
    signal sincro_visible: std_logic;

--Para pintar el coche 1 y coche 2
    signal p_red: std_logic_vector (8 downto 0);
    signal p_blue: std_logic_vector (8 downto 0);
    signal p_green: std_logic_vector (8 downto 0);
    signal p3_red: std_logic_vector (8 downto 0);
    signal p3_blue: std_logic_vector (8 downto 0);
    signal p3_green: std_logic_vector (8 downto 0);
    signal q_red: std_logic_vector (15 downto 0);
    signal q_blue: std_logic_vector (15 downto 0);
    signal q_green: std_logic_vector (15 downto 0);
    signal q3_red: std_logic_vector (15 downto 0);
    signal q3_blue: std_logic_vector (15 downto 0);
    signal q3_green: std_logic_vector (15 downto 0);
--pinta barras --> pista carreras 
    signal p2_verde: std_logic_vector (4 downto 0);
    signal q2_verde: std_logic_vector (31 downto 0);
    signal p2_azul: std_logic_vector (4 downto 0);
    signal q2_azul: std_logic_vector (31 downto 0);
    
begin

--COMPONENTES:

componente_1: sincro_vga
port map (
    rst => rst,
    clk => clk,
    vsinc => vsinc,
    hsinc => hsinc,
    columna => sincro_columna,
    fila => sincro_fila,
    visible => sincro_visible);

componente_2: pinta_barras
port map (
    clk => clk,
    rst => rst,
    visible => sincro_visible,
    fila => sincro_fila,
    col => sincro_columna,
    btn_sube => btnu,
    btn_baja => btnd,
    btn_izq => btnl,
    btn_dcha => btnr,
    rojo => rojo,
    verde => verde,
    azul => azul,
    dato_memo_red => q_red,
    dato_memo_blue => q_blue,
    dato_memo_green => q_green,
    dato_memo3_red => q3_red,
    dato_memo3_blue => q3_blue,
    dato_memo3_green => q3_green,
    addr_memo_red => p_red,
    addr_memo_blue => p_blue,
    addr_memo_green => p_green,
    addr_memo3_red => p3_red,
    addr_memo3_blue => p3_blue,
    addr_memo3_green => p3_green, 
    dato_memo2_verde=> q2_verde,
    dato_memo2_azul =>q2_azul,
    addr_memo2_verde => p2_verde,
    addr_memo2_azul => p2_azul );

componente_3: pista_carreras_verde
Port map (
    clk => clk,
    addr => p2_verde,
    dout => q2_verde);
    
componente_4: pista_carreras_azul
Port map (
    clk => clk,
    addr => p2_azul,
    dout => q2_azul);

componente_5: memo_red_16x16
Port map (
    clk => clk,
    addr => p_red,
    dout => q_red);
    
componente_6: memo_blue_16x16
Port map (
    clk => clk,
    addr => p_blue,
    dout => q_blue);

componente_7: memo_green_16x16
Port map (
    clk => clk,
    addr => p_green,
    dout => q_green);

componente_8: memo2_red_16x16
Port map (
    clk => clk,
    addr => p3_red,
    dout => q3_red);
    
componente_9: memo2_blue_16x16
Port map (
    clk => clk,
    addr => p3_blue,
    dout => q3_blue); 

componente_10: memo2_green_16x16
Port map (
    clk => clk,
    addr => p3_green,
    dout => q3_green);
               
end Estructural;
