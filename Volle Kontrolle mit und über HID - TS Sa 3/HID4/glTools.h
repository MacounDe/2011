/*
 *  glTools.h
 *  HID4
 *
 *  Created by Matthias Krauß on 22.08.11.
 *  Copyright 2011 Matthias Krauß. All rights reserved.
 *
 */

#ifndef _GLTOOLS_
#define	_GLTOOLS_

#define glError() { \
GLenum err = glGetError(); \
while (err != GL_NO_ERROR) { \
fprintf(stderr, "glError: %s caught at %s:%u\n", (char *)gluErrorString(err), __FILE__, __LINE__); \
err = glGetError(); \
} \
}

#endif