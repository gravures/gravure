static void
curves_plot_curve_u16(
		   PixelRow      *curve,
		   gdouble       *pt1,             
		   gdouble       *pt2,
		   gdouble       *pt3, 
		   gdouble       *pt4
			)
{
  CRMatrix geometry;
  CRMatrix tmp1, tmp2;
  CRMatrix deltas;
  double x, dx, dx2, dx3;
  double y, dy, dy2, dy3;
  double d, d2, d3;
  int lastx, lasty;
  int newx, newy;
  int i;
  guint16* curve_data = (guint16*) pixelrow_data (curve);

  /* construct the geometry matrix from the segment */
  for (i = 0; i < 4; i++)
    {
      geometry[i][2] = 0;
      geometry[i][3] = 0;
    }

  for (i = 0; i < 2; i++)
    {
      geometry[0][i] = pt1[i];
      geometry[1][i] = pt2[i];
      geometry[2][i] = pt3[i];
      geometry[3][i] = pt4[i];
    }

  /* subdivide the curve 70000 times */
  /* n can be adjusted to give a finer or coarser curve */
  d = 1.0 / 200000;
  d2 = d * d;
  d3 = d * d * d;

  /* construct a temporary matrix for determining the forward differencing deltas */
  tmp2[0][0] = 0;     tmp2[0][1] = 0;     tmp2[0][2] = 0;    tmp2[0][3] = 1;
  tmp2[1][0] = d3;    tmp2[1][1] = d2;    tmp2[1][2] = d;    tmp2[1][3] = 0;
  tmp2[2][0] = 6*d3;  tmp2[2][1] = 2*d2;  tmp2[2][2] = 0;    tmp2[2][3] = 0;
  tmp2[3][0] = 6*d3;  tmp2[3][1] = 0;     tmp2[3][2] = 0;    tmp2[3][3] = 0;

  /* compose the basis and geometry matrices */
  curves_CR_compose (CR_basis, geometry, tmp1);

  /* compose the above results to get the deltas matrix */
  curves_CR_compose (tmp2, tmp1, deltas);

  /* extract the x deltas */
  x = deltas[0][0];
  dx = deltas[1][0];
  dx2 = deltas[2][0];
  dx3 = deltas[3][0];

  /* extract the y deltas */
  y = deltas[0][1];
  dy = deltas[1][1];
  dy2 = deltas[2][1];
  dy3 = deltas[3][1];

  lastx = BOUNDS (x, 0, 65535);
  lasty = BOUNDS (y, 0, 65535);

  curve_data[lastx] = lasty;

  /* loop over the curve */
  for (i = 0; i < 200000; i++)
    {
      /* increment the x values */
      x += dx;
      dx += dx2;
      dx2 += dx3;

      /* increment the y values */
      y += dy;
      dy += dy2;
      dy2 += dy3;

      newx = BOUNDS ((ROUND (x)), 0, 65535);
      newy = BOUNDS ((ROUND (y)), 0, 65535);

      /* if this point is different than the last one...then draw it */
      if ((lastx != newx) || (lasty != newy))
	curve_data[newx] = newy;

      lastx = newx;
      lasty = newy;
    }
}
