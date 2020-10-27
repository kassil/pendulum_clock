
module rounded_square(l,r)
{
    //assert(len(l) == 1);
    difference()
    {
        square(l,center=true);
        
        union()
        for(i = [0:1:3])
        {
            rotate([0,0,-90*i])
            translate([l,l] / 2)
            rotate([0,0,180])
            //translate([-l,0])
            fillet2d(r);
        }
    }
}

module fillet2d(r) {
    translate([r / 2, r / 2])

        difference() {
            square([r + 0.01, r + 0.01], center = true);

            translate([r/2, r/2])
                circle(r = r);
        }
}

// Extrude a quarter circle of radius r (a quarter cylinder).
module fillet3d(r, h) {
    translate([r / 2, r / 2, 0])

        difference() {
            cube([r + 0.01, r + 0.01, h], center = true);

            translate([r/2, r/2, 0])
                cylinder(r = r, h = h + 1, center = true);

        }
}
