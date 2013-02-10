Welcome - Guest!    Login  /  Register Now  |  Facebook  Twitter
Logo  	
Search:

    Home
    Articles
    Forum
    Interview FAQ
    Activities
    News
    Videos
    Poll
    Links
    People
    Groups

	
C++ Programming Articles
	Submit Article
Home » Articles » C++ Programming » Mathematics Program	RSS Feeds
Program to construct Natural Cubic Spline Interpolant from the given data
Posted By: Easy Tutor     Category: C++ Programming     Views: 1772

A C++ Program to construct Natural Cubic Spline Interpolant from the given data.

Download Sourcecode for Program to construct Natural Cubic Spline Interpolant from the given data  (Size: 2.07 KB)

Code for Program to construct Natural Cubic Spline Interpolant from the given data in C++ Programming

 # include <iostream.h>
 # include   <stdlib.h>
 # include   <string.h>
 # include    <stdio.h>
 # include    <conio.h>
 # include     <math.h>

 constint max_size=13;

 int n=0;

 longdouble an[max_size]={0};
 longdouble bn[max_size]={0};
 longdouble cn[max_size]={0};
 longdouble dn[max_size]={0};

 longdouble fx[max_size]={0};
 longdouble xn[max_size]={0};
 
 void show_screen( );
 void clear_screen( );
 void get_input( );
 void generate_natural_cubic_spline( );
 void show_natural_cubic_spline( );

 /*************************************************************************//*************************************************************************///------------------------------  main( )  ------------------------------///*************************************************************************//*************************************************************************/int main( )
    {
       clrscr( );
       textmode(C4350);

       show_screen( );
       get_input( );
       generate_natural_cubic_spline( );
       show_natural_cubic_spline( );

       getch( );
       return 0;
     }

 /*************************************************************************//*************************************************************************///------------------------  Funcion Definitions  ------------------------///*************************************************************************//*************************************************************************//*************************************************************************///--------------------------  show_screen( )  ---------------------------///*************************************************************************/void show_screen( )
    {
       cprintf("\n********************************************************************************");
       cprintf("**************-                                                    -************");
       cprintf("*-------------- ");

       textbackground(1);
       cprintf(" Construction of Natural Cubic Spline Interpolant ");
       textbackground(8);

       cprintf(" ------------*");
       cprintf("*-************-                                                    -**********-*");
       cprintf("*-****************************************************************************-*");

       for(int count=0;count<42;count++)
      cprintf("*-*                                                                          *-*");

       gotoxy(1,46);
       cprintf("*-****************************************************************************-*");
       cprintf("*------------------------------------------------------------------------------*");
       cprintf("********************************************************************************");

       gotoxy(1,2);
    }

 /*************************************************************************///-------------------------  clear_screen( )  ---------------------------///*************************************************************************/void clear_screen( )
    {
       for(int count=0;count<37;count++)
      {
         gotoxy(5,8+count);
         cout<<"                                                                        ";
      }

       gotoxy(1,2);
    }

 /*************************************************************************///-----------------------------  get_input( )  --------------------------///*************************************************************************/void get_input( )
    {
       do
      {
         clear_screen( );

         gotoxy(6,9);
         cout<<"Number of Distinct Data Points :";

         gotoxy(6,10);
         cout<<"ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ";

         gotoxy(27,13);
         cout<<"[ min. n = 3  |  max. n = 12 ]";

         gotoxy(6,12);
         cout<<"Enter the max. number of distinct data points = n = ";

         cin>>n;

         if(n<3 || n>12)
        {
           gotoxy(12,25);
           cout<<"Error : Wrong Input. Press <Esc> to exit or any other key";

           gotoxy(12,26);
           cout<<"        to try again.";

           n=int(getche( ));

           if(n==27)
              exit(0);
        }
      }
       while(n<3 || n>12);

       clear_screen( );

       gotoxy(6,9);
       cout<<"Data Points & Values of Function :";

       gotoxy(6,10);
       cout<<"ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ";

       gotoxy(25,12);
       cout<<"ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿";

       gotoxy(25,13);
       cout<<"³       x       ³     f(x)      ³";

       gotoxy(25,14);
       cout<<"ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´";

       gotoxy(25,15);
       cout<<"³               ³               ³";

       for(int count_1=0;count_1<n;count_1++)
      {
         gotoxy(25,(wherey( )+1));
         cout<<"³               ³               ³";

         gotoxy(25,(wherey( )+1));
         cout<<"³               ³               ³";
      }

       gotoxy(25,(wherey( )+1));
       cout<<"ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ";

       gotoxy(25,15);

       for(int count_2=0;count_2<n;count_2++)
      {
         gotoxy(25,(wherey( )+1));

         gotoxy(27,wherey( ));
         cin>>xn[count_2];

         gotoxy(43,(wherey( )-1));
         cin>>fx[count_2];
      }

       gotoxy(25,43);
       cout<<"Press any key to continue...";

       getch( );
    }

 /*************************************************************************///-----------------  generate_natural_cubic_spline( )  ------------------///*************************************************************************/void generate_natural_cubic_spline( )
    {
       // set ai=f(xi)     for i=0,1,2,3,...,nfor(int count_1=0;count_1<n;count_1++)
      an[count_1]=fx[count_1];

       longdouble temp_1[max_size]={0};      // hilongdouble temp_2[max_size]={0};      // ailongdouble temp_3[max_size]={0};      // lilongdouble temp_4[max_size]={0};      // uilongdouble temp_5[max_size]={0};      // zi// set hi=x(i+1)-xi     for i=0,1,2,3,...,n-1for(int count_2=0;count_2<(n-1);count_2++)
      temp_1[count_2]=(xn[count_2+1]-xn[count_2]);

       // set ai=(3/hi)*[a(i+1)-ai]-[3/h(i-1)]*[ai-a(i-1)]     for i=1,1,2,3,...,n-1for(int count_3=1;count_3<(n-1);count_3++)
      temp_2[count_3]=(((3/temp_1[count_3])*(an[(count_3+1)]-an[count_3]))-((3/(temp_1[(count_3-1)])*(an[count_3]-an[(count_3-1)]))));

       // set li0=1//     ui0=0//     zi0=0
       temp_3[0]=1;
       temp_4[0]=0;
       temp_5[0]=0;

       // for i=1,1,2,3,...,n-1 ,set//    li=[2*{x(i+1)-x(i-1)}]-[h(i-1)*u(i-1)]//    ui=hi/li//    zi=[ai-{h(i-1)*z(i-1)}]/lifor(int count_4=1;count_4<(n-1);count_4++)
      {
         temp_3[count_4]=((2*(xn[(count_4+1)]-xn[(count_4-1)]))-(temp_1[(count_4-1)]*temp_4[(count_4-1)]));
         temp_4[count_4]=(temp_1[count_4]/temp_3[count_4]);
         temp_5[count_4]=((temp_2[count_4]-(temp_1[(count_4-1)]*temp_5[(count_4-1)]))/temp_3[count_4]);
      }

       // set lin=1//     zin=0//     cn=0
       temp_3[(n-1)]=1;
       temp_5[(n-1)]=0;
       cn[(n-1)]=0;

       // for i=n-1,n-2,...,0   , set//     ci=zi-[ui*c(i+1)]//     bi=[a(i+1)-ai]/[hi-{hi*{c(i+1)+{2*ci}}/3]//     di=[c(i+1)-ci]/[3*hi]for(int count_5=(n-2);count_5>=0;count_5--)
      {
         cn[count_5]=(temp_5[count_5]-(temp_4[count_5]*cn[(count_5+1)]));
         bn[count_5]=(((an[(count_5+1)]-an[count_5])/temp_1[count_5])-((temp_1[count_5]*(cn[(count_5+1)]+(2*cn[count_5])))/3));
         dn[count_5]=((cn[(count_5+1)]-cn[count_5])/(3*temp_1[count_5]));
      }
    }

 /*************************************************************************///--------------------  show_natural_cubic_spline( )  -------------------///*************************************************************************/void show_natural_cubic_spline( )
    {
       clear_screen( );

       gotoxy(6,9);
       cout<<"Natural Cubic Spline :";

       gotoxy(6,10);
       cout<<"ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ";

       gotoxy(10,12);
       cout<<"The required Cubic Polynomials are :";

       for(int count=0;count<(n-1);count++)
      {
         gotoxy(10,(15+(count*2)));
         cout<<"S"<<count<<"(x) =  ";

         longdouble aix=0;
         longdouble bix=0;
         longdouble cix=0;
         longdouble dix=0;

         aix=(an[count]-(bn[count]*xn[count])+(cn[count]*powl(xn[count],2))-(dn[count]*powl(xn[count],3)));
         bix=(bn[count]-(2*cn[count]*xn[count])+(3*dn[count]*powl(xn[count],3)));
         cix=(cn[count]-(3*dn[count]*xn[count]));
         dix=dn[count];

         cout<<aix;

         if(bix>=0)
        cout<<" + ";

         else
        cout<<" - ";

         cout<<fabsl(bix)<<"x";

         if(cix>=0)
        cout<<" + ";

         else
        cout<<" - ";

         cout<<fabsl(cix)<<"x2";

         if(dix>=0)
        cout<<" + ";

         else
        cout<<" - ";

         cout<<fabsl(dix)<<"x3";
      }

       gotoxy(1,2);
    }

ads not by this site
	  	
ads not by this site
Share:   0 0 168
 

Previous Post:
Program to determine whether the given function is a Cubic Spline or not
 
Next Post:
Program to construct Clamped Cubic Spline Interpolant from the given data
 
 

Didn't find what you were looking for? Find more on Program to construct Natural Cubic Spline Interpolant from the given data Or get search suggestion and latest updates.

Easy Tutor
	
Easy Tutor author of Program to construct Natural Cubic Spline Interpolant from the given data is from United States. Easy Tutor says

Hello Friends,

I am Free Lance Tutor, who helped student in completing their homework.

I have 4 Years of hands on experience on helping student in completing their homework. I also guide them in doing their final year projects.

I have share many programs on this website for everyone to use freely, if you need further assistance, than please contact me on easytutor.2ya [at the rate] gmail [dot] com

I have special discount scheme for providing tutor services. I am providing tutor service to students from various contries, currently most of my students are from United States, India, Australia, Pakistan, Germany, UK and Canada.

I am also here to expand my technical network to receive more opportunity in my career, make friends to help them in resolving their technical problem, learn and share my knowledge, If you like to be my friend, Please send me friend request.

Thanks,
Happy Programming :)
 
View All Articles

Related Articles and Code:

    Program to construct Clamped Cubic Spline Interpolant from the given data
    Program to determine whether the given function is a Cubic Spline or not
    Program to construct Newton's Forward Difference Interpolation Formula from the given distinct equally spaced data points
    Program to construct Newton's Backward Difference Interpolation Formula from the given distinct equally spaced data points
    Program to construct Lagranges's Interpolation Formula from the given distinct data points.
    Program to construct and display the Divided Difference Table from the given distinct data points.
    Program to construct Newton's Divided Difference Interpolation Formula from the given distinct data points and estimate the value of the function
    Example of natural join
    Program to draw a 3D Cubic Bezier Curve
    Program to draw a Cubic Bezier Curve
    An applet program to display barchart of given data
    An applet program to draw Polygon Graph with given data
    Program of histogram for given data element
    For a certain electrical circuit with an distance L and resistance R, the damped natural frequency is given by Frequency = sqrt((1/L*C)
    Program to read a Non Linear Function, construct and display the Difference Table
    Program to illusrate data conversion b/w built-in data types
    Program to illusrate data conversion user defined data types using functions
    Program to illusrate data conversion user defined data types using constructor
    Program to estimate value of First Derivative of the function at the given points from the given data using Backward Difference Formula , Forward diff
    Program to estimate the value of First Derivative of the function at the given points from the given data using Central Difference Formula

 
Other Interesting Articles in C++ Programming:

    Program of construction overloading
    Code for finding a no in a binary search tree and displaying its level where it is found (root is at zero level)
    Program to add two numbers
    Program that reads marks of a students and computes and displays grade
    Program that displays checkbox like windows
    Comment line in c
    Program to show the implementation of Liang-Barsky Line Clipping Algorithm
    Program to illustrate the implementation of arrays as a Circular Queue ( in graphics )
    Program that changes an infix expression to a postfix expression according
    Defines and differentiates sequential search and binary search
    Program to estimate the Differential value of the function using Euler Method
    Program of addition and subtraction of large numbers
    Program to construct Newton's Forward Difference Interpolation Formula from the given distinct equally spaced data points
    Program that take font and background color and text input from a user and display it in right aligned
    Program to draw a Circular Arc using Trigonometric Method
    Program to implement the Kurskal's Algorithm to solve Minimum Cost Spanning Tree Problem (MST)
    Program to illustrate the use of call-by-refrence method in functions
    Program to maintain employee information also illustrate virtual class and inheritance
    Program to illustrate pointers and an array of structure
    Program of circular link list

 
Please enter your Comment

    Comment should be atleast 30 Characters.
    Please put code inside [Code] your code [/Code].

 Please login to post comment

 
No Comment Found, Be the First to post comment!
 

     C++ Programming
             View All
             Homework Help
             Data File Structure
             Computer Graphics
             Projects
             Beginners
             Object Oriented Progra...
             Algorithms
             Miscellaneous Problems
             Numerical Analysis
             Mathematics Program
             Mouse Programming
             Parsing
             Scanner
             Interview FAQ
     Assembly Language
     Artificial Intelligence
     C Programming
     Visual C++
     OOAD
     Cobol
     Java
     SQL Server
     Asp.net MVC
     Rest and WCF Services
     Entity Framework
     Knockout.Js
     Unix / Linux / Ubuntu
     Networking
     OOPs Concept
     HTML
     Dos
     SQL
     System Analysis & Design
     Gadgets
     Internet
     CSS
     Javascript
     .Net Framework
     Asp.net
     C#
     VB.Net
     Python
     Perl
     Oracle
     Software Engineering
     RDBMS Terms
     AJAX Framework
     Design Pattern
     UML
     WPF
     WCF
     SEO
     PowerShell
     Visual Studio
     WWF
     BizTalk Server
     Azure
     General
     Testing
     Online Certifications
     PHP
     My SQL
     LinQ
     Project Management
     Silverlight
     XML
     MS Office
     Windows OS
     DHTML
     Sharepoint

 
 
 
 
RSS Feeds:	
Articles |  Forum |  New Users |  Activities |  Interview FAQ |  Poll |  Hotlinks
Social Networking:	
Hall of Fame  |  Facebook  |  Twitter  |  LinkedIn
Terms:	
Terms of Use  |  Privacy Policy |  Contact us
 
DMCA.com
 
Copyright © 2008-2012

