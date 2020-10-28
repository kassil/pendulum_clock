/* Note from the author of the clockwork library Mathieu Glachant:
Modified the escapement wheel profile to support club teeth (still defaults to ratchet teeth)
Club tooth parameters accessible in tooth(), ringtooth(), escapementWheel() and pinionEscapementWheel()
Modified escapement to control angle of impulse faces on the pallets, defaults to 45o as per ideal Graham escapement w/o club teeth
Escapement will work if impulse face angles are set to 45o minus tooth lean plus club angle, and drop can be controlled via face angle
*/

include <clockworkLibrary.scad>
include <Locations.scad>
include <Hardware.scad>
use <rounded.scad>

// Quality settings
$fs = 0.5;                  // minimum size of an arc fragment
$fa = 360/128;              // minimum angle of an arc fragment

//Escape_pinionWheel();

//animated();
//escapeWheel();
//anchor(anchorBore/2,0);
//assembledPivotBelow(time);
//assembledPivotAbove();

//translate([4*escapeRadius,0,0])
laidOutToPrint();
//anchorAxle();

//
// Parameters used by all local modules
//
sleeveThickness=2;	// thickness of the sleeves fitting over the pins, or over each other
clearance=0.05;			// clearance between pin and sleeve, or between sleeve and sleeve
zClearance=0.25;

// how many teeth the escapement spans: choose a 4.5 tooth span for a wide pendulum swing, or an 11.5 tooth span for a narrow swing. It is generally accepted that a 7.5 tooth span gives the most desirable results in practice for a 30 tooth escape wheel.
escapeNumberTeeth=20;           // number of teeth in the escapement wheel
escapeToothSpan=5.5;              // how many teeth the escapement spans

// Distance between anchor and wheel centres:
//escapeAxleDist = norm(pendulum_axle_posn - escape_axle_posn);
escapeAxleDist = 50;
// Formula relates distance between centres to the escape wheel overall radius:
// y = 2*escapeRadius*cos(180/escapeNumberTeeth*escapeToothSpan);
// Escapement wheel radius, including the teeth:
escapeRadius = escapeAxleDist / (2* cos(180/escapeNumberTeeth*escapeToothSpan));

escapeWheelThickness = 4;
anchorThickness = 5;

negativeMargin=5e-3;

escapeToothLean=30;            	// how much the tooth leans over, clockwise, in degrees
escapeClubSize=0.17;        	// relative size of the club on the teeth
escapeClubAngle=22.5;          	// impulse face angle

anchorDriveSize = 8;
anchorDriveHeight = 10;
anchorBore=nail_16d_diam; // Diameter of the escapement (anchor) bore
anchorAxleDepth = 5 + 8 + 3;  // Determined by space in the frame.
	
// Animation parameters:
//
//wheel_phase_angle = 5;  //faceAngle=4
wheel_phase = 0.07;  // num teeth, faceAngle=6
time = 0.50;
function anchor_angle(t) = maxSwing * sin(t * 360);
//function inv_anchor_angle(a) = asin(a


echo("Escape axle distance:", escapeAxleDist);
echo("Escape radius:",escapeRadius);





module Escape_pinionWheel()
{
    wheelTeeth4 = 60;		// Fourth wheel which turns once per (half?) minute
    escapePinionTeeth = 10;
    pitch4 = 2*escapeAxleDist / (wheelTeeth4 + escapePinionTeeth);
    echo("Escape pinion pitch:",pitch4);
    
	// Escapement Wheel Parameters
	//
	escapeRimWidth=4;           // width of the escapement wheel's rim
	numberSpokes=5;             // number of spokes in the escapement wheel
	spokeWidth=1.25;            // width of the escapement wheel's spokes
	drumHeight = 0;
	small_addendum_radius=1.11 * escapePinionTeeth * pitch4 / 2;
	escapeToothLength=15;           // length of the tooth along longest face and to inner radius of the wheel
	escapeToothSharpness=10;       	// the angle between the two side of each tooth
	escapeWheelBore = nail_6d_diam + 0.05;
	escapePinionThick = 6;

    // Wheel and coaxial pinion
    difference()
    {
        union()
        {
            escapementWheel(escapeRadius,
                escapeRimWidth,
                drumHeight,
                escapeWheelThickness,
                escapeNumberTeeth,
                escapeToothLength,
                escapeToothLean,
                escapeToothSharpness,
                numberSpokes,
                spokeWidth,
                small_addendum_radius,  // wheel hub diam as big as coaxial pinion
                0, //bore_radius, see below
                escapeClubSize,
                escapeClubAngle);

            // DXF file origin is that of a Z60 wheel
            translate([-50, 0, escapeWheelThickness - negativeMargin])
            linear_extrude(escapePinionThick)
            import("Gears/Cycloid-M1.429-Z60Z10 Pinion 50mm centre.dxf");
        }

        // Bore
        cylinder(h=3 * (escapePinionThick + escapeWheelThickness), d=escapeWheelBore, center=true);
    }
}


module Escape_anchor()
{
	// Escapement (Anchor) Parameters
	//
	faceAngle=6;                // how many degrees the impulse face covers seen from the hub of the escapement wheel
	armAngle=22;                // angle of the escapement's arms
	maxSwing=8;             	// maximum swing of the escapement, in degrees
	armWidth=4;             	// width of the escapement's arms

	//pin_radius=anchorBore;
    //bore_radius=pin_radius+sleeve_level*sleeveThickness+clearance;
	
	difference()
	{
		union()
		{
			escapement(
				escapeRadius,
				anchorThickness,
				faceAngle,
				armAngle,
				armWidth,
				escapeNumberTeeth,
				escapeToothSpan,
				0,//anchorHubDiam/2,
				0,
				0,//anchorBore/2,
				false, //negativeSpace,
				negativeMargin,
				maxSwing,
				entryPalletAngle=45-escapeToothLean+escapeClubAngle,
				exitPalletAngle=45-escapeToothLean+escapeClubAngle);
				
            // Couple to pendulum axle
			translate([0,0,anchorThickness])
            scale([1,1,-1])
			{
                linear_extrude(anchorThickness+anchorDriveHeight-zClearance)
                rounded_square(anchorDriveSize - clearance, 1);
			}
			
		}
		
		// Anchor bore
		cylinder(h=3*(anchorThickness+anchorDriveHeight),d=anchorBore,center=true);
	}
}

module anchorAxle()
{
    pendulumThick = 4;
    assert(anchorAxleDepth + 1 > anchorDriveHeight);
    driveOutsideSize = 16;
    scale([1,1,-1])
    {
        difference()
        {
            // Box for axle 
            translate([0,0,anchorAxleDepth/2])
                cube([driveOutsideSize,driveOutsideSize,anchorAxleDepth],center=true);
            
            // Cut out the square drive
            translate([0,0,-1]) linear_extrude(anchorDriveHeight+zClearance+1)
            square(anchorDriveSize + clearance, center=true);
            // Bore for axle
            cylinder(h=3*anchorAxleDepth, d=anchorBore,center=true);
        }
        
        // Suspend from the box a miniature pendulum to which we will screw a
        // full-size wooden pendulum.
        filletRadius = 5;
        pendulumLength = 3*filletRadius + 50;
        scale([1,-1,1])
        translate([0,driveOutsideSize/2,anchorAxleDepth-pendulumThick])
        {
            union()
            {
                difference()
                {
                    // Pendulum mount face
                    union()
                    {
                        translate([-driveOutsideSize/2, 0])
                        cube([driveOutsideSize,pendulumLength,pendulumThick]);
                        
                        // At the bottom of the pendulum bracket there is a wide face to
                        // prevent twisting.
                        hull()
                        {
                            for(i=[-1:2:2])
                            {
                                pendulumMaxWidth = 28;
                                translate([i*(pendulumMaxWidth-2*filletRadius),pendulumLength-filletRadius])
                                    cylinder(h=pendulumThick, r=filletRadius);
                            }
                        }
                    }
                    
                    
                    // Holes
                    for(y = [2*filletRadius, pendulumLength-filletRadius])
                    {
                        translate([0,y])
                        cylinder(3*pendulumThick, d=nail_6d_diam,center=true);
                    }
                }

                rotate([0,90,0])
                {
                    fillet3d(filletRadius, driveOutsideSize);
                    // Gussets
                    for(i=[-1:2:2])
                    {
                        translate([0,0,i*(driveOutsideSize - 1)/2])
                        fillet3d(2*(anchorDriveHeight-pendulumThick), 1);
                    }
                }
            }
        }
    }   
}

//
// Assembly modules
//

module assembledPivotAbove()
{
    Escape_pinionWheel();

    // Prepare our frame of reference.
    placeEscapement(0,escapeRadius,escapeNumberTeeth,escapeToothSpan)
    {
        Escape_anchor();
    }

    translate([0,escapeAxleDist,-1])
        anchorAxle();
}

module assembledPivotBelow(time)
{
    rotate([0,0,(time + wheel_phase)*360/escapeNumberTeeth])
    escapeWheel();

    // Prepare our frame of reference.
    placeEscapement(180,escapeRadius,escapeNumberTeeth,escapeToothSpan)
    union()
    {
        anchorPendulumPivotsBelow(anchorBore/2,0);
        frame();
    }
}

module laidOutToPrint()
{
    !Escape_pinionWheel();

    rotate([0,180,0]) // Flat face on bed
    translate([0,1.2*escapeAxleDist,-anchorThickness])
	Escape_anchor();
    
    translate([1.2*escapeAxleDist,0,anchorAxleDepth])
    anchorAxle();
}

//
// Part modules
//


module anchorPendulumPivotsBelow(pin_radius,sleeve_level)
{
	// Pendulum params
	pendulumKink = 0;
	pendulumLength=50;         	// length of the pendulum
	pendulumWidth=2*armWidth;     	// width of the pendulum
	//pendulumHeight=5;  // height of the pendulum
	//snapFitHeight = 4; //??

    bore_radius=pin_radius+sleeve_level*sleeveThickness+clearance;
    sleeve_radius=pin_radius+(sleeve_level+1)*sleeveThickness;

    //rotate([0,0,anchor_angle(time)])
    union()
    {
		difference()
		{
			union()
			{
				// Long member between hub and weight
				translate([bore_radius,-armWidth,0])
				{
				cube([pendulumLength-(bore_radius),2*armWidth,girder_thick]);
				cube([pendulumLength-(bore_radius),girder_thick,hubHeight]);
				cube([5,2*armWidth,hubHeight]);
				}

				if(0)
				{
					// Rectangle weight
					translate([pendulumLength,0,girder_thick/2])
					{
						translate([-pendulumWidth/2,-pendulumWidth/2,-hubHeight/2])
						cube([pendulumWidth/2,pendulumWidth,hubHeight]);
					}
				}
				else
				{
					// Top mount hole
					translate([8,0,0])
					cylinder(h=hubHeight,d=pendulumWidth);
					
					// Circular weight
					translate([pendulumLength,0,0])
					cylinder(h=hubHeight,d=pendulumWidth);
				}
			}
			
			// Top mount hole
			translate([8,0,0])
			cylinder(h=3*hubHeight,d=nail_6d_diam,center=true);
			
			// Bottom mounting hole
			translate([pendulumLength,0,0])
			cylinder(h=3*hubHeight,d=nail_6d_diam,center=true);
		}

		anchor(bore_radius,0);
    }
}

module animated()
{
    // Wheel and coaxial pinion
    unlock = 0.08;   // Wheel unlocks at this time / pendulum angle
    teeth = 1 / 4 * lookup( 2 * $t, [
        [0,         -1  ],
        [  unlock,  0  ],
        [1-unlock,  0  ],
        [1+unlock,  2  ],
        [2-unlock,  2  ],
        [2+unlock,  4  ]]);
    echo("t=",360*$t," pendulum=",anchor_angle($t)," teeth=",teeth);
    rotate([0,0, -360/escapeNumberTeeth * (wheel_phase+teeth)])
    escapementWheel(escapeRadius,
        escapeRimWidth, //rimWidth,
        0, //drumHeight,
        escapeThickness,
        escapeNumberTeeth,
        escapeToothLength,
        escapeToothLean,
        escapeToothSharpness,
        numberSpokes,
        spokeWidth,
        0, //small_addendum_radius
        0, //bore_radius, see below
        escapeClubSize,
        escapeClubAngle);

    placeEscapement(180,escapeRadius,escapeNumberTeeth,escapeToothSpan)
    rotate([0,0, anchor_angle($t)])
    {
        escapement(
            escapeRadius,
            escapeThickness,
            faceAngle,
            armAngle,
            armWidth,
            escapeNumberTeeth,
            escapeToothSpan,
            armWidth, //escapeHubWidth,
            hubHeight,
            1, //bore_radius,
            false, //negativeSpace,
            negativeMargin,
            maxSwing,
            entryPalletAngle=45-escapeToothLean+escapeClubAngle,
            exitPalletAngle=45-escapeToothLean+escapeClubAngle);
        
        pendulumPivotsAbove();
    }
}
