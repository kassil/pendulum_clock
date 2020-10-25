// Clock face

use <Utilities.scad>;
include <Locations.scad>;


numerals = [
    "I",    "II",   "III",  "IV",   "V",    "VI",
    "VII",  "VIII", "IX",   "X",    "XI",   "XII",
];
face_diameter = 170;
// Numerals are centred on an imaginary circle of this diameter:
text_diameter = 142;
face_inner_diameter = 108;
face_thick = 4;
numeral_thick = 4;
// Ratio of font height to face diameter:
alpha = 12;
font = "Times New Roman";

perimeter = [
    movemt_corner_holes[1],     // upper right
    [outer_corner_holes[1][0], movemt_corner_holes[1][1]],
    outer_corner_holes[2],      // lower right
    outer_corner_holes[3],      // lower left
    [ -outer_corner_holes[1][0], movemt_corner_holes[1][1] ],
    //[ -text_diameter/2 * cos(45),  text_diameter/2 * sin(45) + 22]
];
tapped_hole_indices = [ 0, 2, 3 ];
bolt_perimeter = [ for(i = tapped_hole_indices) perimeter[i]];
p_40wheel = [-29, 22];
p_pulley = [24.5135, 1.43079];
p_face = [0, 22];
hour_hand_dia = 14 + .5;  // loose fit
face_locate_pin_diam = nail_6d_diam;

drill_centres = concat(bolt_perimeter, [
    p_face,                         // Centre
    p_40wheel,
    p_pulley,
]);
drill_diams = concat( [for([1:len(bolt_perimeter)]) m5_male_dia], [
    hour_hand_dia,                  // Hour hand
    nail_6d_diam,
    barrel_bore_diam,
]);


scene_orientation()
union()
{
    FaceFrame();    
    translate([0, 0, 4])  // exploded view!
    #Face();
};


module FaceFrame()
{
    n_locating = 6;
    locating_height = 9;  // depth of pin holes

    scale([1,1,-1])
    translate([0,0,-small_arm_height])
    difference()
    {
        union()
        {
            // Additional girders
            girder_square_ends([-text_diameter/2, p_face[1]],
                p_face, small_arm_width, small_arm_height, girder_thick);
            girder_square_ends(outer_corner_holes[2],
                p_face, small_arm_width, small_arm_height, girder_thick);
            
            girder_square_ends(movemt_corner_holes[1],
                movemt_corner_holes[1]+[4,8], small_arm_width, small_arm_height, girder_thick);
            
            translate(p_face)
            {
                // Girder perimeter
                n_girders = 12;
                girder_len = PI * text_diameter / n_girders;
                for(angle_i = [0:1:n_girders])
                {
                    angle = angle_i * 360 / n_girders;
                    rotate([0,0,angle])
                    translate([text_diameter/2,0])
                    girder_round_ends([0,-girder_len/2], [0,girder_len/2],
                        small_arm_width, small_arm_height, girder_thick);
                }
            
                // Locating pins for face/numerals
                for(angle_i = [0:1:n_locating])
                {
                    angle = angle_i * 360 / n_locating;
                    rotate([0,0,angle])
                    translate([text_diameter/2,0])
                    cylinder(d=2*nail_6d_diam,h=locating_height);
                }
            }
            
            spacer_len = 30;
            draw_bosses(bolt_perimeter, m5_spacer_diam, spacer_len);
            draw_bosses(bolt_perimeter, m5_boss_diam, m5_boss_thick);
            translate([0,0,spacer_len - 4])
            draw_bosses(bolt_perimeter, m5_boss_diam, 4);

            // Centre hole
            translate(p_face)
            cylinder(d=hour_hand_dia + 3*2, h=small_arm_height);

            // 40 wheel arbor
            translate(p_40wheel) cylinder(d=8, h=small_arm_height);

            // Pulley wheel arbor
            translate(p_pulley) cylinder(d=15, h=small_arm_height);
        }
        
        thru_drill(drill_centres, drill_diams);
        
        // Locating pins for face/numerals
        translate(p_face)
        for(angle_i = [0:1:n_locating])
        {
            angle = angle_i * 360 / n_locating;
            rotate([0,0,angle])
            translate([text_diameter/2,0,-.05])
            cylinder(d=nail_6d_diam, h=locating_height-1);
        }
        
        // Cut out/inset captive nuts
        translate([0, 0, -0.01]) //m5_boss_thick - m5_nut_recess])
        captive_nuts(bolt_perimeter,
            m5_nut_dia, m5_nut_recess+1);

    }
}

module Face()
{
    translate(p_face)
        {
        // Face ring
        if(1)
        difference()
        {
            // Round face
            cylinder(d=face_diameter, h = face_thick );
            
            // Remove face centre
            translate([0,0,-face_thick/2])
            cylinder(d = face_inner_diameter, h = 2*face_thick);
            
            // Drill locating bosses for frame
            N = 6;
            for(angle_i = [0:1:N])
            {
                angle = angle_i * 360 / N;
                rotate([0,0,angle])
                translate([text_diameter/2,0,-1])
                cylinder(d=face_locate_pin_diam+.04, h=3+1);
            }
        }
        
        // Numerals
        translate([0, 0, face_thick ])
        linear_extrude(height = numeral_thick)
        for(i = [0 : 1 : len(numerals)])
        {
            angle = (i - 3 % len(numerals)) * 360 / len(numerals);
            rotate(-angle)  // Clockwise
            translate([text_diameter / 2,0])
            rotate(angle)  // Orient text upward.
            text(text = numerals[(i-1) % len(numerals)], font = font,
                size = text_diameter / alpha,
                halign = "center", valign = "center");
        }
    }
}

module scene_orientation()
{
    translate([0,-54])
    rotate([90, 0, 0])
    children();
}
