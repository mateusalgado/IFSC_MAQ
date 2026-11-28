// Mini elevador didatico de tres andares - estrutura toda impressa
// Sem varoes nem tabua: a torre e uma coluna em dois segmentos com trilhos em
// cauda de andorinha; a cabine corre nos trilhos e o motor TT fica sob o teto.
// A base da torre e a IHM (ihm.scad) se aparafusam lado a lado: base unica.
//
// Uso:  openscad -D "part=\"segmento\"" -o stl/segmento.stl elevador.scad
// Pecas: base, segmento, emenda, cabeca, cabine, porta, grampo, tambor, gabarito,
//        ihm_caixa, ihm_tampa, anel_parada, montagem, colisao
//
// Unidades em mm. X = largura, Y = frente(-)/fundo(+), Z = altura.
// A face da frente da coluna fica em y = 0.
// COTAS DO MOTOR TT E DA MICROCHAVE SAO NOMINAIS: imprimir "gabarito" antes.

include <comum.scad>
use <ihm.scad>

part = "montagem";
andar_mostrado = 1;

$fn = 64;
eps = 0.01;

// ---------- Coluna ----------
col_w    = 100;          // largura da coluna
col_t    = 5;            // espessura
seg_len  = 195;          // comprimento de cada segmento (dois iguais)
rail_x   = 30;           // posicao dos dois trilhos
rail_h   = 14;           // altura total do trilho
fit_slide = 0.35;        // folga do trilho na sapata da cabine
fit_sock  = 0.3;         // folga da coluna nos encaixes da base e da cabeca
lock_d   = 2.8;          // furo onde o M3 abre rosca
pass_d   = 3.4;          // furo passante de M3
lock_x   = 25;           // furos de trava da coluna
lock_z   = 10;           // distancia dos furos ate a ponta do segmento

// ---------- Percurso ----------
floor_pitch = 110;
overtravel  = 14;
limit_gap   = 8;

// ---------- Base e cabeca ----------
plate_t  = 5;
sock_h_base = 20;        // profundidade do encaixe na base
sock_h_top  = 25;        // profundidade do encaixe na cabeca (parede do motor)
sock_x   = 108;          // largura do bloco de encaixe da base
head_x   = 116;          // largura da cabeca
head_y0  = -72;
sock_y0  = -(rail_h + 3.5);
sock_y1  = col_t + 3.5;

// ---------- Motor TT (nominal, conferir) ----------
tt_w = 22.5;  tt_t = 18.8;  tt_front = 11.25;  tt_gear_len = 37;  tt_len = 65;
tt_shaft_d = 5.4;  tt_flat = 3.7;  tt_shaft_l = 9;
tt_hole_dx = 20.3;  tt_hole_sp = 17.5;

// ---------- Tambor ----------
drum_r = 10;  drum_w = 14;  flange_r = 14;  string_d = 0.6;

// ---------- Cabine ----------
cab_w = 64;  cab_d = 48;  cab_h = 57;  cab_wall = 2;
shoe_w = 20;  shoe_h = 12;
cab_gap = 2;             // folga entre o trilho e o fundo da cabine
cam_h = 3.5;  cam_len = 16;  cam_w = 10;  cam_z = 28;
cam_y = -9;              // centro do ressalto lateral, medido do fundo da cabine

// ---------- Porta com servo (nominal tipo SG90, conferir) ----------
servo_l      = 23.2;     // comprimento do corpo, com folga
servo_w      = 12.6;     // largura do corpo, com folga
servo_tab_sp = 27.8;     // entre os dois furos das abas
servo_axis   = 6.2;      // do fim do corpo ate o eixo
servo_horn_z = 13.5;     // do apoio das abas ate o topo do braco (horn)
porta_t      = 2;
porta_gap    = 2.5;      // folga entre a frente da cabine e a porta
porta_aberta = true;     // posicao da porta na vista de montagem

// ---------- Microchave (nominal tipo KW12, conferir) ----------
sw_hole_sp = 9.5;
clip_h = 12;  tab_h = 26;

// ---------- Cotas derivadas ----------
xs        = -(drum_r + string_d/2);
cab_y     = -(rail_h + cab_gap);                    // fundo da cabine na montagem
motor_y   = sock_y0 - tt_t;                          // face do motor voltada ao tambor
string_y  = motor_y - 0.5 - drum_w/2;                // plano do fio
motor_zc  = -(tt_w/2 + 0.5);                         // eixo do motor abaixo do teto
col_z0    = plate_t;
col_top   = col_z0 + 2*seg_len;                      // topo da coluna = face inferior do teto
z_batente = plate_t + sock_h_base;
z_terreo  = z_batente + overtravel;
handle_top = cab_h + (cab_w/2 - 6);
servo_x0  = cab_w/2 + 3;                             // inicio do alojamento do servo
servo_yf  = -cab_d;                                // frente da cabine (coordenada local)
servo_yc  = -cab_d + 7.2;                           // linha de centro do servo
porta_px  = servo_x0 + servo_axis;                   // eixo da porta
porta_za  = cab_h + servo_horn_z;                    // face inferior do braco da porta
function z_andar(i) = z_terreo + i*floor_pitch;

// ============================================================
// Perfis
// ============================================================

// trilho em cauda de andorinha; y do perfil = distancia da face da coluna
module perfil_trilho(c = 0) {
    offset(delta = c) polygon([
        [-2.5, -eps], [-2.5, 8], [-6, 11.5], [-6, rail_h],
        [6, rail_h], [6, 11.5], [2.5, 8], [2.5, -eps]]);
}

// vao (visto de cima) que recebe a coluna com os dois trilhos
module vao_coluna(c) {
    translate([-col_w/2 - c, -c]) square([col_w + 2*c, col_t + 2*c]);
    for (sx = [-1, 1]) translate([sx*rail_x, 0]) mirror([0, 1]) perfil_trilho(c);
}

// ============================================================
// Pecas
// ============================================================

module placa(x, y0, y1, t, r = 6) {
    hull() for (sx = [-1, 1], yy = [y0 + r, y1 - r])
        translate([sx*(x/2 - r), yy, 0]) cylinder(r = r, h = t);
}

// Segmento da coluna, na posicao de impressao: costas na mesa, trilhos para cima.
module segmento() {
    difference() {
        union() {
            translate([-col_w/2, 0, 0]) cube([col_w, seg_len, col_t]);
            for (sx = [-1, 1]) translate([sx*rail_x, seg_len, col_t])
                rotate([90, 0, 0]) linear_extrude(seg_len) perfil_trilho();
        }
        for (sx = [-1, 1], yy = [lock_z, seg_len - lock_z])
            translate([sx*lock_x, yy, -eps]) cylinder(d = lock_d, h = col_t + 1);
    }
}

module segmento_montado(z0) {
    translate([0, col_t, z0]) rotate([90, 0, 0]) segmento();
}

module base() {
    difference() {
        union() {
            placa(base_x, base_y0, base_y1, plate_t);
            translate([-sock_x/2, sock_y0, 0]) cube([sock_x, sock_y1 - sock_y0, z_batente]);
            // flange de juncao com a IHM, na borda esquerda, com reforcos
            translate([-base_x/2, base_y0 + 8, 0]) cube([junta_t, base_y1 - base_y0 - 16, junta_h]);
            for (y = [base_y0 + 8, -50, 0, base_y1 - 11]) hull() {
                translate([-base_x/2 + junta_t - eps, y, plate_t]) cube([eps, 3, junta_h - plate_t]);
                translate([-base_x/2 + junta_t - eps, y, plate_t - eps]) cube([12, 3, eps]);
            }
            // escoras atras da coluna
            for (xx = [-sock_x/2, -1.5, sock_x/2 - 3]) hull() {
                translate([xx, sock_y1 - eps, plate_t]) cube([3, eps, sock_h_base]);
                translate([xx, sock_y1, plate_t - eps]) cube([3, 28, eps]);
            }
        }
        translate([0, 0, plate_t]) linear_extrude(sock_h_base + 1) vao_coluna(fit_sock);
        for (sx = [-1, 1]) translate([sx*lock_x, col_t, plate_t + lock_z])
            rotate([-90, 0, 0]) cylinder(d = pass_d, h = 10);
        for (sx = [-1, 1], yy = [base_y0 + 9, base_y1 - 9])
            translate([sx*(base_x/2 - 9), yy, -eps]) cylinder(d = 4.5, h = plate_t + 1);
        // passagem dos cabos para a IHM
        translate([-base_x/2 - 1, cabo_y - cabo_w/2, cabo_z0]) cube([junta_t + 2, cabo_w, cabo_z1 - cabo_z0]);
        // furos da juncao: M3 abre rosca na flange
        for (y = junta_y) translate([-base_x/2 - 1, y, junta_z]) rotate([0, 90, 0]) cylinder(d = lock_d, h = junta_t + 2);
    }
}

// Emenda parafusada nas costas, entre os dois segmentos. Imprime deitada.
module emenda() {
    h = 80;
    difference() {
        union() {
            translate([-40, 0, 0]) cube([80, h, 4]);
            for (xx = [-12, 9]) translate([xx, 0, 4 - eps]) cube([3, h, 6]);
        }
        for (sx = [-1, 1], s = [-1, 1])
            translate([sx*lock_x, h/2 + s*lock_z, -eps]) cylinder(d = pass_d, h = 6);
    }
}

// Cabeca: encaixe da coluna, teto em balanco e fixacao do motor.
// Modelada na posicao de montagem (z = 0 na face inferior do teto);
// imprime de cabeca para baixo, com o teto na mesa.
module cabeca() {
    difference() {
        union() {
            translate([0, 0, 0]) placa(head_x, head_y0, sock_y1, plate_t);
            translate([-head_x/2, sock_y0, -sock_h_top]) cube([head_x, sock_y1 - sock_y0, sock_h_top + eps]);
            for (sx = [-1, 1]) scale([sx, 1, 1]) hull() {
                translate([head_x/2 - 3, sock_y0, -sock_h_top + 4]) cube([3, eps, sock_h_top - 4]);
                translate([head_x/2 - 3, head_y0 + 8, -eps]) cube([3, sock_y0 - head_y0 - 8, eps]);
            }
        }
        translate([0, 0, -sock_h_top - 1]) linear_extrude(sock_h_top + 1) vao_coluna(fit_sock);
        for (sx = [-1, 1]) translate([sx*lock_x, col_t, -lock_z])
            rotate([-90, 0, 0]) cylinder(d = pass_d, h = 10);
        // dois furos onde os M3 do motor abrem rosca
        for (s = [-1, 1]) translate([xs + tt_hole_dx, sock_y0 - eps, motor_zc + s*tt_hole_sp/2])
            rotate([-90, 0, 0]) cylinder(d = lock_d, h = 12);
        // alivio para segundo eixo e ressalto da carcaca
        hull() for (xx = [xs, xs + 13]) translate([xx, sock_y0 - eps, motor_zc])
            rotate([-90, 0, 0]) cylinder(d = 9, h = 10);
        // abertura para a flange do tambor
        translate([xs - flange_r - 2, string_y - drum_w/2 - 2, -eps])
            cube([2*flange_r + 4, drum_w + 4, plate_t + 1]);
    }
}

// Suporte do servo na lateral direita da cabine: bloco com cunha de 45 graus
// (imprime sem suporte) e alojamento vazado onde o servo entra por cima.
module suporte_servo() {
    x0 = cab_w/2 - 1;  x1 = servo_x0 + servo_l + 5;  w = servo_w + 4;  bh = 16;
    translate([x0, servo_yc - w/2, cab_h - bh]) cube([x1 - x0, w, bh]);
    hull() {
        translate([x0, servo_yc - w/2, cab_h - bh - eps]) cube([x1 - x0, w, eps]);
        translate([x0, servo_yc - w/2, cab_h - bh - (x1 - x0)]) cube([eps, w, eps]);
    }
}
module corte_servo() {
    translate([servo_x0, servo_yc - servo_w/2, -1]) cube([servo_l, servo_w, cab_h + 2]);
    for (s = [-1, 1]) translate([servo_x0 + servo_l/2 + s*servo_tab_sp/2, servo_yc, cab_h - 8])
        cylinder(d = 1.7, h = 9);
}

// Porta, na posicao fechada e em coordenadas da cabine. O braco de cima
// recebe o horn do servo num rebaixo e e preso pelo parafuso central.
module porta() {
    yp0 = servo_yf - porta_gap - porta_t;
    difference() {
        union() {
            translate([-cab_w/2 - 1, yp0, 4])
                cube([porta_px - 10.5 + cab_w/2 + 1, porta_t, porta_za]);
            translate([porta_px - 19, yp0, porta_za]) cube([26, servo_yc + 7 - yp0, 4]);
        }
        translate([porta_px, servo_yc, porta_za - eps]) cylinder(d = 2.4, h = 6);
        translate([0, 0, porta_za - eps]) linear_extrude(1.7) hull() {
            translate([porta_px, servo_yc]) circle(d = 7.9);
            translate([porta_px, servo_yc - 14.5]) circle(d = 5);
        }
    }
}

module porta_montada(aberta = porta_aberta) {
    translate([porta_px, servo_yc, 0]) rotate([0, 0, aberta ? 90 : 0])
        translate([-porta_px, -servo_yc, 0]) color("khaki") porta();
    color("royalblue") {
        translate([servo_x0, servo_yc - servo_w/2 + 0.2, cab_h - 15.9]) cube([servo_l - 0.4, servo_w - 0.4, 22.7]);
        translate([servo_x0 - 4.5, servo_yc - servo_w/2 + 0.2, cab_h]) cube([servo_l + 9, servo_w - 0.4, 2.5]);
        translate([porta_px, servo_yc, cab_h + 6.8]) cylinder(d = 11.5, h = 4);
    }
}

module perfil_alca() {
    hw = cab_w/2;
    polygon([[-hw, 0], [-hw, cab_h], [-6, handle_top], [6, handle_top], [hw, cab_h], [hw, 0]]);
}

// Cabine: fundo externo em y = 0, caixa para -y, sapatas para +y.
module cabine() {
    hw = cab_w/2;
    shoe_d = rail_h + cab_gap - 1;
    alca_y = string_y - cab_y;
    module canal(c) {
        for (sx = [-1, 1]) translate([sx*rail_x, rail_h + cab_gap]) mirror([0, 1]) perfil_trilho(c);
    }
    difference() {
        union() {
            translate([-hw, -cab_d, 0]) cube([cab_w, cab_d, cab_wall]);
            for (xx = [-hw, hw - cab_wall]) translate([xx, -cab_d, 0]) cube([cab_wall, cab_d, cab_h]);
            translate([-hw, -cab_wall, 0]) cube([cab_w, cab_wall, cab_h]);
            // sapatas e cunha de apoio da sapata superior
            for (sx = [-1, 1]) translate([sx*rail_x - shoe_w/2, -1, 0]) {
                cube([shoe_w, shoe_d + 1, shoe_h]);
                translate([0, 0, cab_h - shoe_h]) cube([shoe_w, shoe_d + 1, shoe_h]);
                hull() {
                    translate([0, 0, cab_h - shoe_h - eps]) cube([shoe_w, shoe_d + 1, eps]);
                    translate([0, 0, cab_h - shoe_h - shoe_d]) cube([shoe_w, eps, eps]);
                }
            }
            // alca do fio
            translate([0, alca_y + 5, 0]) rotate([90, 0, 0]) linear_extrude(10) intersection() {
                difference() { perfil_alca(); offset(delta = -3) perfil_alca(); }
                translate([-hw, cab_h - 8]) square([cab_w, cab_w]);
            }
            suporte_servo();
            // ressaltos laterais das microchaves
            for (sx = [-1, 1]) scale([sx, 1, 1]) translate([hw - eps, cam_y + cam_w/2, 0])
                rotate([90, 0, 0]) linear_extrude(cam_w) polygon([
                    [0, cam_z - cam_len/2 - cam_h], [cam_h, cam_z - cam_len/2],
                    [cam_h, cam_z + cam_len/2],     [0, cam_z + cam_len/2 + cam_h]]);
        }
        corte_servo();
        // canais: justos nas sapatas, folgados no trecho da cunha
        translate([0, 0, -eps]) linear_extrude(shoe_h + 2*eps) canal(fit_slide);
        translate([0, 0, cab_h - shoe_h]) linear_extrude(shoe_h + eps) canal(fit_slide);
        translate([0, 0, shoe_h]) linear_extrude(cab_h - 2*shoe_h) canal(fit_slide + 1);
        translate([0, alca_y, handle_top - 5]) cylinder(d = 2, h = 8);
    }
}

// Grampo que prende na borda da coluna e leva uma microchave.
// Modelado para a borda direita (x = +col_w/2); de cabeca para baixo serve a esquerda.
module grampo() {
    e = col_w/2;
    difference() {
        union() {
            linear_extrude(clip_h) {
                translate([e - 7, col_t + 0.2]) square([11, 3.3]);          // garra de tras
                translate([e + 0.3, -3]) square([3.7, col_t + 6.5]);        // alma
                translate([e - 7, -3]) square([11, 2.8]);                   // garra da frente
                translate([e + 1, cab_y + cam_y - 6.4]) square([3, -(cab_y + cam_y - 6.4) - 3 + eps]);
            }
            // aba da microchave
            translate([e - 12, cab_y + cam_y + 3.3, 0]) cube([16, 3, tab_h]);
        }
        translate([e - 3.5, col_t, clip_h/2]) rotate([-90, 0, 0]) cylinder(d = lock_d, h = 6);
        // rasgos para M2 com porca: ajuste fino da distancia ao ressalto
        for (s = [-1, 1]) hull() for (xx = [e - 5.5, e - 1.5])
            translate([xx, cab_y + cam_y + 2, tab_h/2 + s*sw_hole_sp/2])
                rotate([-90, 0, 0]) cylinder(d = 2.3, h = 6);
    }
}

module furo_eixo_tt(h) {
    intersection() {
        cylinder(d = tt_shaft_d + 0.3, h = h);
        translate([-tt_shaft_d, -(tt_flat + 0.25)/2, 0]) cube([2*tt_shaft_d, tt_flat + 0.25, h]);
    }
}

module tambor() {
    difference() {
        rotate_extrude() polygon([
            [0, 0], [flange_r, 0], [flange_r, 1.5], [drum_r, 1.5],
            [drum_r, drum_w - 5.5], [flange_r, drum_w - 1.5], [flange_r, drum_w], [0, drum_w]]);
        translate([0, 0, -eps]) furo_eixo_tt(tt_shaft_l + 0.5);
        cylinder(d = 2.4, h = drum_w + 1);
        translate([drum_r + 1.5, 0, drum_w - 7]) cylinder(d = 1.8, h = 8);
    }
}

// Corpo de prova: trilho + sapata (o encaixe mais critico), coluna na fenda
// do grampo, eixo e furacao do motor, parafusos.
module gabarito() {
    // trecho de coluna com um trilho
    translate([-15, 0, 0]) cube([30, 25, col_t]);
    translate([0, 25, col_t]) rotate([90, 0, 0]) linear_extrude(25) perfil_trilho();
    // sapata de teste
    translate([32, 0, 0]) difference() {
        translate([-shoe_w/2, 0, 0]) cube([shoe_w, rail_h + 4, 12]);
        translate([0, rail_h + 4 + eps, -eps]) mirror([0, 1, 0]) linear_extrude(13) perfil_trilho(fit_slide);
    }
    // barra de furos e padrao do motor
    translate([-15, -34, 0]) difference() {
        union() {
            cube([64, 14, 10]);
            translate([0, 14 - eps, 0]) cube([44, 16, 3]);
        }
        translate([8, 7, -eps])  furo_eixo_tt(12);
        translate([18, 7, -eps]) cylinder(d = pass_d, h = 12);
        translate([26, 7, -eps]) cylinder(d = lock_d, h = 12);
        translate([34, 7, -eps]) cylinder(d = 2.3, h = 12);
        translate([44, -eps, 4]) cube([col_t + 0.4, 15, 7]);                // fenda do grampo
        translate([10, 18, -eps]) rotate([0, 0, 0]) {
            cylinder(d = 9, h = 5);
        }
    }
    // padrao do motor em chapa separada (eixo + dois furos)
    translate([-15, -64, 0]) difference() {
        cube([40, 26, 3]);
        translate([9, 13, -eps]) {
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
}

module sensor(z_centro, lado) {
    translate([0, 0, z_centro]) scale([lado, 1, lado]) translate([0, 0, -tab_h/2]) {
        color("orangered") grampo();
        color("dimgray") translate([col_w/2 - 10.6, cab_y + cam_y - 3.2, tab_h/2 - 10]) cube([10.6, 6.4, 20]);
        color("silver") translate([col_w/2 - 15.5, cab_y + cam_y - 1.5, tab_h/2 + 4])
            rotate([-90, 0, 0]) cylinder(d = 4.5, h = 3);
    }
}

module montagem() {
    zc = z_andar(andar_mostrado);
    color("slategray") base();
    translate([ihm_cx, ihm_cy, 0]) ihm_montagem();
    color("lightsteelblue") segmento_montado(col_z0);
    color("lightsteelblue") segmento_montado(col_z0 + seg_len);
    color("slategray") translate([0, col_t, col_z0 + seg_len + 40]) rotate([-90, 0, 0]) emenda();
    translate([0, 0, col_top]) {
        color("slategray") cabeca();
        motor_tt_ref();
        color("orangered") translate([xs, motor_y - 0.5, motor_zc]) rotate([90, 0, 0]) tambor();
    }
    color("deepskyblue") translate([0, cab_y, zc]) cabine();
    translate([0, cab_y, zc]) porta_montada();
    color("black") translate([0, string_y, zc + handle_top])
        cylinder(d = 1, h = col_top + motor_zc - zc - handle_top);
    for (i = [0 : 2]) sensor(z_andar(i) + cam_z, 1);
    sensor(z_andar(0) + cam_z - cam_len/2 - cam_h - limit_gap, -1);
    sensor(z_andar(2) + cam_z + cam_len/2 + cam_h + limit_gap, -1);
}

// ============================================================
// Verificacao de colisao: part = "colisao" gera apenas as interferencias
// entre a cabine (com a porta) e as pecas fixas ao longo de todo o curso.
// Resultado vazio ou so com contatos de volume zero = sem colisao. Os roletes
// das microchaves ficam de fora, porque devem mesmo tocar os ressaltos.
// ============================================================

module fixos() {
    base();
    segmento_montado(col_z0);
    segmento_montado(col_z0 + seg_len);
    translate([0, col_t, col_z0 + seg_len + 40]) rotate([-90, 0, 0]) emenda();
    translate([0, 0, col_top]) {
        cabeca(); motor_tt_ref();
        translate([xs, motor_y - 0.5, motor_zc]) rotate([90, 0, 0]) tambor();
    }
    for (s = [[z_andar(0) + cam_z, 1], [z_andar(1) + cam_z, 1], [z_andar(2) + cam_z, 1],
              [z_andar(0) + cam_z - cam_len/2 - cam_h - limit_gap, -1],
              [z_andar(2) + cam_z + cam_len/2 + cam_h + limit_gap, -1]])
        translate([0, 0, s[0]]) scale([s[1], 1, s[1]]) translate([0, 0, -tab_h/2]) {
            grampo();
            translate([col_w/2 - 10.6, cab_y + cam_y - 3.2, tab_h/2 - 10]) cube([10.6, 6.4, 20]);
        }
}

module colisao() {
    for (z = [z_batente : 20 : col_top + motor_zc - flange_r - handle_top]) intersection() {
        translate([0, cab_y, z]) { cabine(); porta_montada(false); }
        fixos();
    }
    for (i = [0 : 2]) intersection() {
        translate([0, cab_y, z_andar(i)]) porta_montada(true);
        fixos();
    }
}

if (part == "colisao") colisao();
else if (part == "ihm_caixa") ihm_caixa();
else if (part == "ihm_tampa") rotate([180, 0, 0]) ihm_tampa();
else if (part == "anel_parada") anel_parada();
else if (part == "base") base();
else if (part == "segmento") segmento();
else if (part == "emenda") emenda();
else if (part == "cabeca") rotate([180, 0, 0]) cabeca();
else if (part == "cabine") cabine();
else if (part == "grampo") grampo();
else if (part == "porta") rotate([90, 0, 0]) porta();
else if (part == "tambor") tambor();
else if (part == "gabarito") gabarito();
else montagem();

echo(str("altura_total=", col_top + plate_t, " z_terreo=", z_terreo, " z_2andar=", z_andar(2),
         " batente_sup=", col_top + motor_zc - flange_r - handle_top, " fio_y=", string_y));
