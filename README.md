# RGB-Sort-O-Matic

## 📌 Project Overview
RGB-Sort-O-Matic is a Verilog-based color detection and sorting system designed for hardware automation using FPGA. This project was developed as part of the Hardware Design and Lab course at National Tsing Hua University (NTHU), under the guidance of Prof. Chun-Yi Lee. The system detects red, green, and blue objects using a color sensor and sorts them using a conveyor belt controlled by DC motors.

## 🚀 Project Motivation
We developed this project to explore FPGA-based control for color detection and motor control. Unlike many existing projects that rely on Arduino, we aimed to implement the color sensor directly using Verilog on an FPGA (Basys3). Our goal was to create a fully FPGA-based system, including motor control without external microcontrollers.

## ⚡ System Architecture
* **Color Sensor Module:** Detects colors (red, green, blue) using the TCS3200 color sensor, processed on the FPGA. The sensor’s frequency output is used to determine the dominant color.
* **Conveyor Belt System:** Driven by two DC motors controlled through PWM, allowing precise speed control.
* **Seat Belt Mechanism:** Ensures the objects remain steady for accurate color detection.
* **User Preferences:** Switches (SW0, SW1, SW2) allow users to set preferred colors for sorting.

## 🌐 How It Works
* Objects move toward the color sensor on the conveyor belt.
* The color sensor detects the color of the object.
* User preferences determine which colors are considered "desirable."
* The system activates LEDs to indicate whether the detected color is desirable.
* The conveyor belt directs the object to the appropriate location based on the color.

## 📊 Experimental Results
* The system accurately detected colors with minor sensitivity to environmental lighting.
* The DC motors operated smoothly, maintaining a consistent belt speed.
* The FPGA utilized efficient resource management, running both the color sensor and motor control modules.

## 📌 Lessons Learned
* The color sensor is highly sensitive to surrounding light, requiring careful calibration.
* Motor control using PWM was challenging but provided precise control.
* We gained a deeper understanding of FPGA pin configuration, especially for motor and sensor control.

## 🚀 Future Improvements
* Replace the color sensor with a more precise model for improved accuracy.
* Use a larger conveyor belt for smoother object handling.
* Implement an advanced calibration method to adapt to different lighting conditions.

## 📄 License
This project is licensed under the MIT License.

## 📝 How to Use
1. Clone this repository:  
   ```bash
   git clone https://github.com/your-username/RGB-Sort-O-Matic.git
