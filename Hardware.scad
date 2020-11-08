// Dimensions of metal bits
use <Utilities.scad>

bearing_od = 22.00 - 0.04;  // Interference fit!
bearing_id = 8.00;
bearing_depth = 7;


// TODO Need an offset more than a scale factor, for small stuff!
nail_16d_diam = 4.16;  // Drill #19 for moderately loose.
nail_6d_diam = 2.92;    // Drill #32 for moderately loose. Add .05 for moderately loose.

m5_male_dia = 4.92;  // Drill #12 D_maj - H/4 = D_maj - .2165 P
m5_minor_dia = 5 * 1.08253*0.8; // 4.13 = (D_maj - 1.25*0.866*P)
m5_nut_dia = 7.89;  // hex flats
m5_boss_diam = 12;
m5_boss_thick = 6;
m5_nut_recess = 3.7 + 0.2;  // nut thickness
m5_spacer_diam = 9;

woodscrew_no5_root_diam = inches(0.100);
woodscrew_no5_male_diam = inches(0.128);

// Drill a hole for the top of the screw (loose fit)
module woodscrew_no5_upperhole(thread_length = inches(0.633))
{
    /*
    .116   Angle 30*
    _____
    \   |  Height = .116/tan(30) = .201 
     \  |
      \*|  
       \|
    */
    //male_outer_diam = inches(0.128);
    countersink_ang = 90;
    head_diam = inches(0.232);
    head_rad = head_diam/2;
    head_height = head_rad / tan(countersink_ang/2);
    union()
    {
        // Vee head
        cylinder(h=head_height, d1=head_diam, r2=0);
        // Shaft
        translate([0,0,head_height/2])
        cylinder(h=head_height/2+thread_length, d=woodscrew_no5_male_diam);
    }
}
