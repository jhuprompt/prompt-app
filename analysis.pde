import Jama.Matrix;

boolean[] analyzed = new boolean[MAX_DEVICES];
int[] Ct1 = new int[MAX_DEVICES];
int[] Ct2 = new int[MAX_DEVICES];

int archive_Ct1 = 0;
int archive_Ct2 = 0;

boolean archive_analyzed = false;

// linreg_Ct needs a double to work with Matrix package
double[] fluo_1; 
double[] fluo_2;


void archive_Ct(String filename, int device) {
    archive_analyzed = true;
    if (device<0) {
        archive_Ct1 = 0;
        archive_Ct2 = 0;
    } else {
        Ct1[device] = 0;
        Ct2[device] = 0;
    }

    float[][] fluo;
    int n_color = 0;

    fluo = new float[2][50];

    int n_fluo = 0;

    File file = new File(fileDir, filename);
    BufferedReader br = null;
    String[] split_str;
    try {
        br = new BufferedReader(new FileReader(file));  
        String line;   
        while ((line = br.readLine()) != null) {

            split_str = line.split(",");  
            if (n_color == 0) n_color = split_str.length-1;

            if (n_color==1) {      
                fluo[0][n_fluo] = parseFloat(split_str[1]);
            } else if (n_color ==2) { 
                fluo[0][n_fluo] = parseFloat(split_str[1]);
                fluo[1][n_fluo] = parseFloat(split_str[2]);
            }
            n_fluo++;
        }
    }
    catch (IOException e) {
        e.printStackTrace();
        setAlert(5, file.getName());  // File not found
        return;
    }

    try {
        br.close();
    }
    catch(IOException e) {
        e.printStackTrace();
    }

    filenameButton.value_str = filename;

    double[] x = new double[n_fluo];
    for (int i = 0; i< n_fluo; i++) {
        x[i] = i+1;
    }

    double[] fluo1;
    double[] fluo2;

    //double[] result = linreg(x, fluo1);
    //println(result);

    //int[] Cts = new int[n_color];

    int result = -1;
    int firstIdx = 14;
    int lastIdx = firstIdx + 3;
    //result = linregCt(firstIdx, fluo1);
    while (result <0 && lastIdx < n_fluo) {   
        fluo1 = new double[lastIdx];
        for (int i = 0; i<lastIdx; i++) {
            fluo1[i] = fluo[0][i];
        }

        result = linregCt(firstIdx, fluo1);
        lastIdx++;
    }


    if (result>0) {
        if (device>=0) Ct1[device] = --lastIdx; // RETURN THIS VALUE AS Cq
        else archive_Ct1 = --lastIdx;
    }


    if (n_color==2) {
        result = -1;
        firstIdx = 14;
        lastIdx = firstIdx + 3;
        //result = linregCt(firstIdx, fluo1);
        while (result <0 && lastIdx < n_fluo) {   
            fluo2 = new double[lastIdx];
            for (int i = 0; i<lastIdx; i++) {
                fluo2[i] = fluo[1][i];
            }

            result = linregCt(firstIdx, fluo2);
            lastIdx++;
        }
        if (result >0) {
            if (device>=0) Ct2[device] = --lastIdx; // RETURN THIS VALUE AS Cq
            else archive_Ct2 = --lastIdx;
        }
    }
    if (n_color>0) {
        archive_plot(fluo, n_color, n_fluo);
    }
}

void archive_plot(float[][] fluo, int n_color, int n_pts) {
    //
    println("n_color: " + n_color);
    float[][] new_fluo_pt = new float[1+n_color][1];
    archive_fluo_plot =  new plot2D(width*3/10, height/5+height/7, width*2/3, height/5, n_color);
    archive_fluo_plot.scatter = true;
    archive_fluo_plot.pt_size = 4;
    archive_fluo_plot.xlabel = "Cycles";
    archive_fluo_plot.ylabel = "Fluorescence";
    archive_fluo_plot.labels = true; 

    archive_fluo_plot.ax_lock = false;
    archive_fluo_plot.ax_lim[0] = 0;
    archive_fluo_plot.ax_lim[1] = 40;
    archive_fluo_plot.ax_lim[2] = 0;
    archive_fluo_plot.ax_lim[3] = 600;
    archive_fluo_plot.labels = true;
    archive_fluo_plot.namelabels=true;

    archive_fluo_plot.names[0] = fluoChan1;
    archive_fluo_plot.colors[0] = color(0, 255, 0);
    if (n_color == 2) {
        archive_fluo_plot.names[1] = fluoChan2;
        archive_fluo_plot.colors[1] = color(255, 0, 0);
    }


    for (int i = 0; i < n_pts; i ++) {
        new_fluo_pt[0][0] = i+1;
        new_fluo_pt[1][0] = fluo[0][i];
        if (n_color == 2) new_fluo_pt[2][0] = fluo[1][i];
        archive_fluo_plot.loadData(new_fluo_pt);
    }
}

int linregCt(int firstIdx, double[] fluo) {
    if (fluo.length-firstIdx < 3) {
        throw new IllegalArgumentException("Fluo array length - firstIdx must be at least 3 points less than fluo.length");
    }
    if (firstIdx >= fluo.length) {
        throw new IllegalArgumentException("Indices must be < length of fluo array");
    }

    // Baseline Subtraction
    double fluoavg = 0;
    double[] fluo_sub = new double[fluo.length];
    for (int i = 0; i< 10; i++) {
        fluoavg+= fluo[i];
    }
    fluoavg /= 10;
    for (int i = 0; i<fluo.length; i++) {
        fluo_sub[i] = fluo[i] - fluoavg;
    }

    int Ct_linreg = -1;
    double Rsq_threshold = 0.2;    // Rsq_comb - Rsq > Rsq_threshold for Ct calling
    double slope_threshold = 3;    // slope_post_split - slope_pre_split > slope_threshold for Ct calling
    //double slope_threshold = 0.02;    

    double[] x;
    // Fit data after firstIdx to single linear regression
    x = new double[fluo.length];
    for (int i = firstIdx; i< fluo.length; i++) {
        x[i] = i+1;
    }
    double[] linfit = linreg(x, fluo);
    double slope = linfit[1];
    double Rsq = linfit[4];

    // 1 and 2 denote data before and after split, not two different colors
    double[] x1;
    double[] x2;
    double[] fluo1;
    double[] fluo2;
    for (int split = firstIdx+2; split <= fluo.length-3; split++) {
        // initialize x and fluo arrays using split value
        x1 = new double[split-firstIdx+1];
        x2 = new double[fluo.length-split];
        fluo1 = new double[x1.length];
        fluo2 = new double[x2.length];
        for (int i = firstIdx; i<=split; i++) {
            x1[i-firstIdx] = i+1;
            fluo1[i-firstIdx] = fluo[i];
        }
        for (int i = split; i< fluo.length; i++) {
            x2[i-split] = i+1;
            fluo2[i-split] = fluo[i];
        }

        double[] linfit1 = linreg(x1, fluo1);
        double[] linfit2 = linreg(x2, fluo2);

        //println(linfit1);
        //println(linfit2);

        double slope1 = linfit1[1];
        double SSres1 = linfit1[2];
        double SStot1 = linfit1[3];

        double slope2 = linfit2[1];
        double SSres2 = linfit2[2];
        double SStot2 = linfit2[3];
        //println("SSres1 = " + SSres1 + "\tSSres2 = " + SSres2+ "\tSStot1 = " + SStot1 + "\tSStot2 = " + SStot2);

        double Rsq_comb = 1 - (SSres1 + SSres2)/(SStot1 + SStot2);
        //println("Rsq = " + Rsq + "\tRsq_comb = " + Rsq_comb);

        boolean dslopeFlag = (slope2-slope1) > slope_threshold;
        //boolean dslopeFlag = (slope2-slope1)/fluo[split] > slope_threshold;
        //println("Fluo #: " + fluo.length +"\tSplit: " + split + "\tdslope1: " + slope1+ "\tdslope2: " + slope2);
        boolean RsqFlag = Rsq_comb - Rsq > Rsq_threshold && Rsq_comb >0.5;
        boolean posSlopeFlag = slope2 > 0;
        boolean incFlag = fluo[fluo.length-1] - fluo[fluo.length-2] > slope2;

        //println("Fluo #: " + fluo.length +"\tSplit: " + split+ "\tdslope: " + dslopeFlag +"\tRsq: " + RsqFlag + "\tposSlope" + posSlopeFlag+ "\tincFlag" + incFlag);

        if (dslopeFlag && RsqFlag && posSlopeFlag && incFlag) {
            Ct_linreg = fluo.length;
            //println("split: " + split);
            return Ct_linreg;
        }
    }

    return Ct_linreg;
}

double[] linreg(double[] _x, double[] _y) {
    // Solves for y = mx + b or y = Xc where c = (b, m) and first column of X is ones
    // Uses Jama Matrix class

    // Returns y-intercept, slope, 
    if (_x.length != _y.length) {
        throw new IllegalArgumentException("Arrays must be the same length.");
    }

    double[][] X_arr = new double[_x.length][2];
    double[][] y_arr = new double[_y.length][1];
    for (int i =0; i< _x.length; i++) {
        X_arr[i][0] = 1;
        X_arr[i][1] = _x[i];
        y_arr[i][0] = _y[i];
    }
    Matrix X = new Matrix(X_arr);
    Matrix y = new Matrix(y_arr);

    Matrix coeffs = X.solve(y);
    Matrix Residual = X.times(coeffs).minus(y);

    double y_mean = y.norm1()/_y.length;
    Matrix y_mean_mat = new Matrix(_y.length, 1, y_mean);
    Matrix Resmean = y.minus(y_mean_mat);

    double SS_res = 0;
    double SS_tot = 0;

    for ( int i=0; i<_x.length; i++) {
        SS_res += Math.pow(Residual.get(i, 0), 2);
        SS_tot += Math.pow(Resmean.get(i, 0), 2);
    }

    /*
  double SS_res = Math.pow(Residual.normF(), 2); // Froebenius norm returns sqrt of sum of squares 
     double SS_tot = Math.pow(Resmean.normF(), 2);
     */

    double Rsq = 1 - SS_res/SS_tot;

    double[] result = {coeffs.get(0, 0), coeffs.get(1, 0), SS_res, SS_tot, Rsq};

    return result;
}
