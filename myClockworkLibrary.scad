use <MCAD/involute_gears.scad>

negativeMargin = 0.01;

// Spokes for gears and wheels.
module spokes(spokes_diam = 1, hub_diam = .25, height, width, num_spokes=5, center=false)
{
    for(i = [0 : 1 : num_spokes])
    {
        rotate([0,0, 360 / num_spokes * i])
        linear_extrude(height, center=center)
        translate([0, hub_diam/2])
        scale([width, (spokes_diam/2 - hub_diam/2)])
        translate([-0.5,0])
        square(1, center = false);
    }
}

// Drum for ropes / winches
// radius: outer radius
// rimWidth: 
// drumHeight: overall height
// 
module drum(
	radius,
	rimWidth,
	drumHeight,
	numberHoles=0,
	holeRadius=0,
	holeRotate=0)
{
	flangeWidth=min(drumHeight*3/4,rimWidth*3/4);
    flangeHeight = drumHeight/6;
    radius_inner = radius-flangeWidth;
    
    lipHeight = min(0.5, flangeHeight/2);

	difference()		// makes the center hollow & includes holes to attach string
	 {
		union() 	// builds the drum with flanges
		{
			cylinder(lipHeight,r=radius);
            translate([0,0,lipHeight])
			cylinder(flangeHeight-lipHeight,radius,radius_inner);
	
			translate([0,0,flangeHeight])
			cylinder(h=drumHeight-2*flangeHeight,r=radius_inner);
	
			translate([0,0,drumHeight-flangeHeight])
			cylinder(flangeHeight-lipHeight,radius_inner,radius);

			translate([0,0,drumHeight-lipHeight])
			cylinder(lipHeight,r=radius);
		}

		translate([0,0,-1])
		cylinder(drumHeight+2,radius-rimWidth,radius-rimWidth);

	for ( j=[0:1:numberHoles-1]) // adds the holes
	{
		translate([0,0,drumHeight/2])
		rotate(holeRotate+360/numberHoles*j,[0,0,1]) 
		rotate(90,[0,1,0])
		cylinder(r=holeRadius,h=radius+1);
	}

	}
}

module involuteWheelDrum(teeth, wheelHeight, pitch, drumHeight, boreDiam)
{
    rimWidth = 7;
    wheelRimDiam = pitch * (teeth - 2.5) - 2*rimWidth;  // Approximate
    isSpokes = wheelRimDiam/boreDiam > 3 ? 1 : 0;
    difference()
    {
        union()
        {
            scale([1,1,wheelHeight])
            gear(number_of_teeth=teeth, circular_pitch=pitch * 180,
                //circles=6,
                //flat=true,
                rim_thickness = 1,
                //rim_width=2,
                gear_thickness = 1,
                hub_thickness=1,
                hub_diameter=0,
                bore_diameter=isSpokes ? wheelRimDiam : 0,
                clearance = 0.25,  // ISO metric root
                pressure_angle=20);

            if(isSpokes)
                spokes(spokes_diam=wheelRimDiam, hub_diam=2*boreDiam, height = wheelHeight+drumHeight, width=1, num_spokes=5);
            
            // Hub
            cylinder(h=wheelHeight+drumHeight, d=3*boreDiam);

            rootRadius=pitch*(teeth-2.5)/2;
            translate([0,0,wheelHeight])
            drum(radius=rootRadius, rimWidth=rimWidth, drumHeight=drumHeight, numberHoles=2, holeRadius=1.2, holeRotate=0);
        }
        
		// Bore
		cylinder(h=3*(wheelHeight+drumHeight), d=boreDiam, center=true);
    }
}

module involutePinionWheel(wheelTeeth, pinionTeeth, wheelHeight, pinionHeight, wheelPitch, pinionPitch, boreDiam)
{
    wheelRimDiam = wheelPitch * (wheelTeeth - 2.5) - 6;  // Smaller than dedendum
    pinionOutDiam = pinionPitch * (pinionTeeth + 2);  // Addendum
    isSpokes = wheelTeeth*wheelPitch/pinionTeeth/pinionPitch > 3 ? 1 : 0;
    difference()
    {
        union()
        {
            scale([1,1,wheelHeight])
            gear(number_of_teeth=wheelTeeth, circular_pitch=wheelPitch * 180,
                //circles=6,
                //flat=true,
                rim_thickness = 1,
                //rim_width=2,
                gear_thickness = 1,
                hub_thickness=1,
                //hub_diameter=//pinionTeeth*1.12,
                bore_diameter=isSpokes ? wheelRimDiam : 0,
                clearance = 0.25,  // ISO metric root
                pressure_angle=20);

            if(isSpokes)
                spokes(spokes_diam=wheelRimDiam, hub_diam=pinionOutDiam, height = wheelHeight, width=1.25, num_spokes=5);
            
            // Hub
            cylinder(h=wheelHeight, d=pinionOutDiam+negativeMargin);

            translate([0,0,wheelHeight-negativeMargin])
            scale([1,1,pinionHeight+negativeMargin])
            gear(number_of_teeth=pinionTeeth, circular_pitch=pinionPitch * 180,
                //circles=6,
                //flat=true,
                rim_thickness = 1,
                //rim_width=2,
                gear_thickness = 1,
                hub_thickness=1,
                hub_diameter=pinionOutDiam,
                bore_diameter=0,
                clearance = 0.25,  // ISO metric root
                pressure_angle=20);
        }
		// Bore
		cylinder(h=3*(wheelHeight+pinionHeight), d=boreDiam, center=true);
    }
}		
