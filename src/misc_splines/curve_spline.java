
public static double[] secondDerivative(Point... P) {
	int n = P.length;
	double yp1=0.0; 
	double ypn=0.0;
 
	// build the tridiagonal system 
	// (assume 0 boundary conditions: y2[0]=y2[-1]=0) 
	double[][] matrix = new double[n][3];
	double[] result = new double[n];
	matrix[0][1]=1;
	for(int i=1;i<n-1;i++) {
		matrix[i][0]=(double)(P[i].x-P[i-1].x)/6;
		matrix[i][1]=(double)(P[i+1].x-P[i-1].x)/3;
		matrix[i][2]=(double)(P[i+1].x-P[i].x)/6;
		result[i]=(double)(P[i+1].y-P[i].y)/(P[i+1].x-P[i].x) - (double)(P[i].y-P[i-1].y)/(P[i].x-P[i-1].x);
	}
	matrix[n-1][1]=1;
 
	// solving pass1 (up->down)
	for(int i=1;i<n;i++) {
		double k = matrix[i][0]/matrix[i-1][1];
		matrix[i][1] -= k*matrix[i-1][2];
		matrix[i][0] = 0;
		result[i] -= k*result[i-1];
	}
	// solving pass2 (down->up)
	for(int i=n-2;i>=0;i--) {
		double k = matrix[i][2]/matrix[i+1][1];
		matrix[i][1] -= k*matrix[i+1][0];
		matrix[i][2] = 0;
		result[i] -= k*result[i+1];
	}
 
	// return second derivative value for each point P
	double[] y2 = new double[n];
	for(int i=0;i<n;i++) y2[i]=result[i]/matrix[i][1];
	return y2;
}


 
Point[] points = /* liste de points, triés par "x" croissants */
 
double[] sd = secondDerivative(points);
 
for(int i=0;i<points.length-1;i++) {
   	Point cur   = points[i];
    	Point next  = points[i+1];
 
    	for(int x=cur.x;x<next.x;x++) {
		double t = (double)(x-cur.x)/(next.x-cur.x);
 
		double a = 1-t;
		double b = t;
		double h = next.x-cur.x;
 
		double y= a*cur.y + b*next.y + (h*h/6)*( (a*a*a-a)*sd[i]+ (b*b*b-b)*sd[i+1] );
 
		draw(x,y); /* ou tout autre utilisation */
	}
}
