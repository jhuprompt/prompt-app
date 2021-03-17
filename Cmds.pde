import java.util.Arrays;

public enum Cmd {
    NONE, HOME, RESET, OPTIONS, OK, CANCEL, CONNECTION, BT_SELECT, INPUT_STR, INPUT_INT, INPUT_FLOAT, LED1, LED2, START, EXPORT, DEVICE_SELECT, FLUO_READ
}

Cmd curr_cmd = Cmd.NONE;

void cmd(Cmd cmd) {

    /************************
     *  HOME SCREEN BUTTONS *
     ************************/
    switch(cmd) {
    case NONE: 
        return;

    case HOME: 

        displayMode = DISP_HOME;
        displayedButtons = homeButtons;
        for (Button b : deviceButtons) {
            if (!displayedButtons.contains(b)) {
                displayedButtons.add(b);
            }
        }
        println("Homescreen Selected");
        return;

    case RESET:
        if (displayDevice<0) return;
        println("Resetting: " + displayDevice);
        reset(displayDevice);
        return;

    case CONNECTION:
        setupBToptions();
        displayMode = DISP_CONNECT;
        displayedButtons = BToptButtons;
        return;

    case OPTIONS:

        displayMode = DISP_OPTIONS;
        displayedButtons = optionsButtons;
        return;
        /************************
         *  DATA INPUT BUTTONS  *
         ************************/
    case OK: 

        println("Pressed OK");      
        input_flag = true;
        OK = true;
        return;

    case CANCEL: 

        println("Pressed Cancel");            
        input_field.Text = "";
        input_flag = true;
        OK = false;
        return;

    case BT_SELECT:

        for (Button b : BToptButtons) {

            if (b.state && !connectedDevices.contains(b.text)) {  // check if button pressed and device has not been connected yet
                if (connectedDevices.size() >= MAX_DEVICES) {
                    setAlert(9);
                    break;
                }
                try {
                    attemptConnect(pairedDevices, b.text);
                    displayDevice = connectedDevices.size()-1;
                    cmd(Cmd.HOME);
                    break;
                }
                catch(Exception e) {
                    println(e);
                    setAlert(0, b.text);
                    b.state = false;
                }
            }
            if (!b.state && connectedDevices.contains(b.text)) { // check if button turned off and device is connected -- disconnect bluetooth
                int device = connectedDevices.indexOf(b.text);
                handleDisconnect(device);
                cmd(Cmd.HOME);
            }
        }
        break;
    case INPUT_STR:
        if (input_flag) {
            input_flag = false; //reset input flag
            if (input_field.Text.equals("")) return;        // Pressed Cancel or no input
            else {
                //inputButton.value_str = input_field.Text;
                if (inputButton == filenameButton ) {
                    if (displayDevice <0) return;
                    if (check_filename(input_field.Text)) {
                        inputButton.value_str = input_field.Text;

                        writers.set(displayDevice, openFile(input_field.Text, fileDir, false, false));    // false = no append (new file)  , false = no overwrite
                        if (writers.get(displayDevice) == null) {
                            println("Failure to create file.");
                            fileOpened[displayDevice] = false;
                            break;
                        }
                        println("Filename set to: " +  filenameButton.value_str);

                        try {
                            logwriters.get(displayDevice).close();
                            File tempFile = new File(logDir, "log.temp.txt");
                            File logwriterFile = new File(logDir, "log." + filenameButton.value_str);
                            //println("tempFile " + tempFile.toString()+ " exists: " + tempFile.exists());
                            //println("logwriterFile "+ logwriterFile.toString()+ "exists: " + logwriterFile.exists());

                            // Rename file (or directory)
                            tempFile.renameTo(logwriterFile);
                            //logwriter = new FileWriter(logwriterFile, true);
                            logwriters.set(displayDevice, openFile("log." + filenameButton.value_str, logDir, true, true));  // logwriter opened with connection to bluetooth
                            writeFile(logwriters.get(displayDevice), filenameButton.value_str + " - File Created: " + timestamp()+ "\n");

                            filenames.set(displayDevice, filenameButton.value_str);
                        }
                        catch(Exception e) {
                            println("Failure to create log file.");
                        }
                        //logwriter = openFile("log." + input_field.Text, logDir, false);

                        fileOpened[displayDevice] = true;
                        analyzed[displayDevice] = false;
                    } else {
                        println("not a valid filename");
                        cmd(Cmd.INPUT_STR);    // call for data entry if wrong values entered
                    }
                } else if (inputButton == analyzeButton) {  // Analyze fluorescence profile of old run
                    archive_analyzed = false;
                    archive_Ct(input_field.Text + ".txt", -1);
                    archive_plot = true;
                    displayDevice = -1;
                    for (Button b : deviceButtons) {
                        b.state = false;
                    }
                } else if (inputButton == emailB ) {
                    if (!isValidEmailAddress(input_field.Text)) {
                        println("not a valid email");

                        setAlert(6);
                    } else {
                        inputButton.value_str = input_field.Text;
                    }
                    break;
                }
            }
        } else {
            input_field.Text = inputButton.value_str;
            getInput(inputButton);
        }
        break;

    case INPUT_FLOAT:
        if (input_flag) {
            input_flag = false; //reset input flag
            if (input_field.Text.equals("")) return;        // Pressed Cancel or no input
            else {
                inputButton.value_float = parseFloat(input_field.Text);
                if (inputButton.value_float <0) cmd(Cmd.INPUT_FLOAT);    // call for data entry if wrong values entered
            }
        } else {
            getInput(inputButton);
        }
        break;

    case INPUT_INT:
        if (input_flag) {
            input_flag = false; //reset input flag
            if (input_field.Text.equals("")) return;        // Pressed Cancel or no input
            else {
                inputButton.value_int = parseInt(input_field.Text);
                if (inputButton.value_int <0) cmd(Cmd.INPUT_INT);    // call for data entry if wrong values entered
            }
        } else {
            getInput(inputButton);
        }
        break;

    case LED1:

        if (LED1.state) {
        } // allow switching LED on
        else {
            // if turning LED1 off
            LED2.state = true;    // turn on LED2
        }
        setMethodType(displayDevice);
        break;


    case LED2:

        if (LED2.state) {
        } else {
            LED1.state = true;
        }
        setMethodType(displayDevice);

        break;

        /************************
         *  START BUTTON        *
         ************************/

    case START:
        if (displayDevice<0) return;
        if (!mobinaatReady[displayDevice]) {
            setAlert(1);
            break;
        }
        if (!fluoConnected[displayDevice]) {
            setAlert(4);
            break;
        }
        if (!fileOpened[displayDevice]) {
            setAlert(3);
            break;
        }
        if (!running[displayDevice]) {
            setupPlot(displayDevice);
            init_routine(displayDevice); 
            startButton.text = "STOP";
            startButton.basecolor = color(255, 0, 0);
        } else {
            stop_routine(displayDevice);
            startButton.text = "START";
            startButton.basecolor = buttonOnColor;
        }
        break;

    case EXPORT:
        if (displayDevice >=0) {
            exportData(filenames.get(displayDevice), emailB.value_str);
        } else {
            exportData(filenameButton.value_str, emailB.value_str);
        }
        break;

    case DEVICE_SELECT:
        for (Button b : deviceButtons) {
            int device = connectedDevices.indexOf(b.text);

            if (b.state && (displayDevice != device || archive_plot)) {  
                // if switching away from an archived plot -- switch off archive_plot flag
                if (archive_plot) archive_plot = false;

                // Change which data is being plotted
                displayDevice = device;
                filenameButton.value_str = filenames.get(device);


                // turn off all other buttons
                for (Button other_b : deviceButtons) {
                    if (b != other_b) other_b.state =false;
                }
                updateStartButton(displayDevice);               
                break;
            }
        }

        updateStartButton(displayDevice);
        if (displayDevice>=0) deviceButtons.get(displayDevice).state = true; // device selection that's already is on was pressed --> reset it to on to make sure one of the device buttons is on to match the displayDevice number
        break;

    case FLUO_READ:

        if (displayDevice>=0 && mobinaatReady[displayDevice] && !running[displayDevice]) {
            setMethodType(displayDevice);
            detecting[displayDevice] = true;
            delay(500);
            ardSend("detect", displayDevice);
        }
        break;
    }
}

/*
public void handleButton(Button b, int mode) {
 
 if (input_flag) {
 input_flag = false; //reset input flag
 if (input_field.Text.equals("")) return;        // Pressed Cancel or no input
 else {
 if (mode == 0) { // INTEGER INPUT
 int input_int = parseInt(input_field.Text);
 println( "Input text to num: " + input_int);
 if (input_int>0) {
 b.value = input_int;
 } else cmd(b.func);    // call for data entry if wrong values entered
 }
 }
 } else {
 getInput(b);
 }
 }
 */

boolean check_filename(String f) {
    if (f == "" || f == null) return false;

    return (f.indexOf(">") == -1 && f.indexOf("<")  == -1 && f.indexOf("\\") == -1 && f.indexOf("\"") == -1 && f.indexOf("\'") == -1 
        && f.indexOf("|") == -1 && f.indexOf(":") == -1 && f.indexOf("*") == -1);
}

void init_routine(int device) { 
    // Initialize points for parsing data -- see handleSerial func. in Bluetooth tab
    Ct1[device] = 0;
    Ct2[device] = 0;
    time_pt[device]=-1;
    temp_pt[device]=-1;
    fluo1_pt[device]=-1;
    fluo2_pt[device]=-1;

    // send all settings to arduino and run routine
    boolean fluo_flag       = true;
    boolean sample_prep_flag = prepSwitch.state; 

    boolean incubate_flag   = cycleSwitch.state;   // GUI incorporates incubation as hot start before cycling
    int incubate_temp       = incTempB.value_int;
    int incubate_time       = incTimeB.value_int;

    boolean cycle_flag      = cycleSwitch.state;
    boolean extend_flag     = extendSwitch.state;
    int annealTemp          = annealTempB.value_int;
    int extendTemp          = extendTempB.value_int;
    int denatureTemp        = denatureTempB.value_int;
    int annealHold          = annealTimeB.value_int;
    int extendHold          = extendTimeB.value_int;
    int denatureHold        = denatureTimeB.value_int;
    int cyclenum            = cycleNumB.value_int;

    boolean hotstart_flag   = false;

    boolean melt_flag       = meltSwitch.state;
    int tStart              = meltStartB.value_int;
    int tFinish             = meltEndB.value_int;
    int duration            = 2000;  // delay time between PWM increase for melting

    /** Setup Data Logging **/
    fluo_1 = new double[cyclenum];
    fluo_2 = new double[cyclenum];

    /** Setup Mode Tracking  must be done before setupPlot(device)**/
    mode.set(device, "");
    if (incubate_flag) { 
        runmodes_init.get(device).add("I");
        runmodes.get(device).add("I");
    }
    if (cycle_flag) {
        runmodes_init.get(device).add("C");
        runmodes.get(device).add("C");
    }
    if (melt_flag) {    
        runmodes_init.get(device).add("M");  
        runmodes.get(device).add("M");
    }

    /** Setup Plots **/
    setMethodType(device);
    setupPlot(device);
    ardSend("flflag("     + (fluo_flag  ? 1:0)          +")", device);
    ardSend("spflag("       + (sample_prep_flag ? 1:0)    +")", device);

    ardSend("inflag("      + (incubate_flag ? 1:0)       +")", device);
    if (incubate_flag) {
        ardSend("inTemp("      + incubate_temp               +")", device);
        ardSend("inTime("      + incubate_time               +")", device);
    }

    ardSend("cyflag("    + (cycle_flag ? 1:0)       +")", device);
    if (cycle_flag) {
        ardSend("exflag("     + (extend_flag ? 1:0)      +")", device);
        ardSend("hsflag("     + (hotstart_flag ? 1:0)    +")", device);
        ardSend("anTemp("      + annealTemp               +")", device);
        ardSend("exTemp("      + extendTemp               +")", device);
        ardSend("deTemp("      + denatureTemp             +")", device);
        ardSend("anHold("      + annealHold               +")", device);
        ardSend("exHold("      + extendHold               +")", device);
        ardSend("deHold("      + denatureHold             +")", device);
        ardSend("cycleN("       + cyclenum                 +")", device);
    }

    ardSend("mtflag("    + (melt_flag ? 1:0)       +")", device);
    if (melt_flag) {
        ardSend("tStart("       + tStart              +")", device);
        ardSend("tFinish("      + tFinish             +")", device);
        ardSend("dur("          + duration            +")", device);
    }
    /*
    ardSend("init(" + (fluo_flag ? 1:0) + "," +
     (sample_prep_flag ? 1:0)+ "," + (incubate_flag ? 1:0) + "," +incubate_temp+ "," +incubate_time + "," + 
     (cycle_flag ? 1:0)+ "," +(int)annealTemp+","+(int)denatureTemp+","+(int)annealHold+","+(int)denatureHold+ "," +(int)cyclenum+ "," +(hotstart_flag ? 1:0)+ ","+
     (melt_flag ? 1:0)+ "," +(int)tStart+ "," + (int)tFinish+ "," +(int)duration + ")");
     */

    while (ardSendList.get(device).size()>0) {
        if (!ardSent[device]) ardSend(ardSendList.get(device).peek(), device);
    }

    delay(500);
    //ardSend("start");
    SendReceiveBytes sendReceiveBT = sendReceiveBTs.get(device);
    sendReceiveBT.write("<start>");


    running[device] = true;
}

void stop_routine(int device) {
    runmodes_init.get(device).clear();
    runmodes.get(device).clear();
    mode.set(device, "");

    running[device] = false;
    closeFiles(device);
    SendReceiveBytes sendReceiveBT = sendReceiveBTs.get(device);
    sendReceiveBT.write("<stop>");
    setupFileDir();
    //delay(500);
}
