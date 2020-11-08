use <threads.scad>
include <Hardware.scad>
use <Utilities.scad>
use <MCAD/regular_shapes.scad>
use <rounded.scad>

// Quality settings
$fs = 1.00;                 // minimum size of an arc fragment
$fa = 360/128;              // minimum angle of an arc fragment

bob_diam = inches(6);
thread_diam = inches(3/8);
thread_pitch = inches(1/16);

LOOSE=0.1;

face_thk = 2;
slider_hole_dia = inches(0.500);        // Dowel 1/2"
lower_thk = slider_hole_dia + 4*face_thk;
slider_dims = [
    bob_diam/2,                         // length
    slider_hole_dia + 2*face_thk,     // width
    slider_hole_dia + 2*face_thk      // thick/height
];

pendulum_bob_lower_half();

//translate([0,0,0.5])  // Explode
//pendulum_bob_upper_half(screw_depth=5.5);

//translate([40,60,20])
//slider(slider_dims);

// Print slider nut in two halves
if(0)
{
    translate([0,140,0])
    {
        slider(slider_dims, printside=1);

        translate([0, 6 + slider_dims[1], slider_dims[2]])
        rotate([180,0,0])
        slider(slider_dims, printside=-1);
    }
}

//pendulum_decorative_nut();
translate([bob_diam/2 + 18, 20,0])
pendulum_wingnut();

//translate([-bob_diam,100,0])
//pendulum_dowel_end(slider_hole_dia);



module pendulum_bob_lower_half()
{
    bob_rad = bob_diam/2;
    inner_rad = (bob_diam - lower_thk)/2;
    slider_wid = slider_dims[1];
    slider_length = slider_dims[0];
    slider_thk = slider_dims[2];

    union()
    {
        // Outer wall (ring)
        difference()
        {
            cylinder(h=lower_thk,   r1=bob_rad, r2=inner_rad+1);
            translate([0,0,-1e-2])
            cylinder(h=lower_thk+2e-2, r1=bob_rad - face_thk, r2=inner_rad-3);
            
            if(0)
            {
                translate([0,0,lower_thk/2])
                torus2(inner_rad, lower_thk/2);

                // Convex inner face holds concrete after it sets.
                translate([0,0,lower_thk/2])
                scale([1-2/bob_rad, 1-2/bob_rad, 1-2/lower_thk])
                torus2(inner_rad, lower_thk/2);
            }

            // Recess to accept front cover
            translate([0,0,lower_thk - face_thk + 1e-2])
            cylinder(r=inner_rad + LOOSE, h=face_thk + 1e-2);
            
            // Hole for slider
            translate([0,0, (3*face_thk + slider_thk + LOOSE)/2])
            cube([bob_diam + 1e-2, slider_wid+2*LOOSE,
                face_thk + slider_thk + 2*LOOSE],center=true);
        }
        
        // Internal walls to support slider
        translate([0, 0, face_thk + slider_thk/2])
        intersection()
        {
            difference()
            {
                // Outer face of slider wall
                wall_thk = face_thk;
                cube([bob_diam, slider_wid+2*wall_thk, slider_thk],center=true);
                // Inner face of wall
                cube([bob_diam + 1e-2, slider_wid+2*LOOSE, slider_thk+1e-2],center=true);
            }
            
            // Chop ends of wall flush with perimeter of the bob.
            union()
            {
                if(0) torus2(inner_rad, lower_thk/2);
                cylinder(h=slider_thk, r1=bob_rad - 1, r2=inner_rad-1, center=true);
                
            }
        }
        
        difference()
        {
            union()
            {
                // Bottom face
                cylinder(h=face_thk, r=bob_rad-1);
                // Screw bosses
                place_screws()
                {
                    translate([0,0, face_thk-1e-2])
                    {
                        boss_diam = 2*woodscrew_no5_male_diam;
                        cylinder(h=slider_thk+1e-2, d=boss_diam);
                        cylinder(h=boss_diam/4/tan(45), r1=boss_diam*3/4, r2=boss_diam/2);
                    }
                }
            }
            // Screw holes
            place_screws()
            {
                woodscrew_no5_upperhole(inches(0.875));
            }
        }
    }
}

module pendulum_bob_upper_half(screw_depth)
{
    thick = 8.5; //lower_thk;
    r = 300;  // Radius of sphere
    
    // Spherical face
    translate([0,0, lower_thk - face_thk])
    difference()
    {
        translate([0,0, thick/2])
        intersection()
        {
            //translate([0,0, -thick/8])
            cylinder(h=thick, r=(bob_diam - lower_thk)/2, center=true);
            
            translate([0, 0, -r + thick/2])
            sphere(r=r, $fn=128);
        }
        // Screw holes
        place_screws()
        {
            translate([0,0,thick-1e-2])
            cylinder(h=screw_depth, d=woodscrew_no5_root_diam);
        }
    }
}

module slider(dims, printside=0)
{
    slider_wid = dims[1];
    length = dims[0];
    slider_thk = dims[2];
    translate([0,0, face_thk + slider_thk/2])
    {
        intersection()
        {
            difference()
            {
                cube([length, slider_wid, slider_thk], center=true);
             
                rotate([0,90,0])
                {
                    // Dowel hole: from centre out to +Z end
                    translate([0,0,-1e-2])
                    cylinder(h=length/2 + 4e-1, d=slider_hole_dia + LOOSE);
                        
                    // Hole for 3/8-16 threaded rod: from centre out to -Z end
                    scale([1,1,-1])
                    metric_thread (diameter=thread_diam + .1, pitch=thread_pitch,
                        length=length/2 + 1e-1, internal=true, n_starts=1);
                }
            }
            
            if(printside != 0)
            {
                // Cut away half the object if desired
                translate([0,0, printside*-slider_thk/2])
                cube([length, slider_wid, slider_thk],center=true);
            }
            else
            {
                translate([0,0, -slider_thk/2])
                cube([length,slider_wid, slider_thk*2], center=true);
            }
                
        }
    }
}

module pendulum_decorative_nut()
{
    difference()
    {
        sphere_d = 8/3 * thread_diam;
        sphere(d = sphere_d);
    
        translate([0, 0, -1/4 * sphere_d])
        metric_thread(diameter=thread_diam + .1, pitch=thread_pitch, length=3/4*sphere_d, internal=true,
                n_starts=1);
    }
}

module pendulum_wingnut()
{
    od = 2.25 * thread_diam;
    h = 1*thread_diam;
    intersection()
    {
        // Outer face is a squished sphere
        translate([0,0,h/2])
        scale([1,1,2.25*h/od])
        sphere(d=od);
            
        difference()
        {
            union()
            {
                cylinder(d = od, h=h);
                for(i = [0:1:3])
                {
                    //rotate([0,0,45+i*90])
                    //translate([od/2,0,-1e-2])
                    //cylinder(d=od-1, h=h+2e-2);
                }
            }
            
            n = 12;
            for(i = [0:1:n-1])
            {
                rotate([0,0,i*360/n])
                translate([od/2,0,-1e-2])
                cylinder(d=od/8, h=h+2e-2);
            }
        
            translate([0, 0, -1e-2])
            metric_thread(diameter=thread_diam + .1, pitch=thread_pitch, length=h + 2e-2, internal=true,
                    n_starts=1);
        }
    }
}

module pendulum_dowel_end(slider_hole_dia)
{
    dowel_dia = inches(0.500);
    h_sleeve = dowel_dia + 2;
    hole_depth = dowel_dia;
    h_pin = 20;
    // Sleeve, glues onto end of dowel.
    difference()
    {
        cylinder(h=h_sleeve, d=dowel_dia + 5);
        translate([0,0,-1e-2])
        {
            cylinder(h=hole_depth+1e-2, d=dowel_dia);
        }
    }
    // Pin fits into slider with glue
    translate([0,0,h_sleeve])
    {
        cylinder(h=h_pin, d=slider_hole_dia);
    }
    //translate([0,0,h1+2])
    //rotate([0,-90,0])fillet3d(r=(h2-h1)/2, h=4, $fs=.8);
}

module place_screws()
{
    n = 6;
    for(i = [0:1:n-1])
    {
        rotate([0, 0, (i+.5) * 360/n])
        translate([bob_diam*0.3,0, -1e-2])
        children();
    }
}
