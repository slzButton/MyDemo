/*===============================================================================
Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/


#ifndef CYLINDER_MODEL_H_
#define CYLINDER_MODEL_H_


// number of sides used to build the cylinder
#define CYLINDER_NB_SIDES 64

// 2 series of CYLINDER_NB_SIDES vertex, plus
// one for the bottom circle, one for the top circle
#define CYLINDER_NUM_VERTEX ((CYLINDER_NB_SIDES * 2) + 2)

#ifdef __cplusplus
extern "C" {
#endif

class CylinderModel {
public:
	CylinderModel(float topRadius);

	void* ptrVertices();
	void* ptrIndices();
	void* ptrTexCoords();
	void* ptrNormals();

	int nbIndices();

private:
	void prepareData();

	const float mTopRadius;

	float cylinderVertices[CYLINDER_NUM_VERTEX * 3];

	// 4 triangles per side, so 12 indices per side
	unsigned short cylinderIndices[CYLINDER_NB_SIDES * 12];

	float cylinderTexCoords[CYLINDER_NUM_VERTEX * 2];

	float cylinderNormals[CYLINDER_NUM_VERTEX * 3];

};

#ifdef __cplusplus
}
#endif
#endif // CYLINDER_MODEL_H_
