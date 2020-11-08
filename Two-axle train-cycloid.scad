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

wh = 4; ph = wh + 2;

// Pendulum period 1.5 sec
// Escape wheel (1.5 sec x 20T)/rev = 0.5 min/rev
escapeTeeth = 20;
escapePinionTeeth = 10;		// Escape wheel
escapeToothSpan=5.5;              // how many teeth the escapement spans

// Extra clearance for addendums and shafts
wheel_spacing_margin = 20;
axle_distance = 50;
escapeWheelRadius = 0.5 * axle_distance / cos(180/escapeTeeth*escapeToothSpan);

escapePitch = 2*escapeWheelRadius / escapeTeeth;  // Simulate escape wheel

// Fourth wheel: 3 min/rev
wheelTeeth4 = 60;		// Fourth wheel which turns once per (half?) minute
pinionTeeth4 = 10;
pitch4 = 2*axle_distance / (wheelTeeth4 + escapePinionTeeth);

// Third wheel: 15 min/rev
wheelTeeth3 = 50;		// Third wheel which drives the pinion of the fourth wheel
pinionTeeth3 = 10;
pitch3 = 2*axle_distance / (wheelTeeth3 + pinionTeeth4);

// Second wheel: 1 hour/rev (minute hand)
wheelTeeth2 = 40;		// Center or Second wheel which turns once per hour
pinionTeeth2 = 10;
pitch2 = 2*axle_distance / (wheelTeeth2 + pinionTeeth3);

// Motionwork wheel M: 4 hour/rev
wheelTeethM = 40;		// Motionwork minute wheel
pinionTeethM = 10;
pitchM = 2*axle_distance / (wheelTeethM + pinionTeeth2);

// Hour wheel: 12 hour/rev
wheelTeethH = 30;		// Motionwork hour wheel
pinionTeethH = 10;
pitchH = 2*axle_distance / (wheelTeethH + pinionTeethM);

// Drum: 36 hour/rev
wheelTeeth1 = 30;       // First or Great wheel attached and ratcheted to the main spring, or cable, barrel
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
    %cycloidPinionWheel(wheelTeeth4, escapePinionTeeth, pinionTeeth4, wheelTeeth3, wh, ph, pitch4, pitch3, nail_16d_diam);

    rotate([0,0,180])
    translate([pitch3*(pinionTeeth4 + wheelTeeth3)/2, 0, ph])
    //scale([1,1,-1])
    {
        rotate([0,0,time*360/6/5])
        %cycloidPinionWheel(wheelTeeth3, pinionTeeth4, pinionTeeth3, wheelTeeth2, wh, ph, pitch3, pitch2, nail_16d_diam);

        rotate([0,0,180])
        translate([pitch2*(pinionTeeth3 + wheelTeeth2)/2, 0, ph])
        {
            // Minute hand
            rotate([0,0,time*360/6/5/4])
            %cycloidPinionWheel(wheelTeeth2, pinionTeeth3, pinionTeeth2, wheelTeethM, wh, ph, pitch2, pitchM, nail_16d_diam);

            rotate([0,0,180])
            translate([pitchM*(pinionTeeth2 + wheelTeethM)/2, 0, ph])
            {
                rotate([0,0,time*360/6/5/4/4])
				%cycloidPinionWheel(wheelTeethM, pinionTeeth2, pinionTeethM, wheelTeethH, wh, ph, pitchM, pitchH, nail_16d_diam);

				rotate([0,0,180])
				translate([pitchH*(pinionTeethM + wheelTeethH)/2, 0, ph])
				{
                    // Hour hand
					rotate([0,0,time*360/6/5/4/4/3])
					%cycloidPinionWheel(wheelTeethH, pinionTeethM, pinionTeethH, wheelTeeth1, wh, ph, pitchH, pitch1, nail_16d_diam);
				
                    rotate([0,0,180])
					translate([pitch1*(pinionTeethH + wheelTeeth1)/2, 0, ph])
					{
                        // Cable drum
						!cycloidWheelDrum(wheelTeeth1, pinionTeethH, wh, pitch1, /*drumHeight*/8, nail_16d_diam);
					}
                }
            }
        }
    }
}
