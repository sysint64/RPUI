module opengl;
public import derelict.opengl;

mixin glFreeFuncs!(GLVersion.gl41, true);
