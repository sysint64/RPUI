module math.linalg;

import gl3n.linalg;
import basic_types;


alias Vector vec;
alias Vector!(float, 2) vec2;
alias Vector!(float, 3) vec3;
alias Vector!(float, 4) vec4;

alias Vector!(int, 2) vec2i;
alias Vector!(int, 3) vec3i;
alias Vector!(int, 4) vec4i;

alias Vector!(uint, 2) vec2ui;
alias Vector!(uint, 3) vec3ui;
alias Vector!(uint, 4) vec4ui;

alias Matrix!(float, 2, 2) mat2;
alias Matrix!(float, 3, 3) mat3;
alias Matrix!(float, 4, 4) mat4;

alias Matrix!(float, 2, 3) mat23;
alias Matrix!(float, 3, 2) mat32;
alias Matrix!(float, 2, 4) mat24;
alias Matrix!(float, 4, 2) mat42;
alias Matrix!(float, 3, 4) mat34;
alias Matrix!(float, 4, 3) mat43;


bool pointInRect(in vec2i point, in vec4i vec) {
    const Rect rect = Rect(vec);
    return pointInRect(point, rect);
}


bool pointInRect(in uint x, in uint y, in uint left, in uint top, in uint width, in uint height) {
    const vec2i point = vec2i(x, y);
    const Rect rect = Rect(left, top, width, height);
    return pointInRect(point, rect);
}


bool pointInRect(in vec2i point, in Rect rect) {
    return (point.x <= rect.left+rect.width ) && (point.x >= rect.left) &&
           (point.y <= rect.top +rect.height) && (point.y >= rect.top);
}
