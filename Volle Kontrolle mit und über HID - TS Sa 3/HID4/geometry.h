/*
 *  geometry.h
 *  HID4
 *
 *  Created by Matthias Krauß on 19.08.11.
 *  Copyright 2011 Matthias Krauß. All rights reserved.
 *
 */

/*
 *  geometry.h
 *  HID4
 *
 *  Created by Matthias Krauß on 19.08.11.
 *  Copyright 2011 Matthias Krauß. All rights reserved.
 *
 */

#ifndef _GEOMETRY_
#define _GEOMETRY_

#include <CoreFoundation/CoreFoundation.h>

typedef struct _vec2 {
	float x;
	float y;
} vec2;

typedef struct _vec3 {
	float x;
	float y;
	float z;
} vec3;

typedef struct _plane3 {	//should be hnf
	vec3 n;
	float d;
} plane3;

typedef struct _box3 {
	vec3 origin;
	vec3 size;
} box3;

typedef struct _simpleVertex {
	vec3 pos;
	vec3 normal;
	vec2 tex;
} simpleVertex;

void add(const vec3* a, const vec3* b, vec3* result);
void sub(const vec3* a, const vec3* b, vec3* result);	//result = a - b
void copy(const vec3* src, vec3* dst);
void set(vec3* dst, float x, float y, float z);
float dotProduct(const vec3* a, const vec3* b);
void crossProduct(const vec3* a, const vec3* b, vec3* result);
void scale(vec3* a, float s);
float length(const vec3* a);
float distance(const vec3* a, const vec3* b);
float distBoxVec(const box3* b, const vec3* v);
void normalize(vec3* a);
float signedDistance(const vec3* v, const plane3* p);	//p must be hnf
void planeFromPoints(const vec3* a, const vec3* b, const vec3* c, plane3* p);	//generates hnf
#endif