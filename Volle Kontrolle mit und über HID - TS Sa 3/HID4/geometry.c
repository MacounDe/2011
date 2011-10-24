/*
 *  geometry.c
 *  HID4
 *
 *  Created by Matthias Krauß on 19.08.11.
 *  Copyright 2011 Matthias Krauß. All rights reserved.
 *
 */

#include "geometry.h"

void add(const vec3* a, const vec3* b, vec3* result) {
	result->x = a->x + b->x;
	result->y = a->y + b->y;
	result->z = a->z + b->z;
}

void sub(const vec3* a, const vec3* b, vec3* result) {
	result->x = a->x - b->x;
	result->y = a->y - b->y;
	result->z = a->z - b->z;
}

void copy(const vec3* src, vec3* dst) {
	dst->x = src->x;
	dst->y = src->y;
	dst->z = src->z;
}

void set(vec3* dst, float x, float y, float z) {
	dst->x = x;
	dst->y = y;
	dst->z = z;
}	

float dotProduct(const vec3* a, const vec3* b) {
	return a->x * b->x + a->y * b->y + a->z * b->z;
}

void crossProduct(const vec3* a, const vec3* b, vec3* result) {
	float x = a->y * b->z - a->z * b->y;
	float y = a->z * b->x - a->x * b->z;
	float z = a->x * b->y - a->y * b->x;
	result->x = x;
	result->y = y;
	result->z = z;
}

void scale(vec3* a, float s) {
	a->x *= s;
	a->y *= s;
	a->z *= s;
}

float length(const vec3* a) {
	return sqrt(a->x * a->x + a->y * a->y + a->z * a->z);
}

float distance(const vec3* a, const vec3* b) {
	vec3 d;
	sub(a,b,&d);
	return length(&d);
}

float distBoxVec(const box3* b, const vec3* v) {
	vec3 d = {
		(v->x < b->origin.x) ? b->origin.x-v->x : (v->x > b->origin.x+b->size.x) ? v->x-(b->origin.x+b->size.x) : 0.0,
		(v->y < b->origin.y) ? b->origin.y-v->y : (v->y > b->origin.y+b->size.y) ? v->y-(b->origin.y+b->size.y) : 0.0,
		(v->z < b->origin.z) ? b->origin.z-v->z : (v->z > b->origin.z+b->size.z) ? v->z-(b->origin.z+b->size.z) : 0.0
	};
	return length(&d);
}


void normalize(vec3* a) {
	float len = length(a);
	if (len>0.0) scale(a,1.0/len);
}

float signedDistance(const vec3* v, const plane3* p) {
	return v->x * p->n.x + v->y * p->n.y + v->z * p->n.z + p->d;
}
	
void planeFromPoints(const vec3* a, const vec3* b, const vec3* c, plane3* p) {
	vec3 d1, d2;
	sub(a,b,&d1);
	sub (b,c,&d2);
	crossProduct(&d1,&d2,&(p->n));
	normalize(&(p->n));
	p->d = 0.0;
	p->d = -signedDistance(a,p);
}
	
