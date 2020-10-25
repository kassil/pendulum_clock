// Hour shaft
// October 2020

TAPER_PER_MM = 1/50;  // 1 mm diameter per 50 mm length

L1 = 9;                     // Hex length
Z2 = L1;                    // Z coordinate of base of taper
taper_len = 12;             // Taper length
taper_diam = 12;            // Diameter at distal end of the shaft.
// Proximal diameter at base of taper
taper_root_diam = taper_diam + taper_len*TAPER_PER_MM;

// Orient as in the assembly model.
translate([0,-36,22])
rotate([90,0,0])
{
    difference()
    {
        union()
        {
            // Hex head is driven by the 48T wheel (driven, in turn, by the pulley).
            // For legacy reasons, the diameter is not specified between parallel flats
            //TODO Bevel
            cylinder(h=L1, d=12 - 0.04, $fn=6);
            translate([0,0,L1])
            {
                // Tapered shaft for hour hand.
                cylinder(h=taper_len, d1=taper_root_diam, d2=taper_diam, $fn=96);
            }
        }
        // Bore through to ride on the minute shaft.
        translate([0,0,-500])
        cylinder(h = 1000, d = 6.04, $fn=64);
    }
}


// Taper calculator for bores.  The bottom of the hole is always less
// than the nominal dimaeter.
function taper_calculator(length, nominal_diam, overdeep) = 
    [
        // Diameter at the bottom of the hole:
        nominal_diam - (overdeep * TAPER_PER_MM),
        // Outer diameter:
        nominal_diam + (length - overdeep) * TAPER_PER_MM,
    ];
