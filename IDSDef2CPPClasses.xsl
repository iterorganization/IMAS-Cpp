<?xml version="1.0" encoding="UTF-8"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./%24GET%5Bstylesheet%5D" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>

<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common" version="1.0" extension-element-prefixes="yaslt exsl"
  xmlns:fn="http://www.w3.org/2005/02/xpath-functions">

<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

 <xsl:template match = "/IDSs">
 <exsl:document href="src/UALClasses.h" standalone="yes" method="text">


#ifndef _UAL_CLASSES
#define _UAL_CLASSES

#include "UALDef.h"

<xsl:apply-templates select = "IDS" mode = "CLASS_HEADER"/>

#if defined(_WIN32)
#  define LIBRARY_API __declspec(dllexport)
#else
#  define LIBRARY_API
#endif

#ifdef __cplusplus
extern "C" {
#endif


namespace IdsNs {

typedef struct {
	char **parameters;
	char **default_param;
	char **schema;
} codeparam_t;


<!--
inline
void checkObject(void *obj)
{
    if (!obj) printf("Problem with array of structure allocation\n");
}
-->
class LIBRARY_API IDS
{
    private:
    int pulseCtx;
    int shot, run, refShot, refRun;
    string treeName;
    bool connected;
    BACKEND backend;
    BACKEND defaultBackend();
    BACKEND fallbackBackend();
    
    public:
    IDS();
    IDS(int shot, int run, int refShot, int refRun);
    IDS(int idx);
    void setExpIdx(int idx);  // will be deprecated in the future!
    void setPulseCtx(int idx);
    void setShot(int inShot) {shot = inShot;}
    void setRun(int inRun) {run = inRun;}
    void setRefShot(int inRefShot){refShot = inRefShot;}
    void setRefNum(int inRefRun){refRun = inRefRun;}
    void setTreeName(char *inTreeName){treeName = inTreeName; }
    void setTreeName(string inTreeName){treeName = inTreeName;}
    void setBackend(BACKEND inBackend){backend = inBackend;}
    int getIdx(); // will be deprecated in the future!
    int getPulseCtx() {return this->pulseCtx;}
    int getShot() {return shot;}
    int getRun() {return run;}
    int getRefShot(){return refShot;}
    int getRefRun(){return refRun;}
    string getTreeName(){return treeName;}
    BACKEND getBackend(){return backend;}
    bool isConnected(){return connected;}
    int open(const char *uri, int mode);
    int create(const char *uri, int mode);
    int openEnv(const char *user, const char *tokamak, const char *version, const char* option = nullptr);
    int createEnv(const char *user, const char *tokamak, const char *version, const char* option = nullptr);
    int close();
    void close(char *name, int shot, int run) {close();}
    int getTime(char *path, IMASArray&lt;double,1&gt; &amp;time);
    ~IDS();
    friend ostream <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>operator <xsl:text disable-output-escaping = "yes">&lt;&lt;</xsl:text> (ostream <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>os, const IDS <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>obj);

    //#include "IdsDef.h"
 <xsl:apply-templates select = "IDS" mode = "EMPTY_CLASS_DEFINITION"/>
 <xsl:apply-templates select = "IDS" mode = "CLASS_INSTANTIATION"/>
 <xsl:apply-templates select = "IDS" mode = "CLASS_DEFINITION"/>
   
    };
    ostream <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>operator <xsl:text disable-output-escaping = "yes">&lt;&lt;</xsl:text> (ostream <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>os, const IDS <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>obj);
}

#ifdef __cplusplus
}
#endif

#endif // _UAL_CLASSES
</exsl:document>
</xsl:template>


<!--=================================================-->
<!--                  IDS headers                    -->
<!--=================================================-->

<xsl:template match = "IDS" mode = "CLASS_HEADER">
 #include "./ids/<xsl:value-of select="@name"/>_IDSBase.h"
</xsl:template>



<!--=================================================-->
<!--              Empty class definition             -->
<!--=================================================-->

<xsl:template match = "IDS" mode = "EMPTY_CLASS_DEFINITION">
      /***** IDS <xsl:value-of select="@name"/>; *****/
    class <xsl:value-of select="@name"/> : public <xsl:value-of select="@name"/>_IDSBase {};
</xsl:template>


<!--=================================================-->
<!--                 IDS instances                   -->
<!--=================================================-->
<xsl:template match = "IDS" mode = "CLASS_INSTANTIATION">
 /***** IDS <xsl:value-of select="@name"/>; *****/
    <xsl:value-of select="@name"/>  _<xsl:value-of select="@name"/>;
</xsl:template>


<!--=================================================-->
<!--                 IDS definition                  -->
<!--=================================================-->

<xsl:template match = "IDS" mode = "CLASS_DEFINITION">
<exsl:document href="ids/{@name}_IDSBase.h" standalone="yes" method="text">
#ifndef _IDS_BASE_<xsl:value-of select="@name"/>
#define _IDS_BASE_<xsl:value-of select="@name"/>

#include "IdsDef.h"

#if defined(_WIN32)
#  define LIBRARY_API __declspec(dllexport)
#else
#  define LIBRARY_API
#endif

namespace IdsNs {


#ifdef __cplusplus
extern "C" {
#endif


<!--============= Define time-dependent IDSs =============-->
class LIBRARY_API <xsl:value-of select="@name"/>_IDSBase:Ids
{
    private:
      int pulseCtx;
      bool connected;

      public:
      void setPulseCtx(int pulseCtx){this->pulseCtx = pulseCtx; connected = true;}
      <xsl:apply-templates select = "field" mode = "DECLARE"/>
      <xsl:value-of select="@name"/>_IDSBase();
    int get();
    int get(int idx);
    int put();
    int put(int idx);
    int getSlice(double inTime, char interpolMode);
    int getSlice(int idx, double inTime, char interpolMode);
    int putSlice();
    int putSlice(int idx);
    int deleteAll();
    int deleteAll(int idx);
    void clear();
};

#ifdef __cplusplus
}
#endif

LIBRARY_API ostream <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>operator <xsl:text disable-output-escaping = "yes">&lt;&lt;</xsl:text> (ostream <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>os, const <xsl:value-of select="@name"/>_IDSBase <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>obj);

}

#endif // _IDS_BASE_<xsl:value-of select="@name"/>
<xsl:text>&#10;</xsl:text>
   </exsl:document>
  </xsl:template>


<!--============ Define IDS fields ============-->

<xsl:template match = "field" mode = "DECLARE">
  <xsl:choose>
    <xsl:when test="@data_type='str_type' or @data_type='STR_0D'">
      std::string <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='int_type' or @data_type='INT_0D'">
      int <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
      double <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@type='cpx_type'  or @data_type='CPX_0D'">
      std_complex_t <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">
      IMASArray<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>double,1<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='int_1d_type' or @data_type='INT_1D'">
      IMASArray<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>int,1<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='str_1d_type' or @data_type='STR_1D'">
      IMASArray<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>std::string,1<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='FLT_2D'">
      IMASArray<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>double,2<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='INT_2D'">
      IMASArray<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>int,2<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='FLT_3D'">
      IMASArray<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>double,3<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='INT_3D'">
      IMASArray<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>int,3<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
   <xsl:when test="@data_type='FLT_4D'">
      IMASArray<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>double,4<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
   <xsl:when test="@data_type='FLT_5D'">
      IMASArray<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>double,5<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='FLT_6D'">
      IMASArray<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>double,6<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='cplx_1d_type' or @data_type='CPX_1D'">
      IMASArray<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>std_complex_t, 1<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='CPX_2D'">
      IMASArray<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>std_complex_t, 2<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='CPX_3D'">
      IMASArray<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>std_complex_t, 3<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='CPX_4D'">
      IMASArray<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>std_complex_t, 4<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='CPX_5D'">
      IMASArray<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>std_complex_t, 5<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='CPX_6D'">
      IMASArray<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>std_complex_t, 6<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>

    <!-- structures and arrays of structures are implemented as classes,
         so that we can initialize the fields in the constructor.
	 Special types complexgrid, complexgrid_scalar and complexgrid_vector are defined above. -->
    <xsl:when test="@data_type='structure'">
	
	class <xsl:value-of select = "@name"/> {
		public:
		  <xsl:apply-templates select = "field" mode = "DECLARE"/>
		  <xsl:value-of select = "@name"/>() {
		    <xsl:apply-templates select = "field" mode = "CONSTRUCTOR"/>
		  };
    int get(int ctx, int idsTimeMode);
    int put(int ctx, int idsTimeMode, const std::string &amp;idsFullName);
    <xsl:if test="descendant-or-self::field[@type='dynamic'] or ancestor::field[@type='dynamic' and @data_type='struct_array']">
    int putSlice(int ctx, int idsTimeMode, const std::string &amp;idsFullName);
     </xsl:if> 

    <xsl:if test="not(ancestor::field[@data_type='struct_array'])">
    int deleteAll(int ctx);
     </xsl:if> 
    void clear();

	      } <xsl:value-of select = "@name"/>;
    </xsl:when>

    <xsl:when test="@data_type='struct_array'">
	class <xsl:value-of select = "@name"/> {
		public:
		<xsl:apply-templates select = "field" mode = "DECLARE"/>
		<xsl:value-of select = "@name"/>() {
		<xsl:apply-templates select = "field" mode = "CONSTRUCTOR"/>
		  };
    int get(int ctx, int idsTimeMode);
    int put(int ctx, int idsTimeMode, const std::string &amp;idsFullName);
    void clear();
    <xsl:if test="descendant-or-self::field[@type='dynamic'] or ancestor::field[@type='dynamic' and @data_type='struct_array']">
    int putSlice(int ctx, int idsTimeMode, const std::string &amp;idsFullName);
    </xsl:if> 

//    int deleteAll(int ctx);
	      };
	      IMASArray&lt;class <xsl:value-of select = "@name"/>,1&gt; <xsl:value-of select = "@name"/>;
    </xsl:when>
	<xsl:otherwise>
    <xsl:message terminate="yes">
        Error: Unknown data type: <xsl:value-of select = "@data_type"/> !      </xsl:message>
</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--=================================================-->
<!--              field initialization               -->
<!--=================================================-->

<xsl:template match = "field" mode = "CONSTRUCTOR">
  <xsl:choose>
    <xsl:when test="@data_type='int_type' or @data_type='INT_0D'">
      <xsl:value-of select = "@name"/>=EMPTY_INT;
    </xsl:when>
    <xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
      <xsl:value-of select = "@name"/>=EMPTY_DOUBLE;
    </xsl:when>
    <xsl:when test="@data_type='cpx_type' or @data_type='CPX_0D'">
      <xsl:value-of select = "@name"/>=EMPTY_COMPLEX;
    </xsl:when>
  </xsl:choose>
</xsl:template>


</xsl:stylesheet>
