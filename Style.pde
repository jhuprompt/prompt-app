
PFont buttonFont1;
PFont buttonFont2;
PFont titleFont;
PFont statusFont;
PFont labelFont;
PFont detectFont;
PFont alertFont;
PFont smallFont;

color backgroundColor;
color txtColor;
color buttonOffColor;
color buttonOverColor;
color buttonOnColor;
color buttonTxtColor;

void setStyle() {

  /*FONTS*/
  titleFont = createFont("Helvetica-Bold", 40, true);
  statusFont = createFont("Helvetica", 32, true);
  detectFont = createFont("Helvetica-Bold", 18, true);
  labelFont = createFont("Helvetica-Bold", 16, true);
  buttonFont1 = createFont("Helvetica", 36, true); // true = smoothing
  buttonFont2 = createFont("arial bold", 10);
  alertFont = createFont("Helvetica", 36, true);
  smallFont = createFont("Arial", 20);

  /*COLORS*/
  backgroundColor = #3498DB;  // "Peter River" blue
  buttonOffColor = #95A5A6;   // "concrete" gray
  buttonOverColor = #7F8C8D;  // "Asbestos" gray -- highlighted color
  buttonOnColor = #2ECC71;    // "Emerald" green
  buttonTxtColor = color(255); // white
  txtColor = color(255);
}
