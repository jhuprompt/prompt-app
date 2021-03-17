public ArrayList<Button> defaultButtons = new ArrayList<Button>();
PImage home_icon;
Button hButton;
RectButton connectButton;
RectButton resetButton;  // used to troubleshoot functions in the android code communication 

public ArrayList<Button> homeButtons = new ArrayList<Button>();
RectButton prepSwitch;
RectButton incSwitch;
RectButton incOptButton;
RectButton cycleSwitch;
RectButton cycleOptButton;
RectButton meltSwitch;
RectButton meltOptButton;
RectButton fluoOptButton;
RectButton optionsButton;
RectButton filenameButton;
RectButton startButton;
RectButton analyzeButton;
RectButton exportButton;

public ArrayList<Button> optionsButtons = new ArrayList<Button>();
Button incTempB;
Button incTimeB;
Button cycleNumB;
Button annealTempB;
Button annealTimeB;
Button extendSwitch;
Button extendTempB;
Button extendTimeB;
Button denatureTempB;
Button denatureTimeB;
Button meltStartB;
Button meltEndB;
Button emailB;
PImage LED;
Button LED1;
Button LED2;
Button fluoReadB;

public ArrayList<Button> inputButtons = new ArrayList<Button>();
Button OKButton;
Button CancelButton;

public ArrayList<Button> BToptButtons;
public ArrayList<Button> deviceButtons = new ArrayList<Button>();


void setupButtons() {
    /***********************
     *  Default buttons *
     ***********************/
    home_icon = loadImage("imgs/home_white.png");
    hButton = new ImageButton(home_icon, width/20, width/20, width/20, width/20, color(255), buttonOverColor, color(255)); 
    hButton.func = Cmd.HOME;
    hButton.locking = false;
    defaultButtons.add(hButton);

    connectButton =  new RectButton(width*6/7, height*1/25, width/5, height/20, buttonOffColor, color(255, 50), buttonOnColor);
    connectButton.locking = false;
    connectButton.text_font =  buttonFont1;
    connectButton.func = Cmd.CONNECTION;
    connectButton.text = "CONNECT";
    defaultButtons.add(connectButton);

    /***********************
     *  HomeScreen buttons *
     ***********************/
    prepSwitch =  new RectButton(width/6, height/8, width/5, height/10, buttonOffColor, color(255, 50), buttonOnColor);
    prepSwitch.locking = true;
    prepSwitch.state = true;
    prepSwitch.text_font = buttonFont1;
    //prepSwitch.func = "prep";
    prepSwitch.text = "Sample\nPrep";
    homeButtons.add(prepSwitch);

    cycleSwitch =  new RectButton(width/6, height*2/8, width/5, height/10, buttonOffColor, color(255, 50), buttonOnColor);
    cycleSwitch.locking = true;
    cycleSwitch.state = true;
    cycleSwitch.text_font =  buttonFont1;
    //cycleSwitch.func = "cycle";
    cycleSwitch.text = "Cycle";
    homeButtons.add(cycleSwitch);


    meltSwitch =  new RectButton(width/6, height*3/8, width/5, height/10, buttonOffColor, color(255, 50), buttonOnColor);
    meltSwitch.locking = true;
    meltSwitch.text_font =  buttonFont1;
    //meltSwitch.func = "melt";
    meltSwitch.text = "Melt";
    homeButtons.add(meltSwitch);

    filenameButton =  new RectButton(width*3/5+width/30, height*2/20, width*2/3, height/20, buttonOffColor, color(255, 50), buttonOnColor);
    filenameButton.locking = false;
    filenameButton.text_font =  buttonFont1;
    filenameButton.func = Cmd.INPUT_STR;
    filenameButton.text = "Filename: ";
    homeButtons.add(filenameButton);

    optionsButton =  new RectButton(width/6, height*4/8, width/5, height/20, buttonOffColor, color(255, 50), buttonOnColor);
    optionsButton.locking = false;
    optionsButton.text_font =  buttonFont1;
    optionsButton.func = Cmd.OPTIONS;
    optionsButton.text = "OPTIONS";
    homeButtons.add(optionsButton);

    startButton =  new RectButton(width*3/5+width/30, height/2+height/10, width*2/3, height/10, buttonOffColor, color(255, 50), buttonOnColor);
    startButton.locking = false;
    startButton.text_font =  titleFont;
    startButton.func = Cmd.START;
    startButton.text = "NOT CONNECTED";
    homeButtons.add(startButton);

    analyzeButton =  new RectButton(width/7, height*23/25, width/4, height/20, buttonOffColor, color(255, 50), buttonOnColor);
    analyzeButton.locking = false;
    analyzeButton.text_font =  buttonFont1;
    analyzeButton.func = Cmd.INPUT_STR;
    analyzeButton.text = "ARCHIVE";
    homeButtons.add(analyzeButton);

    exportButton =  new RectButton(width/7 + width/3, height*23/25, width/4, height/20, buttonOffColor, color(255, 50), buttonOnColor);
    exportButton.locking = false;
    exportButton.text_font =  buttonFont1;
    exportButton.func = Cmd.EXPORT;
    exportButton.text = "EXPORT";
    homeButtons.add(exportButton);

    resetButton =  new RectButton(width*6/7, height*23/25, width/5, height/20, buttonOffColor, color(255, 50), buttonOnColor);
    resetButton.locking = false;
    resetButton.text_font =  buttonFont1;
    resetButton.func = Cmd.RESET;
    resetButton.text = "RESET";
    homeButtons.add(resetButton);

    displayedButtons = homeButtons;

    /***********************
     *  Options buttons *
     ***********************/

    /*Button incTempB;
     Button incTimeB;
     Button cycleNumB;
     Button annealTempB;
     Button annealTimeB;
     Button denatureTempB;
     Button denatureTimeB;
     */
    incTempB =  new RectButton(width/4, height/8, width*3/8, height/10, buttonOffColor, color(255, 50), buttonOnColor);
    incTempB.locking = false;
    incTempB.text_font =  buttonFont1;
    incTempB.func = Cmd.INPUT_INT;
    incTempB.text = "Incubation Temp (C):\n ";
    incTempB.value_int = 106;
    optionsButtons.add(incTempB);

    incTimeB =  new RectButton(width*3/4, height/8, width*3/8, height/10, buttonOffColor, color(255, 50), buttonOnColor);
    incTimeB.locking = false;
    incTimeB.text_font =  buttonFont1;
    incTimeB.func = Cmd.INPUT_INT;
    incTimeB.text = "Incubation Time (s):\n ";
    incTimeB.value_int = 10;
    optionsButtons.add(incTimeB);

    annealTempB =  new RectButton(width/4, height*2/8, width*3/8, height/10, buttonOffColor, color(255, 50), buttonOnColor);
    annealTempB.locking = false;
    annealTempB.text_font =  buttonFont1;
    annealTempB.func = Cmd.INPUT_INT;
    annealTempB.text = "Anneal Temp (C):\n ";
    annealTempB.value_int = 65;
    optionsButtons.add(annealTempB);

    annealTimeB =  new RectButton(width*3/4, height*2/8, width*3/8, height/10, buttonOffColor, color(255, 50), buttonOnColor);
    annealTimeB.locking = false;
    annealTimeB.text_font =  buttonFont1;
    annealTimeB.func = Cmd.INPUT_INT;
    annealTimeB.text = "Anneal Time (s):\n ";
    annealTimeB.value_int = 1;
    optionsButtons.add(annealTimeB);

    extendSwitch = new CircleButton(width/2, height*3/8, height/16, height/16, buttonOffColor, buttonOverColor, buttonOnColor);
    extendSwitch.switcher = true;
    extendSwitch.state = false;
    optionsButtons.add(extendSwitch);

    extendTempB =  new RectButton(width/4, height*3/8, width*3/8, height/10, buttonOffColor, color(255, 50), buttonOnColor);
    extendTempB.locking = false;
    extendTempB.text_font =  buttonFont1;
    extendTempB.func = Cmd.INPUT_INT;
    extendTempB.text = "Extend Temp (C):\n ";
    extendTempB.value_int = 75;
    optionsButtons.add(extendTempB);

    extendTimeB =  new RectButton(width*3/4, height*3/8, width*3/8, height/10, buttonOffColor, color(255, 50), buttonOnColor);
    extendTimeB.locking = false;
    extendTimeB.text_font =  buttonFont1;
    extendTimeB.func = Cmd.INPUT_INT;
    extendTimeB.text = "Extend Time (s):\n ";
    extendTimeB.value_int = 15;
    optionsButtons.add(extendTimeB);

    denatureTempB =  new RectButton(width/4, height*4/8, width*3/8, height/10, buttonOffColor, color(255, 50), buttonOnColor);
    denatureTempB.locking = false;
    denatureTempB.text_font =  buttonFont1;
    denatureTempB.func = Cmd.INPUT_INT;
    denatureTempB.text = "Denature Temp (C):\n ";
    denatureTempB.value_int = 106;
    optionsButtons.add(denatureTempB);

    denatureTimeB =  new RectButton(width*3/4, height*4/8, width*3/8, height/10, buttonOffColor, color(255, 50), buttonOnColor);
    denatureTimeB.locking = false;
    denatureTimeB.text_font =  buttonFont1;
    denatureTimeB.func = Cmd.INPUT_INT;
    denatureTimeB.text = "Denature Time (s):\n ";
    denatureTimeB.value_int = 1;
    optionsButtons.add(denatureTimeB);

    meltStartB =  new RectButton(width/4, height*5/8, width*3/8, height/10, buttonOffColor, color(255, 50), buttonOnColor);
    meltStartB.locking = false;
    meltStartB.text_font =  buttonFont1;
    meltStartB.func = Cmd.INPUT_INT;
    meltStartB.text = "Melt Start (C):\n ";
    meltStartB.value_int = 60;
    optionsButtons.add(meltStartB);

    meltEndB =  new RectButton(width*3/4, height*5/8, width*3/8, height/10, buttonOffColor, color(255, 50), buttonOnColor);
    meltEndB.locking = false;
    meltEndB.text_font =  buttonFont1;
    meltEndB.func = Cmd.INPUT_INT;
    meltEndB.text = "Melt End (C):\n ";
    meltEndB.value_int = 105;
    optionsButtons.add(meltEndB);

    cycleNumB =  new RectButton(width/4, height*6/8, width*3/8, height/10, buttonOffColor, color(255, 50), buttonOnColor);
    cycleNumB.locking = false;
    cycleNumB.text_font =  buttonFont1;
    cycleNumB.func = Cmd.INPUT_INT;
    cycleNumB.text = "# of Cycles:\n ";
    cycleNumB.value_int = 40;
    optionsButtons.add(cycleNumB);

    emailB =  new RectButton(width*3/4, height*6/8, width*3/8, height/10, buttonOffColor, color(255, 50), buttonOnColor);
    emailB.locking = false;
    emailB.text_font =  buttonFont1;
    emailB.func = Cmd.INPUT_STR;
    emailB.text = "E-mail Address:\n";
    emailB.value_str = "atrick1@jhu.edu";
    optionsButtons.add(emailB);

    LED = loadImage("imgs/lightbulb_white.png");
    LED1 = new ImageButton(LED, width/6, height*8/9, height/8, height/8, color(50), color(0, 0, 255, 100), color(0, 0, 255)); 
    LED1.func = Cmd.LED1;
    LED1.state = true;
    LED1.switcher = true;
    optionsButtons.add(LED1);

    LED2 = new ImageButton(LED, width*2/6, height*8/9, height/8, height/8, color(50), color(255, 0, 0, 150), color(255, 0, 0)); 
    LED2.func = Cmd.LED2;
    LED2.state = true;
    LED2.switcher = true;
    optionsButtons.add(LED2);

    fluoReadB = new RectButton(width*1/2, height*8/9-height/24, height/12, height/24, color(50), color(0, 0, 255, 100), color(0, 0, 255));
    fluoReadB.state = false;
    fluoReadB.locking = false;
    fluoReadB.text_font =  buttonFont1;
    fluoReadB.func = Cmd.FLUO_READ;
    fluoReadB.text = "TEST";
    optionsButtons.add(fluoReadB);



    /***********************
     *  Input buttons *
     ***********************/

    OKButton = new RectButton(width/6+width/10, height/2, width/5, height/10, buttonOffColor, buttonOverColor, buttonOnColor);
    OKButton.locking = false;
    OKButton.text_color = color(255);
    OKButton.text_font = titleFont;
    OKButton.text = "OK";
    OKButton.func = Cmd.OK;
    inputButtons.add(OKButton);

    CancelButton = new RectButton(width*5/6-width/8, height/2, width/4, height/10, buttonOffColor, buttonOverColor, buttonOnColor);
    CancelButton.text_color = color(255);
    CancelButton.text_font = titleFont;
    CancelButton.locking = false;
    CancelButton.text = "Cancel";
    CancelButton.func = Cmd.CANCEL;
    inputButtons.add(CancelButton);
}

void setupBToptions() {
    pairedDevices = bluetooth.getBondedDevices();
    int nDevices = pairedDevices.size();
    if (nDevices>0) {
        RectButton b;
        BToptButtons = new ArrayList<Button>();
        int i = 0;
        for (BluetoothDevice bt : pairedDevices) {
            b = new RectButton(width/3, height*(i+1)/10, width/3, height/10, buttonOffColor, color(255, 50), buttonOnColor);
            //b.text_color = color(255);
            b.locking = true;
            //b.text_font = titleFont;
            b.text = bt.getName();
            b.func = Cmd.BT_SELECT;
            BToptButtons.add(b);
            if (connectedDevices.contains(b.text) && BTConnected[connectedDevices.indexOf(b.text)]) {
                b.state = true;
            }
            i++;
        }
    } else {
        BToptButtons = null;
    }
}


void addDeviceButton(int device) {
    RectButton b = new RectButton(width/6, height*(7+device)/10, width/5, height/20, buttonOffColor, color(255, 50), buttonOnColor);
    b.text = connectedDevices.get(device);
    b.state = true;
    b.locking = true;
    b.func = Cmd.DEVICE_SELECT;

    displayDevice = device;

    for (Button _b : deviceButtons) {
        _b.state = false;
    }

    deviceButtons.add(b);
}

void updateStartButton(int device) {
    if (running[device]) {
        startButton.text = "STOP";
        startButton.basecolor = color(255, 0, 0);
    } else if (mobinaatReady[device]) {
        startButton.text = "START";
        startButton.basecolor = buttonOnColor;
    } else {
        startButton.text = "NOT CONNECTED";
        startButton.basecolor = buttonOffColor;
    }
}

public class Button {

    int x, y;
    int w, h;
    color basecolor, highlightcolor, oncolor;
    color currentcolor;

    String text = "";
    PFont text_font = buttonFont1;
    color text_color = buttonTxtColor;    // black default
    color stroke_color = color(0);  // black default

    boolean pressed = false;
    boolean state = false;   // on or off
    boolean locking = true;  // button stays on after pressed
    boolean stroke = false;  // no outline
    boolean switcher = false;

    //String func = "";
    Cmd func = Cmd.NONE;
    int value_int = -1;
    float value_float = -1;
    String value_str = "";


    void update() 
    {
        if (over()) {
            //if (!state) currentcolor = highlightcolor;
        } else {
            if (state) {
                currentcolor = oncolor;
            } else {
                currentcolor = basecolor;
            }
        }
    }

    void pressed() // called if mouse pressed and over button -- returns func string for parsing into serial cmd
    {  
        if (locking) {
            if (state) currentcolor = basecolor;
            if (!state) currentcolor = oncolor; 
            state = !state;
            //println("state switched");
        }
    }
    boolean over() 
    { 
        return true;
    } 

    boolean overRect(int x, int y, int w, int h, int mouseXscaled, int mouseYscaled) 

    { 
        if (mouseXscaled >= x-w/2 && mouseXscaled <= x+w/2 && mouseYscaled >= y-h/2 && mouseYscaled <= y+h/2) {
            return true;
        } else {
            return false;
        }
    }

    boolean overCircle(int x, int y, int diameter, int mouseXscaled, int mouseYscaled) 
    {
        float disX = x - mouseXscaled;
        float disY = y - mouseYscaled;
        if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
            return true;
        } else {
            return false;
        }
    }
    void display() {
    }
}


class CircleButton extends Button
{ 
    CircleButton(int ix, int iy, int iw, int ih, color icolor, color ihighlight, color ioncolor) 
    {
        x = ix;
        y = iy;
        w = iw;
        h = ih;
        basecolor = icolor;
        highlightcolor = ihighlight;
        oncolor = ioncolor;
        currentcolor = basecolor;
    }

    boolean over() 
    {   
        //mXscaled = mouseX * width/width;
        //mYscaled = mouseY * height/height;
        if ( overCircle(x, y, w, mouseX, mouseY) ) {
            //over = true;
            return true;
        } else {
            //over = false;
            return false;
        }
    }

    void display() 
    {
        if (stroke) stroke(stroke_color);
        else noStroke();
        fill(currentcolor);
        ellipse(x, y, w, h);

        if (this.switcher) {
            if (state) this.text = "ON";
            else this.text = "OFF";
        }

        fill(this.text_color);
        textFont(this.text_font);
        textAlign(CENTER, CENTER);
        text(this.text, x, y);
    }
}

class RectButton extends Button
{   
    int roundness = 5;
    RectButton(int ix, int iy, int iw, int ih, color icolor, color ihighlight, color ioncolor) 
    {
        x = ix;
        y = iy;
        w = iw;
        h = ih;
        basecolor = icolor;
        highlightcolor = ihighlight;
        oncolor = ioncolor;
        currentcolor = basecolor;
    }

    boolean over() 
    {
        //mXscaled = mouseX * width/width;
        //mYscaled = mouseY * height/height;
        if ( overRect(x, y, w, h, mouseX, mouseY) ) {
            //over = true;
            return true;
        } else {
            //over = false;
            return false;
        }
    }

    void display() 
    {
        if (stroke) stroke(stroke_color);
        else noStroke();
        fill(currentcolor);
        rectMode(CENTER);
        rect(x, y, w, h, roundness);

        if (this.switcher) {
            if (state) {
                fill(this.text_color);
                textFont(this.text_font);
                textAlign(CENTER, CENTER);
                text(this.text + "ON", x, y);
            } else {
                fill(this.text_color);
                textFont(this.text_font);
                textAlign(CENTER, CENTER);
                text(this.text + "OFF", x, y);
            }
        } else {
            fill(this.text_color);
            textFont(this.text_font);
            textAlign(CENTER, CENTER);
            if (value_int != -1) {
                text(this.text +this.value_int, x, y);
            } else if (value_float > 0) {
                text(this.text +this.value_float, x, y);
            } else if (value_str != "") {
                text(this.text +this.value_str, x, y);
            } else {
                text(this.text, x, y);
            }
        }
    }
}

class ImageButton extends Button
{
    PImage img;
    ImageButton(PImage iimg, int ix, int iy, int iw, int ih, color icolor, color ihighlight, color ioncolor) 
    {
        x = ix;
        y = iy;
        w = iw;
        h = ih;
        img = iimg;
        basecolor = icolor;
        highlightcolor = ihighlight;
        oncolor = ioncolor;
        currentcolor = basecolor;
    }

    boolean over() 
    {
        //mXscaled = mouseX * width/width;
        //mYscaled = mouseY * height/height;
        if ( overRect(x, y, w, h, mouseX, mouseY) ) {
            //over = true;
            return true;
        } else {
            //over = false;
            return false;
        }
    }

    void display() 
    { 
        if (state) {
            tint(oncolor);
        } else if (this.over()) {
            tint(highlightcolor);
        } else tint(basecolor);
        imageMode(CENTER);
        image(img, x, y, w, h);
    }
}
