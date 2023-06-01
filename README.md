# ov5640-VGA

12010508 Yuxiao Hua

## System description

### Function

In this project, I am going to design a system to implement the following functions: use OV5640 to read picture from the environment, and display the image captured from the camera in real time. 

### Specification

- resolution: 640x480

- frame rate: 60 fps

- color standard: RGB444

### Development environment

- language: VHDL and verilog

- software: Vivado 2017.4 and 2022.2

- protocol: I2C

### Extension

If time permits, I am planning to attach additional functions to the system. For example, digit and letter recognition.

### Schedule

Since my teammate refused to cooperate, I am responsible for the whole project.

- **week 9**: purchase necessary items for the porject
- **week 10 and 11**: equipe myself with necessary knowledge of OV5640, I2C, VGA and RAM
- **week 12 to 14**: deal with code matters and debug
- **week 15**: final check and extension functions

## Top module 

### Block diagrams

The whole system works following the order below: 

Module **clk_wiz_0** serves as a  clock frequency divider, which provides three outputs: `clk_24m`, `clk_25m` and `clk_50m`. Signal `rst_n` controls the whole system to start or stop, once set to low, module **power_on_delay** outputs a specific signal sequence `pwdn` to module **ov5640_capture** inder to start up OV5640. After completing the after process, the module **I2C_com** start to configure the 250 registers of OV5640. Once finished, the camera start to capture image data with clk `xclk`. The control signal for camera to work properly is `vsync` and `href`, whose woking principle will be talked about later in the report. The camera module converts the analog signal to digital signal of formation RGB444. The `addr` and `d[7:0]` define the data transfering rules. The image data is kept in module **blk_men_gen_0**, which is a type of RAM. With clock signal synchronized, module **ov5640_vga** outputs the RGB data in RAM. We can see the image displayed on the screen in real time.

![image](https://github.com/HuaYuXiao/ov5640-VGA/assets/117464811/efe4dbf8-df4c-4290-8a72-6d64c38d3f1c)

### Global inputs and outputs

```VHDL
entity top is
  Port ( 
//clock signal used for system synchronization    
    sys_clock: in std_logic;
//reset signal used for resetting the system    
    rst_n:in std_logic;
//pixel clock signal from the OV5640 camera module    
  pclk:in std_logic;
//vertical sync signal from the OV5640 camera module  
  vsync:in std_logic;
//Input horizontal sync signal from the OV5640 camera module  
  href:in std_logic;
//data bus carrying the pixel data from the OV5640 camera module  
  d:in std_logic_vector (7 downto 0 );
//signal indicating the completion of camera configuration  
  config_finished:out std_logic;
//signal used for the I2C SIOC (Serial Clock) line of the OV5640 camera module  
  sioc:out std_logic;
//signal used for the I2C SIOD (Serial Data) line of the OV5640 camera module  
  siod:inout std_logic;
//signal used for resetting the OV5640 camera module  
  reset:out std_logic;
//signal used for controlling the power-down mode of the OV5640 camera module  
  pwdn:out std_logic;
//pixel clock signal provided to the OV5640 camera module  
  xclk:out std_logic;
//horizontal sync signal for VGA display  
  vga_hsync:out std_logic;
//vertical sync signal for VGA display
  vga_vsync:out std_logic;
//signal carrying the red color component for VGA display  
  vga_r:out std_logic_vector ( 3 downto 0);
//signal carrying the green color component for VGA display  
  vga_g:out std_logic_vector( 3 downto 0);
//signal carrying the blue color component for VGA display
  vga_b:out std_logic_vector( 3 downto 0)
  );
end top;
```

## Pmods devices and other modules

### OV5640

**cost**: 168 yuan

The OV5640 is a high-performance 1/4-inch CMOS image sensor designed and manufactured by OmniVision Technologies. It is an image sensor widely used in digital cameras, smartphones and embedded systems.

![th](https://github.com/HuaYuXiao/ov5640-VGA/assets/117464811/3363c16f-faf1-4a56-ac5d-2564dfc40d14)

The following is the port definition of the module **ov5640_capture**:

```VHDL
entity ov5640_capture is
    port (
//Pixel Clock is the input signal used to drive the camera's image acquisition and data transmission.
        pclk  : in   std_logic;
//The camera vertical sync signal (Vertical Sync) is an input signal used to indicate the camera's vertical sync moment, that is, the frame start and end of the image.        
        vsync : in   std_logic；
Camera line synchronization signal (Horizontal Reference), is an input signal used to indicate the camera's line synchronization moment, that is, the line start and end of the image.        
        href  : in   std_logic;
The camera data bus (Data Bus) is an input signal used to transmit the pixel data collected by the camera.        
        d     : in   std_logic_vector ( 7 downto 0);
Output signal, which is an 18-bit signal that transmits the address of the data read from the camera.        
        addr  : out  std_logic_vector (17 downto 0);
Output signal, which is a 12-bit signal that transmits pixel data read from the camera.        
        dout  : out  std_logic_vector (11 downto 0);
Output signal, indicating Write Enable, which indicates data reading operations on the camera.        
        we    : out  std_logic
    );
end ov5640_capture;
```

The figure below shows the structure of OV5640. 

![image](https://github.com/HuaYuXiao/ov5640-VGA/assets/117464811/79b3e73b-d511-4826-b136-1aa64954958d)

Combining the above structure diagram, the working principle of the module is as follows:

- **Array of Light Sensitive Elements**: The OV5640 contains an array of light sensitive elements, typically manufactured using CMOS (Complementary Metal Oxide Semiconductor) technology. Each pixel in the array corresponds to a point in the image and is able to perceive the intensity of the light.

- **Pixel reading and amplification**: When the camera receives a pixel clock (PCLK) signal, each pixel is read line by line. During reading, pixel values are amplified by amplification circuitry to enhance signal quality and image detail.

- **Line sync and frame sync signals**: The OV5640 uses line sync signals (href) and frame sync signals (vsync) to synchronize lines and frames of an image. The row-sync signal represents the beginning and end of a row of pixel data, while the frame-sync signal represents the beginning and end of a framed image.

![image](https://github.com/HuaYuXiao/ov5640-VGA/assets/117464811/3e540f20-227d-4e37-8f3c-ebb8c2863f97)

- **Data transfer**: Readout pixel data is transmitted via the data bus (d) to an external device such as an FPGA, processor, or memory. Each pixel is typically represented by multiple bits, for example, each pixel in an RGB color image is typically represented by three components: red, green, and blue.

- **Control interface**: The OV5640 also provides a control interface that allows external devices to configure and control various parameters of the camera, such as image resolution, exposure time, white balance, etc., via I2C or other communication protocols.






### VGA screen

**cost**: 168 yuan

VGA (Video Graphics Array) is a video transmission standard for displaying images, and its principles involve data transmission, synchronization signals and display control. The screen I adopt is an LCD screen, with maximum resolution 1024x600.

The following is the port definition of the module **VGA**:

```VHDL
entity ov5640_vga is
    port ( 
//clock signal with a frequency of 25 MHz. It synchronizes the data transmission between the device and the VGA display    
        clk25       : in  STD_LOGIC;
//4-bit vector representing the red color component of the VGA signal. It determines the intensity of red in each pixel displayed on the screen        
        vga_red     : out STD_LOGIC_VECTOR(3 downto 0);
//4-bit vector representing the green color component of the VGA signal. It determines the intensity of green in each pixel displayed on the screen        
        vga_green   : out STD_LOGIC_VECTOR(3 downto 0);
//-bit vector representing the blue color component of the VGA signal. It determines the intensity of blue in each pixel displayed on the screen        
        vga_blue    : out STD_LOGIC_VECTOR(3 downto 0);
//synchronization signal for the horizontal synchronization of the VGA display. It indicates the beginning of each horizontal line on the screen        
        vga_hsync   : out STD_LOGIC;
//synchronization signal for the vertical synchronization of the VGA display. It indicates the beginning of each vertical frame on the screen        
        vga_vsync   : out STD_LOGIC;
//18-bit vector representing the address of the current frame being displayed on the VGA screen 
        frame_addr  : out STD_LOGIC_VECTOR(17 downto 0);
//12-bit vector representing the pixel data for the current frame. It contains information about the color of each pixel in the frame        
        frame_pixel : in  STD_LOGIC_VECTOR(11 downto 0)
    );
end ov5640_vga;
```

The figure below shows the structure of VGA connection. Here the color standard is RGB444.

![image](https://github.com/HuaYuXiao/ov5640-VGA/assets/117464811/2b385db8-f4ae-4e8a-a41f-136c64313749)

- **Data transmission mode**: VGA adopts analog signal transmission, RGB color signal transmission through 15 pins and synchronization signal transmission through 2 pins.

  - The red,green and blue signal (4 bits) is transmitted through the red, green and blue pin respectively

  - The hsync and vsync signal identify the beginning and end of each line and frame respectively

- **Data transmission process**: Taking 640x480@60 as an example, the transmission process of each row of pixels is as follows:

  - When the horizontal sync signal is high, it indicates the start of a line. The data of the red, green and blue color signals is sent and displayed on the screen.

  - When the horizontal sync signal is low, it indicates the end of a line. The screen goes to the display of the next line.

- **V-sync signal**: V-sync signals are used to identify the beginning and end of a frame. In a full cycle of the v-sync signal, the transmission process of multiple lines of pixels is included.

  - When the vSync signal is high, it indicates the beginning of a frame. The screen displays the first row of pixels starting from the upper-left corner.

  - When the vertical sync signal is low, it indicates the end of a frame. The screen finishes displaying one frame and is ready to start the next.

### Frequency divider

The **frequency divider** is generated by IP core, with input 100 MHz and output 24 MHz, 25 MHz(for **camera** and **VGA**) and 50 MHz(for **RAM**).

![QQ截图20230601130320](https://github.com/HuaYuXiao/ov5640-VGA/assets/117464811/1de71493-c314-45b0-a673-ee9b93c47f14)

The following is the port definition of the module frequency divider:

```VHDL
component clk_wiz_0 is
    port (
    clk_out1: out std_logic;
    clk_out2: out std_logic;
    clk_out3: out std_logic;
    clk_in1    :in std_logic;
    reset   :in std_logic
  );
  end component;
```

### RAM

The **RAM** module is also generated by IP core, with same width and depth for input and output port.

![QQ截图20230601131138](https://github.com/HuaYuXiao/ov5640-VGA/assets/117464811/bc32c736-e83c-4d80-b8d6-299b4fd95aea)

The following is the port definition of the module **blk_men_gen_0**:

```VHDL
  component blk_mem_gen_0 IS
    PORT (
-- Clock input for Port A
    clka : IN STD_LOGIC;
-- Write enable input for Port A    
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
-- Address input for Port A    
    addra : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
-- Data input for Port A    
    dina : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
-- Clock input for Port B    
    clkb : IN STD_LOGIC;
-- Address input for Port B    
    addrb : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
-- Data output for Port B    
    doutb : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
    );
    end component;
```

### I2C

I2C is a simple, reliable serial communication protocol suitable for connecting integrated circuit chips for communication between chips, widely used in a variety of electronic devices and systems. I2C communication uses a master-slave structure, where one device acts as the master and the other device acts as the slave.(see figure below) The master is responsible for initiating the communication and controlling the entire communication process. During communication, I2C uses two wires for data transmission: the clock line (SCL) and the data line (SDA). The SCL is a clock signal generated by the master to synchronize data transmission. SDAs are bidirectional lines that transmit actual data.

![image](https://github.com/HuaYuXiao/ov5640-VGA/assets/117464811/c77cdd5e-084b-4bfe-9e66-f0f249d1d60f)

The following is the port definition of the module **I2C**:

```VHDL
entity i2c_com is
    port (
-- Input clock for I2C module    
        clock_i2c   : in  std_logic;
-- Camera reset signal        
        camera_rstn : in  std_logic;
-- I2C acknowledge signal        
        ack         : out std_logic;
-- Input data for I2C module        
        i2c_data    : in  std_logic_vector(31 downto 0);
-- Start signal for I2C communication        
        start       : in  std_logic;
-- I2C transaction end signal        
        tr_end      : out std_logic;
-- I2C serial clock signal        
        i2c_sclk    : out std_logic;
-- I2C serial data signal        
        i2c_sdat    : inout std_logic
    );
end entity i2c_com;
```

In this project, **I2C** serves as a transmition method to configure registers of **OV5640**. Once `rst` is set low, the I2C driver start to write data into the 250 registers of ov5640.

## Results

The system is able to display in real time, but the image experiences some kind of distortion, and it is manifested in the following aspects specifically:

- Unexpected three extra ghosting

- Mismatch resoltion, and this may results from the above one

- Loss of half of data, which means some white strip appear on the screen

![IMG_1865](https://github.com/HuaYuXiao/ov5640-VGA/assets/117464811/c53c402d-ecd1-4aaf-bf87-f534f43d8fd5)

### Analyses and limitations

Possible reasons are as follows:

- **The clock frequency does not match**: The clock frequency used by the video input and output modules should be the same to maintain correct sampling and transmission of data.

- **Buffer overflow or underflow**: If the data transfer rate does not match between the video input and output modules, it can cause buffer overflow or undercurrent problems.

- **Clock phase skew**: The clock phase of the video input and output modules should be consistent to ensure that the correct data is sampled and transmitted on the clock edges.

- **Data latency mismatch**: The data path delay between the video input and output modules should be equal to keep the data synchronized and aligned.

- **The control signal is incorrect**: The control signals between the video input and output modules should properly coordinate the transmission of data.

### Future impvoments

Here is another version of my project. Unfortunately, it is left unfinished.

![QQ截图20230531233838](https://github.com/HuaYuXiao/ov5640-VGA/assets/117464811/648079d7-2ee6-4e2b-bb81-baadae280d49)

It applies **ddr2** rather than **BRAM** to solve problem of insufficient memory space. The read and write rate will be improved too.

![C9505B5F9FF879EE0D7889E6D0E77AA2](https://github.com/HuaYuXiao/ov5640-VGA/assets/117464811/b66fd99d-066c-4f94-941a-370bfc354850)

Moreover, the **i2c** module is modified to be a state machine. Unexpected problems resulted from improper time series will be solved. The figure below reflects the working ASM chart of the I2C driver.

![DD67F10A00031DB0E31B53B3194CE3C5](https://github.com/HuaYuXiao/ov5640-VGA/assets/117464811/5f2074a9-d81f-4661-96c3-c55e4fcf9698)

## Conclusion

In this project, I am scheduled to design a system where image from environment is captured from OV5640 camera, with obtained data processed on FPGA, RGB444 image displayed on an LCD screen via VGA. I learn much knowledge of state machine, I2C, VGA. Sadly, I fail to perfectly cooperate with my teammate, which is the main reason that I fail to complete the whole project. I will try my best to finish the project in the coming summer holiday. Sorry and thanks to all who provide support for me!
