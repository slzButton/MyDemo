//
//  GCanvasCore.h
//  GCanvasCore
//
//  Created by xufan.yk on 13-11-21.
//  Copyright (c) 2013 xufan.yk. All rights reserved.
//


#ifndef __GCANVAS__
#define __GCANVAS__

#include "array.h"
#include "EJCanvas/EJCanvasContext.h"
#include "support/log.h"

using namespace gcanvas;

// -----------------------------------------------------------
// --    Clip utility class
// --    Used to process drawImage
// --    Populates the textureArr and vertexArr of a Quad
// -----------------------------------------------------------
struct Clip {
    int textureID;
    float cx, cy, cw, ch, px, py, pw, ph;    
};


// -----------------------------------------------------------
// --    CaptureParams struct
//
//  Contains the information needed to take a capture of the
//  GL context.
// -----------------------------------------------------------
struct CaptureParams {
    enum {
        ALLOCATED = 512
    };

    CaptureParams();
    CaptureParams(int x, int y, int w, int h, const char * callbackID, const char * fileName);

    int x;
    int y;
    int width;
    int height;
    char callbackID[ALLOCATED];
    char fileName[ALLOCATED];
};

// -----------------------------------------------------------
// --    Callback struct
//
//  Contains the information needed to execute a success or error
//  callback on the cordova side
// -----------------------------------------------------------
struct Callback {
    enum {
        ALLOCATED = 512
    };

    Callback(const char * id, const char * res, bool error);

    char callbackID[ALLOCATED];
    char result[ALLOCATED];
    bool isError;
};

class GGlObject
{
public:
    int app_id_;
    GLuint gl_handle_;
};

class GGlObjectMgr{
private:
    std::map<int, GGlObject> pool_;
    std::string flag_;
public: 
    void SetFlag(const char* flag){
        flag_ = flag;
    };
    const char* GetFlag(){
        return flag_.c_str();
    };
    void Append(int app_id, GLuint gl_id){
        LOG_D("[GGlObjectMgr::Append][%s]app_id=%d, gl_id=%u", flag_.c_str(), app_id, gl_id);
        GGlObject& obj = pool_[app_id];
        obj.app_id_ = app_id;
        obj.gl_handle_ = gl_id;
        // TODO:need delete exist instance   
    }
    
    void remove(int app_id){
		int num = (int)pool_.erase(app_id);
        LOG_D("[GGlObjectMgr::remove][%s]app_id=%d, %d object been remove..."
			, flag_.c_str(), app_id, num);
    }
	
    const GGlObject* Get(int app_id) const{
        std::map<int, GGlObject>::const_iterator itr;
        itr = pool_.find(app_id);
        if (pool_.end() != itr) {
            LOG_D("[GGlObjectMgr::Get][%s]app_id=%d, found...", flag_.c_str(), app_id);
            return &(itr->second);
        }
        LOG_D("[GGlObjectMgr::Get][%s]app_id=%d, unfound!!!", flag_.c_str(), app_id);
        return nullptr;
    };
};

class GCanvasCore : public EJCanvasContext
{
public:
	GCanvasCore();
	~GCanvasCore();

    void OnSurfaceChanged( int width, int height );
    void OnSurfaceChanged( int width, int height, EJColorRGBA color);
    void SetBackgroundColor(float red, float green, float blue);
    void SetOrtho(int width, int height);
    void AddTexture(int id, int glID, int width, int height);
    bool AddPngTexture(const unsigned char *buffer, long size, int id, unsigned int *pWidth, unsigned int *pHeight);
    void RemoveTexture(int id);
    void Render(const char *renderCommands, int length);
    void QueueCaptureGLLayer(int x, int y, int w, int h, const char * callbackID, const char * fn);
    //callback helper functions
    Callback * GetNextCallback(); //return front of callback queue
    void PopCallbacks(); //delete front of callback queue
    void AddCallback(const char * callbackID, const char * result, bool isError);

    void Clear();
    void SetTyOffsetFlag(bool flag);
    void GetImageData(int x, int y, int w, int h, bool base64_encode, std::string& pixels_data);
    void PutImageData(const char* image_data, int data_len,
        float dx, float dy, float sw, float sh, float dw, float dh);

    // drawImage called by JNI api
    void DrawImage(int textureId, float sx, float sy, float sw, float sh, float dx, float dy, float dw, float dh);
    void DrawText(const char *text, float x, float y,float maxWidth, bool isStroke);
    void FillRect(float x, float y, float w, float h);
    void UsePatternRenderPipeline(int texture_list_id, const std::string& pattern);
	int ExecuteWebGLCommands(const char* &cmd,int length);
	void GetAllParameter(std::string& ret);    

protected:
    void DrawFBO();
	void CalculateFPS();
	void ExecuteRenderCommands(const char *renderCommands, int length);
	bool IsCmd(const char* in, const char* match) { return in[0] == match[0]; }
	bool CaptureGLLayer(CaptureParams * params);
	const char* ParseSetTransform(const char *renderCommands,
								  int parseMode,               // what to read: IDENTITY, FULL_XFORM, etc.
								  bool concat,                 // if true, concatenate, else replace.
								  EJTransform transIn,           // the current xform
								  EJTransform *transOut);        // where to write the new xform

	void ParseSetTransForTextform(float v1,float v2,
	                                       int parseMode,               // what to read: IDENTITY, FULL_XFORM, etc.
	                                       bool concat,                 // if true, concatenate, else replace.
	                                       EJTransform transIn,           // the current xform
	                                       EJTransform *transOut );
	const char* ParseSetTransformT(const char *renderCommands,
								  int parseMode,               // what to read: IDENTITY, FULL_XFORM, etc.
								  bool concat,                 // if true, concatenate, else replace.
								  EJTransform transIn,           // the current xform
								  EJTransform *transOut);        // where to write the new xform

	const char* ParseTokens( const char *renderCommands, float * tokens, int iMaxCount=6)	;
	void ParseTokesOpt(float tokens[], const char **pp);

	const char* ParseDrawImage(const char *renderCommands, Clip *clipOut);
	const char* ParseUnknown(const char *renderCommands);
	const char* ExtractOneParameterFromCommand(char* out_parameter, const char* commands);
	const Texture* GetTextureWithOneImage(int id);
	float FastFloat(const char *str) { return (float)atof( str ); }

	//----------------------------------------------------------------------------------
    enum {
       IDENTITY,           // rt
       SET_XFORM,          // st
       SCALE,              // sc
       ROTATE,             // ro
       TRANSLATE,          // tr
       NUM_PARSE_MODES
    };
	
public:    

    clock_t last_time_;
    int     frames_;
    int	    messages_;
    float   fps_;
    float   mps_;
    int     msg_length_;
    float   bytes_ps_;
    bool    ty_offset_flag_;
    short   ty_offset_;
    std::string str_tmp_;//avoid new memory every times

    DynArray<EJTransform>     action_stack_;
    TextureMgr                texture_mgr_;
    DynArray<CaptureParams *> cap_params_;
    DynArray<Callback *>      callbacks_;
    GGlObjectMgr              texture_map_;
    GGlObjectMgr              shader_mgr_;// TODO:shader is part by prog?
    GGlObjectMgr              program_mgr_;
    GGlObjectMgr              attrib_mgr_;
    GGlObjectMgr              buffer_mgr_;
    GGlObjectMgr              uniform_mrg_;
    GGlObjectMgr              frame_buf_mrg_;
    GGlObjectMgr              render_buf_mrg_;
	int pixel_flip_y_;
	int render_count_;
};

#endif /* defined(__EJCanvas__EJCanvasContext__) */
