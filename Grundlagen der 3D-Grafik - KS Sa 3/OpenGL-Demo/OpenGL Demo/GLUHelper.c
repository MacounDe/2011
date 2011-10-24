//
//  GLUHelper.c
//  OpenGL Demo
//
//  Created by Dönigus Daniel on 09.10.11.
//  Copyright (c) 2011 PRODEVCON. All rights reserved.
//

#include <stdio.h>
#include <OpenGL/gl.h>
#include "GLUHelper.h"
#import <Cocoa/Cocoa.h>

void glutSolidCubeTextured(GLfloat size) {
    static GLfloat n[6][3] =
    {
        {-1.0, 0.0, 0.0},
        {0.0, 1.0, 0.0},
        {1.0, 0.0, 0.0},
        {0.0, -1.0, 0.0},
        {0.0, 0.0, 1.0},
        {0.0, 0.0, -1.0}
    };
    static GLint faces[6][4] =
    {
        {0, 1, 2, 3},
        {3, 2, 6, 7},
        {7, 6, 5, 4},
        {4, 5, 1, 0},
        {5, 6, 2, 1},
        {7, 4, 0, 3}
    };
    GLfloat v[8][3];
    GLint i;
    
    v[0][0] = v[1][0] = v[2][0] = v[3][0] = -size / 2;
    v[4][0] = v[5][0] = v[6][0] = v[7][0] = size / 2;
    v[0][1] = v[1][1] = v[4][1] = v[5][1] = -size / 2;
    v[2][1] = v[3][1] = v[6][1] = v[7][1] = size / 2;
    v[0][2] = v[3][2] = v[4][2] = v[7][2] = -size / 2;
    v[1][2] = v[2][2] = v[5][2] = v[6][2] = size / 2;
    
    for (i = 5; i >= 0; i--) {
        glBegin(GL_QUADS);
        glNormal3fv(&n[i][0]);
        glTexCoord2d(0, 0);
        glVertex3fv(&v[faces[i][0]][0]);
        glTexCoord2d(1, 0);
        glVertex3fv(&v[faces[i][1]][0]);
        glTexCoord2d(1, 1);
        glVertex3fv(&v[faces[i][2]][0]);
        glTexCoord2d(0, 1);
        glVertex3fv(&v[faces[i][3]][0]);
        glEnd();
    }
}

void glutSolidSphereTextured(float radius, int nSlices, int nStacks) {
	
    
    if ( nSlices < 1 ) nSlices = 1;
    if ( nStacks < 1 ) nStacks = 1;
    
	int nVertices = ( nStacks + 1 ) * ( nSlices + 1 );
	int nIndices = nStacks * nSlices * 6;
	float psi = (2.0f * M_PI) / ((float) nSlices);
    float phi = (2.0f * M_PI) / ((float) nStacks*2);
    
    double* vertices = (double *)calloc( sizeof(double), 3 * nVertices );
    double* normals = (double *)calloc( sizeof(double), 3 * nVertices );
    double* texCoords = (double *)calloc( sizeof(double), 2 * nVertices );
    GLushort* indices = (GLushort *)calloc( sizeof(GLushort), nIndices );
	
	for(int i = 0; i < nStacks + 1; i++) {
		for(int j = 0; j < nSlices + 1; j++) {
			int vertex = ( i * (nSlices + 1) + j ) * 3; 
			
            vertices[vertex + 0] = radius * sinf(phi * (float)i) * sinf(psi * (float)j);
            vertices[vertex + 1] = radius * cosf(phi * (float)i);
            vertices[vertex + 2] = radius * sinf(phi * (float)i) * cosf(psi * (float)j);
            
            normals[vertex + 0] = vertices[vertex + 0] / radius;
            normals[vertex + 1] = vertices[vertex + 1] / radius;
            normals[vertex + 2] = vertices[vertex + 2] / radius;
            
            int texIndex = ( i * (nSlices + 1) + j ) * 2;
            texCoords[texIndex + 0] = (float) j / (float) nSlices;
            texCoords[texIndex + 1] = ((float) i ) / (float) (nStacks);
		}
	}
	
	// Generate the indices
	if(indices != NULL){
		GLushort *indexBuf = indices;
		for (int i = 0; i < nStacks ; i++) {
			for (int j = 0; j < nSlices; j++) {
				*indexBuf++ = i * ( nSlices + 1 ) + j;
				*indexBuf++ = ( i + 1 ) * ( nSlices + 1 ) + j;
				*indexBuf++ = ( i + 1 ) * ( nSlices + 1 ) + ( j + 1 );
				
				*indexBuf++ = i * ( nSlices + 1 ) + j;
				*indexBuf++ = ( i + 1 ) * ( nSlices + 1 ) + ( j + 1 );
				*indexBuf++ = i * ( nSlices + 1 ) + ( j + 1 );
			}
		}
	}
	
    glEnableClientState(GL_NORMAL_ARRAY); 
    glNormalPointer(GL_DOUBLE, 0, normals);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY); 
    glTexCoordPointer(2, GL_DOUBLE, 0, texCoords);
    glEnableClientState(GL_VERTEX_ARRAY); 
    glVertexPointer(3, GL_DOUBLE, 0, vertices);
    glDrawElements(GL_TRIANGLES, nSlices*6*nStacks, GL_UNSIGNED_SHORT, indices);
    
    free(vertices);
    free(indices);
    free(texCoords);
    free(normals);
}

void glutSolidTorusTextured( GLdouble dInnerRadius, GLdouble dOuterRadius, GLint nSides, GLint nRings ) {
    double  iradius = dInnerRadius, oradius = dOuterRadius, phi, psi, dpsi, dphi;
    double *vertex, *normal;
    int    i, j;
    double spsi, cpsi, sphi, cphi ;
    
    if ( nSides < 1 ) nSides = 1;
    if ( nRings < 1 ) nRings = 1;
    
    /* Increment the number of sides and rings to allow for one more point than surface */
    nSides ++ ;
    nRings ++ ;
    
    /* Allocate the vertices array */
    vertex = (double *)calloc( sizeof(double), 3 * nSides * nRings );
    normal = (double *)calloc( sizeof(double), 3 * nSides * nRings );
    
    glPushMatrix();
    
    dpsi =  2.0 * M_PI / (double)(nRings - 1) ;
    dphi = -2.0 * M_PI / (double)(nSides - 1) ;
    psi  = 0.0;
    
    for( j=0; j<nRings; j++ )
    {
        cpsi = cos ( psi ) ;
        spsi = sin ( psi ) ;
        phi = 0.0;
        
        for( i=0; i<nSides; i++ )
        {
            int offset = 3 * ( j * nSides + i ) ;
            cphi = cos ( phi ) ;
            sphi = sin ( phi ) ;
            *(vertex + offset + 0) = cpsi * ( oradius + cphi * iradius ) ;
            *(vertex + offset + 1) = spsi * ( oradius + cphi * iradius ) ;
            *(vertex + offset + 2) =                    sphi * iradius  ;
            *(normal + offset + 0) = cpsi * cphi ;
            *(normal + offset + 1) = spsi * cphi ;
            *(normal + offset + 2) =        sphi ;
            phi += dphi;
        }
        
        psi += dpsi;
    }
    
    glBegin( GL_QUADS );
    for( i=0; i<nSides-1; i++ )
    {
        for( j=0; j<nRings-1; j++ )
        {
            int offset = 3 * ( j * nSides + i ) ;
            glNormal3dv( normal + offset );
            glTexCoord2d((double)i/(double)nSides, (double)j/(double)nRings);
            glVertex3dv( vertex + offset );
            
            glNormal3dv( normal + offset + 3 );
            glTexCoord2d((double)(i+1)/(double)nSides, (double)j/(double)nRings);
            glVertex3dv( vertex + offset + 3 );
            
            glNormal3dv( normal + offset + 3 * nSides + 3 );
            glTexCoord2d((double)(i+1)/(double)nSides, (double)(j+1)/(double)nRings);
            glVertex3dv( vertex + offset + 3 * nSides + 3 );
            
            glNormal3dv( normal + offset + 3 * nSides );
            glTexCoord2d((double)i/(double)nSides, (double)(j+1)/(double)nRings);
            glVertex3dv( vertex + offset + 3 * nSides );
        }
    }
    
    glEnd();
    
    free ( vertex ) ;
    free ( normal ) ;
    glPopMatrix();
}
