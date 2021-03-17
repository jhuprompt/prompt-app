// https://forum.processing.org/two/discussion/6018/run-android-keyboard
// ^ use if deciding to run on android in future

import android.view.inputmethod.InputMethodManager;
import android.text.InputType;
import android.content.res.Configuration;
//import android.view.inputmethod;
InputMethodManager imm;


/***************
 *  USER INPUT *
 ***************/
Button inputButton;
TEXTBOX input_field;
String input_ID;
String input_val;
Cmd input_cmd = Cmd.NONE;
boolean input_flag = false;
boolean OK = true; // tracks if cancelled button pressed
boolean NumKeyboard = true;

void setupTextbox() {
  input_field = new TEXTBOX((width/2-width*1/3), height/3, width*2/3, height/10);
  imm = (InputMethodManager) act.getSystemService(Context.INPUT_METHOD_SERVICE);
  //imm.toggleSoftInput(0, 0);
}

/*
 
 public void showKeyboard(boolean numeric){
 if(numeric){
 imm.setRawInputType(InputType.TYPE_CLASS_NUMBER); 
 // imm.setRawInputType(Configuration.KEYBOARD_12KEY); 
 }
 else{
 imm.setRawInputType(InputType.TYPE_CLASS_TEXT); 
 // imm.setRawInputType(Configuration.KEYBOARD_QWERTY); 
 }
 showKeyboard();
 }
 */


public void showKeyboard() {
  //Call this to show the keyboard
  //imm = (InputMethodManager) act.getSystemService(Context.INPUT_METHOD_SERVICE);
  imm.toggleSoftInput(InputMethodManager.SHOW_FORCED, 0);
}


public void hideKeyboard() {
  //Call this to hide the keyboard
  // imm = (InputMethodManager) act.getSystemService(Context.INPUT_METHOD_SERVICE);
  imm.toggleSoftInput(InputMethodManager.HIDE_IMPLICIT_ONLY, 0);
}

void getInput(Button b) {
  println("Get Input");
  input_cmd = b.func;
  switch(input_cmd) {
  case INPUT_STR:
    input_val = b.value_str;
    break;
  case INPUT_INT:
    input_val = Integer.toString(b.value_int);
    break;
  case INPUT_FLOAT:
    input_val = Float.toString(b.value_float);   
    break;
  }
  input_field.Text = "";
  input_field.TextLength = 0;
  last_displayMode = displayMode;
  last_displayedButtons = displayedButtons;
  input_ID = b.text;

  displayMode = -1; // input field display
  //showKeyboard();
}

public class TEXTBOX {
  public int X = 0, Y = 0, H = 35, W = 200;
  public int TEXTSIZE = 40;

  // COLORS
  public color Background = color(140, 140, 140);
  public color Foreground = color(0, 0, 0);
  public color BackgroundSelected = color(160, 160, 160);
  public color Border = color(30, 30, 30);

  public boolean BorderEnable = false;
  public int BorderWeight = 1;

  public String Text = "";
  public int TextLength = 0;

  private boolean selected = false;

  TEXTBOX() {
    // CREATE OBJECT DEFAULT TEXTBOX
  }

  TEXTBOX(int x, int y, int w, int h) {
    X = x; 
    Y = y; 
    W = w; 
    H = h;
  }

  void DRAW() {
    // DRAWING THE BACKGROUND
    if (selected) {
      fill(BackgroundSelected);
    } else {
      fill(Background);
    }

    if (BorderEnable) {
      strokeWeight(BorderWeight);
      stroke(Border);
    } else {
      noStroke();
    }

    rectMode(CORNER);
    rect(X, Y, W, H);

    // DRAWING THE TEXT ITSELF
    fill(Foreground);
    textSize(TEXTSIZE);
    textAlign(LEFT, CENTER);
    text(Text, X + (textWidth("a") / 2), Y + TEXTSIZE);
  }

  // IF THE KEYCODE IS ENTER RETURN 1
  // ELSE RETURN 0
  boolean KEYPRESSED(char KEY, int KEYCODE) {
    println(KEYCODE);
      if (selected) {
      // CHECK IF THE KEY IS A LETTER OR A NUMBER      
      boolean isKeyCapitalLetter = (KEY >= 'A' && KEY <= 'Z');
      boolean isKeySmallLetter = (KEY >= 'a' && KEY <= 'z');
      boolean isKeyNumber = (KEY >= '0' && KEY <= '9');
      boolean isKeyPunc = (KEY == '.' || KEY == '/' || KEY == '_');
      if (isKeyCapitalLetter || isKeySmallLetter || isKeyNumber || isKeyPunc) {
        addText(KEY);
      } else if (KEYCODE == (int)BACKSPACE) {
        //println((int)BACKSPACE);
        BACKSPACE();
      } else if (KEYCODE == 62) {
        // SPACE
        Text += " ";
        TextLength++;
      }
      else if (KEYCODE == 69) {
        // SPACE
        Text += "-";
        TextLength++;
      }
        else if (KEYCODE == 9) {
        // @
        Text += "@";
        TextLength++;
      } else if (KEYCODE == (int)ENTER) {
        return true;
      }
    }

    return false;
  }

  private void addText(char text) {
    // IF THE TEXT WIDHT IS IN BOUNDARIES OF THE TEXTBOX
    if (textWidth(Text + text) < W) {
      Text += text;
      TextLength++;
    }
  }

  private void BACKSPACE() {
    if (TextLength - 1 >= 0) {
      Text = Text.substring(0, TextLength - 1);
      TextLength--;
    }
  }

  // FUNCTION FOR TESTING IS THE POINT
  // OVER THE TEXTBOX
  private boolean overBox(int x, int y) {
    if (x >= X && x <= X + W) {
      if (y >= Y && y <= Y + H) {
        return true;
      }
    }

    return false;
  }

  void PRESSED() {
    //mXscaled = mouseX * width/width;
    //mYscaled = mouseY * height/height;

    if (overBox(mouseX, mouseY)) {
      selected = true;
      showKeyboard();
    } else {
      selected = false;
    }
  }
}
