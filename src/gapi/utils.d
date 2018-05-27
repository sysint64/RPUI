module gapi.utils;

import opengl;
import glu;

import application;


void glBegin2D() {
    auto app = Application.getInstance();

    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();

    gluOrtho2D(0, app.viewportWidth, 0, app.viewportHeight);
    glMatrixMode(GL_MODELVIEW);

    glPushMatrix();
    glLoadIdentity();
}


void glEnd2D() {
    glPopMatrix();
    glMatrixMode (GL_PROJECTION);

    glPopMatrix();
    glMatrixMode (GL_MODELVIEW);
}
