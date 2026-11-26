// Caixa de eletronica do mini elevador: painel de comando com LCD, joystick,
// botao de parada e LED na tampa; protoboards, entradas de alimentacao,
// USB e saida de cabos na caixa. Serve as duas versoes da torre.
//
// Uso:  openscad -D "part=\"caixa\"" -o stl/caixa.stl painel.scad
// Pecas: caixa, tampa, montagem
//
// Unidades em mm. X = largura, Y = frente(-)/fundo(+), Z = altura.
// COTAS DOS MODULOS SAO NOMINAIS: conferir com as pecas reais antes de imprimir.

part = "montagem";

$fn = 64;
eps = 0.01;

// ---------- Caixa ----------
box_x   = 200;
box_y   = 130;
box_h   = 50;           // altura da caixa sem a tampa
wall    = 2.5;
floor_t = 2.5;
box_r   = 6;
boss_d  = 8;
boss_in = 7;            // centro dos pilares a partir da borda externa
pilot_d = 2.8;          // M3 abre rosca no pilar
pass_d  = 3.4;          // M3 passante na tampa

// ---------- Protoboards no fundo (encaixe com borda) ----------
bb_gap  = 0.6;          // folga em volta da protoboard
bb_rim  = 2;            // altura da borda
bb1 = [83, 55];  bb1_c = [-52, -30];   // 400 pontos: placa STM32
bb2 = [47, 35];  bb2_c = [ 55, -38];   // 170 pontos: TB6612FNG e conversor de nivel

// ---------- Furos das paredes ----------
usb_w = 14;  usb_z0 = 13;  usb_z1 = 25;   // USB da placa, parede esquerda
dc_d  = 11;  dc_z = 15;                    // jaques P4 de painel, parede de tras
dc_x  = [-70, -45];                        // 5 V e alimentacao do motor
cab_x0 = 5;  cab_x1 = 35;  cab_dz = 12;    // entalhe para os cabos da torre

// ---------- Tampa e componentes ----------
lid_t   = 3;
lcd_c   = [-45, 22];
lcd_win = [72, 25];     // abertura para o modulo do LCD 1602
lcd_sp  = [75, 31];     // furos do LCD 1602 (80 x 36)
lcd_h   = 4;            // pilares: frente do LCD alinhada com a tampa
joy_c   = [40, -15];
joy_hole = 24;          // furo do joystick KY-023
joy_sp  = [26.5, 20.5]; // furos do KY-023 (nominal, conferir)
joy_h   = 8;            // pilares do joystick
stop_c  = [80, 40];  stop_d = 16;   // botao de parada
led_c   = [80, -45]; led_d = 5;     // LED de estado

// ============================================================

module placa(x, y, t, r) {
    hull() for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(x/2 - r), sy*(y/2 - r), 0]) cylinder(r = r, h = t);
}

module cantos() {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(box_x/2 - boss_in), sy*(box_y/2 - boss_in), 0]) children();
}

module borda_pb(tam, c) {
    translate([c[0], c[1], floor_t - eps]) difference() {
        translate([-tam[0]/2 - bb_gap - 1.5, -tam[1]/2 - bb_gap - 1.5, 0])
            cube([tam[0] + 2*bb_gap + 3, tam[1] + 2*bb_gap + 3, bb_rim]);
        translate([-tam[0]/2 - bb_gap, -tam[1]/2 - bb_gap, -1])
            cube([tam[0] + 2*bb_gap, tam[1] + 2*bb_gap, bb_rim + 2]);
    }
}

module caixa() {
    difference() {
        union() {
            difference() {
                placa(box_x, box_y, box_h, box_r);
                translate([0, 0, floor_t]) placa(box_x - 2*wall, box_y - 2*wall, box_h, box_r - wall);
            }
            cantos() cylinder(d = boss_d, h = box_h);
            borda_pb(bb1, bb1_c);
            borda_pb(bb2, bb2_c);
        }
        cantos() translate([0, 0, box_h - 12]) cylinder(d = pilot_d, h = 13);
        // USB da placa STM32
        translate([-box_x/2 - 1, bb1_c[1] - usb_w/2, floor_t + usb_z0]) cube([wall + 2, usb_w, usb_z1 - usb_z0]);
        // jaques de alimentacao
        for (x = dc_x) translate([x, box_y/2 + 1, floor_t + dc_z]) rotate([90, 0, 0]) cylinder(d = dc_d, h = wall + 2);
        // entalhe para os cabos da torre (fechado pela tampa)
        translate([cab_x0, box_y/2 - wall - 1, box_h - cab_dz]) cube([cab_x1 - cab_x0, wall + 2, cab_dz + 1]);
        // fixacao na bancada
        for (sx = [-1, 1]) translate([sx*30, 20, -eps]) cylinder(d = 4.5, h = floor_t + 1);
    }
}

// Tampa modelada com a face de cima em z = lid_t e pilares para baixo.
module pilares(c, sp, h) {
    for (sx = [-1, 1], sy = [-1, 1]) translate([c[0] + sx*sp[0]/2, c[1] + sy*sp[1]/2, -h])
        difference() { cylinder(d = 6, h = h + eps); translate([0, 0, -1]) cylinder(d = 2.5, h = h); }
}

module tampa() {
    difference() {
        union() {
            placa(box_x, box_y, lid_t, box_r);
            pilares(lcd_c, lcd_sp, lcd_h);
            pilares(joy_c, joy_sp, joy_h);
        }
        cantos() translate([0, 0, -1]) cylinder(d = pass_d, h = lid_t + 2);
        translate([lcd_c[0] - lcd_win[0]/2, lcd_c[1] - lcd_win[1]/2, -1]) cube([lcd_win[0], lcd_win[1], lid_t + 2]);
        translate([joy_c[0], joy_c[1], -1]) cylinder(d = joy_hole, h = lid_t + 2);
        translate([stop_c[0], stop_c[1], -1]) cylinder(d = stop_d, h = lid_t + 2);
        translate([led_c[0], led_c[1], -1]) cylinder(d = led_d, h = lid_t + 2);
        // legendas gravadas
        for (t = [["PARADA", stop_c, -14], ["FALHA", led_c, 7], ["SELECAO", joy_c, -18]])
            translate([t[1][0], t[1][1] + t[2], lid_t - 0.6]) linear_extrude(1)
                text(t[0], size = 4, halign = "center", valign = "center");
    }
}

// ============================================================
// Montagem (apenas visualizacao)
// ============================================================

module montagem() {
    color("slategray") caixa();
    translate([0, 0, box_h]) color("lightsteelblue") tampa();
    // protoboards e modulos
    color("white") {
        translate([bb1_c[0] - bb1[0]/2, bb1_c[1] - bb1[1]/2, floor_t]) cube([bb1[0], bb1[1], 8.5]);
        translate([bb2_c[0] - bb2[0]/2, bb2_c[1] - bb2[1]/2, floor_t]) cube([bb2[0], bb2[1], 8.5]);
    }
    color("black") translate([bb1_c[0] - 53/2 - 12, bb1_c[1] - 10.5, floor_t + 17]) cube([53, 21, 1.6]);
    color("crimson") translate([bb2_c[0] - 18, bb2_c[1] - 10, floor_t + 17]) cube([20, 20, 1.6]);
    color("purple") translate([bb2_c[0] + 6, bb2_c[1] - 7, floor_t + 17]) cube([14, 13, 1.6]);
    // LCD, joystick, parada e LED
    translate([0, 0, box_h]) {
        color("darkgreen") translate([lcd_c[0] - 40, lcd_c[1] - 18, -lcd_h - 1.6]) cube([80, 36, 1.6]);
        color("dimgray") translate([lcd_c[0] - 35.5, lcd_c[1] - 12, -lcd_h]) cube([71, 24, lcd_h + lid_t]);
        color("darkgreen") translate([joy_c[0] - 17, joy_c[1] - 13, -joy_h - 1.6]) cube([34, 26, 1.6]);
        color("black") translate([joy_c[0], joy_c[1], -joy_h]) cylinder(d = 16, h = joy_h + lid_t + 2);
        color("black") translate([joy_c[0], joy_c[1], lid_t + 2]) cylinder(d = 22, h = 8);
        color("red") translate([stop_c[0], stop_c[1], lid_t]) cylinder(d = 22, h = 9);
        color("gold") translate([stop_c[0], stop_c[1], -25]) cylinder(d = 14, h = 25);
        color("orange") translate([led_c[0], led_c[1], 0]) cylinder(d = 5, h = lid_t + 4);
    }
}

if (part == "caixa") caixa();
else if (part == "tampa") rotate([180, 0, 0]) tampa();
else montagem();
