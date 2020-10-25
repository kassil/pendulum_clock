include <Hardware.scad>

movemt_corner_holes = [
    [-40, +97],         // upper left
    [+40, +72],         // upper right        
    [+40, -10],         // lower right
    [-40, -10],         // lower left
];

movemt_corner_holes_diam = [
    m5_male_dia,m5_male_dia,
    m5_male_dia,m5_male_dia,
];

outer_corner_holes = [
    [-60, +122],        // upper left
    [+60, +122],        // upper right        
    [+60, -23],         // lower right
    [-60, -23],         // lower left
];
outer_corner_holes_diam = [
    m5_male_dia,m5_male_dia,
    m5_male_dia,m5_male_dia,
];


// For all frame components
thick = 2.5;
arm_width = 8;
bearing_boss_diam = 32;
minshaft_bore_diam = 8.01;  // Loose fit!
minshaft_boss_diam = 16;
girder_thick = 1.2; // six layers at 0.2mm/layer
small_arm_width = 5;  // For small girders
small_arm_height = 4;

// Ratchet, barrel,pulley arbor, face frame
barrel_bore_diam = 10;
pulley_hex_diam = 8;

// Quality settings
$fs = 0.5;
$fa = 5;
