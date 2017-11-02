/*===============================================================================
Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/


#include "CylinderModel.h"
#include <math.h>


CylinderModel::CylinderModel(float topRadius):mTopRadius(topRadius)
{
	prepareData();
}

void*
CylinderModel::ptrVertices()
{
	return &cylinderVertices[0];
}

void*
CylinderModel::ptrIndices()
{
	return &cylinderIndices[0];
}

void*
CylinderModel::ptrTexCoords()
{
	return &cylinderTexCoords[0];
}

void*
CylinderModel::ptrNormals()
{
	return &cylinderNormals[0];
}

int
CylinderModel::nbIndices()
{
	return sizeof(cylinderIndices) / sizeof(unsigned short);
}


void
CylinderModel::prepareData() {
	double deltaTex = 1.0 / (double) CYLINDER_NB_SIDES;

	// vertices index for the bottom and top vertex
	const int ix_vertex_center_bottom  = 2 * CYLINDER_NB_SIDES;
	const int ix_vertex_center_top = ix_vertex_center_bottom + 1;

	for (int i = 0; i < CYLINDER_NB_SIDES; i++)
	{
	    double angle = 2 * M_PI * i / CYLINDER_NB_SIDES;

	    // bottom circle
	    cylinderVertices[(i * 3) + 0] = cos(angle); // x
	    cylinderVertices[(i * 3) + 1] = sin(angle); // y
	    cylinderVertices[(i * 3) + 2] = 0;          // z

	    // top circle
	    cylinderVertices[(i + CYLINDER_NB_SIDES) * 3 + 0] = mTopRadius * cylinderVertices[i * 3 + 0]; // x
	    cylinderVertices[(i + CYLINDER_NB_SIDES) * 3 + 1] = mTopRadius * cylinderVertices[i * 3 + 1]; // y
	    cylinderVertices[(i + CYLINDER_NB_SIDES) * 3 + 2] = 1;          // z

	    // texture coordinates
	    cylinderTexCoords[(i * 2) + 0] = i * deltaTex;
	    cylinderTexCoords[(i * 2) + 1] = 1;

	    cylinderTexCoords[((i + CYLINDER_NB_SIDES) * 2) + 0] = i * deltaTex;
	    cylinderTexCoords[((i + CYLINDER_NB_SIDES) * 2) + 1] = 0;

	    // normals

	    cylinderNormals[(i * 3) + 0] = cylinderVertices[(i * 3) + 1];
	    cylinderNormals[(i * 3) + 1] = - (cylinderVertices[(i * 3) + 0]);
	    cylinderNormals[(i * 3) + 2] = 0;          // z

	    // top circle
	    cylinderNormals[(i + CYLINDER_NB_SIDES) * 3 + 0] = mTopRadius * cylinderVertices[i * 3 + 1];
	    cylinderNormals[(i + CYLINDER_NB_SIDES) * 3 + 1] = - (mTopRadius * cylinderVertices[i * 3 + 0]);
	    cylinderNormals[(i + CYLINDER_NB_SIDES) * 3 + 2] = 0;          // z

	    // indices
	    // triangles are b0 b1 t1  and t1 t0 b0 (bn: vertex #n on the bottom circle, tn: vertex #n on the to circle)
	    // i1 is the index of the next vertex - we wrap if we reach the end of the circle
	    int i1 = i + 1;
	    if (i1 == CYLINDER_NB_SIDES) {
	    	i1 = 0;
	    }
	    cylinderIndices[(i * 12) + 0] = i ;
	    cylinderIndices[(i * 12) + 1] = i1 ;
	    cylinderIndices[(i * 12) + 2] = (i1 + CYLINDER_NB_SIDES) ;

	    cylinderIndices[(i * 12) + 3] = (i1 + CYLINDER_NB_SIDES) ;
	    cylinderIndices[(i * 12) + 4] = (i + CYLINDER_NB_SIDES);
	    cylinderIndices[(i * 12) + 5] = i;

	    // bottom circle
	    cylinderIndices[(i * 12) + 6] = i1 ;
	    cylinderIndices[(i * 12) + 7] = i ;
	    cylinderIndices[(i * 12) + 8] = ix_vertex_center_bottom ;

	    // top circle
	    cylinderIndices[(i * 12) + 9] = (i + CYLINDER_NB_SIDES) ;
	    cylinderIndices[(i * 12) + 10] = (i1 + CYLINDER_NB_SIDES) ;
	    cylinderIndices[(i * 12) + 11] = ix_vertex_center_top ;

	}

	// we are adding 2 extra vertices: the center of each circle
    cylinderVertices[(3 * ix_vertex_center_bottom) + 0] = 0; // x
    cylinderVertices[(3 * ix_vertex_center_bottom) + 1] = 0; // y
    cylinderVertices[(3 * ix_vertex_center_bottom) + 2] = 0; // z

    cylinderVertices[(3 * ix_vertex_center_top) + 0] = 0; // x
    cylinderVertices[(3 * ix_vertex_center_top) + 1] = 0; // y
    cylinderVertices[(3 * ix_vertex_center_top) + 2] = 1; // z

    cylinderTexCoords[(ix_vertex_center_bottom * 2) + 0] = 0.5;
    cylinderTexCoords[(ix_vertex_center_bottom * 2) + 1] = 0.5;

    cylinderTexCoords[(ix_vertex_center_top * 2) + 0] = 0.5;
    cylinderTexCoords[(ix_vertex_center_top * 2) + 1] = 0.5;

    cylinderNormals[(3 * ix_vertex_center_bottom) + 0] = 0;
    cylinderNormals[(3 * ix_vertex_center_bottom) + 1] = 0;
    cylinderNormals[(3 * ix_vertex_center_bottom) + 2] = -1;          // z

    cylinderNormals[(3 * ix_vertex_center_top) + 0] = 0;
    cylinderNormals[(3 * ix_vertex_center_top) + 1] = 0;
    cylinderNormals[(3 * ix_vertex_center_top) + 2] = 1;          // z
}
