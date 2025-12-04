# Verilog Digital Clock with Alarm & Password Protection

A feature-rich digital clock implementation in Verilog designed for the **Digilent Basys3 FPGA board**. This project includes real-time clock functionality, configurable alarms with password protection, UART time synchronization, and an intuitive 7-segment display interface.

## Features

- **24-Hour Digital Clock** - Displays hours and minutes on a 4-digit 7-segment display
- **UART Time Synchronization** - Sync time from PC via serial connection (115200 baud)
- **Configurable Alarm** - Set alarm time using on-board buttons
- **Password Protection** - 16-bit password to dismiss alarms (configured via switches)
- **Visual Feedback** - LED indicators for system status
- **Global Reset** - Hold center button for 3 seconds to reset the system

## Hardware Requirements

- **Digilent Basys3 FPGA Board** (Artix-7 XC7A35T)
- USB cable for programming and UART communication
- (Optional) Python environment for time synchronization

## Pin Mapping

The project uses the standard Basys3 constraints file with the following peripherals:

| Peripheral | Usage |
|------------|-------|
| 7-Segment Display | Time/Alarm display (HH:MM format) |
| 16 Switches (sw[15:0]) | Password input |
| 16 LEDs (led[15:0]) | Status indicators |
| 5 Push Buttons | Navigation and control |
| UART RX (RsRx) | Time synchronization from PC |

## Button Functions

| Button | Function |
|--------|----------|
| **BTNC** (Center) | Enter/Exit alarm set mode; Hold 3s for global reset |
| **BTNU** (Up) | Increment value / Check password / Stop alarm |
| **BTND** (Down) | Decrement value / Clear password |
| **BTNL** (Left) | Move cursor left (in alarm set mode) |
| **BTNR** (Right) | Move cursor right (in alarm set mode) |

## LED Indicators

| LED | Status |
|-----|--------|
| LED[15] | Password is set |
| LED[14] | Alarm is set |
| LED[13] | Alarm is enabled (requires both password and alarm to be set) |
| LED[11] | Password set mode active |
| LED[10] | Alarm set mode active |
| LED[3] | Alarm is currently active (ringing) |
| LED[2] | Password mismatch |
| LED[1] | Password match |
| LED[0] | Password set OK |

## Display Messages

The 7-segment display shows contextual messages:

- **Normal Mode**: Current time (HH:MM)
- **Alarm Set Mode**: Alarm time with blinking cursor
- **PASS**: Password input prompt
- **OK**: Password accepted
- **Err**: Password error
- **tMO**: Timeout occurred

## Usage

### Setting the Time (UART Sync)

1. Connect the Basys3 to your PC via USB
2. Run the Python synchronization script:

```python
python pyserial.py
```

> **Note**: Edit `pyserial.py` to set the correct COM port for your system.

The script sends the current time in `HHMMSS` format every second.

### Setting a Password

1. Use switches (sw[15:0]) to configure your 16-bit password
2. Press **BTNU** to set the password
3. LED[15] will light up confirming the password is stored

### Setting an Alarm

1. Press **BTNC** to enter alarm set mode (LED[10] lights up)
2. Use **BTNL/BTNR** to move the cursor between digits
3. Use **BTNU/BTND** to increment/decrement the selected digit
4. Press **BTNC** again to confirm and save the alarm
5. LED[14] will light up confirming the alarm is set

> **Note**: The alarm will only be enabled (LED[13]) when both password AND alarm are set.

### Stopping an Active Alarm

1. When the alarm triggers (LED[3] lights up), enter your password on the switches
2. Press **BTNU** to verify the password and stop the alarm
3. If the password matches, the alarm will be dismissed

### Clearing the Password

- Press **BTND** when not in alarm set mode and alarm is not active

### Global Reset

- Hold **BTNC** for 3 seconds to perform a complete system reset

## Project Structure

```
Verilog-Clock/
├── main.v                    # Top-level module
├── Basys3_Master.xdc         # Constraints file for Basys3
├── pyserial.py               # Python script for UART time sync
│
├── Clock Core
│   ├── counter.v             # 24-hour counter module
│   ├── counter_utils.v       # Counter utility modules (0-59, 0-23)
│   ├── divider.v             # 1Hz clock divider
│   └── divider_scan.v        # Display scan clock divider
│
├── Display
│   ├── seven_segs_driver.v   # 7-segment display controller
│   └── seven_segs_decoder.v  # BCD to 7-segment decoder
│
├── Alarm System
│   ├── alarm_manager.v       # Alarm setter and trigger modules
│   └── alarm_mode_controller.v # Alarm mode state machine
│
├── Password System
│   ├── password_manager.v    # Password set/check/clear modules
│   ├── password_helper.v     # Password LED status helper
│   └── password_mode_controller.v # Password mode state machine
│
├── UART
│   ├── uart_rx.v             # UART receiver (115200 baud)
│   └── time_loader.v         # Parses UART data into time values
│
├── Utilities
│   ├── button_helper.v       # Button debouncer
│   ├── leds_helper.v         # LED control helpers
│   └── reset_controller.v    # Global reset controller
```

## Module Descriptions

### `main.v`
Top-level module that instantiates and connects all sub-modules.

### `counter_24hr`
Cascaded counters for seconds (0-59), minutes (0-59), and hours (0-23) with loadable values.

### `uart_rx`
Standard UART receiver configured for 100MHz clock and 115200 baud rate.

### `time_loader`
Parses incoming UART ASCII characters (HHMMSS format) and generates load signals for the counter.

### `alarm_setter`
Manages alarm time configuration with cursor-based digit editing.

### `alarm_trigger`
Compares current time with alarm time and manages alarm activation/deactivation.

### `password_setter` / `password_checker` / `password_clearer`
Manages 16-bit password storage, verification, and clearing.

### `sevenseg_display_driver`
Multiplexed 7-segment display driver with support for time display, alarm setting mode with blinking cursor, and text messages.

## Building the Project

1. Open **Xilinx Vivado**
2. Create a new RTL project
3. Add all `.v` source files
4. Add `Basys3_Master.xdc` as constraints
5. Set `main` as the top module
6. Run Synthesis, Implementation, and Generate Bitstream
7. Program the Basys3 board

## Configuration

### Clock Frequency
The design assumes a 100MHz input clock (standard for Basys3).

### UART Settings
- Baud Rate: 115200
- Data Bits: 8
- Stop Bits: 1
- Parity: None

### Timeout Values
- Alarm set mode timeout: Configurable via `alarm_mode_controller`
- Password set mode timeout: 10 seconds (configurable)
- Message display duration: 2 seconds

## License

This project is provided as-is for educational purposes.

## Acknowledgments

- Digilent for the Basys3 board and constraints file
- Xilinx for Vivado Design Suite