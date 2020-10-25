
module perimeter_round_ends(corners, width, thick)
{
    // Extend a linear member between corner holes
    for(i = [1:len(corners)] )
    {
        arm_round_ends(corners[i-1], corners[i%len(corners)], width, thick);
    }
}

module perimeter_girder(corners, width, height, thick)
{
    // Extend a linear member between corner holes
    for(i = [1:len(corners)] )
    {
        girder_round_ends(corners[i-1], corners[i%len(corners)], width, height, thick);
    }
}

// Draw a rectangle with two rounded ends (====)
module arm_round_ends(p1, p2, width, height)
{
    hull() {
        for(p = [p1,p2])
        {
            translate(p) cylinder(d=width,h=height);
        }
    }
}
// Draw a T-profile girder with two rounded ends (====)
// TODO three dimensional inputs!
module girder_round_ends(p1, p2, width, height, thick)
{
    arm_round_ends(p1, p2, width, thick);
    // Extend rectangles to fully overlap with others (hackish)
    dir = (p2 - p1) / norm(p2 - p1);
    arm_square_ends( p1 - dir*thick*.5, p2 + dir*thick*.5, thick, height);
}

// Draw a T-profile girder with two rounded ends (====)
// TODO three dimensional inputs!
module girder_square_ends(p1, p2, width, height, thick)
{
    arm_square_ends(p1, p2, width, thick);
    arm_square_ends(p1, p2, thick, height);
}

// Draw a rectangular 3D member between two points.
// TODO three dimensional inputs!
module arm_square_ends(p1, p2, width, height) {
    
    disp = concat(p2 - p1, 0);
    dir = disp / norm(disp);
    ortho = cross([0,0,1], dir);
    linear_extrude(height)
    polygon([
        p1 + width/2 * ortho,
        p1 - width/2 * ortho,
        p2 - width/2 * ortho,
        p2 + width/2 * ortho]);
}


// Draw a rectangular 3D member between two points.
// TODO three dimensional inputs!
module arm_square_ends(points, width, height) {
    
    disp = concat(p2 - p1, 0);
    dir = disp / norm(disp);
    ortho = cross([0,0,1], dir);
    linear_extrude(height)
    polygon([
        p1 + width/2 * ortho,
        p1 - width/2 * ortho,
        p2 - width/2 * ortho,
        p2 + width/2 * ortho]);
}
