include <nuts_and_bolts.scad>;
use <fingerjoint.scad>;

$fn = 124;

SIZE_X = 92;
SIZE_Y = 85;
SIZE_Z = 23.8;
BOX_Z = 1.9;
FINGER = 7.5;

T = 0.05;

m2_standoff = ["M2 Standoff", 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0];

sides_assembly();
standoff_assembly();
%box();
corners();

//%box_assembly();

//!corner_support_with_holes(10);
//!box_flat();

module box_flat() {
    side(SIZE_X, SIZE_Y, false, true);
    translate([SIZE_X + 1, 0, 0]) side(SIZE_X, SIZE_Y, false, true);
    translate([0, SIZE_X / 2 + SIZE_Z / 2 - 2, 0]) side(SIZE_X, SIZE_Z, true, true);
    translate([SIZE_X + 1, SIZE_X / 2 + SIZE_Z / 2 - 2, 0]) side(SIZE_X, SIZE_Z, true, true);
    translate([0 , SIZE_X / 2 + SIZE_Z * 2 - 12, 0]) side(SIZE_Y, SIZE_Z, false, false);
    translate([SIZE_X + 1, SIZE_X / 2 + SIZE_Z * 2 - 12, 0]) side(SIZE_Y, SIZE_Z, false, false);
}


module box_assembly() {
    // XY: SIZE_X, SIZE_Y, false, true
    // YZ: SIZE_Y, SIZE_Z, false, false
    // XZ: SIZE_X, SIZE_Z, true, true
    
    // left / right
    for (i = [-1, 1]) {
        translate([i * SIZE_X / 2 + i * -BOX_Z / 2, 0, 0])
            rotate([90, 0, 90])
            linear_extrude(height = BOX_Z, center = true) side(SIZE_Y, SIZE_Z, false, false);
     }
     // front / back
     for (i = [-1, 1]) {
        translate([0, i * SIZE_Y / 2 + i * -BOX_Z / 2, 0])
            rotate([90, 0, 0])
            linear_extrude(height = BOX_Z, center = true) side(SIZE_X, SIZE_Z, true, true);
        }
     // top / bottom
     for (i = [-1, 1]) {
        translate([0, 0, i * SIZE_Z / 2 + i * -BOX_Z / 2])
        linear_extrude(height = BOX_Z, center = true) side(SIZE_X, SIZE_Y, false, true);
    }
}

module side(x, y, xc = true, yc = true) {
    difference() {
        square([x, y], center = true);

        for (i = [-1, 1]) {
            // X edges fingers
            translate([0, i * y / 2 + i * -BOX_Z / 2, 0])
                if (xc) {
                    insideCuts(length = x, finger = FINGER, material = BOX_Z, text = false, center = true);
                } else {
                    outsideCuts(length = x, finger = FINGER, material = BOX_Z, text = false, center = true);
                }
            // Y edges fingers
            translate([i * x / 2 + i * -BOX_Z / 2, 0, 0]) rotate([0, 0, 90])
                if (yc) {
                    insideCuts(length = y, finger = FINGER, material = BOX_Z, text = false, center = true);
                } else {
                    outsideCuts(length = x, finger = FINGER, material = BOX_Z, text = false, center = true);
                }
        }
        
        // holes
        for (xi = [-1, 1]) {
            for (yi = [-1, 1]) {
                translate([(x / 2 - BOX_Z - 5) * xi, (y / 2 - BOX_Z - 5) * yi, 0])
                    circle(d = 2 - T);
            }
        }
    }
}

module box() {
    //color("gray", 0.9)
    difference() {
        box_assembly();
        //cube([SIZE_X, SIZE_Y, SIZE_Z]);
        for (x = [-1, 1]) {
            for (y = [-1, 1]) {
                for (z = [-1, 1]) {
                    translate([(SIZE_X / 2) * x, (SIZE_Y / 2) * y, (SIZE_Z / 2 - BOX_Z - 5) * z]) {
                        translate([(-BOX_Z - 3.5 + T) * x, (-BOX_Z - 5) * y, 0]) rotate([x < 0 ? -90 : 90, 180, 90])
                            countersunkBoltHole(size = metric_fastener[2], length = 5, tolerance = 0.1);
                        translate([(-BOX_Z - 5) * x, (-BOX_Z - 3.5 + T) * y, 0]) rotate([y < 0 ? 90 : -90, 0, 0])
                            countersunkBoltHole(size = metric_fastener[2], length = 5, tolerance = 0.1);
                        translate([(-BOX_Z - 5) * x, (-BOX_Z - 5) * y, (BOX_Z + T) * z]) rotate([0, z < 0 ? 180 : 0, 0])
                            countersunkBoltHole(size = metric_fastener[2], length = 5, tolerance = 0.1);

                    }
                }
            }
        }
    }
}

module sides_assembly() {
    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            for (z = [-1, 1]) {
                translate([(SIZE_X / 2) * x, (SIZE_Y / 2) * y, (SIZE_Z / 2 - BOX_Z - 5) * z]) {
                    translate([(-BOX_Z - 1) * x, (-BOX_Z - 5) * y, 0]) rotate([x < 0 ? 90 : -90, 180, 90])
                        nut_bolt_side();
                    translate([(-BOX_Z - 5) * x, (-BOX_Z - 1) * y, 0]) rotate([y < 0 ? -90 : 90, 0, 0])
                        nut_bolt_side();
                }
            }
        }
    }
}

module corners() {
    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            translate([(SIZE_X / 2 - BOX_Z) * x, (SIZE_Y / 2 - BOX_Z) * y, -SIZE_Z / 2]) {
                translate([0, 0, BOX_Z + T / 2]) rotate([0, 0, y * -90 - (x == y ? 90 : 0)]) corner_support_with_holes(10);
                translate([0, 0, SIZE_Z - BOX_Z - T / 2]) rotate([180, 0, 90 + y * -90 - (x == y ? 90 : 0)]) corner_support_with_holes(10);
            }
        }
    }
}

module standoff_assembly() {
    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            translate([(SIZE_X / 2 - BOX_Z - 5) * x, (SIZE_Y / 2 - BOX_Z - 5) * y, -SIZE_Z / 2]) {
                translate([0, 0, BOX_Z + 1]) rotate([0, 0, x != y ? 90 : 0]) standoff(SIZE_Z - BOX_Z * 2 - 2);
                translate([0, 0, SIZE_Z - 4 + T])
                    bolt(size = metric_fastener[2], length = 4, head = "flatSocket", threadType = "none");
                translate([0, 0, 4 - T]) rotate([180, 0, 0])
                    bolt(size = metric_fastener[2], length = 4, head = "flatSocket", threadType = "none");
            }
        }
    }
}

module standoff(height) {
    /*difference() {
        cylinder(r = 1.5, h = height);
        translate([0, 0, -0.05]) cylinder(r = 1, h = height + 0.1);
    }*/
    echo(height);
    difference() {
        rotate([0, 0, 45]) nutHole(size = m2_standoff, tolerance = 0, h = height);
        translate([0, 0, - T]) boltHole(size = metric_fastener[2], length = height + T * 2);
    }
}

module nut_bolt_side() {
    nut(metric_fastener[2], threadType = "none");
    translate([0, 0, 4 - BOX_Z - 1]) rotate([0, 180, 0]) bolt(size = metric_fastener[2], length = 4, head = "flatSocket", threadType = "none");
}

// corner support functions
module corner_support_with_holes(size) {
    difference() {
        corner_support(size);
        translate([5, 1, 5]) rotate([90, 0, 180]) nut_bolt_hole(2);
        translate([1, 5, 5]) rotate([90, 0, 90]) nut_bolt_hole(2);
        translate([5, 5, 1]) rotate([0, 0, 45]) nut_bolt_hole(2, true);
    }
}

module corner_support(size) {
    color("black") 
    intersection() {
        cube([size - 0.5, size - 0.5, size - 0.5]);
        union() {
            corner_support_side(size);
            rotate([0, -90, -90]) corner_support_side(size);
            translate([2.5, 0, 0]) rotate([0, -90, 0]) corner_support_side(size);
        }
    }
}

module corner_support_side(size) {
    intersection() {
        cube([size, size, 2.5]);
        cylinder(r=size, h=2.5);
    }
}

module nut_bolt_hole(size, standoff = false) {
    translate([0, 0, -1.9]) boltHole(size = metric_fastener[size], length = 2);
    if (standoff) {
        nutHole(size = m2_standoff, h = 2);
    } else {
        nutHole(size = metric_fastener[size], h = 2);
    }
}