// Stacking frame for the PSU housing (part 1).
//
// This is an open ring, like the "change" sample: you can see through it.
// It is not a box with a lid. Top and bottom are flanges only.
//
// Hole grid is part 1's, so a frame stacks on the housing and on another
// frame. Local (0,0,0) is part 1's minimum corner.
//   part 1 hole X = -184.6 and 82.5  ->  7.5 mm from each end
//   part 1 hole Y = -95, -75 ... 85   ->  20, 40 ... 200
//   part 1 front/back Z = 43.5, 63.5, 83.5, 103.5, 123.5
//
// 9 mm pocket is on the side the screw head or nut sits, never on the
// face that touches the next part, so the joint is flat.
//   bottom flange: pocket on top
//   top flange:    pocket on the underside
//   front/back:    pocket on the outside
// M4, 5 mm clearance, 9 mm x 4 mm pocket.
//
// 45 degree: both ends flare OUT toward the top, with plastic under the
// slope. That is the printable side of part 1. The other end of part 1
// is mirrored (a lip with air under it) and is not copied here.
// Corner posts stay full width so the front and back holes stay whole.
// Print with the bottom flange on the bed.

/* [Part] */
part = "frame"; // [frame, cover, front, preview]

/* [Frame] */
frame_h = 150;     // hole faces UP. 150 fits all five front/back holes
flange = 10;
end_t = 16;        // left and right, holds the 9 mm pocket (centre is 7.5 mm in)
front_t = 10;      // front and back walls
lip = 4;           // flange sticks out past the front and back walls
post = 22;
flare = 8;         // 45 degree, both ends, same direction, at the TOP only

/* [Cover and front plate] */
cover_t = 6;
front_plate_t = 8;

/* [Screws] */
hole_d = 5;
cbore_d = 9;
cbore_h = 4;
pitch = 20;

/* [Hidden] */
size_x = 282.1;
size_y = 229.9;
$fn = 48;

hole_x = [7.5, size_x - 7.5];
hole_y = [for (i = [0:9]) 20 + i * pitch];          // 20 .. 200
face_z = [for (i = [0:4]) 43.5 + i * pitch];         // 43.5 .. 123.5

module screw_z(x, y, z0, z1, pocket) {
    translate([x, y, z0 - 0.2])
        cylinder(h = (z1 - z0) + 0.4, d = hole_d);
    if (pocket == "top")
        translate([x, y, z1 - cbore_h])
            cylinder(h = cbore_h + 0.2, d = cbore_d);
    else
        translate([x, y, z0 - 0.2])
            cylinder(h = cbore_h + 0.2, d = cbore_d);
}

// Horizontal hole along Y. Point of the teardrop is up.
// y_out is the face the 9 mm pocket opens on.
module screw_y(x, y_out, y_in, z) {
    y0 = min(y_out, y_in);
    y1 = max(y_out, y_in);
    translate([x, y0 - 0.2, z])
        rotate([-90, 0, 0])
            linear_extrude((y1 - y0) + 0.4)
                hull() {
                    circle(d = hole_d);
                    translate([0, hole_d / 2]) circle(d = 0.08, $fn = 6);
                }
    depth = min(cbore_h, (y1 - y0) - 1);
    if (y_out < y_in)
        translate([x, y_out - 0.2, z])
            rotate([-90, 0, 0])
                linear_extrude(depth + 0.2)
                    circle(d = cbore_d);
    else
        translate([x, y_out - depth, z])
            rotate([-90, 0, 0])
                linear_extrude(depth + 0.2)
                    circle(d = cbore_d);
}

module ring(z, h) {
    difference() {
        translate([0, 0, z]) cube([size_x, size_y, h]);
        translate([end_t, lip + front_t, z - 0.1])
            cube([size_x - 2 * end_t, size_y - 2 * (lip + front_t), h + 0.2]);
    }
}

// 45 degree, solid underneath. Outer face steps OUT as Z increases.
// Left: x = flare at the bottom of the slope, x = 0 at the top.
module flare_left(h) {
    z0 = h - flange - flare;
    hull() {
        translate([flare, 0, z0]) cube([0.02, size_y, 0.02]);
        translate([0, 0, z0 + flare]) cube([0.02, size_y, 0.02]);
        translate([end_t, 0, z0]) cube([0.02, size_y, 0.02]);
        translate([end_t, 0, z0 + flare]) cube([0.02, size_y, 0.02]);
    }
}

module flare_right(h) {
    z0 = h - flange - flare;
    hull() {
        translate([size_x - flare, 0, z0]) cube([0.02, size_y, 0.02]);
        translate([size_x, 0, z0 + flare]) cube([0.02, size_y, 0.02]);
        translate([size_x - end_t, 0, z0]) cube([0.02, size_y, 0.02]);
        translate([size_x - end_t, 0, z0 + flare]) cube([0.02, size_y, 0.02]);
    }
}

module frame(h) {
    z_wall = flange;
    wall_h = h - 2 * flange;
    recess_h = wall_h - flare;
    difference() {
        union() {
            ring(0, flange);
            ring(h - flange, flange);
            // front and back walls, set in so the flange is the rim
            translate([0, lip, z_wall])
                cube([size_x, front_t, wall_h]);
            translate([0, size_y - lip - front_t, z_wall])
                cube([size_x, front_t, wall_h]);
            // corner posts, full outer width, both ends the same
            for (x = [0, size_x - end_t])
                for (y = [0, size_y - post])
                    translate([x, y, z_wall])
                        cube([end_t, post, wall_h]);
            // end walls between the posts, set in by the flare
            if (recess_h > 0) {
                translate([flare, post, z_wall])
                    cube([end_t - flare, size_y - 2 * post, recess_h]);
                translate([size_x - end_t, post, z_wall])
                    cube([end_t - flare, size_y - 2 * post, recess_h]);
            }
            // both ends flare out the same way. Not mirrored.
            flare_left(h);
            flare_right(h);
        }
        // stack holes. Pocket on top of the bottom flange, under the top flange.
        for (x = hole_x)
            for (y = hole_y) {
                screw_z(x, y, 0, flange, "top");
                screw_z(x, y, h - flange, h, "bottom");
            }
        // front and back columns. Skip any hole the flare would cut open.
        z_max = h - flange - flare - cbore_d / 2 - 1;
        for (z = face_z)
            if (z > flange + cbore_d / 2 + 1 && z < z_max)
                for (x = hole_x) {
                    screw_y(x, 0, lip + front_t, z);
                    screw_y(x, size_y, size_y - lip - front_t, z);
                }
    }
}

module cover() {
    difference() {
        cube([size_x, size_y, cover_t]);
        for (x = hole_x)
            for (y = hole_y)
                screw_z(x, y, 0, cover_t, "top");
    }
}

// Closes the front of a frame. Pocket on the outside (y = thickness).
module front_plate(h) {
    difference() {
        cube([size_x, front_plate_t, h]);
        z_max = h - flange - flare - cbore_d / 2 - 1;
        for (z = face_z)
            if (z > flange + cbore_d / 2 + 1 && z < z_max)
                for (x = hole_x)
                    screw_y(x, front_plate_t, 0, z);
    }
}

module preview() {
    frame(frame_h);
    translate([0, 0, frame_h + 30])
        frame(frame_h);
    translate([0, size_y + 40, 0])
        cover();
    translate([0, -front_plate_t - 30, 0])
        front_plate(frame_h);
}

if (part == "frame") frame(frame_h);
else if (part == "cover") cover();
else if (part == "front") front_plate(frame_h);
else if (part == "preview") preview();
