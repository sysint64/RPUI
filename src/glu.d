module glu;

import derelict.opengl;

extern (C) {
    void gluOrtho2D(GLdouble left, GLdouble right, GLdouble bottom, GLdouble top);
}
