// Daniel Shiffman       
// http://www.shiffman.net   

// Simple E-mail Checking    
// This code requires the Java mail library
// smtp.jar, pop3.jar, mailapi.jar, imap.jar, activation.jar
// Download:// http://java.sun.com/products/javamail/

// Modified by Alex Trick for POC_PCR_droid.pde 10/11/2018

import java.util.*;
import java.io.*;
import javax.activation.*;
import javax.activation.DataSource;

import javax.mail.*;
import javax.mail.internet.*;
import javax.mail.Message.RecipientType;

// A function to send mail
void sendMail(String subject, String body, String address, File file, String filename, File logfile, String logfilename) throws FileNotFoundException {
    if (!file.exists()) {
        throw new FileNotFoundException("No file by filename " + file.getPath() + " exists.");
    }

    // Create a session
    String host="smtp.gmail.com";
    Properties props=new Properties();

    // SMTP Session
    props.put("mail.transport.protocol", "smtp");
    props.put("mail.smtp.host", host);
    props.put("mail.smtp.port", "587");
    props.put("mail.smtp.auth", "true");
    // We need TTLS, which gmail requires
    props.put("mail.smtp.starttls.enable", "true");

    // Create a session
    Session session = Session.getDefaultInstance(props, new Auth());

    try
    {
        // Below solves configureation files problem: https://stackoverflow.com/questions/21856211/javax-activation-unsupporteddatatypeexception-no-object-dch-for-mime-type-multi
        MailcapCommandMap mc = (MailcapCommandMap) CommandMap.getDefaultCommandMap(); 
        mc.addMailcap("text/html;; x-java-content-handler=com.sun.mail.handlers.text_html"); 
        mc.addMailcap("text/xml;; x-java-content-handler=com.sun.mail.handlers.text_xml"); 
        mc.addMailcap("text/plain;; x-java-content-handler=com.sun.mail.handlers.text_plain"); 
        mc.addMailcap("multipart/*;; x-java-content-handler=com.sun.mail.handlers.multipart_mixed"); 
        mc.addMailcap("message/rfc822;; x-java-content- handler=com.sun.mail.handlers.message_rfc822");

        MimeMessage msg=new MimeMessage(session);
        msg.setFrom(new InternetAddress("mobinaatresults@gmail.com", "MobiNAATResults"));
        msg.addRecipient(RecipientType.TO, new InternetAddress(address));
        msg.setSubject(subject);
        msg.setText("");
        BodyPart messageBodyPart = new MimeBodyPart();
        // Fill the message
        messageBodyPart.setText(body);
        Multipart multipart = new MimeMultipart();
        multipart.addBodyPart(messageBodyPart);
        // Part two is attachment

        //Attach fluorescence data file
        messageBodyPart = new MimeBodyPart();
        DataSource source = new FileDataSource(file.getPath());
        messageBodyPart.setDataHandler(new DataHandler(source));
        messageBodyPart.setFileName(filename);
        multipart.addBodyPart(messageBodyPart);

        //Attach log data file
        messageBodyPart = new MimeBodyPart();
        source = new FileDataSource(logfile.getPath());
        messageBodyPart.setDataHandler(new DataHandler(source));
        messageBodyPart.setFileName(logfilename);
        multipart.addBodyPart(messageBodyPart);

        msg.setContent(multipart);
        msg.setSentDate(new Date());
        Transport.send(msg);
        println("Mail sent!");
        setAlert(8, filename);
    }
    catch(Exception e)
    {
        e.printStackTrace();
        setAlert(7);
    }
}

// Daniel Shiffman       
// http://www.shiffman.net   

// Simple Authenticator      
// Careful, this is terribly unsecure!!

import javax.mail.Authenticator;
import javax.mail.PasswordAuthentication;

public class Auth extends Authenticator {

    public Auth() {
        super();
    }

    public PasswordAuthentication getPasswordAuthentication() {
        String username, password;
        username = "mobinaatresults@gmail.com";
        password = "M0b1n44t";
        System.out.println("authenticating. . ");
        return new PasswordAuthentication(username, password);
    }
}

public static boolean isValidEmailAddress(String email) {
    boolean result = true;
    try {
        InternetAddress emailAddr = new InternetAddress(email);
        emailAddr.validate();
    } 
    catch (AddressException ex) {
        result = false;
    }
    return result;
}
