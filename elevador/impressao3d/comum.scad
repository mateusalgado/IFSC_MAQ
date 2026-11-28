// Cotas compartilhadas entre a base da torre (elevador.scad) e a IHM (ihm.scad).
// As duas pecas se aparafusam lado a lado e formam uma base unica.
// Coordenadas no sistema da torre: coluna centrada em x = 0, frente em -y.

base_x  = 170;           // largura do modulo da torre
base_y0 = -110;          // frente da base
base_y1 = 60;            // fundo da base

ihm_box_x = 200;                          // largura do modulo da IHM
ihm_box_y = base_y1 - base_y0;            // mesma profundidade da base
ihm_cx    = -base_x/2 - ihm_box_x/2;      // IHM encostada a esquerda da torre
ihm_cy    = (base_y0 + base_y1)/2;

// Juncao: flange vertical na borda esquerda da base da torre, parafusada por
// dentro da IHM, atraves da parede direita da caixa.
junta_t = 6;                    // espessura da flange
junta_h = 26;                   // altura da flange a partir da mesa
junta_y = [-85, -35, 15];       // furos dos parafusos, no sistema da torre
junta_z = 15;                   // altura dos furos
// Passagem dos cabos da torre para dentro da IHM, pela flange e pela parede.
cabo_y  = 35;                   // centro da passagem, no sistema da torre
cabo_w  = 24;
cabo_z0 = 7;
cabo_z1 = 21;
