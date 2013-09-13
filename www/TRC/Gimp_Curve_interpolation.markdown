# Gimp Curve interpolation
Created dimanche 27 janvier 2013

/*

* This function calculates the curve values between the control points
* p2 and p3, taking the potentially existing neighbors p1 and p4 into
* account.

 *

* This function uses a cubic bezier curve for the individual segments and
* calculates the necessary intermediate control points depending on the
* neighbor curve control points.

 */

