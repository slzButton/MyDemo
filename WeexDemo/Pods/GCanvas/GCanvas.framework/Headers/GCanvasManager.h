/*
 * GCanvasManager.h
 *
 *  Created on: Nov 27, 2013
 *      Author: xufan
 */

#ifndef GCANVASMANAGER_H_
#define GCANVASMANAGER_H_

#include <map>
#include "GCanvasCore.h"
#include "memory/AutoPtr.h"

namespace gcanvas
{
    class GCanvasManager 
    {
    public:
        GCanvasManager();
        virtual ~GCanvasManager();

        void newCanvas(std::string id);
        void removeCanvas(std::string id);
        GCanvasCore * getCanvas(std::string id);
        void clear();
    protected:
        std::map< std::string , GCanvasCore* > mCanvases;
    private:
        // Members
        static AutoPtr<GCanvasManager> theManager;
    public:
        static GCanvasManager *getManager(); // Call any time you need a renderer
        static void Release(); // Call at shutdown to free memory (calls ContextLost)
    };
}

#endif /* GCANVASMANAGER_H_ */
