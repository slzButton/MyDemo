/*===============================================================================
Copyright (c) 2016 PTC Inc. All Rights Reserved.

Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/


#ifndef _VUFORIA_CUBE_H_
#define _VUFORIA_CUBE_H_


#define NUM_CUBE_VERTEX 24
#define NUM_CUBE_INDEX 36


static const float cubeVertices[NUM_CUBE_VERTEX * 3] =
{
    -1.00f,  -1.00f,   1.00f, // front
     1.00f,  -1.00f,   1.00f,
     1.00f,   1.00f,   1.00f,
    -1.00f,   1.00f,   1.00f,

    -1.00f,  -1.00f,  -1.00f, // back
     1.00f,  -1.00f,  -1.00f,
     1.00f,   1.00f,  -1.00f,
    -1.00f,   1.00f,  -1.00f,

    -1.00f,  -1.00f,  -1.00f, // left
    -1.00f,  -1.00f,   1.00f,
    -1.00f,   1.00f,   1.00f,
    -1.00f,   1.00f,  -1.00f,

     1.00f,  -1.00f,  -1.00f, // right
     1.00f,  -1.00f,   1.00f,
     1.00f,   1.00f,   1.00f,
     1.00f,   1.00f,  -1.00f,

    -1.00f,   1.00f,   1.00f, // top
     1.00f,   1.00f,   1.00f,
     1.00f,   1.00f,  -1.00f,
    -1.00f,   1.00f,  -1.00f,

    -1.00f,  -1.00f,   1.00f, // bottom
     1.00f,  -1.00f,   1.00f,
     1.00f,  -1.00f,  -1.00f,
    -1.00f,  -1.00f,  -1.00f
};

static const float cubeTexCoords[NUM_CUBE_VERTEX * 2] =
{
    0, 0,
    1, 0,
    1, 1,
    0, 1,

    1, 0,
    0, 0,
    0, 1,
    1, 1,

    0, 0,
    1, 0,
    1, 1,
    0, 1,

    1, 0,
    0, 0,
    0, 1,
    1, 1,

    0, 0,
    1, 0,
    1, 1,
    0, 1,

    1, 0,
    0, 0,
    0, 1,
    1, 1
};

static const float cubeNormals[NUM_CUBE_VERTEX * 3] =
{
    0, 0, 1,
    0, 0, 1,
    0, 0, 1,
    0, 0, 1,

    0, 0, -1,
    0, 0, -1,
    0, 0, -1,
    0, 0, -1,

    0, -1, 0,
    0, -1, 0,
    0, -1, 0,
    0, -1, 0,

    0, 1, 0,
    0, 1, 0,
    0, 1, 0,
    0, 1, 0,

    1, 0, 0,
    1, 0, 0,
    1, 0, 0,
    1, 0, 0,

    -1, 0, 0,
    -1, 0, 0,
    -1, 0, 0,
    -1, 0, 0
};

static const unsigned short cubeIndices[NUM_CUBE_INDEX] =
{
     0,  1,  2,  0,  2,  3, // front
     4,  6,  5,  4,  7,  6, // back
     8,  9, 10,  8, 10, 11, // left
    12, 14, 13, 12, 15, 14, // right
    16, 17, 18, 16, 18, 19, // top
    20, 22, 21, 20, 23, 22  // bottom
};


#endif // _QC_AR_CUBE_H_
