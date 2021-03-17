boolean[] fluoConnected = new boolean[2];
boolean[] fluoInit = new boolean[2];
boolean[] detecting = new boolean[MAX_DEVICES];

String[] test_detect_vals = new String[MAX_DEVICES];

int method_type = 5; // Stores method type setting for fluorescence detection
String detect_mode;
String[] detect_methods = new String[]{"", "E1D1", "E1D2", "E2D2", "E1D1+E1D2", " E1D1+E2D2", "E1D2+E2D2", "E1D1 + E1D2 + E2D2", "S_E1D1", "S_E1D2", "S_E2D2"};


/*
 1 = E1D1
 2 = E1D2
 3 = E2D2
 4 = E1D1+E1D2
 5 = E1D1+E2D2
 6 = E1D2+E2D2
 7 = E1D1 + E1D2 + E2D2
 8 = S_E1D1 // default
 9 = S_E1D2
 10 = S_E2D2
 */
int led1_current = 96;
int led1_on_delay = 100;
int led1_off_delay = 100;

int led2_current = 128;
int led2_on_delay = 100;
int led2_off_delay = 100;

String fluoChan1 = "FAM";
String fluoChan2 = "Cy5";

String detect_val = "-1";
boolean detect_flag = false; // true if fluo_test button has been pressed

String msg;              // holds command for parsing into modbus (e.g. "write,method_type,8")
int cmds[] = new int[2];
String modbus_str;       // holds modbus str to send to arduino
int addr;                // holds address of register for reading/writing on fluosens
int data;                // holds data for writing to fluosens
String args[];
String strbuff;          // temporary buffer for building modbus string

void setupFluosens(int device) {
  println("Initializing fluosens.");
  
  modbus("write,cycles,1", device);     // initialize to one cycle per measurement
  modbus("write,led1_current,"+ led1_current, device);
  modbus("write,led2_current,"+ led2_current, device);
  modbus("write,method_type," + method_type, device);
  modbus("write,led1_on_delay," + led1_on_delay, device);
  modbus("write,led2_on_delay," + led2_on_delay, device);
  modbus("write,led1_off_delay," + led1_off_delay, device);
  modbus("write,led2_off_delay," + led2_off_delay, device);

  fluoInit[device] = true;
}

void setMethodType(int device) {
 
  if (LED1.state) {
    if (LED2.state) { // both emissions on
      method_type = 5;        // E1D1 + E2D2
      detect_mode = "Duplex Assay";
    } else {
      method_type = 8; // S_E1D1
      detect_mode = "Monoplex - " + fluoChan1;
    }
  } else if (LED2.state) { // only LED 2 on
    method_type = 10; // S_E2D2
    detect_mode = "Monoplex - " + fluoChan2;
  } 
  if(connectedDevices.size() <1 || device > connectedDevices.size()) return;
  modbus_str = modbus("write,method_type,"+method_type, device);
 
}

//called in modbus(String msg) to send modbus code to arduino
void modbusSend(String modbus_str, int device) {
  if (fluoConnected[device]) {
    ardSend(modbus_str,device);
  } else println("fluosens not connected - didn't send: " + modbus_str);
}

// Input:   String cmd called in serialCmds
// Output:  Modbus string to send to arduino (e.g. :000600000001f9 setting single measurement)
String modbus(String msg, int device) {
  modbus_str = ":000TXXXXXXXXCC"; // placeholder for modbus string -- \n\r put onto string by arduino
  char[] modbus_char = modbus_str.toCharArray();
  if (msg.substring(0, 4).equals("read")) {
    modbus_char[4] = '3';

    args = new String[1];  // populated in parse_cmd
    parse_cmd(msg, 1, 5);  // 1 argument = addr, start_idx = first char after comma
    try {
      addr = parseInt(args[0]);
      if ((addr >= 260 && addr <= 383) || (addr >= 512 && addr <= 3513)) {
        cmds[0] = addr;
        cmds[1] = 2; // number of registers for each data point
      } else if (addr >= 400 && addr <= 511) {
        cmds[0] = addr;
        cmds[1] = 1; // number of registers for each data point
      } else {
        return "";
      }
    } 
    catch (NumberFormatException e) {
      // try parsing message as string
      cmd_register(args[0]);  // parses String and populates cmds[] (e.g. "method_type")]
      if (cmds[0] == -1) return "";
    }

    strbuff = decToHex(cmds[0], 4);
    for (int i = 0; i <= 3; i++) {
      modbus_char[i + 5] = strbuff.charAt(i);
    }
    strbuff = decToHex(cmds[1], 4);
    for (int i = 0; i <= 3; i++) {
      modbus_char[i + 9] = strbuff.charAt(i);
    }
    String LRC = lrc_calc(modbus_char);
    modbus_char[13] = LRC.charAt(0);
    modbus_char[14] = LRC.charAt(1);
  } else if (msg.substring(0, 5).equals("write")) {

    //println("Making write command");

    modbus_char[4] = '6';
    args = new String[2];
    parse_cmd(msg, 2, 6);

    //println("Parsing addr:" + args[0]);
    addr = parseInt(args[0]);            
    if (addr >= 400 && addr <= 511) {
      cmds[0] = addr;
      cmds[1] = 1;
    } else {
      //println("Checking cmd register");
      // try parsing message as string
      cmd_register(args[0]);  // parses String and populates cmds[] (e.g. "method_type")]
    }

    try {
      data = parseInt(args[1]);
    }
    catch(NumberFormatException e) {
      println("Error: non-number data in modbus(String msg)");
      return "";
    }
    strbuff = decToHex(cmds[0], 4);
    for (int i = 0; i < 4; i++) {
      modbus_char[i + 5] = strbuff.charAt(i);
    }

    // exception for 1-byte writes into register: pad with trailing zeros
    // write data as HEX with number of digits specified by the command (as determined by cmd_register)
    if ((cmds[0] >= 2 && cmds[0] <= 6) || (cmds[0] >= 24 && cmds[0] <= 31) || (cmds[0] >= 164 && cmds[0] <= 165)) {
      strbuff = decToHex(data, 2);
      for (int i = 0; i < 2; i++) {
        modbus_char[i + 9] = strbuff.charAt(i);
      }
      modbus_char[11] = '0';
      modbus_char[12] = '0';
    } else {
      strbuff = decToHex(data, 4);
      for (int i = 0; i < 4; i++) {
        modbus_char[i + 9] = strbuff.charAt(i);
      }
    }
    String LRC = lrc_calc(modbus_char);
    modbus_char[13] = LRC.charAt(0);
    modbus_char[14] = LRC.charAt(1);
  } else return "";

  modbus_str = String.valueOf(modbus_char); // convert back to String
  modbusSend(modbus_str, device);
  return modbus_str;
}

// Takes String cmd which includes all letters after "write" or "read"
void parse_cmd(String msg, int num_cmds, int start_idx) {
  String arg = "";
  char c;
  int k = 0;
  for (int i = start_idx; i < msg.length(); i++) {
    c = msg.charAt(i);
    // if lowercase alphabet/underscore or number, add to argument
    if ((int(c) <= 122 && int(c) >= 95) || (int(c) <= 57 && int(c) >= 48)) {
      arg += c;
    }
    if (c == ')' || c == ',' || c == ';' || i == msg.length() - 1) {
      args[k] = arg; // add argument to array
      k++;
      arg = "";
    }
    if (k==num_cmds) break;
  }
}

// Calculates and appends LRC to modbus command
String lrc_calc(char message[]) {
  byte myLRC;
  long redundancy = 0;

  for (int i = 1; i < 13; i = i + 2) {
    strbuff = String.valueOf(message[i]);
    strbuff += message[i + 1];
    //Serial.print("Hex:\t");
    //Serial.println(strbuff);
    redundancy += hexToDec(strbuff);
    //Serial.print("Redundancy:\t");
    //Serial.println(redundancy);
  }

  // convert numerical sum into 2-digit HEX code
  myLRC = byte(redundancy); // cast into byte (truncate carryover bits)
  int myLRC_unsigned = myLRC & (0xff); // in Java byte is signed between -128 128 --> bitwise AND to remove sign

  strbuff = decToHex(256 - myLRC_unsigned, 2); // calculate two's complement, convert to 2-digit HEX and add to message

  return strbuff;
}


// Decimal to hex converter (converts decimal values into hex of specified digit size (defualt: 4))
String decToHex(int value, int write_size) {
  String strValue = Integer.toHexString(value);
  int zeros = write_size - strValue.length();
  for (int i = 0; i < zeros; i++) {
    strValue = "0" + strValue;
  }
  return strValue;
}

// Hex to decimal converter
long hexToDec(String hexString) {
  //println("HexString: " + hexString);
  long decValue = 0;
  int nextInt;

  for (int i = 0; i < hexString.length(); i++) {
    nextInt = int(hexString.charAt(i));
    if (nextInt >= 48 && nextInt <= 57) nextInt = nextInt - 48;
    // Convert A-F to 10-15
    if (nextInt >= 65 && nextInt <= 70) nextInt = nextInt - 55;
    if (nextInt >= 97 && nextInt <= 102) nextInt = nextInt - 87;
    nextInt = constrain(nextInt, 0, 15);
    decValue = (decValue * 16) + nextInt;
  }
  //println("decValue: " + decValue);
  return decValue;
}

// Hex to string converter (converts every two digits of HEX into one ASCII character)
String hexToStr(String hexString) {

  String strValue = "";
  long nextInt;

  for (int i = 0; i < hexString.length(); i = i + 2) {
    nextInt = hexToDec(hexString.substring(i, i + 2));
    strValue += nextInt;
  }
  return strValue;
}

// Command register locator: handles most commands except datapoint read access and NVRam read/write
// command[0] = register address, command[1] = number of registers
void cmd_register(String cmd) {
  // Device config settings
  if (cmd.equals("cycles")) {
    cmds[0] = 0;
    cmds[1] = 1;
    return;
  }
  if (cmd.equals("cycletime")) {
    cmds[0] = 1;
    cmds[1] = 1;
    return;
  }
  if (cmd.equals("start_mode")) {
    cmds[0] = 2;
    cmds[1] = 1;
    return;
  }
  if (cmd.equals("method_type")) {
    cmds[0] = 3;
    cmds[1] = 1;
    return;
  }
  if (cmd.equals("dark_signal_type")) {
    cmds[0] = 4;
    cmds[1] = 1;
    return;
  }
  if (cmd.equals("average")) {
    cmds[0] = 5;
    cmds[1] = 1;
    return;
  }
  if (cmd.equals("led_mode")) {
    cmds[0] = 6;
    cmds[1] = 1;
    return;
  }
  if (cmd.equals("trig_delay")) {
    cmds[0] = 7;
    cmds[1] = 1;
    return;
  }
  /*
    // LED/detector parameters
   if (cmd.equals("e1d1_factor")) {
   cmds[0] = 8;
   cmds[1] = 2;
   return;
   }
   if (cmd.equals("e1d2_factor")) {
   cmds[0] = 10;
   cmds[1] = 2;
   return;
   }
   if (cmd.equals("e2d2_factor")) {
   cmds[0] = 12;
   cmds[1] = 2;
   return;
   }
   if (cmd.equals("e1d1_offset")) {
   cmds[0] = 14;
   cmds[1] = 2;
   return;
   }
   if (cmd.equals("e1d2_offset")) {
   cmds[0] = 16;
   cmds[1] = 2;
   return;
   }
   if (cmd.equals("e2d2_offset")) {
   cmds[0] = 18;
   cmds[1] = 2;
   return;
   }
   */
  if (cmd.equals("led1_on_delay")) {
    cmds[0] = 20;
    cmds[1] = 1;
    return;
  }
  if (cmd.equals("led2_on_delay")) {
    cmds[0] = 21;
    cmds[1] = 1;
    return;
  }
  if (cmd.equals("led1_off_delay")) {
    cmds[0] = 22;
    cmds[1] = 1;
    return;
  }
  if (cmd.equals("led2_off_delay")) {
    cmds[0] = 23;
    cmds[1] = 1;
    return;
  }
  if (cmd.equals("led1_current")) {
    cmds[0] = 24;
    cmds[1] = 1;
    return;
  }
  if (cmd.equals("led2_current")) {
    cmds[0] = 25;
    cmds[1] = 1;
    return;
  }
  if (cmd.equals("led1_default")) {
    cmds[0] = 26;
    cmds[1] = 1;
    return;
  }
  if (cmd.equals("led2_default")) {
    cmds[0] = 27;
    cmds[1] = 1;
    return;
  }
  if (cmd.equals("led1_current_max")) {
    cmds[0] = 28;
    cmds[1] = 1;
    return;
  }
  if (cmd.equals("led2_current_max")) {
    cmds[0] = 29;
    cmds[1] = 1;
    return;
  }
  if (cmd.equals("led1_current_min")) {
    cmds[0] = 30;
    cmds[1] = 1;
    return;
  }
  if (cmd.equals("led2_current_min")) {
    cmds[0] = 31;
    cmds[1] = 1;
    return;
  }
  /*
    if (cmd.equals("adc_sampling")) {
   cmds[0] = 32;
   cmds[1] = 1;
   return;
   }
   
   // Hardware information
   if (cmd.equals("board_name")) {
   cmds[0] = 128;
   cmds[1] = 16;
   return;
   }
   if (cmd.equals("board_serial")) {
   cmds[0] = 144;
   cmds[1] = 4;
   return;
   }
   if (cmd.equals("board_id")) {
   cmds[0] = 148;
   cmds[1] = 8;
   return;
   }
   if (cmd.equals("hw_revision")) {
   cmds[0] = 156;
   cmds[1] = 4;
   return;
   }
   if (cmd.equals("optic_revision")) {
   cmds[0] = 160;
   cmds[1] = 4;
   return;
   }
   if (cmd.equals("board_type")) {
   cmds[0] = 164;
   cmds[1] = 1;
   return;
   }
   
   // Communication settings
   if (cmd.equals("modbus_addr")) {
   cmds[0] = 165;
   cmds[1] = 1;
   return;
   }
   if (cmd.equals("baudrate")) {
   cmds[0] = 166;
   cmds[1] = 2;
   return;
   }
   
   // on-off values
   if (cmd.equals("ticket")) {
   cmds[0] = 256;
   cmds[1] = 2;
   return;
   }
   */
  if (cmd.equals("temp")) {
    cmds[0] = 258;
    cmds[1] = 2;
    return;
  }
  if (cmd.equals("onval1")) {
    cmds[0] = 260;
    cmds[1] = 2;
    return;
  }
  if (cmd.equals("onval2")) {
    cmds[0] = 262;
    cmds[1] = 2;
    return;
  }
  if (cmd.equals("onval3")) {
    cmds[0] = 264;
    cmds[1] = 2;
    return;
  }
  if (cmd.equals("offval1")) {
    cmds[0] = 266;
    cmds[1] = 2;
    return;
  }
  if (cmd.equals("offval2")) {
    cmds[0] = 268;
    cmds[1] = 2;
    return;
  }
  if (cmd.equals("offval3")) {
    cmds[0] = 270;
    cmds[1] = 2;
    return;
  }

  // Software version
  if (cmd.equals("software_ver")) {
    cmds[0] = 384;
    cmds[1] = 16;
    return;
  }

  // Trigger commands
  if (cmd.equals("start_method")) {
    cmds[0] = 512;
    cmds[1] = 1;
    return;
  }
  if (cmd.equals("stop_method")) {
    cmds[0] = 513;
    cmds[1] = 1;
    return;
  }
  if (cmd.equals("led1_onoff")) {
    cmds[0] = 514;
    cmds[1] = 1;
    return;
  }
  if (cmd.equals("led2_onoff")) {
    cmds[0] = 515;
    cmds[1] = 1;
    return;
  }
  /*
    if (cmd.equals("start_autozero")) {
   cmds[0] = 516;
   cmds[1] = 1;
   return;
   }
   if (cmd.equals("save_parameters")) {
   cmds[0] = 517;
   cmds[1] = 1;
   return;
   }
   if (cmd.equals("save_parameters_nvram")) {
   cmds[0] = 518;
   cmds[1] = 1;
   return;
   }
   if (cmd.equals("setup_adc")) {
   cmds[0] = 518;
   cmds[1] = 1;
   return;
   }
   */
  // Not recognized
  println("Cannot recognize command.");
  cmds[0] = -1;
}
