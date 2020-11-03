use <MCAD/involute_gears.scad>
use <cycloid_gear.scad>

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
    flangeHeight = min(rimWidth/4,drumHeight/4);
    radius_inner = radius-flangeWidth;
    
    lipHeight = min(0.3, flangeHeight/2);

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

        // Holes to tie end of rope
        for ( j=[0:1:numberHoles-1])
        {
            translate([0,0,drumHeight/2])
            rotate(holeRotate+15*j,[0,0,1]) 
            rotate(90,[0,1,0])
            cylinder(r=holeRadius,h=radius+1);
        }
	}
}

module involuteWheelDrum(teeth, wheelHeight, pitch, drumHeight, boreDiam)
{
    rimWidth = 7;
    wheelRimDiam = pitch * (teeth - 2.5) - 2*rimWidth;
    hub_diam = 3 * boreDiam;
    spokeLength = (wheelRimDiam - hub_diam) / 2;
	// Long spokes are wider.  Round to nearest 0.5 mm.
	spokeWidth = round( spokeLength / 10 / 2 ) * 2;
	// Number of spokes is a function of wheel diameter.  We limit the
	// outer circumference between two adjacent spokes.
    numSpokes =  spokeLength < 20 ? 0 : 5;
		//round(PI * wheelRimDiam / 50);
        //spokeLength < 10 ? 0
        //: (spokeLength < 20 ? 5 :
        //8);
    echo(str("Wdrum",teeth," OD",wheelRimDiam," Spokes(",numSpokes," L",spokeLength," W",spokeWidth,")"));
    difference()
    {
        union()
        {
            involuteGear(teeth,pitch,wheelHeight,
                numSpokes ? wheelRimDiam : 0);

            if(numSpokes)
                spokes(spokes_diam=wheelRimDiam, hub_diam=0, height = wheelHeight+drumHeight, width=spokeWidth, num_spokes=numSpokes);
            
            // Hub
            cylinder(h=wheelHeight+drumHeight, d=3*boreDiam);

            rootRadius=pitch*(teeth-2.5)/2;
            translate([0,0,wheelHeight])
            drum(radius=rootRadius, rimWidth=rimWidth, drumHeight=drumHeight, numberHoles=2, holeRadius=1.1, holeRotate=15);
        }
        
		// Bore
		cylinder(h=3*(wheelHeight+drumHeight), d=boreDiam, center=true);
    }
}

module involutePinionWheel(wheelTeeth, pinionTeeth, wheelHeight, pinionHeight, wheelPitch, pinionPitch, boreDiam)
{
    rimWidth = 4;
    wheelRimDiam = wheelPitch * (wheelTeeth - 2.5) - 2*rimWidth;  // Smaller than dedendum
    pinionOutDiam = pinionPitch * (pinionTeeth + 2);  // Addendum
    spokeLength = (wheelRimDiam - pinionOutDiam) / 2;
	// Long spokes are wider.  Round to nearest 0.5 mm.
	spokeWidth = round( spokeLength / 10 / 2 ) * 2;
	// Number of spokes is a function of wheel diameter.  We limit the
	// outer circumference between two adjacent spokes.
    numSpokes =  spokeLength < 20 ? 0 : 6;
		//round(PI * wheelRimDiam / 50);
        //spokeLength < 10 ? 0
        //: (spokeLength < 20 ? 5 :
        //8);
    echo(str("Pwheel",wheelTeeth,"x",pinionTeeth," OD",wheelRimDiam,"ID",pinionOutDiam," Spokes(",numSpokes," L",spokeLength," W",spokeWidth,")"));
    //isSpokes = wheelTeeth*wheelPitch/pinionTeeth/pinionPitch > 3 ? 1 : 0;
    difference()
    {
        union()
        {
            involuteGear(wheelTeeth,wheelPitch,wheelHeight,
                numSpokes ? wheelRimDiam : 0);

            if(numSpokes)
                spokes(spokes_diam=wheelRimDiam, hub_diam=pinionOutDiam, height = wheelHeight, width=spokeWidth, num_spokes=numSpokes);
            
            // Hub
            cylinder(h=wheelHeight, d=pinionOutDiam+negativeMargin);

            translate([0,0,wheelHeight-negativeMargin])
            involuteGear(pinionTeeth,pinionPitch,pinionHeight+negativeMargin,
                0);
        }
		// Bore
		cylinder(h=3*(wheelHeight+pinionHeight), d=boreDiam, center=true);
    }
}		

// Involute helper function
//
module involuteGear(teeth,pitch,height,boreDiam)
{
    scale([1,1,height])
    difference()
    {
        gear(number_of_teeth=teeth, circular_pitch=pitch * 180,
            //circles=6,
            //flat=true,
            rim_thickness = 1,
            //rim_width=2,
            gear_thickness = 1,
            hub_thickness=1,
            //hub_diameter=//pinionTeeth*1.12,
            bore_diameter=0,//numSpokes ? wheelRimDiam : 0,
            clearance = 0.25,  // ISO metric root
            pressure_angle=20);
        
        if(boreDiam)
        {
            cylinder(h=3, d=boreDiam, center=true);
        }
    }
}

//
// Cycloid Wheels & Pinions (Gears)
//

function cycloidFilename(teeth,partnerTeeth) = str("Gears/Cycloid-M1-",teeth,"Z",partnerTeeth,".dxf");

module cycloidPinionWheel(wheelTeeth, wheelPartnerTeeth, pinionTeeth, pinionPartnerTeeth, wheelHeight, pinionHeight, wheelPitch, pinionPitch, boreDiam)
{
    rimWidth = 7;
    wheelRimDiam = wheelPitch * (wheelTeeth - 2.5) - 2*rimWidth;  // Smaller than dedendum
    pinionOutDiam = pinionPitch * (pinionTeeth + 2);  // Addendum
    spokeLength = (wheelRimDiam - pinionOutDiam) / 2;
	// Long spokes are wider.  Round to nearest 0.5 mm.
	spokeWidth = round( spokeLength / 10 / 2 ) * 2;
	// Number of spokes is a function of wheel diameter.  We limit the
	// outer circumference between two adjacent spokes.
    numSpokes =  spokeLength < 10 ? 0 : 6;
		//round(PI * wheelRimDiam / 50);
        //spokeLength < 10 ? 0
        //: (spokeLength < 20 ? 5 :
        //8);
    echo(str("Pwheel",wheelTeeth,"x",pinionTeeth," OD",wheelRimDiam," ID",pinionOutDiam," Spokes(",numSpokes," L",spokeLength," W",spokeWidth,")"));
    //isSpokes = wheelTeeth*wheelPitch/pinionTeeth/pinionPitch > 3 ? 1 : 0;
    difference()
    {
        union()
        {
            cycloidImportWheel(wheelTeeth, wheelPartnerTeeth, wheelPitch, wheelHeight,
                numSpokes ? wheelRimDiam : 0);

            if(numSpokes)
            {
                spokes(spokes_diam=wheelRimDiam, hub_diam=0, height = wheelHeight, width=spokeWidth, num_spokes=numSpokes);
            }
                        
            // Hub
            cylinder(h=wheelHeight, d=pinionOutDiam+negativeMargin);

            translate([0,0,wheelHeight])
            cycloidImportPinion(pinionTeeth, pinionPartnerTeeth, pinionPitch, pinionHeight);
        }
        
        cylinder(h=3 * (wheelHeight + pinionHeight), d=boreDiam, center=true);    
    }
}

module cycloidWheelDrum(teeth, partnerTeeth, wheelHeight, pitch, drumHeight, boreDiam)
{
    rimWidth = 7;
    wheelRimDiam = pitch * (teeth - 2.5) - 2*rimWidth;
    hub_diam = 3 * boreDiam;
    spokeLength = (wheelRimDiam - hub_diam) / 2;
	// Long spokes are wider.  Round to nearest 0.5 mm.
	spokeWidth = round( spokeLength / 10 / 2 ) * 2;
	// Number of spokes is a function of wheel diameter.  We limit the
	// outer circumference between two adjacent spokes.
    numSpokes =  spokeLength < 12 ? 0 : 5;
		//round(PI * wheelRimDiam / 50);
        //spokeLength < 10 ? 0
        //: (spokeLength < 20 ? 5 :
        //8);
    echo(str("Wdrum",teeth," OD",wheelRimDiam," Spokes(",numSpokes," L",spokeLength," W",spokeWidth,")"));
    difference()
    {
        union()
        {
            cycloidImportWheel(teeth, partnerTeeth, pitch, wheelHeight,
                numSpokes ? wheelRimDiam : 0);

            if(numSpokes)
                spokes(spokes_diam=wheelRimDiam, hub_diam=0, height = wheelHeight+drumHeight, width=spokeWidth, num_spokes=numSpokes);
            
            // Hub
            cylinder(h=wheelHeight+drumHeight, d=3*boreDiam);

            rootRadius=pitch*(teeth-2.5)/2;
            translate([0,0,wheelHeight])
            drum(radius=rootRadius, rimWidth=rimWidth, drumHeight=drumHeight, numberHoles=2, holeRadius=1.1, holeRotate=(72+15)/2);
        }
        
		// Bore
		cylinder(h=3*(wheelHeight+drumHeight), d=boreDiam, center=true);
    }
}

// Cycloid helper functions
//
module cycloidImportWheel(teeth, partnerTeeth, pitch, height, boreDiam)
{
    difference()
    {
        linear_extrude(height)
        //translate([-15 -5, 0, thickness*.9999])
        scale([pitch,pitch,1])
        import(cycloidFilename(teeth,partnerTeeth));
        
        if(boreDiam > 0)
            cylinder(h=3*height, d=boreDiam, center=true);
    }
}

module cycloidImportPinion(teeth, partnerTeeth, pitch, height)
{
    echo(str("Pinion: ", teeth, " Partner:", partnerTeeth));
    linear_extrude(height)
    scale([pitch,pitch,1])
	translate([-(teeth + partnerTeeth) / 2, 0])
    import(cycloidFilename(teeth,partnerTeeth));
}
