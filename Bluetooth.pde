// Adapted from this tutorial https://arduinobasics.blogspot.com/2013/03/bluetooth-android-processing-1.html
/* DiscoverBluetooth: Written by ScottC on 18 March 2013 using 
 Processing version 2.0b8
 Tested on a Samsung Galaxy SII, with Android version 2.3.4
 Android ADK - API 10 SDK platform 
 Modified by Alex Trick on 26 September 2018
 */

import android.Manifest;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.app.Activity;
import android.app.ListActivity;
import android.widget.Toast;
import android.widget.ArrayAdapter;
import android.view.Gravity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;

import android.os.Handler;
import android.os.Message;
import android.util.Log;

import java.io.InputStream;
import java.io.OutputStream;
import java.util.UUID;
import java.util.Set;
import java.util.List;
import java.util.Queue;

final int MAX_DEVICES = 2;

boolean[] ardSent = new boolean[MAX_DEVICES];
ArrayList<String> ardSentStr = new ArrayList<String>();   // holds last sent String for each device

boolean[] mobinaatReady = new boolean[MAX_DEVICES];
boolean[] running = new boolean[MAX_DEVICES];

ArrayList<Queue<String>> runmodes_init = new ArrayList<Queue<String>>(); // populates queue with modes flagged on -- modes signalled with asterisk - String = "", "I", "C", "M" for no mode/sample prep, incubation, cycling, melt
ArrayList<Queue<String>> runmodes = new ArrayList<Queue<String>>();      // initialized same as runmodes_init -- each element of list is removed after the modes complete
ArrayList<String> mode = new ArrayList<String>();                        // current mode device is running

ArrayList<Queue<String>> ardSendList = new ArrayList<Queue<String>>();    // holds queue for messages to be sent to arduino for each bluetooth connection

String BTConnectStr = "Not Connected";

BluetoothAdapter bluetooth = BluetoothAdapter.getDefaultAdapter();
BroadcastReceiver receiver = new myOwnBroadcastReceiver();
Set<BluetoothDevice> pairedDevices;  // devices bonded to device through bluetooth 

boolean[] BTConnected = new boolean[MAX_DEVICES];                                             // set max of 2 devices connected for now -- default values = false
ArrayList<ConnectToBluetooth> connectBTs = new ArrayList<ConnectToBluetooth>();
ArrayList<BluetoothSocket> scSockets = new ArrayList<BluetoothSocket>();
ArrayList<SendReceiveBytes> sendReceiveBTs = new ArrayList<SendReceiveBytes>();
ArrayList<String> connectedDevices = new ArrayList<String>();                      // devices currently communicating through bluetooth
ArrayList<deviceHandler> mHandlers = new ArrayList<deviceHandler>();

// Message types used by the Handler
public static final int MESSAGE_WRITE = 1;
public static final int MESSAGE_READ = 2;

ArrayList<String> readMessages= new ArrayList<String>() ;

void setupBT() {

    act = this.getActivity();
    /*IF Bluetooth is NOT enabled, then ask user permission to enable it */
    if (!bluetooth.isEnabled()) {
        Intent requestBluetooth = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
        this.getActivity().startActivityForResult(requestBluetooth, BLUETOOTH_REQUEST_CODE);
    }

    act.registerReceiver(receiver, new IntentFilter(BluetoothDevice.ACTION_ACL_DISCONNECTED));

    pairedDevices = bluetooth.getBondedDevices();    // Get all devices already bonded through bluetooth
}

/* This BroadcastReceiver will handle bluetooth disconnects */
public class myOwnBroadcastReceiver extends BroadcastReceiver {
    @Override
        public void onReceive(Context context, Intent intent) {

        String action = intent.getAction();
        if (BluetoothDevice.ACTION_ACL_DISCONNECTED.equals(action)) {
            //Device has disconnected -- need to update code to handle this action (figure out how to tell which device it was)
            //handleDisconnect();
        }
    }
}


void attemptConnect(Set<BluetoothDevice> devices, String BTname) {

    for (BluetoothDevice bt : devices) {

        if (bt.getName().equals(BTname)) {
            println("Attempting to connect to "+ BTname);
            ConnectToBluetooth connectBT = new ConnectToBluetooth(bt);
            //Connect to the the device in a new thread
            new Thread(connectBT).start();     
            connectBTs.add(connectBT);
            long startTime = System.currentTimeMillis();

            FileWriter logwriter = openFile("log.temp", logDir, false, true);
            logwriters.add(logwriter);
            FileWriter writer = openFile("temp", fileDir, false, true);
            writers.add(writer);

            filenames.add("");

            while (scSockets.size() != connectBTs.size()) {         // socket added to scSockets in connectToBluetooth runnable
                if (System.currentTimeMillis() - startTime > 5000) {  // wait 3 seconds before cancelling connection attempt
                    connectBTs.remove(connectBTs.size()-1);
                    logwriters.remove(logwriters.size()-1);
                    filenames.remove(filenames.size()-1);
                    setAlert(0, BTname);
                    return;
                }
            }

            int _device = connectBTs.size()-1;

            runmodes_init.add(new LinkedList<String>());
            runmodes.add(new LinkedList<String>());
            mode.add("");

            readMessages.add("");
            Queue<String> ardSendMessages =  new LinkedList<String>();
            ardSendList.add(ardSendMessages);
            ardSentStr.add("");

            // Setup Handler for receiving/sending messages
            mHandlers.add(new deviceHandler(_device));

            SendReceiveBytes sendReceiveBT = new SendReceiveBytes(scSockets.get(_device), _device);
            new Thread(sendReceiveBT).start();
            sendReceiveBT.write("<reset>");
            sendReceiveBTs.add(sendReceiveBT);
            connectedDevices.add(BTname);
            BTConnected[_device] = true;

            addDeviceButton(_device);

            // Initialize and add new plot objects
            setupPlotDisplay();

            break;
        }
    }
}


/* My ToastMaster function to display a messageBox on the screen */
void ToastMaster(String textToDisplay) {
    Toast myMessage = Toast.makeText(this.getActivity().getApplicationContext(), 
        textToDisplay, 
        Toast.LENGTH_LONG);
    myMessage.setGravity(Gravity.CENTER, 0, 0);
    myMessage.show();
}

public class ConnectToBluetooth implements Runnable {
    private BluetoothDevice btShield;
    private BluetoothSocket mySocket = null;
    private UUID uuid = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");

    public ConnectToBluetooth(BluetoothDevice bluetoothShield) {
        btShield = bluetoothShield;
        try {
            mySocket = btShield.createRfcommSocketToServiceRecord(uuid);
        }
        catch(IOException createSocketException) {
            //Problem with creating a socket
        }
    }

    /*@Override*/    public void run() {

        try {
            /*Connect to the bluetoothShield through the Socket. This will block
             until it succeeds or throws an IOException */
            mySocket.connect();
            scSockets.add(mySocket);
            println("Socket Connected: scSockets size = " + scSockets.size());
            return;
        } 
        catch (IOException connectException) {
            try {
                mySocket.close(); //try to close the socket
                println("Socket Closed: " + connectException);
                //BTConnected = false;
            }
            catch(IOException closeException) {
            }
            return;
        }
    }

    /* Will cancel an in-progress connection, and close the socket */
    public void cancel() {
        try {
            mySocket.close();
            //BTConnected = false;
        } 
        catch (IOException e) {
        }
    }
}


void onPause() { 
    super.onPause();
}


public class deviceHandler {
    private Handler mHandler;
    public int device;

    public deviceHandler(int _device) {
        device = _device;
        mHandler = new Handler(android.os.Looper.getMainLooper()) {
            private StringBuilder sb = new StringBuilder();
            @Override public void handleMessage(Message msg) {
                switch (msg.what) {
                case MESSAGE_WRITE:
                    //Do something when writing
                    break;
                case MESSAGE_READ:
                    //Get the bytes from the msg.obj
                    byte[] readBuf = (byte[]) msg.obj;
                    // construct a string from the valid bytes in the buffer
                    String strIncom = new String(readBuf, 0, msg.arg1);                 // create string from bytes array

                    sb.append(strIncom);                                                // append string
                    //println("sb: \t" + sb);

                    // Handle both NL and CR
                    while (sb.indexOf("\r\n") > 0 || (sb.lastIndexOf("\n")>0 && sb.indexOf("\r")!=0)) {
                        int rnidx = sb.indexOf("\r\n");
                        int nidx = sb.indexOf("\n") >0 ? sb.indexOf("\n") : sb.substring(1, sb.length()).indexOf("\n");
                        //println("rnidx:"+rnidx +"\tnidx:"+nidx);
                        int endOfLineIndex = rnidx;          // determine the end-of-line
                        if (rnidx<0 || (nidx < rnidx && nidx >0)) {
                            endOfLineIndex = nidx;
                            if (sb.indexOf("\n") == 0) {
                                endOfLineIndex = sb.substring(1, sb.length()).indexOf("\n")+1;
                                readMessages.set(device, sb.substring(1, endOfLineIndex));               // extract string
                            } else {
                                readMessages.set(device, sb.substring(0, endOfLineIndex));
                            }
                            sb.delete(0, endOfLineIndex);
                            println(connectedDevices.get(device) + "\treadMessage:\t" + readMessages.get(device));
                            handleSerial(readMessages.get(device), device);
                        } else {
                            if (sb.indexOf("\n") == 0) {
                                readMessages.set(device, sb.substring(1, endOfLineIndex));               // extract string
                            } else {
                                readMessages.set(device, sb.substring(0, endOfLineIndex));
                            }
                            sb.delete(0, endOfLineIndex+1);
                            println(connectedDevices.get(device) + "readMessage:\t" + readMessages.get(device));
                            handleSerial(readMessages.get(device), device);
                        }
                    }
                    break;
                }
            }
        };
    }

    public Handler get() {
        return mHandler;
    }
}


public class SendReceiveBytes implements Runnable {
    private BluetoothSocket btSocket;
    private InputStream btInputStream = null;
    private OutputStream btOutputStream = null;
    public int device;
    String TAG = "SendReceiveBytes";

    public SendReceiveBytes(BluetoothSocket socket, int _device) {
        btSocket = socket;
        device = _device;
        try {
            btInputStream = btSocket.getInputStream();
            btOutputStream = btSocket.getOutputStream();
            println("IO Streams established");
        } 
        catch (IOException streamError) { 
            println("STREAMERROR");
            Log.e(TAG, "Error when getting input or output Stream");
        }
    }

    public void run() {
        byte[] buffer = new byte[1024]; // buffer store for the stream
        int bytes; // bytes returned from read()
        println("Running SendReceiveBytes thread");
        // Keep listening to the InputStream until an exception occurs
        while (true) {
            try {
                // Read from the InputStream
                bytes = btInputStream.read(buffer);
                // Send the obtained bytes to the UI activity
                Handler mHandler = mHandlers.get(device).get();    // returns Handler from array of deviceHandlers
                mHandler.obtainMessage(MESSAGE_READ, bytes, -1, buffer).sendToTarget();
            } 
            catch (IOException e) {
                Log.e(TAG, "Error reading from btInputStream");
                break;
            }
            delay(50);
        }
    }

    /* Call this from the main activity to send data to the remote device */
    public void write(String msg) {
        try {
            btOutputStream = btSocket.getOutputStream();
            btOutputStream.write(stringToBytes(msg));
        } 
        catch (IOException e) { 
            Log.e(TAG, "Error when writing to btOutputStream");
        }
    }



    /* Call this from the main activity to shutdown the connection */
    public void cancel() {
        try {
            btSocket.close();
        } 
        catch (IOException e) { 
            Log.e(TAG, "Error when closing the btSocket");
        }
    }
}



public void ardSend(String str, int device) {
    if (ardSent[device] && !str.equals(ardSentStr.get(device))) {
        // Add message to queue if currently sending another message and not trying to resend the same message
        ardSendList.get(device).add(str);
        println("Added to ardSendMessages Queue: " + str);
    } else if (sendReceiveBTs.get(device) !=null) {
        SendReceiveBytes sendReceiveBT = sendReceiveBTs.get(device);
        println("Sending: \t" + str);
        //byte[] byteStr = stringToBytesUTFCustom(str);
        //byte[] byteStr = str.getBytes();

        //Send string in packets of 10 characters
        sendReceiveBT.write("<");
        if (str.length() < 16) sendReceiveBT.write(str);
        else {
            for (int i = 0; i<str.length(); i+=16) {
                sendReceiveBT.write(str.substring(i, i+10>str.length() ? str.length() : i+10));
                println("Sent: " + str.substring(i, i+10>str.length() ? str.length() : i+10));
            }
        }
        sendReceiveBT.write(">");

        ardSent[device] = true;
        ardSentStr.set(device, str);
        delay(100);
    }
}


public byte[] stringToBytes(String str) {
    char[] buffer = str.toCharArray();
    byte[] b = new byte[buffer.length << 1];
    for (int i = 0; i < buffer.length; i++) {
        int bpos = i << 1;
        b[bpos] = (byte) ((buffer[i]&0xFF00)>>8);
        b[bpos + 1] = (byte) (buffer[i]&0x00FF);
    }
    return b;
}

void handleSerial(String msg, int device) {
    writeFile(logwriters.get(device), msg+"\n");
    // Check if a command has been sent to the arduino and correctly received
    if (ardSent[device]) {
        if (ardSentStr.get(device).equals(msg)) {
            if (ardSendList.get(device).size()>0) {
                if (ardSentStr.get(device).equals(ardSendList.get(device).peek())) {    // ardSentStr stores most recently sent string to android. ardSendList contains queues of strings needing to be sent
                    ardSendList.get(device).remove();
                }
            }
            ardSent[device] = false;
            return;
        } else {
            // Resend string if msg does not match sent string
            delay(500);
            ardSend(ardSentStr.get(device), device);
        }
    }

    if (!mobinaatReady[device]) {
        if (msg.equals("Connected")) {
            fluoConnected[device] = true;
        }
        if (msg.equals("<MOBINAAT READY>")) {
            println("Mobinaat ready.");
            if (device == displayDevice) {
                startButton.text = "START";
                startButton.basecolor = buttonOnColor;
            }
            mobinaatReady[device] = true;
            return;
        }
    } else if (detecting[device]) {
        parseData(msg, device);
        return;
    }

    // If "running" start log data
    else if (running[device]) {
        if (msg.equals("NAAT Completed.")) {
            println("NAAT Completed.");
            running[device] = false;
            if (device == displayDevice) {
                startButton.text = "START";
                startButton.basecolor = buttonOnColor;
            }
            closeFiles(device);
            //exportData(filenameButton.value_str, emailB.value_str);
        } else if (msg.equals("*") || msg.equals("\n*")) {
            println("Asterisk");
            parseData(msg, device);
            if (runmodes.get(device).peek().equals(mode.get(device))) {
                // current mode just finished
                runmodes.get(device).remove();
            } else {
                mode.set(device, runmodes.get(device).peek()); 
                println("Mode set to " + mode.get(device));
                if (mode.get(device).equals("M")) {
                    // open melt file and change writer
                    try {
                        writers.get(device).flush();
                        writers.get(device).close();
                    }
                    catch(Exception e) {
                        println(e);
                    }
                    writers.set(device, openFile("melt."+filenames.get(device), fileDir, false, false));    // false = no append (new file)  , false = no overwrite
                    filenameButton.value_str = filenames.get(device);
                }
            }
        } else { 
            parseData(msg, device);
        }
    }
    /* check if device was reset */
    if (msg.equals("<ARDUINO CONNECTED>")) {
        println("Arduino Connected");
        running[device] = false;
        mobinaatReady[device] = false;
        ardSent[device] = false;
        fluoConnected[device] = false;
        if (device == displayDevice) {
            startButton.text = "CONNECTING...";
            startButton.basecolor = color(255, 211, 0);
        }
    } else if (msg.equals("<MOBINAAT READY>")) {
        println("Mobinaat ready.");
        running[device] = false;
        mobinaatReady[device] = true;
        ardSent[device] = false;
        if (device == displayDevice) {
            startButton.text = "START";
            startButton.basecolor = buttonOnColor;
        }
    }
}

float[] time_pt= new float[MAX_DEVICES];
float[] temp_pt= new float[MAX_DEVICES];
float[] fluo1_pt= new float[MAX_DEVICES];
float[] fluo2_pt= new float[MAX_DEVICES];

float time_pt_new;
float temp_pt_new;

boolean[] fluoStored = new boolean[MAX_DEVICES];
void parseData(String msg, int device) {
    /* Split data by tabs */
    String[] split_str;
    split_str = msg.split("\t");

    if (detecting[device]) {     
        String val = "";
        for (int i =1; i<split_str.length; i++) {
            val +=  split_str[i];
            if (i < split_str.length-1) val += "\n";  // add new line between fluorescence values
        }
        test_detect_vals[device] = val;
        detecting[device]=false;
        return;
    }

    plot2D temp_plot = temp_plots.get(device);
    plot2D fluo_plot = fluo_plots.get(device);
    plot2D melt_plot = melt_plots.get(device);


    if (split_str.length >1) {                            // Time, Temp, (Fluo1), (Fluo2)
        //time_pt = parseFloat(split_str[0]);
        //temp_pt = parseFloat(split_str[1]);
        time_pt_new = checkData(split_str[0], 0, time_pt[device], device, 0);
        temp_pt_new = checkData(split_str[1], 1, temp_pt[device], device, 0);
        time_pt[device] = time_pt_new >0 ? time_pt_new : time_pt[device] + 0.5;
        temp_pt[device] = temp_pt_new >0 ? temp_pt_new : temp_pt[device];

        temp_pts[0][0] = time_pt[device] / 60.0; // convert seconds to minutes
        temp_pts[1][0] = temp_pt[device];
        temp_plot.loadData(temp_pts);
    }

    /* FOR CYCLING: Check if fluorescence value was previously stored i.e. last fluorescence from an anneal was read and new line doesn't contain a fluorescence value*/
    if (mode.get(device).equals("C")) {
        if (split_str.length < 3 && fluoStored[device]) {
            /* ...and store them in plot arrays... */
            fluo_pts[0][0] = fluo_plot.n_pts + 1;
            fluo_pts[1][0] = fluo1_pt[device];

            writeFile(writers.get(device), Integer.toString(Math.round(fluo_pts[0][0])) + "," + Float.toString(fluo1_pt[device]));

            if (n_plots_fluo == 2) {
                fluo_pts[2][0] = fluo2_pt[device];
                writeFile(writers.get(device), "," + Float.toString(fluo2_pt[device]));
            } 
            writeFile(writers.get(device), "\n");

            fluo_plot.loadData(fluo_pts);
            fluoStored[device] = false;

            /* ...and check if Ct reached...*/
            int startIdx = 15;
            if (fluo_plot.n_pts >startIdx +3) {
                if (Ct1[device] <= 0) {
                    fluo_1 = new double[fluo_plot.n_pts];
                    for (int i =0; i<fluo_plot.n_pts; i++) {
                        fluo_1[i] = fluo_plot.data[1][i];
                    }
                    //println(fluo_1);
                    Ct1[device] = linregCt(startIdx, fluo_1);
                }
                if (n_plots_fluo == 2) {
                    if (Ct2[device] <= 0) {
                        fluo_2 = new double[fluo_plot.n_pts];
                        for (int i =0; i<fluo_plot.n_pts; i++) {
                            fluo_2[i] = fluo_plot.data[2][i];
                        }
                        Ct2[device] = linregCt(startIdx, fluo_2);
                    }
                }
            }
        } else { 
            if (split_str.length>2) {
                float new_fluo1_pt = checkData(split_str[2], 2, fluo1_pt[device], device, 1);    //(String data_str, int data_type, float last_pt, int device, int fluo_option)
                fluo1_pt[device] = new_fluo1_pt >0? new_fluo1_pt : fluo1_pt[device];
                fluoStored[device] = true;
            }
            if (split_str.length>3) {
                float new_fluo2_pt = checkData(split_str[3], 2, fluo2_pt[device], device, 2);
                fluo2_pt[device] = new_fluo2_pt >0? new_fluo2_pt : fluo2_pt[device];
                fluoStored[device] = true;
            }
        }
    } else if (mode.get(device).equals("M")) {
        // Time and temp already stored in time_pt_new, temp_pt_new
        if (split_str.length==3) {
            fluo1_pt[device] = checkData(split_str[2], 2, fluo1_pt[device], device, 1);

            //write temp and fluo to plot and file
            melt_pts[0][0] = temp_pt_new;
            melt_pts[1][0] = fluo1_pt[device]; 
            melt_plot.loadData(melt_pts);

            writeFile(writers.get(device), Float.toString(temp_pt_new) + "," + Float.toString(fluo1_pt[device]) + "\n");
        } else if (split_str.length==4) {
            println("2 fluorescence values detected. n_plots_fluo = " + n_plots_fluo);

            fluo1_pt[device] = checkData(split_str[2], 2, fluo1_pt[device], device, 1);  
            fluo2_pt[device] = checkData(split_str[3], 2, fluo2_pt[device], device, 2);

            println( "Checked fluo points");
            println("fluo1_pt " + fluo1_pt);
            println("fluo2_pt " + fluo2_pt);

            melt_pts[0][0] = temp_pt_new;
            melt_pts[1][0] = fluo1_pt[device]; 
            melt_pts[2][0] = fluo2_pt[device];
            melt_plot.loadData(melt_pts);

            println("Loaded melt fluo to plot");

            //write temp and fluo to plot and file
            writeFile(writers.get(device), Float.toString(time_pt_new) + "," + Float.toString(temp_pt_new) + "," + Float.toString(fluo1_pt[device]) + "," + Float.toString(fluo2_pt[device]) + "\n");
        }
    }
}

float dFluo_threshold = 100;    // threshold for max difference between two fluorescence measurements
float ddFluo_threshold = 100;   // threshold for max change in the dFluo between two sets of points
float checkData(String data_str, int data_type, float last_pt, int device, int fluo_option) {
    // Modes: 0 = time, 1 = temp, 2 = fluo 
    // Return -1 if data does not check out

    //if (data_str.lastIndexOf('.') != data_str.length()-3) return -1; // period in wrong place -- should be 2 #s after decimal

    float data_float = parseFloat(data_str); 

    if (last_pt >0) {
        if (data_type == 0) {       // time
            if (data_float < last_pt) return -1;
        } else if (data_type == 1) {    // temp
            if (data_float > 120 || data_float < 15) return -1;
        } else if (data_type == 2) {    // fluo
            if (data_float < 0 || data_float > 2499) return -1;
            if (mode.get(device).equals("C")) {
                // if newest data looks erroneous log newest point same value as previous point              
                /*
                // Calculate last ddF
                int n_pts = fluo_plots.get(device).n_pts;
                float last_ddf = 0;
                float pt0 =0;
                float pt1 =0;
                if (n_pts>2) {
                    
                    pt0 = fluo_plots.get(device).data[fluo_option][n_pts-2]; // 2 fluo pts previous
                    pt1 = fluo_plots.get(device).data[fluo_option][n_pts-1]; // 1 fluo pt previous
                    
                    last_pt = pt1;
                    
                    last_ddf = pt1-pt0;
                }

                // check if change in fluo is within a range -- checks for erroneous jumps
                if (abs(last_pt - data_float)>dFluo_threshold) return last_pt + last_ddf;

                // check if diff in fluo compares correctly to the last set of fluo points (after 10 cycles to allow for fluorescence stabilization)
                if (n_pts>10) {
                    if (abs((data_float-pt1) - last_ddf)> ddFluo_threshold) return last_pt + last_ddf;
                }
                */
            }
        }
    }

    return data_float;
}
void handleDisconnect(int device) {
    println("Disconnecting device: " + connectedDevices.get(device));

    // Check if names in ConnectedDevices match with bondedDevices?
    pairedDevices = bluetooth.getBondedDevices();


    // Remove corresponding elements from all ArrayLists
    readMessages.remove(device);
    ardSentStr.remove(device);
    ardSendList.remove(device);
    connectBTs.get(device).cancel();  // closes socket associated with device
    connectBTs.remove(device);
    scSockets.remove(device);
    sendReceiveBTs.remove(device);
    connectedDevices.remove(device);
    mHandlers.remove(device);

    runmodes_init.remove(device);
    runmodes.remove(device);
    mode.remove(device);

    // Adjust the device assignments for all mHandlers and sendReceiveBytes
    if (connectedDevices.size()>0) {
        for (int i = device; i<connectedDevices.size(); i++) {
            sendReceiveBTs.get(i).device = i;
            mHandlers.get(i).device = i;
        }
    }

    closeFiles(device);
    writers.remove(device);
    logwriters.remove(device);
    filenames.remove(device);

    // Change deviceButtons y position on screen:
    for (int i=0; i<deviceButtons.size(); i++) {        
        homeButtons.remove(deviceButtons.get(i));
        if (i>device) {
            deviceButtons.get(i).y = deviceButtons.get(i-1).y;
        }
    }

    // Shift all boolean arrays to remove "true" statement at device index
    for (int i =0; i< MAX_DEVICES-1; i++) {

        if (i>=device) {
            ardSent[i] = ardSent[i+1];
            mobinaatReady[i] = mobinaatReady[i+1];
            running[i] = running[i+1];
            BTConnected[i]= BTConnected[i+1];

            analyzed[i] = analyzed[i+1];
        }
    }
    ardSent[MAX_DEVICES-1] = false;
    mobinaatReady[MAX_DEVICES-1] = false;
    running[MAX_DEVICES-1] = false;
    BTConnected[MAX_DEVICES-1]= false;

    analyzed[MAX_DEVICES-1] = false;

    // remove plots
    temp_plots.remove(device);
    fluo_plots.remove(device);
    melt_plots.remove(device);

    deviceButtons.remove(device);

    // Switch device being displayed
    if (connectedDevices.size() >0) {
        displayDevice = displayDevice > connectedDevices.size()-1 ? 0 : displayDevice;
    } else { 
        displayDevice = -1;
        startButton.text = "NOT CONNECTED";
        startButton.basecolor = buttonOffColor;
    }
}
