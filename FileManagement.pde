import android.widget.Spinner;
import java.util.Calendar;

File fileDir;
File logDir;
String storageFolder = "/mobinaat";
String logFolder = "/mobinaat/logs";

ArrayList<FileWriter> writers = new ArrayList<FileWriter>();
ArrayList<FileWriter> logwriters = new ArrayList<FileWriter>();
ArrayList<String> filenames = new ArrayList<String>();

boolean[] fileOpened =new boolean[MAX_DEVICES];

public void setupFileDir() {
    fileDir = new File(Environment.getExternalStorageDirectory() + storageFolder);
    if (!fileDir.isDirectory()) {  // make directory for file storage if it doesn't exist already
        fileDir.mkdir();
        println("Making new directory: " + fileDir.toString());
    }  
    logDir = new File(Environment.getExternalStorageDirectory() + logFolder);
    if (!logDir.isDirectory()) {  // make directory for file storage if it doesn't exist already
        logDir.mkdir();
        println("Making new directory: " + logDir.toString());
    }
}

public FileWriter openFile(String filename, File dir, boolean append, boolean overwrite) {

    // Check if filename has .txt at end
    if (filename.length() > 4) {
        if (filename.substring(filename.length()-4).equals(".txt")) {
            filename = filename.substring(0, filename.length()-4);
        }
    }

    try {
        File myFile = new File(dir, filename + ".txt");
        int i = 2;
        while (myFile.exists() && !overwrite) {
            myFile = new File(dir, filename + '-' + i + ".txt");
            i++;
        }
        if (filename.length() < 3 || (!filename.substring(0, 3).equals("log") && !filename.substring(0, 4).equals("temp"))) {
            filenameButton.value_str = myFile.getName();
        }

        if (i>2) {
            println("File " + filename + " already exists. Opening new file: " + myFile.toString());      
            setAlert(2, myFile.getName());
        }

        FileWriter writer = new FileWriter(myFile, append);

        /*writer.append("First string is here to be written.");
         writer.flush();
         writer.close();
         */
        return writer;
    }
    catch( Exception e) {
        println(e);
        return null;
    }
}


public void writeFile(FileWriter writer, String str) {
    try {
        writer.append(str);
        writer.flush();
    }
    catch(Exception e) {
        println(e);
    }
}

public void closeFiles(int device) {
    try {
        writers.get(device).flush();
        writers.get(device).close();

        logwriters.get(device).flush();
        logwriters.get(device).close();

        fileOpened[device] = false;

        FileWriter logwriter = openFile("log.temp", logDir, false, true);
        logwriters.set(device, logwriter);
        FileWriter writer = openFile("temp", fileDir, false, true);
        writers.set(device, writer);

        filenameButton.value_str = filenames.get(device);
    }
    catch(Exception e) {
        println(e);
    }
}

public void exportData(String filename, String address) {
    //fileOpened = false;
    if (filename == "") { 
        setAlert(5);
        return;
    }
     String subject = filename;
     String body;
    if (displayDevice >=0) { 
        body = "Exported:\t" + timestamp() + "\nInstrument:\t" + connectedDevices.get(displayDevice) + "\n";

        body += fluoChan2 +" Ct =\t" + Ct2[displayDevice] + "\n";
        body += fluoChan1 + " Ct =\t" + Ct1[displayDevice] + "\n";
/*
        body += "Diagnosis:\t";
        if (Ct2[displayDevice]>0 && Ct1[displayDevice]>0) body+= "NG Positive (Cipro-Susceptible)";
        else if (Ct2[displayDevice]>0) body+= "NG Positive (Cipro-Resistant)";
        else if (Ct1[displayDevice] >0) body+="gyrA detected - no NG";
        else body += "NG Negative";
        */
    }else{
        body = "Exported:\t" + timestamp()+ "\n";

        body += fluoChan2 +" Ct =\t" + archive_Ct2+ "\n";
        body += fluoChan1 +" Ct =\t" + archive_Ct1 + "\n";
/*
        body += "Diagnosis:\t";
        if (archive_Ct2>0 && archive_Ct1>0) body+= "NG Positive (Cipro-Susceptible)";
        else if (archive_Ct2>0) body+= "NG Positive (Cipro-Resistant)";
        else if (archive_Ct1 >0) body+="gyrA detected - no NG";
        else body += "NG Negative";
        */
    }

    String logfilename = "log."+filename;
    String meltfilename = "melt." + filename;

    /* Send data to designated e-mail address */
    File file = new File(fileDir, filename);
    File logfile = new File(logDir, logfilename);
    File meltfile = new File(fileDir, meltfilename);
    
    if (!file.exists()) {
        setAlert(5, filename);    // File not found
    }


    try {
        sendMail(subject, body, address, file, filename, logfile, logfilename);
    }
    catch(Exception e) {
        println(e);
        return;
    }
    
      if (meltfile.exists()) {
        try {
            sendMail(subject + " - melt", body, address, meltfile, meltfilename, logfile, logfilename);
        }
        catch(Exception e) {
            println(e);
            return;
        }
    }
}

String timestamp() {
    Calendar now = Calendar.getInstance();
    return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}
