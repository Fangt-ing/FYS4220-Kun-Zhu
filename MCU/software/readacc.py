import threading
import serial #pyserial: https://pyserial.readthedocs.io/en/latest/
import queue
import time
import numpy as np

# Modify RESOLUTION, RANGE and COM port according to your setting.
RESOLUTION = "FULL" # 10BIT
RANGE = 2 # 4/8/16
COM_PORT = "COM6"


HEADER_ID = 0xe2
RESOLUTION_TABLE = {"FULL":{2:2/2**9,4:4/2**10,8:8/2**11,16:16/2**12},
              "10BIT":{2:2/2**9,4:4/2**9,8:8/2**9,16:16/2**9}}

# Create a command queue for key
cmd_queue = queue.Queue(10)

# Keyboard thread to detect input commands and put them in the command queue
def keyboard(run_app):
    while run_app():
        cmd = input("\r\n> ")
        cmd_queue.put(cmd)
        time.sleep(0.5)


# Keep program running as long as True. Terminate by writing "quit" in terminal window
run_app = True 

# Thread for reading serial data
def serial_data(run_app):
    # Open serial port
    ser = serial.Serial(COM_PORT, 115200,timeout = 1)

    # Initialize a data packet array with zero data bytes    
    data_packet = bytearray(0)
    # Initalize a data packet window array to shift through the data bytes.
    # This window will be used to find the start of the data packet, and when 
    # a full packet has been received, copy the data packet to the data_packet array.
    packet_window = bytearray(0)

    new_packet = False
    packet_cnt = 0 

    while run_app():

        no_bytes = ser.inWaiting()
        if no_bytes > 0:
            data = ser.read(no_bytes)

            # Loop through received bytes        
            for byte_value in data:    
                # Add received byte to the packet window
                packet_window.append(byte_value)
                # Find index of header id
                start_idx = packet_window.find(HEADER_ID)
                # If correct header ID is found in first position and a total of 9 bytes have been received
                # the packet window may no contain a full valid data packet.            
                if start_idx == 0 and len(packet_window) == 9:
                    # check if last byte is start of next packet. If true, a full correct data packet has been received.
                    if packet_window[8] == HEADER_ID:
                        data_packet = packet_window[2:-1] # Extract the 6 data bytes
                        packet_no = int(packet_window[1]) # Extract the packet counter
                        new_packet = True 
                        packet_cnt = packet_cnt + 1
                if new_packet: # New data packet is available, organize data bytes
                    new_packet = False

                    # The data is received in the following order
                    # x0, x1, y0, y1, z1, z2. This means that the least significatn byte is at the lowest position in the byte array
                    # corresponding to little endian. The data for each axis is 2 bytes or 16 bits which corresponds to a short. 
                    # It is also formated in two-complement format, which means that it is a signed short.
                    
                    # Arrange bytes
                    x_value_raw = (data_packet[1] << 8) +  data_packet[0]
                    y_value_raw = (data_packet[3] << 8) +  data_packet[2]
                    z_value_raw = (data_packet[5] << 8) +  data_packet[4]
                    
                    # Convert to signed 16 bit
                    x_value = np.int16(x_value_raw)
                    y_value = np.int16(y_value_raw)
                    z_value = np.int16(z_value_raw)
                    
                    # Convert to g
                    x_value = x_value * RESOLUTION_TABLE[RESOLUTION][RANGE]
                    y_value = y_value * RESOLUTION_TABLE[RESOLUTION][RANGE]
                    z_value = z_value * RESOLUTION_TABLE[RESOLUTION][RANGE]    
                    
                    # Print value in g
                    print("Packet no: {:3d}, (x: {:+1.3f}), (y: {:+1.3f}), (z: {:+1.3f})".format(packet_no, x_value, y_value, z_value))
                    # print raw value
                    # print("Packet no: {:3d}, (x:{:4x}), (y:{:4x}), (z:{:4x})".format(packet_no, x_value_raw, y_value_raw, z_value_raw))

                    

                ## remove oldest received byte 
                if len(packet_window) == 9:
                    packet_window.pop(0) 
        time.sleep(0.001) 

    ser.close()

if __name__ == "__main__":
    
    # Create threads
    keyboard_thread = threading.Thread(target=keyboard, args=(lambda: run_app,))
    serial_thread = threading.Thread(target=serial_data, args=(lambda: run_app,))

    # Set threads as deamon -- threads are automatically killed if program is killed
    keyboard_thread.setDaemon(True)
    serial_thread.setDaemon(True)

    # Start threads
    keyboard_thread.start()
    serial_thread.start()

    while run_app:
        while not cmd_queue.empty():
            cmd = cmd_queue.get()
            if "quit" == cmd.lower():
                run_app = False       
        time.sleep(0.1)

