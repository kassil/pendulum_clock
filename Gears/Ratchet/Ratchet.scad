// Create a spoked gear with a ratchet nested inside.

use <MCAD/involute_gears.scad>
include <../../Locations.scad>
use <../../Utilities.scad>

gear_height = 8;
ratchet_height = 5;
ratchet_diam = 40;
spokes_diam = 35;
hub_diam = 15;
ratchet_hex_diam = 8 / sin(60);  // Shared with Face.scad !!

num_teeth = 30;
NATIVE_RADIUS = 52;
TEETH_PAWL_RATIO = 5;

// For arbor length
faceframethick = 4;
faceframegap = 5;
arbor_len5 = gear_height - ratchet_height + faceframegap + faceframethick;
arbor_diam5 = 8;
arbor_rear_sleeve_len = bearing_depth;
arbor_rear_sleeve_diam = 6;

{//rotate([90,0,0]) {
    //arbor();
    //translate([30,0])
    //arbor_front_sleeve();
    
    //Hack front arbor
    translate([60,0])
    difference()
    {
        // 2020-Oct: Test in PLA:
        // Arbor 8 mm outer dia prints as 7.94 mm
        // Sleeve 9.95 mm round prints as 9.90 mm
        union()
        {
            arbor_len5a = gear_height - ratchet_height + faceframegap;
            cylinder(d=9.88, h=arbor_len5a);  // Loose
            
            translate([0,0,arbor_len5a-.01])
            cylinder(d=9.25, h=arbor_len5 - arbor_len5a+.01);  // Loose
        }
        cylinder(d=arbor_diam5 + .10, h = 3*arbor_len5, center = true);
    }    
    //translate([60,0])
    //arbor_rear_sleeve();
}
//barrel();
//ratchet_teeth(ratchet_diam, 2*ratchet_height,true);

//rotate([0,0,0.05]) translate([0,0,gear_height])
//ratchet();

module ratchet()
{
    linear_extrude(ratchet_height)
    difference()
    {
        ratchet2d(ratchet_diam, is_clockwise=true);
        circle(d=ratchet_hex_diam, $fn=6);
    }
}

module barrel()
{
    difference()
    {
        difference()
        {
            // Solid gear
            linear_extrude(height = gear_height)
            gear(number_of_teeth=48, circular_pitch=1 * 180,
                //circles=6,
                flat=true,
                rim_thickness = 1,
                //rim_width=2,
                gear_thickness = 1,
                hub_thickness = 1,
                //hub_diameter=0,
                bore_diameter=0,
                clearance = 0.25,  // ISO metric root
                pressure_angle=20);

            // Cut out the ratchet teeth from inside the barrel.
            translate([0,0,gear_height - ratchet_height])
            scale([1,1])
            ratchet_teeth(ratchet_diam, 2*ratchet_height,true);

            // Cut out the spokes but leave the hub
            difference()
            {
                // Negative cylinder for spokes
                cylinder(h=3*gear_height, center = true, d=spokes_diam);
                // Cut out spokes from this cylinder
                spokes(spokes_diam=spokes_diam+.05, hub_diam=0, height = 3*gear_height, width=3, num_spokes=5, center=true);
                // Hub
                cylinder(h=gear_height-ratchet_height+1/*avoid coplanar*/, d=hub_diam);
            }
        }
        // Hub bore
        cylinder(h=3*gear_height, d=barrel_bore_diam, center=true);
    }
}

module ratchet2d(ratchet_diam, is_clockwise)
{
    // |\      Radial edge approx 5.1 units long.
    // | \     Tooth tip is at r=55, 3 units away from the r=52 circle.
    // |  \
    // -----
    factor =  ratchet_diam / NATIVE_RADIUS / 2;
    //linear_extrude(ratchet_height, center = false, convexity=4)
    scale([(is_clockwise?-1:1) * factor,factor])
    {
        circle(r = 19);
        for(i = [0:1:num_teeth/TEETH_PAWL_RATIO])
        {
            rotate([0,0,i*360/num_teeth*TEETH_PAWL_RATIO])
            translate([0,-108,0])
            import(file = "RatchetArm Inkscape.svg");
        }
    }
}

module arbor()
{
    difference()
    {
        union()
        {
            // Rear bearing sleeve hex
            cylinder(h=arbor_rear_sleeve_len, d=arbor_rear_sleeve_diam, $fn=6);
            translate([0,0,arbor_rear_sleeve_len])
            {
                // Weight pulley hex
                len2 = 13;
                cylinder(h=len2, d=8-.02, $fn=6);
                translate([0,0,len2])
                {
                    // Front bearing, round
                    len3 = 7+1;
                    cylinder(h=len3, d=bearing_id);
                    translate([0,0,len3])
                    {
                        // Ratchet hex
                        len4 = ratchet_height + 11;
                        cylinder(h=len4, d=ratchet_hex_diam-.02, $fn=6);
                        translate([0,0,len4])
                        {
                            // Ratchet barrel and face bearing, round
                            cylinder(h=arbor_len5, d=arbor_diam5 - .02);
                        }
                    }
                }
            }
        }
        // Through bore
        cylinder(d=nail_16d_diam+.04, h=1000,center=true);
    }
}

// Ratchet barrel and face bearing, round
module arbor_front_sleeve()
{
    linear_extrude(arbor_len5, center = false, convexity=4)
    difference()
    {
        // 2020-Oct: Test in PLA:
        // Arbor 8 mm outer dia prints as 7.94 mm
        // Sleeve 9.95 mm round prints as 9.90 mm
        circle(d=barrel_bore_diam-.05);  // Loose
        circle(d=arbor_diam5 + .02);
    }
}

// Rear bearing sleeve hex
module arbor_rear_sleeve()
{
    linear_extrude(arbor_rear_sleeve_len, center = false)
    difference()
    {
        // 2020-Oct: Test in PLA:
        // Arbor 8 mm outer round prints as 7.91 mm.
        // Arbor 6 mm outer hex   prints as 6.12 mm edges, 5.60 flats.
        // Sleeve 8.09 mm round outer prints as 8.24 mm.
        circle(d=bearing_id + .09);
        circle(d=arbor_rear_sleeve_diam + .06, $fn=6);
    }
}

// Draw the ratchet teeth inside the barrel that engage the ratchet.
// Use an STL file exported from a mesh in Blender.
module ratchet_teeth(diam, height, is_clockwise)
{
    // |\      Radial edge approx 5.1 units long.
    // | \     Tooth tip is at r=55, 3 units away from the r=52 circle.
    // |  \
    // -----
    linear_extrude(height, center = false, convexity=4)
    {
        factor =  diam / NATIVE_RADIUS / 2;
        circle(d = diam - 1);
        scale([(is_clockwise?-1:1) * factor,factor])
        for(i = [0:1:num_teeth])
        {
            rotate([0,0,i*360/num_teeth])
            projection(cut = false)
            import(file = "Tooth.stl");
        }
    }
}
