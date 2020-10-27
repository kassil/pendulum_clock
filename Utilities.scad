/*


module ring(outerRadius,innerRadius,thickness,outerSegment=30,innerSegment=30)
	creates a hollow cylinder centered at origin
		outerRadius and innerRadius should be self-explanatory
		thickess is along z
		outerSegment is an optional override of the system variable $fn
		innerSegment is an optional override of the system variable $fn


*/

module ring(
	outerRadius,
	innerRadius,
	thickness,
	outerSegment=30,
	innerSegment=30)
{
	difference() // hollows out the center of one cylinder with another, smaller one
	{
		cylinder(thickness,outerRadius,outerRadius,$fn=outerSegment);
		translate([0,0,-1])
		cylinder(thickness+2,innerRadius,innerRadius,,$fn=innerSegment);
	}
}

module draw_bosses(centres, diam, h)
{
    // Draw a boss around every hole
    for(i = [0:1:len(centres)-1])
    {
        translate(centres[i])
        cylinder(d=diam, h=h);
    }
}

// Use this inside a difference()
module thru_drill(centres, diams, drill_depth = 100)
{
    assert(len(centres) == len(diams));
    n = min( len(centres), len(diams) );
    for(i = [0:1:n-1])
    {
        translate(concat(centres[i], -drill_depth))
        cylinder(d=diams[i], h=2*drill_depth);
    }
}

// Draw the head of zero or more hex fasteners
// Use this within an intersection
module captive_nuts(holes, flat_diam, thick)
{
    for(hole = holes)
    {
        translate(hole)
        cylinder(d=flat_diam/sin(60), h=thick, $fn=6);
    }
}

function bounding_box_2d(pts) = 
[
    [
        min( [ for(i = [0:1:len(pts)-1]) pts[i][0] ] ),
        min( [ for(i = [0:1:len(pts)-1]) pts[i][1] ] )
    ],[
        max( [ for(i = [0:1:len(pts)-1]) pts[i][0] ] ),
        max( [ for(i = [0:1:len(pts)-1]) pts[i][1] ] )
    ],
];
