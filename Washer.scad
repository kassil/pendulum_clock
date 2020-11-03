include <Locations.scad>

$fs = 0.2;                  // minimum size of an arc fragment
$fa = 360/128;              // minimum angle of an arc fragment

LOOSE = 0.00;

washer(8, 3.95, 6.20);

if(0)
{
washer(2, nail_16d_diam, 10);

translate([15,0,0])
washer(1, nail_16d_diam, 10);

translate([30,0,0])
washer(1, nail_16d_diam, 10);

// In front of second wheel Z80
translate([0,0,0])
washer(1.25, 12.15, 16, true);

// Behind second wheel Z80
translate([0,20,0])
washer(8+5-.25, nail_16d_diam, m5_spacer_diam);

// Behind third wheel Z75
translate([20,0,0])
washer(8-.75, nail_6d_diam, m5_spacer_diam);

// In front of third wheel Z75
translate([20,20,0])
washer(1, nail_6d_diam, m5_spacer_diam);

translate([40,0,0])
// Behind escape wheel
washer(1.75, nail_6d_diam, m5_spacer_diam);
}


module washer(h, id, od, is_hex_id=false)
{
    difference()
    {
        cylinder(h=h, d=od - LOOSE);
        
        // Bore
        cylinder(h=3*h, d=id + LOOSE, center=true, $fn=is_hex_id?6:$fn);
    }
}

