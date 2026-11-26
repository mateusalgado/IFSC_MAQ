// Mini elevador didatico de tres andares - prototipo mecanico parametrico
// Motor TT com tambor e fio, cabine em dois varoes de 8 mm, microchaves em
// bracadeiras ajustaveis num terceiro varao (mastro).
//
// Uso:  openscad -D "part=\"base\"" -o stl/base.stl elevador.scad
// Pecas: base, topo, cabine, bracadeira, tambor, gabarito, montagem
//
// Unidades em mm. X = largura, Y = frente(-)/fundo(+), Z = altura.
// COTAS DO MOTOR TT E DA MICROCHAVE SAO NOMINAIS: imprimir "gabarito" e
// conferir com as pecas reais antes das pecas grandes.

part = "montagem";
andar_mostrado = 1;      // posicao da cabine na vista de montagem (0, 1 ou 2)

$fn = 64;
eps = 0.01;

// ---------- Varoes e ajustes de impressao ----------
rod_d      = 8;          // diametro dos varoes
rod_len    = 400;        // comprimento dos tres varoes
rod_sep    = 110;        // distancia entre centros dos dois varoes-guia
fit_press  = 0.3;        // folga diametral dos encaixes fixos
fit_slide  = 0.6;        // folga diametral dos furos deslizantes da cabine
mast_y     = 52;         // posicao do mastro dos sensores, atras da cabine

// ---------- Percurso ----------
floor_pitch = 110;       // distancia entre andares
overtravel  = 14;        // folga entre o terreo e o batente inferior
limit_gap   = 8;         // quanto a cabine passa do andar ate tocar o fim de curso

// ---------- Placas ----------
plate_t     = 5;
boss_d      = 18;
base_x      = 170;  base_y0 = -45;  base_y1 = 75;
base_boss_h = 22;
base_floor  = 2;         // material sob a ponta do varao na base
top_x       = 150;  top_y0 = -22;   top_y1 = 64;
top_boss_h  = 15;
lock_d      = 2.8;       // furo para parafuso M3 abrir rosca e travar o varao

// ---------- Motor TT (nominal, conferir) ----------
tt_w        = 22.5;      // largura da caixa de reducao
tt_t        = 18.8;      // espessura (direcao do eixo)
tt_front    = 11.25;     // da ponta da caixa ate o eixo
tt_gear_len = 37;
tt_len      = 65;
tt_shaft_d  = 5.4;
tt_flat     = 3.7;       // medida entre os dois chanfros do eixo
tt_shaft_l  = 9;
tt_hole_dx  = 20.3;      // do eixo ate o par de furos de fixacao
tt_hole_sp  = 17.5;      // entre os dois furos
tt_slot     = 2;         // meia-folga dos rasgos (absorve erro de tt_hole_dx)

// ---------- Tambor ----------
drum_r   = 10;           // raio onde o fio enrola
drum_w   = 14;
flange_r = 14;
string_d = 0.6;
drum_y   = 2;            // plano do fio; desloca o motor para livrar o varao

// ---------- Cabine ----------
cab_w   = 64;
cab_d   = 48;
cab_h   = 57;
cab_wall = 2;
ear_h   = 12;
ear_d   = 16;
cam_h   = 3.5;           // altura do ressalto que aciona a microchave
cam_len = 16;            // trecho plano do ressalto (janela de parada)
cam_x   = 11.5;          // centro do ressalto, um de cada lado
cam_w   = 11;
cam_z   = 28;            // altura do centro do ressalto na cabine

// ---------- Microchave (nominal tipo KW12, conferir) ----------
sw_hole_sp = 9.5;
sw_hole_d  = 1.9;        // parafuso M2 abre rosca
clamp_h    = 12;
tab_h      = 26;

// ---------- Cotas derivadas ----------
xs        = -(drum_r + string_d/2);               // eixo do motor: fio cai em x = 0
base_top  = plate_t + base_boss_h;                // batente inferior da cabine
z_terreo  = base_top + overtravel;                // piso da cabine no terreo
top_z     = base_floor + rod_len - plate_t - top_boss_h;   // face inferior do topo
motor_y   = drum_y + drum_w/2 + 0.5;              // face do motor voltada ao tambor
wall_y    = motor_y + tt_t + 0.2;
wall_t    = 4;
motor_zc  = plate_t + tt_w/2 + 0.5;               // eixo do motor acima da face inferior
handle_top = cab_h + (cab_w/2 - 6);               // ponto mais alto da cabine

function z_andar(i) = z_terreo + i*floor_pitch;

// ============================================================
// Pecas
// ============================================================

module placa(x, y0, y1, t, r = 6) {
    hull() for (sx = [-1, 1], yy = [y0 + r, y1 - r])
        translate([sx*(x/2 - r), yy, 0]) cylinder(r = r, h = t);
}

module posicoes_varoes() {
    for (sx = [-1, 1]) translate([sx*rod_sep/2, 0, 0]) children();
    translate([0, mast_y, 0]) children();
}

// furo radial de trava: aponta para fora da torre
module travas(z) {
    for (sx = [-1, 1]) translate([sx*rod_sep/2, 0, z])
        rotate([0, sx*90, 0]) cylinder(d = lock_d, h = boss_d);
    translate([0, mast_y, z]) rotate([-90, 0, 0]) cylinder(d = lock_d, h = boss_d);
}

module base() {
    difference() {
        union() {
            placa(base_x, base_y0, base_y1, plate_t);
            posicoes_varoes() cylinder(d = boss_d, h = base_top);
        }
        posicoes_varoes() translate([0, 0, base_floor])
            cylinder(d = rod_d + fit_press, h = base_top);
        travas(plate_t + base_boss_h/2);
        // fixacao em tabua ou pes
        for (sx = [-1, 1], yy = [base_y0 + 9, base_y1 - 9])
            translate([sx*(base_x/2 - 9), yy, -eps]) cylinder(d = 4.5, h = plate_t + 1);
    }
}

module rasgo_y(x0, x1, z, d) {
    hull() for (xx = [x0, x1]) translate([xx, wall_y - 1, z])
        rotate([-90, 0, 0]) cylinder(d = d, h = wall_t + 2);
}

module topo() {
    wall_x0 = xs - 16;
    wall_x1 = xs + tt_hole_dx + 12;
    wall_h  = tt_w + 2;
    difference() {
        union() {
            placa(top_x, top_y0, top_y1, plate_t);
            posicoes_varoes() cylinder(d = boss_d, h = plate_t + top_boss_h);
            // parede onde o motor e parafusado
            translate([wall_x0, wall_y, 0]) cube([wall_x1 - wall_x0, wall_t, plate_t + wall_h]);
            // maos-francesas
            for (xx = [wall_x0, wall_x1 - 3]) hull() {
                translate([xx, wall_y + wall_t - eps, plate_t]) cube([3, eps, wall_h]);
                translate([xx, wall_y + wall_t, plate_t - eps]) cube([3, 10, eps]);
            }
        }
        // varoes atravessam a placa
        posicoes_varoes() translate([0, 0, -eps])
            cylinder(d = rod_d + fit_press, h = plate_t + top_boss_h + 1);
        travas(plate_t + top_boss_h/2);
        // abertura do tambor e do fio
        translate([xs - flange_r - 2, drum_y - drum_w/2 - 2, -eps])
            cube([2*flange_r + 4, drum_w + 4, plate_t + 1]);
        // rasgos dos dois parafusos M3 do motor
        for (s = [-1, 1])
            rasgo_y(xs + tt_hole_dx - tt_slot, xs + tt_hole_dx + tt_slot,
                    motor_zc + s*tt_hole_sp/2, 3.4);
        // alivio central: segundo eixo e ressalto da carcaca
        rasgo_y(xs, xs + 13, motor_zc, 9);
    }
}

module furo_guia(alongado) {
    d = rod_d + fit_slide;
    module perfil(dd) {
        if (alongado) hull() for (dx = [-1, 1]) translate([dx, 0]) circle(d = dd);
        else circle(d = dd);
    }
    // guia apenas nas orelhas; alivio entre elas
    translate([0, 0, -eps]) linear_extrude(ear_h + 2*eps) perfil(d);
    translate([0, 0, cab_h - ear_h - eps]) linear_extrude(ear_h + 2*eps) perfil(d);
    translate([0, 0, ear_h]) linear_extrude(cab_h - 2*ear_h - 1.5) perfil(d + 2.4);
    translate([0, 0, cab_h - ear_h - 1.5 - eps]) hull() {
        linear_extrude(eps) perfil(d + 2.4);
        translate([0, 0, 1.5]) linear_extrude(eps) perfil(d);
    }
}

module cabine() {
    hw = cab_w/2;
    ear_x1 = rod_sep/2 + 8;
    difference() {
        union() {
            // piso, laterais e fundo (frente aberta)
            translate([-hw, -cab_d/2, 0]) cube([cab_w, cab_d, cab_wall]);
            for (sx = [-1, 1]) translate([sx > 0 ? hw - cab_wall : -hw, -cab_d/2, 0])
                cube([cab_wall, cab_d, cab_h]);
            translate([-hw, cab_d/2 - cab_wall, 0]) cube([cab_w, cab_wall, cab_h]);
            // orelhas-guia e cunha de apoio da orelha superior (imprime sem suporte)
            for (sx = [-1, 1]) scale([sx, 1, 1]) {
                translate([hw - 1, -ear_d/2, 0]) cube([ear_x1 - hw + 1, ear_d, ear_h]);
                translate([hw - 1, -ear_d/2, cab_h - ear_h]) cube([ear_x1 - hw + 1, ear_d, ear_h]);
                hull() {
                    translate([hw - 1, -ear_d/2, cab_h - ear_h - eps]) cube([ear_x1 - hw + 1, ear_d, eps]);
                    translate([hw - 1, -ear_d/2, cab_h - ear_h - (ear_x1 - hw)]) cube([eps, ear_d, eps]);
                }
            }
            // alca em 45 graus para o fio
            rotate([90, 0, 0]) translate([0, 0, -5]) linear_extrude(10) intersection() {
                difference() {
                    perfil_alca();
                    offset(delta = -3) perfil_alca();
                }
                translate([-hw, cab_h - 8]) square([cab_w, cab_w]);
            }
            // ressaltos que acionam as microchaves (um por lado)
            for (sx = [-1, 1]) translate([sx*cam_x - cam_w/2, cab_d/2 - eps, 0])
                rotate([90, 0, 90]) linear_extrude(cam_w) polygon([
                    [0, cam_z - cam_len/2 - cam_h], [cam_h, cam_z - cam_len/2],
                    [cam_h, cam_z + cam_len/2],     [0, cam_z + cam_len/2 + cam_h]]);
        }
        translate([-rod_sep/2, 0, 0]) furo_guia(false);
        translate([ rod_sep/2, 0, 0]) furo_guia(true);   // rasgo: tolera erro de distancia
        // furo do fio
        translate([0, 0, handle_top - 5]) cylinder(d = 2, h = 8);
    }
}

module perfil_alca() {
    hw = cab_w/2;
    polygon([[-hw, 0], [-hw, cab_h], [-6, handle_top], [6, handle_top], [hw, cab_h], [hw, 0]]);
}

// Bracadeira do mastro com aba para uma microchave. Virada de cabeca para
// baixo, a mesma peca serve o outro lado (fins de curso).
module bracadeira() {
    od = rod_d + 8;
    difference() {
        union() {
            cylinder(d = od, h = clamp_h);
            translate([-4.25, 0, 0]) cube([8.5, od/2 + 8, clamp_h]);      // orelhas do aperto
            translate([od/2 - 3, -20, 0]) cube([3, 22, tab_h]);           // aba da chave
        }
        translate([0, 0, -eps]) cylinder(d = rod_d + 0.4, h = tab_h + 1);
        translate([-0.75, 0, -eps]) cube([1.5, od, clamp_h + 1]);         // fenda
        translate([-10, od/2 + 3.5, clamp_h/2]) rotate([0, 90, 0]) cylinder(d = 3.4, h = 20);
        for (s = [-1, 1]) translate([0, -13, tab_h/2 + s*sw_hole_sp/2])
            rotate([0, 90, 0]) cylinder(d = sw_hole_d, h = od);
    }
}

module furo_eixo_tt(h) {
    intersection() {
        cylinder(d = tt_shaft_d + 0.3, h = h);
        translate([-tt_shaft_d, -(tt_flat + 0.25)/2, 0]) cube([2*tt_shaft_d, tt_flat + 0.25, h]);
    }
}

// Tambor: face z = 0 encosta no motor e fica na mesa de impressao.
module tambor() {
    difference() {
        rotate_extrude() polygon([
            [0, 0], [flange_r, 0], [flange_r, 1.5], [drum_r, 1.5],
            [drum_r, drum_w - 5.5], [flange_r, drum_w - 1.5], [flange_r, drum_w], [0, drum_w]]);
        translate([0, 0, -eps]) furo_eixo_tt(tt_shaft_l + 0.5);
        cylinder(d = 2.4, h = drum_w + 1);                                // parafuso da ponta do eixo
        translate([drum_r + 1.5, 0, drum_w - 7]) cylinder(d = 1.8, h = 8); // ancoragem do fio
    }
}

// Corpo de prova: confere folgas e o padrao do motor antes das pecas grandes.
module gabarito() {
    difference() {
        union() {
            cube([64, 20, 10]);
            translate([0, 20 - eps, 0]) cube([44, 30, 3]);
        }
        translate([9, 10, 2])    cylinder(d = rod_d + fit_press, h = 10);   // encaixe fixo
        translate([22, 10, -eps]) cylinder(d = rod_d + fit_slide, h = 12);  // furo deslizante
        translate([34, 10, -eps]) furo_eixo_tt(12);                         // eixo do motor
        translate([43, 10, -eps]) cylinder(d = 3.4, h = 12);                // M3 passante
        translate([50, 10, -eps]) cylinder(d = lock_d, h = 12);             // M3 rosca
        translate([57, 10, -eps]) cylinder(d = sw_hole_d, h = 12);          // M2 rosca
        // padrao do motor TT: eixo + dois furos
        translate([10, 35, -eps]) {
            cylinder(d = 9, h = 5);
            for (s = [-1, 1]) translate([tt_hole_dx, s*tt_hole_sp/2, 0]) cylinder(d = 3.2, h = 5);
        }
    }
}

// ============================================================
// Montagem (apenas visualizacao)
// ============================================================

module motor_tt_ref() {
    color("gold") {
        translate([xs - tt_front, motor_y, motor_zc - tt_w/2]) cube([tt_gear_len, tt_t, tt_w]);
        translate([xs - tt_front + tt_gear_len, motor_y + tt_t/2, motor_zc])
            rotate([0, 90, 0]) cylinder(d = 20, h = tt_len - tt_gear_len);
    }
    color("white") translate([xs, motor_y, motor_zc]) rotate([90, 0, 0])
        cylinder(d = tt_shaft_d, h = tt_shaft_l);
}

module chave_ref() {
    color("dimgray") translate([rod_d/2 + 4, -20.7, tab_h/2 - 10]) cube([6.4, 10.6, 20]);
    color("silver") translate([rod_d/2 + 6, -25, tab_h/2 + 4]) rotate([0, 90, 0]) cylinder(d = 4.5, h = 3);
}

module sensor(z_centro, lado) {
    translate([0, mast_y, z_centro]) scale([lado, 1, lado]) translate([0, 0, -tab_h/2]) {
        color("orangered") bracadeira();
        chave_ref();
    }
}

module montagem() {
    zc = z_andar(andar_mostrado);
    color("slategray") base();
    color("silver") posicoes_varoes() translate([0, 0, base_floor]) cylinder(d = rod_d, h = rod_len);
    translate([0, 0, top_z]) {
        color("slategray") topo();
        motor_tt_ref();
        color("orangered") translate([xs, drum_y + drum_w/2, motor_zc]) rotate([90, 0, 0]) tambor();
    }
    color("deepskyblue") translate([0, 0, zc]) cabine();
    // fio
    color("black") translate([0, 0, zc + handle_top])
        cylinder(d = 1, h = top_z + motor_zc - zc - handle_top);
    // tres sensores de andar (lado +x) e dois fins de curso (lado -x)
    for (i = [0 : 2]) sensor(z_andar(i) + cam_z, 1);
    sensor(z_andar(0) + cam_z - cam_len/2 - cam_h - limit_gap, -1);
    sensor(z_andar(2) + cam_z + cam_len/2 + cam_h + limit_gap, -1);
}

if (part == "base") base();
else if (part == "topo") topo();
else if (part == "cabine") cabine();
else if (part == "bracadeira") bracadeira();
else if (part == "tambor") tambor();
else if (part == "gabarito") gabarito();
else montagem();

echo(str("top_z=", top_z, " z_terreo=", z_terreo, " z_2andar=", z_andar(2),
         " batente_sup=", top_z - handle_top, " curso=", 2*floor_pitch));
