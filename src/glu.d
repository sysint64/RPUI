module glu;

import derelict.opengl3.gl;


extern (C) {
    void gluOrtho2D(GLdouble left, GLdouble right, GLdouble bottom, GLdouble top);
}
