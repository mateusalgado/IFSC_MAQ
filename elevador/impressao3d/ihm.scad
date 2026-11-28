// IHM do mini elevador: modulo esquerdo da base unica. Caixa de comando com LCD,
// joystick, botoes de andar (T, 1, 2), botao de emergencia e LED na tampa;
// protoboards, entradas de alimentacao e USB na caixa. A parede direita se
// aparafusa na flange da base da torre (ver comum.scad) e deixa passar os cabos.
//
// Usada por elevador.scad. Sozinha: openscad -D "part=\"ihm_caixa\"" ihm.scad
// Pecas: ihm_caixa, ihm_tampa, anel_parada, ihm_montagem
//
// Unidades em mm. X = largura, Y = frente(-)/fundo(+), Z = altura.
// COTAS DOS MODULOS SAO NOMINAIS: conferir com as pecas reais antes de imprimir.

include <comum.scad>

part = "ihm_montagem";

$fn = 64;
eps = 0.01;

// ---------- Caixa ----------
box_x   = ihm_box_x;
box_y   = ihm_box_y;
box_h   = 50;           // altura da caixa sem a tampa
wall    = 2.5;
floor_t = 2.5;
box_r   = 6;
boss_d  = 8;
boss_in = 7;            // centro dos pilares a partir da borda externa
pilot_d = 2.8;          // M3 abre rosca no pilar
pass_d  = 3.4;          // M3 passante

// ---------- Protoboards no fundo (encaixe com borda) ----------
bb_gap  = 0.6;
bb_rim  = 2;
bb1 = [83, 55];  bb1_c = [-52, -30];   // 400 pontos: placa STM32
bb2 = [47, 35];  bb2_c = [ 55, -38];   // 170 pontos: TB6612FNG e conversor de nivel

// ---------- Furos das paredes ----------
usb_w = 14;  usb_z0 = 13;  usb_z1 = 25;   // USB da placa, parede esquerda
dc_d  = 11;  dc_z = 15;                    // jaques P4 de painel, parede de tras
dc_x  = [-70, -45];                        // 5 V e alimentacao do motor

// ---------- Tampa: painel de comando ----------
lid_t    = 3;
lcd_c    = [-35, 30];
lcd_win  = [72, 25];      // abertura para o modulo do LCD 1602
lcd_sp   = [75, 31];      // furos do LCD 1602 (80 x 36)
lcd_h    = 4;             // pilares: frente do LCD alinhada com a tampa
joy_c    = [-55, -32];
joy_hole = 24;            // furo do joystick KY-023
joy_sp   = [26.5, 20.5];  // furos do KY-023 (nominal, conferir)
joy_h    = 8;
btn_d    = 12.4;          // botoes de andar de 12 mm com rosca
btn_x    = 30;
btn_y    = [-28, -3, 22]; // T, 1, 2: de baixo para cima, como na cabine
stop_c   = [75, 5];
stop_d   = 22.4;          // botao de emergencia padrao 22 mm
ring_od  = 42;            // anel amarelo de fundo da emergencia
led_c    = [75, -45];
led_d    = 5;


// ============================================================

module ihm_placa(x, y, t, r) {
    hull() for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(x/2 - r), sy*(y/2 - r), 0]) cylinder(r = r, h = t);
}

module ihm_cantos() {
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

module ihm_caixa() {
    difference() {
        union() {
            difference() {
                ihm_placa(box_x, box_y, box_h, box_r);
                translate([0, 0, floor_t]) ihm_placa(box_x - 2*wall, box_y - 2*wall, box_h, box_r - wall);
            }
            ihm_cantos() cylinder(d = boss_d, h = box_h);
            borda_pb(bb1, bb1_c);
            borda_pb(bb2, bb2_c);
        }
        ihm_cantos() translate([0, 0, box_h - 12]) cylinder(d = pilot_d, h = 13);
        translate([-box_x/2 - 1, bb1_c[1] - usb_w/2, floor_t + usb_z0]) cube([wall + 2, usb_w, usb_z1 - usb_z0]);
        for (x = dc_x) translate([x, box_y/2 + 1, floor_t + dc_z]) rotate([90, 0, 0]) cylinder(d = dc_d, h = wall + 2);
        // juncao com a base da torre: parafusos M3 por dentro e passagem dos cabos
        for (y = junta_y) translate([box_x/2 - wall - 1, y - ihm_cy, junta_z]) rotate([0, 90, 0]) cylinder(d = pass_d, h = wall + 2);
        translate([box_x/2 - wall - 1, cabo_y - ihm_cy - cabo_w/2, cabo_z0]) cube([wall + 2, cabo_w, cabo_z1 - cabo_z0]);
    }
}

module pilares(c, sp, h) {
    for (sx = [-1, 1], sy = [-1, 1]) translate([c[0] + sx*sp[0]/2, c[1] + sy*sp[1]/2, -h])
        difference() { cylinder(d = 6, h = h + eps); translate([0, 0, -1]) cylinder(d = 2.5, h = h); }
}

module legenda(t, pos, size = 4) {
    translate([pos[0], pos[1], lid_t - 0.6]) linear_extrude(1)
        text(t, size = size, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
}

// Tampa modelada com a face de cima em z = lid_t e pilares para baixo.
module ihm_tampa() {
    difference() {
        union() {
            ihm_placa(box_x, box_y, lid_t, box_r);
            pilares(lcd_c, lcd_sp, lcd_h);
            pilares(joy_c, joy_sp, joy_h);
        }
        ihm_cantos() translate([0, 0, -1]) cylinder(d = pass_d, h = lid_t + 2);
        translate([lcd_c[0] - lcd_win[0]/2, lcd_c[1] - lcd_win[1]/2, -1]) cube([lcd_win[0], lcd_win[1], lid_t + 2]);
        translate([joy_c[0], joy_c[1], -1]) cylinder(d = joy_hole, h = lid_t + 2);
        for (y = btn_y) translate([btn_x, y, -1]) cylinder(d = btn_d, h = lid_t + 2);
        translate([stop_c[0], stop_c[1], -1]) cylinder(d = stop_d, h = lid_t + 2);
        translate([led_c[0], led_c[1], -1]) cylinder(d = led_d, h = lid_t + 2);
        // legendas gravadas
        for (i = [0 : 2]) legenda(["T", "1", "2"][i], [btn_x - 15, btn_y[i]], 6);
        legenda("ANDAR", [btn_x, btn_y[2] + 14]);
        legenda("EMERGENCIA", [stop_c[0], stop_c[1] - ring_od/2 - 5], 3.5);
        legenda("FALHA", [led_c[0], led_c[1] + 8]);
        legenda("SELECIONA / CONFIRMA", [joy_c[0], joy_c[1] + 19], 3.5);
    }
}

// Anel amarelo de fundo do botao de emergencia (imprimir em filamento amarelo).
module anel_parada() {
    difference() {
        cylinder(d = ring_od, h = 1.6);
        translate([0, 0, -1]) cylinder(d = stop_d, h = 4);
    }
}


// ============================================================
// Montagem (apenas visualizacao)
// ============================================================

module ihm_montagem() {
    color("slategray") ihm_caixa();
    translate([0, 0, box_h]) color("lightsteelblue") ihm_tampa();
    color("white") {
        translate([bb1_c[0] - bb1[0]/2, bb1_c[1] - bb1[1]/2, floor_t]) cube([bb1[0], bb1[1], 8.5]);
        translate([bb2_c[0] - bb2[0]/2, bb2_c[1] - bb2[1]/2, floor_t]) cube([bb2[0], bb2[1], 8.5]);
    }
    color("black") translate([bb1_c[0] - 53/2 - 12, bb1_c[1] - 10.5, floor_t + 17]) cube([53, 21, 1.6]);
    color("crimson") translate([bb2_c[0] - 18, bb2_c[1] - 10, floor_t + 17]) cube([20, 20, 1.6]);
    color("purple") translate([bb2_c[0] + 6, bb2_c[1] - 7, floor_t + 17]) cube([14, 13, 1.6]);
    translate([0, 0, box_h]) {
        color("darkgreen") translate([lcd_c[0] - 40, lcd_c[1] - 18, -lcd_h - 1.6]) cube([80, 36, 1.6]);
        color("dimgray") translate([lcd_c[0] - 35.5, lcd_c[1] - 12, -lcd_h]) cube([71, 24, lcd_h + lid_t]);
        color("darkgreen") translate([joy_c[0] - 17, joy_c[1] - 13, -joy_h - 1.6]) cube([34, 26, 1.6]);
        color("black") translate([joy_c[0], joy_c[1], -joy_h]) cylinder(d = 16, h = joy_h + lid_t + 2);
        color("black") translate([joy_c[0], joy_c[1], lid_t + 2]) cylinder(d = 22, h = 8);
        for (y = btn_y) {
            color("silver") translate([btn_x, y, lid_t]) cylinder(d = 15, h = 2);
            color("white") translate([btn_x, y, lid_t]) cylinder(d = 10, h = 5);
            color("dimgray") translate([btn_x, y, -18]) cylinder(d = 12, h = 18);
        }
        color("gold") translate([stop_c[0], stop_c[1], lid_t]) anel_parada();
        color("red") translate([stop_c[0], stop_c[1], lid_t + 1.6]) cylinder(d = 30, h = 12);
        color("dimgray") translate([stop_c[0], stop_c[1], -40]) cylinder(d = 26, h = 40);
        color("orangered") translate([led_c[0], led_c[1], 0]) cylinder(d = 5, h = lid_t + 4);
    }
}

if (part == "ihm_caixa") ihm_caixa();
else if (part == "ihm_tampa") rotate([180, 0, 0]) ihm_tampa();
else if (part == "anel_parada") anel_parada();
else if (part == "ihm_montagem") ihm_montagem();
