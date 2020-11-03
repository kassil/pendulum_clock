use <Utilities.scad>
use <Girders.scad>
include <Hardware.scad>

// Quality settings
$fs = 0.5;
$fa = 5;

arm_width = 6;
arm_thick = 1; // five layers at 0.2mm/layer
boss_diam = 10;
axis_separation = 50;

origin2 = [0,0];
origin3 = [0,0,0];

rearFrame(axis_separation + 1.5, axis_separation);

//pts = [ for(x = [0:1:1]) for (y = [0:1:1]) [ 10*x,20*y ] ];
//
//echo(pts);
////arm_round_ends([for (i=[0:1:1]) pts[i]],width=2, height=1);
//arm_round_ends(pts[0],pts[2],width=2, height=1);

//
// Assemblies
//
module rearFrame(axle_distance, bolt_distance)
{
	bolt_pos = bolt_distance/2 * [1,0];
    axle_pos = axle_distance/2 * [1,0];
    //color([0.4,1,0.4]) // green
    color([.3,.6,1])  // bright blue
    difference()
    {
        union()
        {
            girder_square_ends(axle_pos, -axle_pos, arm_width,arm_width,arm_thick);
            draw_bosses( [axle_pos,-axle_pos], boss_diam, arm_width );
         
            // Two equilateral triangles share an edge
            for(i = [-1:2:1])
            {
                scale([i,1,1])  // Symmetry in Y axis
                for(j = [-1:2:1])
                {
                    translate(bolt_pos)
                    rotate([0,0,60*j])
                    translate(-2*bolt_pos)
                    {
                        difference()
                        {
                            union()
                            {
                                cylinder(h=arm_width, d=m5_boss_diam);
                                girder_square_ends(origin2, 2*bolt_pos, arm_width,arm_width,arm_thick);
                            }
                            // Bolt hole
                            union()
                            {
                                cylinder(h=3*arm_width, d=m5_male_dia, center=true);
                                captive_nuts([origin3-[0,0,1e-2]], m5_nut_dia, m5_nut_recess);
                            }
                        }
                    }
                }
            }
        }
        // Axle holes
        thru_drill([axle_pos,-axle_pos], [for([0:1:1]) nail_16d_diam]);
    }
}


