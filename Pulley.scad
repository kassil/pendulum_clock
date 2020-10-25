include <Locations.scad>

pulley_height = 12.5; // Available in frame
flange_height = 1.25;
arbor_height = pulley_height - 2 * flange_height;
flange_diam = 21;
arbor_diam = 17;


module flange()
{
    slope_height = flange_height * 3/4;
    lip_height = flange_height - slope_height;
    z = arbor_height / 2;
    translate([0,0,z])
    // Slope
    cylinder(h=slope_height, d1=arbor_diam, d2=flange_diam);
    // Strengthen outer face
    translate([0,0,z + slope_height])
    cylinder(h=lip_height, d1=flange_diam, d2=flange_diam);
}

module pulley()
{
    flange();

    scale([1,1,-1])  // Mirror
    flange();

    // Arbor
    cylinder(d=arbor_diam, h=arbor_height, center=true);

    //// Boss
    //translate([0,0,pulley_height/2])
    //cylinder(h=.2, d=bearing_id+3);
}

difference()
{
    pulley();
    
    // Hex bore for pulley/ratchet arbor
    cylinder(h=3*pulley_height, d=pulley_hex_diam+.04, $fn=6, center=true);
}
