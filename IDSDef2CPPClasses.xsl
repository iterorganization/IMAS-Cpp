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

// this definition is needed to avoid mutex problems with blitz++
//#define BZ_THREADSAFE

#include "UALDef.h"
//#include &lt;blitz/array.h&gt;

<xsl:apply-templates select = "IDS" mode = "CLASS_HEADER"/>

//using namespace blitz;
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
class IDS
{
    private:
    int expIdx;
    int shot, run, refShot, refRun;
    string treeName;
    bool connected;

    public:
    IDS();
    IDS(int shot, int run, int refShot, int refRun);
    IDS(int idx);
    void setExpIdx(int idx);
    void setShot(int inShot) {shot = inShot;}
    void setRun(int inRun) {run = inRun;}
    void setRefShot(int inRefShot){refShot = inRefShot;}
    void setRefNum(int inRefRun){refRun = inRefRun;}
    void setTreeName(char *inTreeName){treeName = inTreeName; }
    void setTreeName(string inTreeName){treeName = inTreeName;}
    void setCacheLevel(int level) {imas_set_cache_level(expIdx, level);}
    int getCacheLevel() {return imas_get_cache_level(expIdx);}
    int getIdx() {return expIdx;}
    int getShot() {return shot;}
    int getRun() {return run;}
    int getRefShot(){return refShot;}
    int getRefRun(){return refRun;}
    string getTreeName(){return treeName;}
    bool isConnected(){return connected;}
    void open();
    void create();
    void openEnv(char *user, char *tokamak, char *version);
    void createEnv(char *user, char *tokamak, char *version);
    void openHdf5();
    void createHdf5();
    void openPublic(const char* expName);
    void createPublic(const char* expName);
    void close();
    void close(char *name, int shot, int run) {close();}
    void discardAll();
    void flushAll();
    void enableMemCache();
    void disableMemCache();
    int getTime(char *path, Array&lt;double,1&gt; &amp;time);
    ~IDS();
    friend ostream <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>operator <xsl:text disable-output-escaping = "yes">&lt;&lt;</xsl:text> (ostream <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>os, const IDS <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>obj);

    //#include "IdsDef.h"
 <xsl:apply-templates select = "IDS" mode = "EMPTY_CLASS_DEFINITION"/>
 <xsl:apply-templates select = "IDS" mode = "CLASS_INSTANTIATION"/>
 <xsl:apply-templates select = "IDS" mode = "CLASS_DEFINITION"/>
   
    };
    ostream <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>operator <xsl:text disable-output-escaping = "yes">&lt;&lt;</xsl:text> (ostream <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>os, const IDS <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>obj);
}

 #endif
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

//#include &lt;blitz/array.h&gt;
#include "IdsDef.h"
namespace IdsNs {

<!--============= Define time-dependent IDSs =============-->
class <xsl:value-of select="@name"/>_IDSBase:Ids
{
    private:
      int expIdx;
      bool connected;
      public:
      void setExpIdx(int expIdx){this->expIdx = expIdx; connected = true;}
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
    int replaceLastSlice();
    int replaceLastSlice(int idx);
    int deleteAll();
    int deleteAll(int idx);
    int remove();
    int remove(int idx);
    int putNonTimed();
    int putNonTimed(int idx);
    void discardCache();
    void discardCache(int idx);
    void flushCache();
    void flushCache(int idx);
    friend ostream <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>operator <xsl:text disable-output-escaping = "yes">&lt;&lt;</xsl:text> (ostream <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>os, const <xsl:value-of select="@name"/>_IDSBase <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>obj);
};
 ostream <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>operator <xsl:text disable-output-escaping = "yes">&lt;&lt;</xsl:text> (ostream <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>os, const <xsl:value-of select="@name"/>_IDSBase <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>obj);

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
    <xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">
      Array<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>double,1<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='int_1d_type' or @data_type='INT_1D'">
      Array<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>int,1<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='str_1d_type' or @data_type='STR_1D'">
      Array<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>std::string,1<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='FLT_2D'">
      Array<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>double,2<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='INT_2D'">
      Array<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>int,2<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='FLT_3D'">
      Array<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>double,3<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='INT_3D'">
      Array<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>int,3<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
   <xsl:when test="@data_type='FLT_4D'">
      Array<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>double,4<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
   <xsl:when test="@data_type='FLT_5D'">
      Array<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>double,5<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='FLT_6D'">
      Array<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>double,6<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
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
	      } <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='struct_array'">
	class <xsl:value-of select = "@name"/> {
		public:
		<xsl:apply-templates select = "field" mode = "DECLARE"/>
		<xsl:value-of select = "@name"/>() {
		<xsl:apply-templates select = "field" mode = "CONSTRUCTOR"/>
		  };
	      };
	      Array&lt;class <xsl:value-of select = "@name"/>,1&gt; <xsl:value-of select = "@name"/>;
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
    <xsl:when test="@data_type='int' or @data_type='INT_0D'">
      <xsl:value-of select = "@name"/>=EMPTY_INT;
    </xsl:when>
    <xsl:when test="@name='xs:double'">
      <xsl:value-of select = "@name"/>=EMPTY_DOUBLE;
    </xsl:when>
    <xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
      <xsl:value-of select = "@name"/>=EMPTY_DOUBLE;
    </xsl:when>
  </xsl:choose>
</xsl:template>


</xsl:stylesheet>
