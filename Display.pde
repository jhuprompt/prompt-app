public ArrayList<Button> displayedButtons; // points to list of buttons currently displayed on screen
public ArrayList<Button> last_displayedButtons;

public final int DISP_INPUT = -1;
public final int DISP_HOME = 0;
public final int DISP_OPTIONS = 1;
public final int DISP_CONNECT = 2;

/*public final int DISP_INCOPT = 1;
 public final int DISP_CYCLEOPT = 2;
 public final int DISP_MELTOPT = 3;
 */


int displayMode = 0;    // Default display mode homescreen
int displayDevice = -1;
int last_displayMode = 0;
boolean alert_flag = false;
int alertID = 0;
String alertComment = "";

boolean archive_plot = false;

void display() {    
    // Display Text
    fill(txtColor);
    textFont(titleFont);
    textAlign(CENTER, CENTER);
    text(title, width/2, height/30);

    textAlign(LEFT, CENTER);
    textFont(smallFont);
    if (displayDevice >=0) {
        text("Log: \t" +readMessages.get(displayDevice), width/10, height - textAscent() * 1.1);
    }

    displayDefault();

    if (alert_flag) {
        displayAlert(alertID);
    } else {

        if (displayedButtons!=null) {
            for (Button b : displayedButtons) {
                if (!extendSwitch.state && (b == extendTempB || b == extendTimeB)) {
                } else {
                    b.display();
                }
            }
        }

        switch(displayMode) {
        case -1: 

            /*
             *  Text Input from User
             */

            displayInputField();
            if (input_flag) {
                displayMode = last_displayMode; 
                displayedButtons = last_displayedButtons;
                cmd(input_cmd);
            }
            break;

        case DISP_HOME:  

            displayHome();
            fill(color(50));
            rectMode(CENTER);
            //noStroke();
            rect(width*3/5+width/30, height/2+height/4, width*2/3, height/5);  // background for Status texts 
            fill(color(255));
            textFont(statusFont);
            textAlign(LEFT, CENTER);
            text("STATUS: ", width*3/5+width/30-width/3, height/2+height/5);

            if (displayDevice >=0) {

                if (running[displayDevice]) {  // live updates 
                    textAlign(LEFT, CENTER);

                    if (Ct2[displayDevice] >0) {
                        fill(color(200, 0, 0));
                        text(fluoChan2 +" Detected (" + Ct2[displayDevice] +")", width*2/5+width/10, height/2+height/5);
                    } else {
                        fill(color(200));
                        text(fluoChan2+ " - In Progress", width*2/5+width/10, height/2+height/5);
                    }
                    if (Ct1[displayDevice] >0) {
                        fill(color(200, 0, 0));
                        text(fluoChan1 + " Detected (" + Ct1[displayDevice] +")", width*2/5+width/10, height/2+height/5+height/20);
                    } else {
                        fill(color(200));
                        text(fluoChan1 + " - In Progress", width*2/5+width/10, height/2+height/5+height/20);
                    }
                } else if (fluo_plots.get(displayDevice).n_pts + 1 > 20) { // analysis of completed run
                    textAlign(LEFT, CENTER);

                    if (Ct2[displayDevice] >0) {
                        fill(color(200, 0, 0));
                        text(fluoChan2 + " Detected (" + Ct2[displayDevice] +")", width*2/5+width/10, height/2+height/5);
                    } else {
                        fill(color(200));
                        text(fluoChan2 + " - No Detection", width*2/5+width/10, height/2+height/5);
                    }
                    if (Ct1[displayDevice] >0) {
                        fill(color(200, 0, 0));
                        text(fluoChan1 + " Detected (" + Ct1[displayDevice] +")", width*2/5+width/10, height/2+height/5+height/20);
                    } else {
                        fill(color(200));
                        text(fluoChan1 + " - No Detection", width*2/5+width/10, height/2+height/5+height/20);
                    }
                } else {
                    fill(color(200));
                    textAlign(RIGHT, CENTER);
                    text("UNKNOWN", width*8/10, height/2+height/5);
                }
            } else if (filenameButton.value_str != "") {
                //if (!analyzed[displayDevice] && !fileOpened[displayDevice]) {
                //archive_Ct(filePaths.get(displayDevice).getAbsolutePath() + ".txt", displayDevice);
                if (!archive_analyzed) archive_Ct(filenameButton.value_str, -1);

                else {
                    textAlign(LEFT, CENTER);

                    if (archive_Ct2 >0) {
                        fill(color(200, 0, 0));
                        text(fluoChan2 + " Detected (" + archive_Ct2  +")", width*2/5+width/10, height/2+height/5);
                    } else {
                        fill(color(200));
                        text(fluoChan2 + " - No Detection", width*2/5+width/10, height/2+height/5);
                    }
                    if (archive_Ct1 >0) {
                        fill(color(200, 0, 0));
                        text(fluoChan1 + " Detected (" + archive_Ct1 +")", width*2/5+width/10, height/2+height/5+height/20);
                    } else {
                        fill(color(200));
                        text(fluoChan1 + " - No Detection", width*2/5+width/10, height/2+height/5+height/20);
                    }
                }

                //analyzed[displayDevice]=true;
            } else {            // no run selected
                fill(color(200));
                textAlign(RIGHT, CENTER);
                text("UNKNOWN", width*8/10, height/2+height/5);
            }
            break;

        case DISP_OPTIONS:  
            displayOptions();
            break;


        case DISP_CONNECT:

            displayConnect();
            break;

        default:
            break;
        }
    }
}

void displayDefault() {

    // Display Buttons
    for (Button b : defaultButtons) {
        //buttonBuffer = buttonList[i]; 
        b.display();
    }
}

void displayHome() {

    for (Button b : homeButtons) {
        //buttonBuffer = buttonList[i]; 
        b.display();
    }

    fill(txtColor);
    textFont(statusFont);
    textAlign(CENTER, CENTER);
    text("Connected\nDevices:", width/6, height*6/10);

    if (deviceButtons.size() ==0) {
        textFont(buttonFont1);
        text("NONE", width/6, height*7/10);
    } else if (deviceButtons != null) {
        for (Button b : deviceButtons) {
            b.display();
        }
    }

    if (displayDevice >=0) {
        //temp_plots.get(displayDevice).display();
        if (running[displayDevice]) { // Replaced temperature plot with text display for time and temp          
            textFont(statusFont);
            textAlign(LEFT, CENTER);           
            if (mode.get(displayDevice).equals("I") || mode.get(displayDevice).equals("C") || mode.get(displayDevice).equals("M")) {
                text("Time Elapsed: " + String.format("%.02f", time_pt[displayDevice]/60) + " min.", width*3/5+width/30-width/5, height*1/7);
                if (temp_pt[displayDevice] >0) text("Block Temp.: " + temp_pt[displayDevice] + "C", width*3/5+width/30-width/5, height*1/7+height/20);
                if (mode.get(displayDevice).equals("C")) {
                    text("Current Cycle: " + (fluo_plots.get(displayDevice).n_pts+1), width*3/5+width/30-width/5, height*1/7+height*2/20);
                }
            } else {
                text("Processing Sample...", width*3/5+width/30-width/5, height*1/7);
            }
            if (temp_pt[displayDevice] >0) text("Block Temp.: " + temp_pt[displayDevice] + "C", width*3/5+width/30-width/5, height*1/7+height/20);
        }
        fluo_plots.get(displayDevice).display();
        if (runmodes_init.get(displayDevice).contains("M")) {
            melt_plots.get(displayDevice).display();
        }
    } else if (archive_plot) {
        archive_fluo_plot.display();
        textAlign(LEFT, CENTER);

        if (archive_Ct2 >0) {
            fill(color(200, 0, 0));
            text(fluoChan2 + " Detected (" + archive_Ct2 +")", width*2/5+width/10, height/2+height/5);
        } else {
            fill(color(200));
            text(fluoChan2 + " - No Detection", width*2/5+width/10, height/2+height/5);
        }
        if (archive_Ct1 >0) {
            fill(color(200, 0, 0));
            text(fluoChan1 + " Detected(" + archive_Ct1 +")", width*2/5+width/10, height/2+height/5+height/20);
        } else {
            fill(color(200));
            text(fluoChan1 + " - In Progress", width*2/5+width/10, height/2+height/5+height/20);
        }
    } else {
        fill(txtColor);
        textFont(titleFont);
        textAlign(CENTER, CENTER);
        text("Please Connect the Instrument", width*3/5+width/30, height*1/4);
    }
}

void displayOptions() {
    fill(txtColor);
    textFont(titleFont);
    textAlign(CENTER, CENTER);
    text("Detection Mode:\n" + detect_mode, width*3/4, height*6/7);

    // Display fluo read output after clicking "TEST"
    if (displayDevice>=0 && test_detect_vals[displayDevice] != null) {
        textAlign(CENTER, TOP);
        text(test_detect_vals[displayDevice], width/2, height*8/9-height/48);
    }

    textAlign(CENTER, CENTER);    
    textFont(smallFont);
    text("3-STEP", width/2, height*3/8 - height/16);
}

void displayConnect() {
    if (BToptButtons != null) {
        //println("Displaying BT options");
        for (Button b : BToptButtons) {
            //buttonBuffer = buttonList[i]; 
            b.display();
        }
    } else {
        fill(txtColor);
        textFont(titleFont);
        textAlign(CENTER, CENTER);
        text("Please pair Bluetooth with MobiNAAT", width/2, height/2);
    }
}

/*****************************************
 * Receive text input                    *
 *****************************************/
void displayInputField() {
    input_field.DRAW();    // draw input textfield

    displayedButtons = inputButtons;

    fill(txtColor);
    textFont(titleFont);
    textAlign(LEFT, CENTER);
    text(input_ID, width/7, height*1/6);

    fill(txtColor);
    textFont(titleFont);
    textAlign(LEFT, CENTER);
    text("Current setting:\t" + input_val, width/7, height/4);
    /*
  fill(txtColor);
     textFont(titleFont);
     textAlign(RIGHT, CENTER);
     text(input_val, width*3/4, height/4);
     */

    /*
  for (Button b : inputButtons) {
     //buttonBuffer = buttonList[i]; 
     b.display();
     }
     */
}

/*****************************************
 * ALERTS -- layered over other displays *
 *****************************************/
void displayAlert(int _alertID) {
    displayAlert(_alertID, alertComment);
}
void displayAlert(int _alertID, String comment) {
    //println("Displaying alert: "+ alertID);
    String alert = alerts[_alertID];
    int n_chars = alert.length();
    int lines = 1;
    for (int i =0; i< n_chars; i++) {
        if (alert.charAt(i) == '\n') lines++;
    }
    fill(txtColor);
    textFont(alertFont);
    //int fs = 600/(n_chars/lines);
    if (n_chars/lines > 30) textSize(28);
    textAlign(CENTER, CENTER);
    text(alert + '\n' + comment, width/2, height/3);
    //println(fs);

    fill(txtColor);
    textSize(18);
    textAlign(CENTER, CENTER);
    text("\n\n\nTap Screen to Continue", width/2, height/2);
}

void setAlert(int _alertID) {
    setAlert(_alertID, "");
}

void setAlert(int _alertID, String comment) {
    println("Alert " + _alertID + " set");
    alertID = _alertID;
    alert_flag = true;
    alertComment = comment;
}


String[] alerts = new String[]{
/*0*/    "Bluetooth cannot connect to:", 
/*1*/    "MobiNAAT not Connected", 
/*2*/    "Filename already exists. Opened new file:", 
/*3*/    "Please select a filename.", 
/*4*/    "FluoSens Detector not found.", 
/*5*/    "File not found: ", 
/*6*/    "Invalid Email Address", 
/*7*/    "Failed to export data", 
/*8*/    "Data successfully exported!", 
/*9*/    "Already connected to maximum device #: " + MAX_DEVICES
};
