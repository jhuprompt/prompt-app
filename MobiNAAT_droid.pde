/*
 *
 *    Sketch Permissions Needed:
 *            Bluetooth, Internet, Read_external_storage, Write_external_storage
 *            
 */


String title = "PROMPT Test";

import android.content.Intent;
import android.app.Activity;
import android.os.Environment; // for finding directories
import android.os.Vibrator;
import android.os.VibrationEffect;
import android.view.KeyEvent; // for handling backspaces
import android.view.WindowManager;
import android.net.Uri;
import android.os.ParcelFileDescriptor;
import java.util.Arrays;
import java.util.Calendar;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;


Activity act;  // assigned in Bluetooth setup
Context mc;

Vibrator v;

void setup()
{
    orientation(PORTRAIT);    
    size(displayWidth, displayHeight);
    smooth(2); // anti-alisased edges
    setStyle();

    background(backgroundColor);
    //mySerial = new Serial( this, Serial.list()[0], 115200);

    act = this.getActivity();

    // Keep screen on while app is running
    act.runOnUiThread(new Runnable()
    {
        public void run() {
            act.getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        }
    }
    );

    v = (Vibrator) act.getSystemService(Context.VIBRATOR_SERVICE);
    setupButtons();
    setupBT();
    setupFileDir();
    setupTextbox();
    setMethodType(displayDevice);
    setupPlotDisplay();

    /*FileWriter writer = openFile("test",true); // true means append to already existing file
     writeFile(writer, "test");
     */
}

void draw() {
    background(backgroundColor);

    update();
    display();
}

void update() {
    for (Button b : defaultButtons) {
        b.update();
    }
    if (displayedButtons != null) {
        for (Button b : displayedButtons) {
            b.update();
        }
    }
}

void buzz() {
    if ( android.os.Build.VERSION.SDK_INT >= 26) {
        v.vibrate(VibrationEffect.createOneShot(10, 50));
    } else {
        v.vibrate(10);
    }
}

void mousePressed() {

    if (alert_flag) {
        alert_flag = false;
        return;
    }
    for (Button b : defaultButtons) {
        if (b.over()) {
            buzz();
            b.pressed();    // switches state setting
            curr_cmd = b.func;
            cmd(curr_cmd);    // re-call initial cmd for input
            break;
        }
    }
    if (displayMode == DISP_INPUT) {
        input_field.PRESSED();
        for (Button b : inputButtons) {
            //buttonBuffer = buttonList[i]; 
            if (b.over()) {
                b.pressed();    // switches state setting
                buzz();
                curr_cmd = b.func;
                cmd(curr_cmd);
                hideKeyboard();
                break;
            }
        }
    } else if (displayedButtons  != null) {
        for (Button b : displayedButtons) {
            if (b.over()) {
                b.pressed();    // switches state setting
                buzz();
                curr_cmd = b.func;
                if (curr_cmd == Cmd.INPUT_STR || curr_cmd == Cmd.INPUT_FLOAT || curr_cmd == Cmd.INPUT_INT) inputButton = b;
                cmd(curr_cmd);    
                break;
            }
        }
    }
}

void keyPressed() {
    if (displayMode == -1) {
        //showKeyboard();
        if (keyCode == KeyEvent.KEYCODE_DEL) {  // need to handle backspaces differently on android
            input_field.KEYPRESSED(key, (int)BACKSPACE);
        } else {
            input_field.KEYPRESSED(key, keyCode);
            println(key);
        }
    }
    if (alert_flag) {
        if (key == 10) {  // PRESSED ENTER
            alert_flag = false;
        }
    }
}

void reset(int device) {
    startButton.text = "NOT CONNECTED";
    startButton.basecolor = buttonOffColor;


    //setupBT();
    //setupPlotDisplay();
    //setupFileDir();

    if (running[device]) {
        stop_routine(device);
    }

    fluoConnected[device] = false;
    mobinaatReady[device] = false;
    ardSent[device] = false;

    analyzed[device] = false;

    if (sendReceiveBTs.get(device)!=null) sendReceiveBTs.get(device).write("<reset>");

    /*
  if (fileOpened) {
     fileOpened=false;
     closeFiles();
     }
     */
}

/*The startActivityForResult() within setup() launches an 
 Activity which is used to request the user to turn Bluetooth on. 
 The following onActivityResult() method is called when this 
 Activity exits. */

//TRY THIS https://forum.processing.org/two/discussion/20843/how-to-do-a-file-chooser-for-android-mode

static int BLUETOOTH_REQUEST_CODE = 0;
static int READ_REQUEST_CODE = 1;  // for Opening files for data analysis

@Override public void onActivityResult(int requestCode, int resultCode, Intent data) {
    println("Activity result - requestCode = " + requestCode);

    if (requestCode==BLUETOOTH_REQUEST_CODE) {
        if (resultCode == Activity.RESULT_OK) {
            ToastMaster("Bluetooth has been switched ON");
            println("Bluetooth has been switched ON");
        } else {
            //ToastMaster("You need to turn Bluetooth ON !!!");
            //println("You need to turn Bluetooth ON !!!");
        }
    }
}
