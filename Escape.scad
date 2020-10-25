/* Note from the author of the clockwork library Mathieu Glachant:
Modified the escapement wheel profile to support club teeth (still defaults to ratchet teeth)
Club tooth parameters accessible in tooth(), ringtooth(), escapementWheel() and pinionEscapementWheel()
Modified escapement to control angle of impulse faces on the pallets, defaults to 45o as per ideal Graham escapement w/o club teeth
Escapement will work if impulse face angles are set to 45o minus tooth lean plus club angle, and drop can be controlled via face angle
*/

include <clockworkLibrary.scad>
include <../Locations.scad>
include <../Hardware.scad>

// Distance between anchor and wheel centres:
//
escape_axle_posn = [  0,       72];
pendulum_axle_posn = [  0,  122.28];
//axle_separation = norm(pendulum_axle_posn - escape_axle_posn);
axle_separation = 50;
// Formula relates distance between centres to the escape wheel overall radius:
// y = 2*escapeRadius*cos(180/escapeNumberTeeth*toothSpan);

// Distance between anchor and wheel:
echo("Bore separation",axle_separation);

spacer=1;			// height of the drum between gears in a pinion wheel
sleeve_extension=0;
negativeMargin=5e-3;
sleeveThickness=2;	// thickness of the sleeves fitting over the pins, or over each other
tightFit=0.25;			// clearance between hands and sleeves
clearance=0.25;			// clearance between pin and sleeve, or between sleeve and sleeve

escapeRimWidth=4;         // width of the escapement wheel's rim
numberSpokes=5;             // number of spokes in the escapement wheel
spokeWidth=1.5;             // width of the escapement wheel's spokes

// Escapement (Anchor) Parameters
//
// how many teeth the escapement spans: choose a 4.5 tooth span for a wide pendulum swing, or an 11.5 tooth span for a narrow swing. It is generally accepted that a 7.5 tooth span gives the most desirable results in practice for a 30 tooth escape wheel.
toothSpan=3.5;              // how many teeth the escapement spans
faceAngle=6;                // how many degrees the impulse face covers seen from the hub of the escapement wheel
armAngle=24;                // angle of the escapement's arms
maxSwing=8;             	// maximum swing of the escapement, in degrees
armWidth=4;             	// width of the escapement's arms
escapeHubWidth=10;            	// width of the escapement's hub
escapeWheelBore = nail_6d_diam + 0.05;
escapeThickness = 4;
escapePinionThick = 6;
hubHeight=escapeThickness + 1;          // thickness of the escapement's hub

// Escapement Wheel Parameters
//
escapeNumberTeeth=15;           // number of teeth in the escapement wheel
escapeToothLength=15;           // length of the tooth along longest face and to inner radius of the wheel
escapeToothLean=33;            	// how much the tooth leans over, clockwise, in degrees
escapeToothSharpness=10;       	// the angle between the two side of each tooth
escapeClubSize=0.2;            	// relative size of the club on the teeth
escapeClubAngle=22.5;          	// impulse face angle

escapeRadius = axle_separation / (2* cos(180/escapeNumberTeeth*toothSpan)); // escapement wheel radius, including the teeth

anchorHubDiam=11;           	// width (diameter) of the escapement's hub
anchorHexDiam = 8/sin(60);
anchorHexHeight = 10;
anchorBore=nail_16d_diam + 0.05; // Diameter of the escapement (anchor) bore

// Pendulum stuff
pendulumKink = 0;
pendulumLength=80;         	// length of the pendulum
pendulumWidth=24;     	// width of the pendulum
//pendulumHeight=5;  // height of the pendulum
//snapFitHeight = 4; //??

// Animation parameters:
//
//wheel_phase_angle = 5;  //faceAngle=4
wheel_phase_angle = 6;  //faceAngle=6
function anchor_angle(t) = maxSwing * sin($t * 360);
//function inv_anchor_angle(a) = asin(a



//animated();

//escapeWheel();
//anchor(nail_16d_diam,0);
assembledPivotBelow();
//assembledPivotAbove();

//translate([2.5*escapeRadius,0,0])
//laidOutToPrint();





//
// Assembly modules
//

module assembledPivotAbove()
{
    rotate([0,0,180])
    {
        escapeWheel();

        // Prepare our frame of reference.
        placeEscapement(180,escapeRadius,escapeNumberTeeth,toothSpan)
        union()
        {
            anchor(nail_16d_diam,0);
            frame();

            rotate([180,0,0])
            translate([0,0,0.5])
            {
                pendulum();
            }
        }
    }
}

module assembledPivotBelow()
{
    escapeWheel();

    // Prepare our frame of reference.
    placeEscapement(180,escapeRadius,escapeNumberTeeth,toothSpan)
    union()
    {
        anchor(nail_16d_diam,0);
        frame();
    }
}

module laidOutToPrint()
{
    rotate([0,0,180])
    ;//escapeWheel();

    translate([0,2*escapeRadius,0])
    rotate([0,180,0]) anchor(nail_16d_diam,0);


    //translate([2*escapeRadius,2*escapeRadius,0]) rotate([180,0,0]) pendulum();
}

//
// Part modules
//

module anchor(pin_radius,sleeve_level)
{
    bore_radius=pin_radius+sleeve_level*sleeveThickness+clearance;
    sleeve_radius=pin_radius+(sleeve_level+1)*sleeveThickness;

    union()
    {
        rotate(90-pendulumKink,[0,0,1])
        {
            // Long member between hub and weight
            translate([bore_radius,-armWidth,0])
            cube([pendulumLength-(bore_radius),2*armWidth,girder_thick]);

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
                translate([pendulumLength,0,0])
                difference()
                {
                    // Circular weight
                    cylinder(h=hubHeight,d=pendulumWidth);
                    // Mounting hole
                    cylinder(h=3*hubHeight,d=nail_6d_diam,center=true);
                }
            }
        }

        ring(sleeve_radius,bore_radius,escapeThickness+sleeve_extension+spacer);

        escapement(
            escapeRadius,
            escapeThickness,
            faceAngle,
            armAngle,
            armWidth,
            escapeNumberTeeth,
            toothSpan,
            escapeHubWidth,
            hubHeight,
            bore_radius,
            false, //negativeSpace,
            negativeMargin,
            maxSwing,
            entryPalletAngle=45-escapeToothLean+escapeClubAngle,
            exitPalletAngle=45-escapeToothLean+escapeClubAngle);
    }
}

module frame()
{
}

module escapeWheel()
{
    small_addendum_radius=11.1 / 2;

    // Wheel and coaxial pinion
    difference()
    {
        union()
        {
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
                small_addendum_radius,  // wheel hub diam as big as coaxial pinion
                0, //bore_radius, see below
                escapeClubSize,
                escapeClubAngle);

            // DXF file origin is that of a Z30 wheel
            //translate([-15 -5, 0, escapeThickness*.9999])
            //linear_extrude(escapePinionThick)
            //import("Cycloid-M1-Z30Z10 Pinion.dxf");
        }

        // Bore
        cylinder(h=3 * (escapePinionThick + escapeThickness), d=escapeWheelBore, center=true);
    }
}

module animated()
{
    projection()
    rotate([0,0,180])
    {
        // Wheel and coaxial pinion
        unlock = 0.005;   // Wheel unlocks at this time / pendulum angle
        teeth = 1 / 4 * lookup( 2 * $t, [
            [0,         -1  ],
            [  unlock,  0  ],
            [1-unlock,  0  ],
            [1+unlock,  2  ],
            [2-unlock,  2  ],
            [2+unlock,  3  ]]);
        echo("t=",360*$t," pendulum=",anchor_angle($t)," teeth=",teeth);
        rotate([0,0, wheel_phase_angle + -360/escapeNumberTeeth * teeth])
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
			small_addendum_radius,  // wheel hub diam as big as coaxial pinion
			0, //bore_radius, see below
			escapeClubSize,
			escapeClubAngle);

        placeEscapement(180,escapeRadius,escapeNumberTeeth,toothSpan)
        rotate([0,0, anchor_angle($t)])
        {
            //escapement(escapeRadius,thickness,faceAngle,armAngle,armWidth,escapeNumberTeeth,toothSpan,anchorHubDiam/2,hubHeight,0,lockAndDropAngle);
            cube([1,30,1],center=true);  // Pendulum
        }
    }
}

