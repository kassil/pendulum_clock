// Lay out a two-axle wheel train
use <Utilities.scad>
include <Hardware.scad>
use <myClockworkLibrary.scad>

// Quality settings
$fs = 0.5;                  // minimum size of an arc fragment
$fa = 360/128;              // minimum angle of an arc fragment

// When a pair of gears are meshed so that their reference circles are in contact, the center distance (a) is half the sum total of their reference diameters.
// a = ( d1 + d2 ) / 2

/*
120:1 reduction by:

60  50  40
--  --  --
10  10  10
*/

time = 0;

wh = 3; ph = wh + 2;

escapeTeeth = 20;
escapePinionTeeth = 10;		// Escape wheel
escapeToothSpan=5.5;              // how many teeth the escapement spans

// Extra clearance for addendums and shafts
wheel_spacing_margin = 20;
axle_distance = 50;
escapeWheelRadius = 0.5 * axle_distance / cos(180/escapeTeeth*escapeToothSpan);

escapePitch = 2*escapeWheelRadius / escapeTeeth;  // Simulate escape wheel

wheelTeeth4 = 60;		// Fourth wheel which turns once per (half?) minute
pinionTeeth4 = 10;
pitch4 = 2*axle_distance / (wheelTeeth4 + escapePinionTeeth);

wheelTeeth3 = 50;		// Third wheel which drives the pinion of the fourth wheel
pinionTeeth3 = 10;
pitch3 = 2*axle_distance / (wheelTeeth3 + pinionTeeth4);

wheelTeeth2 = 40;		// Center or Second wheel which turns once per hour
pinionTeeth2 = 10;
pitch2 = 2*axle_distance / (wheelTeeth2 + pinionTeeth3);

wheelTeethM = 40;		// Motionwork minute wheel
pinionTeethM = 10;
pitchM = 2*axle_distance / (wheelTeethM + pinionTeeth2);

wheelTeethH = 30;		// Motionwork hour wheel
pinionTeethH = 10;
pitchH = 2*axle_distance / (wheelTeethH + pinionTeethM);

wheelTeeth1 = 96;       // First or Great wheel attached and ratcheted to the main spring, or cable, barrel
pitch1 = 2*axle_distance / (wheelTeeth1 + pinionTeethH);


echo("Axle distance:",axle_distance, "Escape radius:",escapeWheelRadius);
echo("Pitch:",pitch1,pitchH,pitchM,pitch2,pitch3,pitch4,escapePitch);


// Placeholder for 20T escape wheel with d ~= 81 mm
rotate([0,0,time*360])
%involutePinionWheel(escapeTeeth, escapePinionTeeth, wh, ph, escapePitch, pitch4, nail_16d_diam);
//cylinder(h=wh,r=escapeWheelRadius);
//translate([0,0,wh])
//    cylinder(h=ph,d=escapePinionTeeth*pitch4);

translate([pitch4*(escapePinionTeeth + wheelTeeth4)/2, 0, ph])
{
    rotate([0,0,time*360/6])
    involutePinionWheel(wheelTeeth4, pinionTeeth4, wh, ph, pitch4, pitch3, nail_16d_diam);
    
    rotate([0,0,180])
    translate([pitch3*(pinionTeeth4 + wheelTeeth3)/2, 0, ph])
    //scale([1,1,-1])
    {
        rotate([0,0,time*360/6/5])
        involutePinionWheel(wheelTeeth3, pinionTeeth3, wh, ph, pitch3, pitch2, nail_16d_diam);

        rotate([0,0,180])
        translate([pitch2*(pinionTeeth3 + wheelTeeth2)/2, 0, ph])
        {
            // Minute hand
            rotate([0,0,time*360/6/5/4])
            involutePinionWheel(wheelTeeth2, pinionTeeth2, wh, ph, pitch2, pitchM, nail_16d_diam);

            rotate([0,0,180])
            translate([pitchM*(pinionTeeth2 + wheelTeethM)/2, 0, ph])
            {
                rotate([0,0,time*360/6/5/4/4])
				involutePinionWheel(wheelTeethM, pinionTeethM, wh, ph, pitchM, pitchH, nail_16d_diam);

				rotate([0,0,180])
				translate([pitchH*(pinionTeethM + wheelTeethH)/2, 0, ph])
				{
                    // Hour hand
					rotate([0,0,time*360/6/5/4/4/3])
					involutePinionWheel(wheelTeethH, pinionTeethH, wh, ph, pitchH, pitch1, nail_16d_diam);
				
                    rotate([0,0,180])
					translate([pitch1*(pinionTeethH + wheelTeeth1)/2, 0, ph])
					{
                        // Cable drum
						involuteWheelDrum(wheelTeeth1, wh, pitch1, 8, nail_16d_diam);
					}
                }
            }
        }
    }
}
