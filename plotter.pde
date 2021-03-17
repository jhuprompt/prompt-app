import java.util.Arrays;
static int PLOT_SIZE = 300; // initial space given to data arrays

int n_plots_fluo = 1; // # of independent variables (1= just temperature vs. time)

ArrayList<plot2D> temp_plots = new ArrayList<plot2D>();    // If displayDevice is changed, update corresponding device of previous display in these arrays and switch
ArrayList<plot2D> fluo_plots = new ArrayList<plot2D>();
ArrayList<plot2D> melt_plots = new ArrayList<plot2D>();


plot2D archive_temp_plot;
plot2D archive_fluo_plot;
plot2D archive_melt_plot;


float[][] temp_pts;  // holds points for loading into plot2D object
float[][] fluo_pts;  // holds points for loading into plot2D object
float[][] melt_pts;

void setupPlotDisplay() {
  /* Called during setup to show position of empty plots */

  plot2D temp_plot = new plot2D(width*3/10, height/7, width*2/3, height/5, 1);
  temp_plot.pt_size = 4;
  temp_pts = new float[][] {{0}, {0}};
  temp_plot.loadData(temp_pts);
  temp_plot.xlabel = "Time (min)";
  temp_plot.ylabel = "Temp (degC)";
  temp_plot.labels = true;

  if (method_type == 5) { 
    n_plots_fluo = 2;
    fluo_pts =new float[][] {{0}, {0}, {0}};
  } else {
    n_plots_fluo = 1;
    fluo_pts = new float[][] {{0}, {0}};
  }

  plot2D fluo_plot =  new plot2D(width*3/10, height/5+height/7, width*2/3, height/5, n_plots_fluo);
  fluo_plot.pt_size = 4;
  fluo_plot.loadData(fluo_pts);
  fluo_plot.xlabel = "Cycles";
  fluo_plot.ylabel = "Fluorescence";
  fluo_plot.labels = true;

  plot2D melt_plot =  new plot2D(width*3/10, height/5+height/7, width*2/3, height/5, n_plots_fluo);

  temp_plots.add(temp_plot);
  fluo_plots.add(fluo_plot);
  melt_plots.add(melt_plot);

  archive_fluo_plot = new plot2D(width*3/10, height/5+height/7, width*2/3, height/5, 1);
}

void setupPlot(int device) {
  /* Called with press of START button (doesn't have empty point added for display) */

  //temp_plot = new plot2D(plot1x-plot1w/2, plot1y-plot1h/2, plot1w, plot1h, 1);
  plot2D temp_plot = new plot2D(width*3/10, height/7, width*2/3, height/5, 1);
  temp_plot.pt_size = 4;
  temp_pts = new float[][] {{0}, {0}};
  temp_plot.xlabel = "Time (min)";
  temp_plot.ylabel = "Temp (degC)";
  temp_plot.labels = true;
  temp_plot.scatter = true;
  //temp_plot.namelabels=true;
  //temp_plot.names[0] = "Temp";

  if (method_type == 5) { 
    n_plots_fluo = 2;
    fluo_pts =new float[][] {{0}, {0}, {0}};
  } else {
    n_plots_fluo = 1;
    fluo_pts = new float[][] {{0}, {0}};
  }

  plot2D fluo_plot =  new plot2D(width*3/10, height/5+height/7, width*2/3, height/5, n_plots_fluo);
  fluo_plot.pt_size = 4;
  fluo_plot.scatter = true;
  fluo_plot.xlabel = "Cycles";
  fluo_plot.ylabel = "Fluorescence";
  fluo_plot.ax_lock = false;
  fluo_plot.ax_lim[0] = 0;
  fluo_plot.ax_lim[1] = 40;
  fluo_plot.ax_lim[2] = 100;
  fluo_plot.ax_lim[3] = 400;
  fluo_plot.labels = true;
  fluo_plot.namelabels=true;
  if (LED1.state) {
    fluo_plot.names[0] = fluoChan1;
    fluo_plot.colors[0] = color(0, 255, 0);
    if (LED2.state) {
      fluo_plot.names[1] = fluoChan2;
      fluo_plot.colors[1] = color(255, 0, 0);
    }
  } else {
    fluo_plot.names[0] = fluoChan2;
    fluo_plot.colors[0] = color(255, 0, 0);
  }

  plot2D melt_plot = new plot2D(width*3/10+width*1/3, height/5+height/7, width*1/3, height/5, n_plots_fluo);
  if (runmodes_init.get(device).contains("M")) {
    fluo_plot.w = width*1/3;  // set width to half of screen

    if (method_type == 5) { 
      n_plots_fluo = 2;
      melt_pts =new float[][] {{0}, {0}, {0}};
    } else {
      n_plots_fluo = 1;
      melt_pts = new float[][] {{0}, {0}};
    }

    melt_plot.pt_size = 4;
    melt_plot.scatter = true;
    melt_plot.xlabel = "Temp (degC)";
    melt_plot.ylabel = "Fluorescence";
    melt_plot.ax_lock = false;
    melt_plot.labels = true;
    melt_plot.namelabels=true;
    if (LED1.state) {
      melt_plot.names[0] = fluoChan1;
      melt_plot.colors[0] = color(0, 255, 0);
      if (LED2.state) {
        melt_plot.names[1] = fluoChan2;
        melt_plot.colors[1] = color(255, 0, 0);
      }
    } else {
      melt_plot.names[0] = fluoChan2;
      melt_plot.colors[0] = color(255, 0, 0);
    }
  }

  temp_plots.set(device, temp_plot);
  fluo_plots.set(device, fluo_plot);
  melt_plots.set(device, melt_plot);
}

public class plot2D {
  int x, y;
  int w, h;
  int roundness = 7;

  float[][] data;   // data[row][col] -- col 0 = x axis
  int n_pts = 0;     // tracks number of pts in data
  int n_plots;       // number of columns -1 for X axis
  color[] colors;
  int pt_size = 5;
  boolean scatter = false;

  boolean namelabels = false;
  String[] names;   // contains titles for n_plots

  boolean labels = false;
  String xlabel;
  String ylabel;    

  color bcolor = color(255);
  color lcolor = color(0);
  PFont lfont;

  float[] axis = {0.2, 0.95, 0.30, 0.90};        // size = 4 for x-start, x-end, y-start, y-end listed as fraction of total background size
  boolean ax_lock = false;          // false = axes limits match data limits
  float[] ax_lim = {0, 100, 0, 100};   // settings for axes limits {xmin, xmax, ymin,ymax}
  boolean ticks = true;
  int n_ticks = 5;

  plot2D(int ix, int iy, int iw, int ih, int in_plots)
  {
    x = ix;
    y = iy;
    w = iw;
    h = ih;

    n_plots = in_plots;
    xlabel = "";
    ylabel = "";
    names = new String[in_plots];
    data = new float[n_plots+1][PLOT_SIZE]; //
    colors = new color[n_plots];
    for (int i = 0; i<n_plots; i++) {
      colors[i] = color(0); // initialize colors as black
    }

    lfont = createFont("Helvetica", h/20);
  } 

  void loadData(float[][] load) {
    int n_load_pts = load[0].length;
    int n_load_row = load.length;

    if (n_load_row != this.n_plots+1) {
      println("Error: data not correct dimensions");
      return;
    }

    if (n_load_pts + this.n_pts >this.data[0].length) {
      float[][] temp = data;  // temp points at original data points
      this.data = new float[this.n_plots+1][this.data[0].length+PLOT_SIZE];
      for (int i = 0; i<this.n_plots+1; i++) {
        for (int pt_idx = 0; pt_idx < this.n_pts; pt_idx++) {
          this.data[i][pt_idx] = temp[i][pt_idx];
        }
      }
    }
    for (int i = 0; i<this.n_plots+1; i++) {
      for (int pt_idx = this.n_pts; pt_idx< this.n_pts+n_load_pts; pt_idx++) {
        this.data[i][pt_idx] = load[i][pt_idx-this.n_pts];
      }
    }
    this.n_pts += n_load_pts;
  }

  void clearData() {
    this.data = new float[PLOT_SIZE][this.n_plots+1];
    this.n_pts = 0;
  }

  void display() {
    if (this.n_pts <1) {
      return;
    }
    // Draw Background
    rectMode(CORNER);
    fill(bcolor);
    rect(x, y, w, h, roundness);

    // Draw Axes
    int ax0 = int(x+w*axis[0]);
    int ax1 = int(x+w*axis[1]);
    int ay0 = int(y+h*(1-axis[2]));
    int ay1 = int(y+h*(1-axis[3]));
    fill(lcolor);
    stroke(lcolor);
    line(ax0, ay0, ax1, ay0);  // x-axis
    line(ax0, ay0, ax0, ay1);

    // Add axis labels        
    if (labels) { 
      textAlign(CENTER);
      textFont(lfont);
      textSize(24);
      text(xlabel, (ax0+ax1)/2, ay0+h/5);

      pushMatrix();
      translate( ax0-h/5, (ay0+ay1)/2);
      rotate(PI*3.0/2.0);
      textFont(lfont);
      textSize(24);
      text(ylabel, 0, 0);
      popMatrix();
    }


    // Draw Ticks
    if (ticks) this.drawticks();

    if (!ax_lock)
    {
      ax_lim[0] = floor(min(Arrays.copyOfRange(data[0], 0, n_pts))*0.9);
      //println(Arrays.copyOfRange(data[0],0,n_pts));
      ax_lim[1] = max(Arrays.copyOfRange(data[0], 0, n_pts))*1.1;
      ax_lim[2] = min(Arrays.copyOfRange(data[1], 0, n_pts));
      ax_lim[3] = max(Arrays.copyOfRange(data[1], 0, n_pts));
      for (int i=1; i<n_plots; i++)
      {
        float temp_min = min(Arrays.copyOfRange(data[i+1], 0, n_pts));
        float temp_max = max(Arrays.copyOfRange(data[i+1], 0, n_pts));
        if (temp_min < ax_lim[2]) ax_lim[2] = temp_min;
        if (temp_max > ax_lim[3]) ax_lim[3] = temp_max;
      }
    }

    for (int p = 0; p < n_plots; p++)
    {    
      int[] last_pt = point_conv(data[0][0], data[p+1][0]);
      for (int i = 0; i< n_pts; i++) {
        //println("Point: " + data[0][i] + '\t'+ data[p+1][i]);
        int[] pt = point_conv(data[0][i], data[p+1][i]);     
        noStroke();

        fill(colors[p]);
        stroke(colors[p]);
        if (scatter) {
          ellipseMode(CENTER);
          ellipse(float(pt[0]), float(pt[1]), pt_size, pt_size);
        } else {
          line(float(last_pt[0]), float(last_pt[1]), float(pt[0]), float(pt[1]));  // x-axis
        }
        //ellipseMode(CENTER);
        //ellipse(float(pt[0]), float(pt[1]), pt_size, pt_size);
        //println("Plotted x: " + pt[0] + "\t y: " + pt[1]);
        last_pt[0] = pt[0];
        last_pt[1] = pt[1];
      }
    }
    // Draw names next to last point
    if (namelabels && names.length == n_plots && names[0] != null) {
      for (int p = 0; p < n_plots; p++)
      {   
        int[] pt = point_conv(data[0][n_pts-1], data[p+1][n_pts-1]);
        textAlign(LEFT);
        fill(colors[p]);
        text(names[p], float(pt[0]), float(pt[1]));
      }
    }
  }

  void drawticks() {
    float x_range = ax_lim[1]-ax_lim[0];
    float y_range = ax_lim[3]-ax_lim[2];
    float x_space = x_range/(n_ticks-1);
    float y_space = y_range/(n_ticks-1);

    int ax0 = int(x+w*axis[0]);
    int ax1 = int(x+w*axis[1]);
    int ay0 = int(y+h*(1-axis[2]));
    int ay1 = int(y+h*(1-axis[3]));

    int ax_space = (ax1-ax0)/(n_ticks-1);
    int ay_space = (ay1-ay0)/(n_ticks-1);

    for (int i = 0; i<n_ticks; i++) {      
      fill(lcolor);
      stroke(lcolor);
      line(ax0+ax_space*i, ay0, ax0+ax_space*i, ay0+h/20); // length of tick determined by height of plot
      line(ax0, ay0+ay_space*i, ax0-h/20, ay0+ay_space*i);

      textFont(lfont);
      textAlign(CENTER, TOP);
      text(String.format("%.2f", (ax_lim[0]+x_space*i)), ax0+ax_space*i, ay0+h/20);
      textAlign(RIGHT, CENTER);
      text(String.format("%.0f", ax_lim[2]+y_space*i), ax0-h/20, ay0+ay_space*i);
    }
  }

  int[] point_conv(float x_in, float y_in) {
    float ax0 = x+w*axis[0];
    float ax1 = x+w*axis[1];
    float ay0 = y+h*(1-axis[2]);
    float ay1 = y+h*(1-axis[3]);
    int[] pt = new int[2];
    pt[0] = int(ax0 + (x_in - ax_lim[0])/(ax_lim[1]-ax_lim[0])*(ax1-ax0));
    pt[1] = int(ay0 + (y_in - ax_lim[2])/(ax_lim[3]-ax_lim[2])*(ay1-ay0));
    return pt;
  }
}
