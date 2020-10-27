// Create a spoked gear with a hexagon bore
use <MCAD/involute_gears.scad>
use <../../Utilities.scad>

// When a pair of gears are meshed so that their reference circles are in contact, the center distance (a) is half the sum total of their reference diameters.
// a = ( d1 + d2 ) / 2

height = 5;
hex_diam = 12.02;  // Legacy: not between parallel flats
spokes_diam = 80;
hub_boss = 0;
$fn=64;


//difference()
{
    union()
    {
    if(0) gear(number_of_teeth=48, circular_pitch=1 * 180,
        //circles=6,
        //flat=true,
        rim_thickness = 1,
        //rim_width=2,
        gear_thickness = 1,
        hub_thickness=1,
        hub_diameter=8,
        bore_diameter=0,
        clearance = 0.25,  // ISO metric root
        pressure_angle=20);
    }

    spokes(spokes_diam=spokes_diam, hub_diam=10, height = height*2, width=2, num_spokes=12);

    // Hex cutout
    translate([0, 0, -50])
    ;//cylinder(h=100, d=hex_diam, $fn=6);
}

