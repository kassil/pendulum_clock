use <MCAD/involute_gears.scad>

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
module drum(
	radius,
	rimWidth,
	drumHeight,
	numberHoles=0,
	holeRadius=0,
	holeRotate=0)
{
	flangeWidth=min(drumHeight/3,rimWidth/2);

	difference()		// makes the center hollow & includes holes to attach string
	 {
		union() 	// builds the drum with flanges
		{
			cylinder(flangeWidth,radius,radius-flangeWidth);
	
			translate([0,0,flangeWidth])
			cylinder(drumHeight-2*flangeWidth,radius-flangeWidth,radius-flangeWidth);
	
			translate([0,0,drumHeight-flangeWidth])
			cylinder(flangeWidth,radius-flangeWidth,radius);
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
    wheelRimDiam = pitch * (teeth - 2.5) - 8;  // Approximate
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
            drum(radius=rootRadius, rimWidth=8, drumHeight=drumHeight, numberHoles=2, holeRadius=1.5, holeRotate=0);
        }
        
		// Bore
		cylinder(h=3*(wheelHeight+drumHeight), d=boreDiam, center=true);
    }
}

module involutePinionWheel(wheelTeeth, pinionTeeth, wheelHeight, pinionHeight, wheelPitch, pinionPitch, boreDiam)
{
    wheelRimDiam = wheelPitch * (wheelTeeth - 2.5) - 3;  // Approximate
    pinionOutDiam = pinionPitch * (pinionTeeth + 2);  // Approximate
    isSpokes = wheelTeeth*wheelPitch/pinionTeeth/pinionPitch > 3 ? 1 : 0;
    difference()
    {
    union()
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
                spokes(spokes_diam=wheelRimDiam, hub_diam=pinionOutDiam, height = wheelHeight, width=1, num_spokes=5);
            
            // Hub
            cylinder(h=wheelHeight, d=pinionOutDiam);
        }
        
        
        translate([0,0,wheelHeight])
        scale([1,1,pinionHeight])
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
