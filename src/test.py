import sys
import os.path
from numpy import linspace, array, float64
import matplotlib.pyplot as plt


# TESTING DATA
xData = [0, .20, .5, 1]
yData = [0., .1, .75, 1]

xData = [0,  .5, 1]
yData = [0.,  .85, 1]


# NATURAL SPLINE FROM DECIMALPY FINANCIAL PACKAGE
base_dir = os.path.abspath(os.path.dirname(__file__))
sys.path.append(os.path.join(base_dir, 'financial_ncs'))
from decimalpy import decimalfunctions as df

f_NCS_1 = df.NaturalCubicSpline(xData, yData)
xnew = linspace(0, 1, 40)
f0Lst = array([f_NCS_1(x) for x in xnew])
#plt.plot(xData, yData, 'o', xnew, f0Lst, color="green")
print xnew, f0Lst


# ANDERSON SPLINES PACKAGE
from py_spline import spline2 as sp2

# natural cubic spline
curve = sp2.NaturalCubicSpline()
for i in range(len(xData)):
    curve.knots.append(sp2.Point(xData[i], yData[i]))
inp = []
trace = []
u = 0.0
du = 0.1
lim = len(curve) + du
while (u < lim):
    #inp.append(u)
    p = curve(u)
    inp.append(p.x)
    trace.append(p.y)
    u = u + du

plt.plot(inp, trace, color="red")

# Spline
curve = sp2.BlendedQuadraticSpline()
for i in range(len(xData)):
    curve.knots.append(sp2.Point(xData[i], yData[i]))
inp = []
trace = []
u = 0.0
du = 0.1
lim = len(curve) + du
while (u < lim):
    #inp.append(u)
    p = curve(u)
    inp.append(p.x)
    trace.append(p.y)
    u = u + du

plt.plot(inp, trace, color="black")

# EPIC PACKAGE
from epics_new import spline as sp3

inp = []
trace = []
curve2 = sp3.Spline(xData, yData, low_slope=None, high_slope=None)
for i in range(100):
    inp.append(i / 100.0)
    trace.append(curve2(inp[i]))

#plt.plot(inp, trace, color="blue")


# PLOTTING
plt.xlim(0.0,1.0)
plt.ylim(-0.25,1.25)
plt.grid(True)
plt.xticks([0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0])
plt.yticks([0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0])

plt.box(on=True)

ax = plt.gca()
ax.spines['bottom'].set_position(('data',0))
ax.spines['top'].set_position(('data',1))
ax.spines['top'].set_color('black')
#plt.legend(['data', 'fitted f', 'tangent', '2. order'], loc='best')
plt.show()









