// Minute shaft (minshaft)
// October 2020

// TODO Need an offset more than a scale factor, for small stuff!
nail_16d_diam = 4.13 + .04;  // Drill #20

TAPER_PER_MM = 1/50;  // 1 mm diameter per 50 mm length

//Z1 = 0;
L1 = 5;
Z2 = L1;
L2 = 30;
Z3 = Z2 +  L2;
L3 = 5;
Z4 = Z3 + L3;
L4 = 28;
//Z5;

// Taper calculator for bores.  The bottom of the hole is always less
// than the nominal dimaeter.
function taper_calculator(length, nominal_diam, overdeep) = 
    [
        // Diameter at the bottom of the hole:
        nominal_diam - (overdeep * TAPER_PER_MM),
        // Outer diameter:
        nominal_diam + (length - overdeep) * TAPER_PER_MM,
    ];

// Orient as in the assembly model.
rotate([90,0,0])
{
    difference()
    {
        union()
        {
            // Hex head drives the Second Wheel (80T)
            // For legacy reasons, the diameter is not specified between parallel flats
            //TODO Bevel
            cylinder(h=L1, d=12, $fn=6);
            translate([0,0,L1])
            {
                // Smooth proximal shaft
                cylinder(h=L2, d=8, $fn=64);
                translate([0,0,L2])
                {
                    // Hex is driven by 40 Wheel pinion.
                    //TODO Bevel
                    cylinder(h=L3, d=8, $fn=6);
                    translate([0,0,L3])
                    {
                        // Smooth distal shaft.  Hourshaft rides on this.
                        cylinder(h=L4, d = 6, $fn=32);
                    }
                }
            }
        }
        
        // Bore for the 16d nail at proximal end
        translate([0,0,-0.001])
        cylinder(h=16, d=nail_16d_diam,$fn=24);
        
        // Taper bore for minute hand.
        taper_len = 50;
        taper_diams = taper_calculator(taper_len,4,4);
        echo(taper_diams);
        translate([0, 0, Z4])
        cylinder(h=taper_len, d1=taper_diams[1], d2=taper_diams[0],$fn=32);
    }
}
