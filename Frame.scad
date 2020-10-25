// 2020 October
// Pendulum clock project
// Design the frame component "Frame.Escape".

// FrameEscape mainshaft has a 16d nail bore
// FrameWeight mainshaft has a big 8mm bore for the minute shaft

$fn = 64;  // num arc facets

use <../Utilities.scad>;
include <../Locations.scad>;

// Z distance between adjacent components (including its own thickness)
depth_FrameRear = 22;
depth_FrameEscape = 21.5;
depth_FrameWeight = 20;

// Component: Frame.Rear
// A bolt spacer at each corner.  Rear bearing for pendulum.
module FrameRear()
{
    holes = concat(outer_corner_holes, [
        [  0,  122.28],         // Anchor bearing bore
    ]);
    holes_diam = concat(outer_corner_holes_diam,
        [bearing_od]
    );

    difference()
    {
        union()
        {
            // Extend a linear member between corner holes
            perimeter_girder([ for (i = [0 : 3]) holes[i] ],
                arm_width, m5_boss_thick, girder_thick);

            // Additional support members
            // Struts from each lower corner support the bearing above (inverted V)
            bb = bounding_box_2d(outer_corner_holes);
            midpt = (bb[0] + bb[1]) / 2;
            top_centre = [midpt[0],bb[1][1]];
            girder_square_ends(
                [bb[0][0],bb[0][1]], top_centre, small_arm_width, small_arm_height, girder_thick);
            girder_square_ends(
                [bb[1][0],bb[0][1]], top_centre, small_arm_width, small_arm_height, girder_thick);
            
            // Corner bolt head bosses
            draw_bosses(outer_corner_holes,
                diam=m5_boss_diam,
                h=m5_boss_thick  + .01);

            // Corner bolt spacers reach to front frame
            draw_bosses(outer_corner_holes,
                diam=m5_spacer_diam,
                h=depth_FrameRear + depth_FrameEscape
                + depth_FrameWeight + .01);

            // 608 ball bearing housing
            draw_bosses([holes[4]], diam=bearing_boss_diam, h=bearing_depth);
        }

        // Drill all holes
        thru_drill(holes, holes_diam);
    }
}

// Component: Frame.Escape
module FrameEscape()
{
    holes = concat(movemt_corner_holes, [
        [  0,       22],            // Second (main) shaft
        [-35.8586,  49.1876],       // Third wheel Z75
        [  0,       72],            // Escape wheel
    ]);
    holes_diam = concat(movemt_corner_holes_diam,
        [nail_16d_diam, nail_6d_diam, nail_6d_diam]
    );

    difference()
    {
        union()
        {
            // Extend a linear member between corner holes
            perimeter_round_ends(
                [ for (i = [0 : 3]) holes[i] ],
                arm_width, thick);

            // Additional support member in centre
            arm_round_ends([0, -10], [0, 82], width=arm_width, height=thick);
            
            // Corner bolt spacers
            draw_bosses([ for (i = [0 : 3]) holes[i] ],
                diam=m5_spacer_diam, h=depth_FrameEscape+.01);
            
            // Non-corner hole bosses
            draw_bosses([ for (i = [4 : 6]) holes[i] ],
                diam=m5_spacer_diam, h=thick);
        }

        // Drill all holes
        thru_drill(holes, holes_diam);
    }
}

// Component: Frame.Weight
module FrameWeight()
{
    holes = concat(movemt_corner_holes, [
        [  0,       22],            // Second (main) shaft
        [-35.8586,  49.1876],       // Third wheel Z75
        [  0,       72],            // Escape wheel
        [ 24.5134,  1.43079],       // Weight pulley bearing
        [-24.5134,  1.4308 ],       // Counterweight pulley bearing
    ]);
    holes_diam = concat(movemt_corner_holes_diam,
        [minshaft_bore_diam, nail_6d_diam, nail_6d_diam, bearing_od, bearing_od]
    );

    difference()
    {
        union()
        {
            // Extend a linear member between corner holes
            perimeter_round_ends(
                [ for (i = [0 : 3]) holes[i] ],
                arm_width, thick);
        
            // Additional support member in centre
            arm_round_ends([0, -10], [0, 82], width=arm_width, height=thick);
            
            // Corner bolt spacers
            draw_bosses([ for (i = [0 : 3]) holes[i] ],
                diam=m5_spacer_diam, h=depth_FrameWeight+0.01);

            // Large boss for minute shaft
            draw_bosses([holes[4]], diam=minshaft_boss_diam, h=thick);

            // Non-corner hole bosses
            draw_bosses([ for (i = [5 : 6]) holes[i] ],
                diam=m5_spacer_diam, h=thick);

            // Bearing bosses
            draw_bosses([ for (i = [7 : 8]) holes[i] ],
                diam=bearing_boss_diam, h=bearing_depth);
        }
        
        // Drill all holes
        thru_drill(holes, holes_diam);
    }
}
        
// Component: Frame.Front
module FrameFront()
{
    holes = concat(outer_corner_holes, [
        [  0,       122.28],        // Anchor bearing bore
        [ 24.5134,  1.43079],       // Weight pulley bearing
        [-24.5134,  1.4308 ],       // Counterweight pulley bearing
    
        [  0,       22],            // Second (main) shaft Z80
        [-29.0000,  22],            // 40 wheel shaft Z40
        ], movemt_corner_holes
    );
    holes_diam = concat(outer_corner_holes_diam, [
        bearing_od,
        bearing_od,
        bearing_od,
        
        minshaft_bore_diam,
        nail_6d_diam,],
        movemt_corner_holes_diam
    );

    difference()
    {
        union()
        {
            // Extend a linear member between corner holes
            perimeter_girder([ for (i = [0 : 3]) holes[i] ],
                arm_width, m5_boss_thick, girder_thick);

            // Corner bosses
            draw_bosses(outer_corner_holes,
                diam=m5_boss_diam, h=m5_boss_thick);

            // Extend a linear member between movement holes
            perimeter_girder(movemt_corner_holes, small_arm_width, small_arm_height, girder_thick);
            
            // Movement hole bosses
            draw_bosses([ for (i = [9 : 12]) holes[i] ],
                diam=m5_boss_diam, h=m5_boss_thick);
                
            // Additional support members
            bb = bounding_box_2d(outer_corner_holes);
            // Horizontal between pulleys
            girder_square_ends(
                [bb[0][0],holes[5][1]+6], [bb[1][0],holes[5][1]+6], small_arm_width, small_arm_height, girder_thick);
            // Vertical in centre
            midpt = (bb[0] + bb[1]) / 2;
            girder_square_ends(
                [midpt[0],bb[0][1]], [midpt[0],bb[1][1]], arm_width, m5_boss_thick, girder_thick);
            // Vertical under each pulley
            girder_square_ends([holes[5][0],bb[0][1]], holes[5], small_arm_width, small_arm_height, girder_thick);
            girder_square_ends([holes[6][0],bb[0][1]], holes[6], small_arm_width, small_arm_height, girder_thick);
                            
            // Upper diagonals
            for(i = [0:1])
            {
                girder_square_ends(movemt_corner_holes[i],holes[i],small_arm_width, small_arm_height, girder_thick);
                girder_square_ends(movemt_corner_holes[i],holes[i],small_arm_width, small_arm_height, girder_thick);
            }

            // 608 ball bearing bosses
            draw_bosses([ for (i = [4 : 6]) holes[i] ],
                diam=bearing_boss_diam, h=bearing_depth);

            // Mainshaft boss
            draw_bosses([holes[7]], diam=minshaft_boss_diam, h=m5_boss_thick);
            
            // 40 wheel arbor boss
            // Weld to nearby counterweight boss
            draw_bosses([holes[8]], diam=m5_spacer_diam, h=m5_boss_thick);
            girder_square_ends(holes[8], [movemt_corner_holes[3][0], holes[8][1]],
                small_arm_width, small_arm_height, girder_thick);
            girder_square_ends(holes[8], holes[8]-[0,12],
                small_arm_width, small_arm_height, girder_thick);
        }

        // Drill all holes
        thru_drill(holes, holes_diam);
        
        // Inset nuts
        translate([0, 0, m5_boss_thick - m5_nut_recess])
        captive_nuts([ for (i = [0,1,2,3, 9,10,11,12]) holes[i] ],
            m5_nut_dia, 2*m5_nut_recess);
    }
}

// Assembly
//print = true;
print = false;

if(!print)
{
    $fn=32;
    rotate([90,0,0])
    {
        translate([0,0,-41.5])
        {
            FrameRear();

            translate([0,0,depth_FrameRear])
            {
                FrameEscape();
            
                translate([0,0,depth_FrameEscape])
                {
                    FrameWeight();
                    translate([0,0,depth_FrameWeight])
                    {
                        FrameFront();
                    }
                }
            }
        }
    }
}
else
{
    // Components are printed in a different orientation than the model.
    $fn=128;
    FrameRear();
    //FrameEscape();
    //FrameWeight();
//    FrameFront();
}
