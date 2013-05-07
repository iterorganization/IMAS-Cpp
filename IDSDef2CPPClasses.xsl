<?xml version="1.0" encoding="UTF-8"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./%24GET%5Bstylesheet%5D" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>

<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" version="1.0" extension-element-prefixes="yaslt"
  xmlns:fn="http://www.w3.org/2005/02/xpath-functions">

<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

 <xsl:template match = "/IDSs">
#ifndef _UAL_CLASSES

#define _UAL_CLASSES

// this definition is needed to avoid mutex problems with blitz++
#define BZ_THREADSAFE

#include "UALDef.h"
#include &lt;blitz/array.h&gt; 

using namespace blitz;
namespace IdsNs {

typedef struct {
	char **parameters;
	char **default_param;
	char **schema;
} codeparam_t;

<!--class complexgrid_scalar {
	public:
        int subgrid;
        Array &lt;double,1&gt; scalar;
        Array &lt;double,2&gt; vector;
        Array &lt;double,3&gt; matrix;
	complexgrid_scalar() {
		subgrid = EMPTY_INT;
	}
};

class complexgrid_vector {
	public:
	std::string label;
	Array &lt; class complexgrid_scalar, 1 &gt; comp;
	Array &lt; int, 1 &gt; align;
	Array &lt; std::string, 1 &gt; alignid;
};

class complexgrid {
      public:

	class spaces {
	  public:
	    Array &lt; int, 1 &gt; coordtype;
	    class properties {
	      public:
		int geotype;
		 std::string geotypeid;
		 properties() {
		    geotype = EMPTY_INT;
		};
	    } properties;

	    class objects {
	      public:
		Array &lt; int, 2 &gt; boundary;
		Array &lt; int, 3 &gt; neighbour;
		Array &lt; double, 3 &gt; geo;
		Array &lt; double, 1 &gt; measure;
	    };
	    Array &lt; class objects, 1 &gt; objects;

	    class nodes {
	      public:
		Array &lt; double, 3 &gt; geo;
		Array &lt; int, 1 &gt; xpoints;

		class altgeo {
		  public:
		    Array &lt; int, 1 &gt; coordtype;
		    Array &lt; double, 3 &gt; geo;
		};
		Array &lt; class altgeo, 1 &gt; altgeo;
		Array &lt; int, 1 &gt; alias;
	    } nodes;
	};
	Array &lt; class spaces, 1 &gt; spaces;

	class subgrids {
	  public:
	    std::string id;

	    class list {
	      public:
		Array &lt; int, 1 &gt; cls;

		class indset {
		  public:
		    Array &lt; int, 1 &gt; range;
		    Array &lt; int, 1 &gt; ind;
		};
		Array &lt; class indset, 1 &gt; indset;
		Array &lt; int, 2 &gt; ind;
	    };
	    Array &lt; class list, 1 &gt; list;
	};
	Array &lt; class subgrids, 1 &gt; subgrids;

	class metric {
	  public:
	    class complexgrid_scalar measure;
	    class complexgrid_scalar g11;
	    class complexgrid_scalar g12;
	    class complexgrid_scalar g13;
	    class complexgrid_scalar g22;
	    class complexgrid_scalar g23;
	    class complexgrid_scalar g33;
	    class complexgrid_scalar jacobian;
	};
	Array &lt; class metric, 1 &gt; metric;
};-->
                         
inline 
void checkObject(void *obj) 
{
    if (!obj) printf("Problem with array of structure allocation\n");
}

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
    void close();
    void close(char *name, int shot, int run) {close();}
    void discardAll();
    void flushAll();
    void enableMemCache();
    void disableMemCache();
    int getTime(char *path, Array&lt;double,1&gt; &amp;time);
    ~IDS();
    friend ostream <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>operator <xsl:text disable-output-escaping = "yes">&lt;&lt;</xsl:text> (ostream <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>os, const IDS <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>obj);

    #include "IdsDef.h"
    
    
    <xsl:apply-templates select = "IDS" mode = "CLASS_DEFINITION"/>
    <xsl:apply-templates select = "IDS" mode = "CLASS_INSTANTIATION"/>

    };
}
 
 #endif
 
<!--=================================================-->
<!--                 IDS instances                   -->
<!--=================================================-->

</xsl:template>
<xsl:template match = "IDS" mode = "CLASS_INSTANTIATION">
 <!--YBYB   <xsl:choose> >
        <xsl:when test = "@timed = 'no'">
YBYB-->
            <xsl:value-of select="@name"/>  
            _<xsl:value-of select="@name"/>;
 <!--YBYB          </xsl:when>
      <xsl:otherwise>
            <xsl:value-of select="@name"/>  
            _<xsl:value-of select="@name"/>;
            <xsl:value-of select="@name"/>Array
            _<xsl:value-of select="@name"/>Array;
       </xsl:otherwise>
    </xsl:choose>
YBYB-->
</xsl:template>


<!--=================================================-->
<!--                 IDS definition                  -->
<!--=================================================-->

<xsl:template match = "IDS" mode = "CLASS_DEFINITION">
<!-- YBYB  <xsl:choose> -->
  
<!--============ Define time-independent IDSs ============-->

<!-- YBYB        <xsl:when test = "@timed = 'no'"> 
          class <xsl:value-of select="@name"/>:Ids
          {
          private:
          int expIdx;
          bool connected;
          public:
          <xsl:apply-templates select = "field" mode = "DECLARE"/>
          <xsl:value-of select="@name"/>();
          void setExpIdx(int expIdx){this->expIdx = expIdx; connected = true;}
          int get();
          int get(int idx);
          int put();
          int put(int idx);
	  void flush();
	  void flush(int idx);
	  void discard();
	  void discard(int idx);
          friend ostream <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>operator <xsl:text disable-output-escaping = "yes">&lt;&lt;</xsl:text> (ostream <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>os, const <xsl:value-of select="@name"/> <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>obj);

};
     </xsl:when>
YBYB-->
      
<!--============= Define time-dependent IDSs =============-->
<!-- YBYBYBYBYBYB
      <xsl:otherwise>
YBYB-->
class <xsl:value-of select="@name"/>:Ids
{
    private:
      int expIdx;
      bool connected;
      public:
      void setExpIdx(int expIdx){this->expIdx = expIdx; connected = true;}
      <xsl:apply-templates select = "field" mode = "DECLARE"/>
          <xsl:value-of select="@name"/>();
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
    friend ostream <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>operator <xsl:text disable-output-escaping = "yes">&lt;&lt;</xsl:text> (ostream <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>os, const <xsl:value-of select="@name"/> <xsl:text disable-output-escaping = "yes">&amp;</xsl:text>obj);
};
<!--YBYB
class <xsl:value-of select="@name"/>Array:Ids
{
private:
          int expIdx;
	  bool connected;
          
          
public:
    <xsl:value-of select="@name"/>Array(){connected = false;}
    void setExpIdx(int expIdx){this->expIdx = expIdx; connected = true;}
    Array<xsl:text disable-output-escaping = "yes"> &lt;</xsl:text><xsl:value-of select="@name"/>,1<xsl:text disable-output-escaping = "yes"> &gt;</xsl:text> array;

    int get();
    int put();
    int deleteAll();
    int deleteAll(int idx);
    int get(int idx);
    int put(int idx);
    void discardCache();
    void discardCache(int idx);
    void flushCache();
    void flushCache(int idx);
    <xsl:value-of select="@name"/> &amp;operator() (int index) {return array(index);};
    <xsl:value-of select="@name"/> &amp;operator[] (int index) {return array(index);};
    int extent(int dim = 0) {return array.extent(dim);};
  };
  </xsl:otherwise>

  </xsl:choose>
-->
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
    <xsl:when test="@name='xs:boolean'">
      int <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@name='xs:double'">
      double <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
      double <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">
      Array<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>double,1<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@name='vecdbl_type'">
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
    <xsl:when test="@name='matdbl_type'">
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
    <xsl:when test="@name='array3ddbl_type'">
      Array<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>double,3<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='FLT_4D'">
      Array<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>double,4<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@name='array4dint_type'">
      Array<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>int,4<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@name='array4ddbl_type'">
      Array<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>double,4<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='FLT_5D'">
      Array<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>double,5<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@name='array5dint_type'">
      Array<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>int,5<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@name='array5ddbl_type'">
      Array<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>double,5<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@data_type='FLT_6D'">
      Array<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>double,6<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@name='array6dint_type'">
      Array<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>int,6<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>
    <xsl:when test="@name='array6ddbl_type'">
      Array<xsl:text disable-output-escaping = "yes">&lt;</xsl:text>double,6<xsl:text disable-output-escaping = "yes">&gt;</xsl:text> <xsl:value-of select = "@name"/>;
    </xsl:when>

    <!-- structures and arrays of structures are implemented as classes,
         so that we can initialize the fields in the constructor.
	 Special types complexgrid, complexgrid_scalar and complexgrid_vector are defined above. -->
    <xsl:when test="@data_type='structure'">
	<!--<xsl:choose>
	      <xsl:when test="@name-name='complexgrid_scalar'">
		class complexgrid_scalar <xsl:value-of select = "@name"/>;
	      </xsl:when>
	      <xsl:when test="@name-name='complexgrid_vector'">
		class complexgrid_vector <xsl:value-of select = "@name"/>;
	      </xsl:when>
	      <xsl:when test="@name-name='complexgrid'">
		class complexgrid <xsl:value-of select = "@name"/>;
	      </xsl:when>
	      <xsl:otherwise> -->
		      class <xsl:value-of select = "@name"/> {
			public:
			  <xsl:apply-templates select = "field" mode = "DECLARE"/>
			  <xsl:value-of select = "@name"/>() {
			    <xsl:apply-templates select = "field" mode = "CONSTRUCTOR"/>
			  };
		      } <xsl:value-of select = "@name"/>;
	<!--      </xsl:otherwise>
	</xsl:choose>-->
    </xsl:when>
    <xsl:when test="@data_type='struct_array'">
	<!--<xsl:choose>
	      <xsl:when test="@name-name='complexgrid_scalar'">
		Array&lt;class complexgrid_scalar,1&gt;  <xsl:value-of select = "@name"/>;
	      </xsl:when>
	      <xsl:when test="@name-name='complexgrid_vector'">
		Array&lt;class complexgrid_vector,1&gt;  <xsl:value-of select = "@name"/>;
	      </xsl:when>
	      <xsl:when test="@name-name='complexgrid'">
		Array&lt;class complexgrid,1&gt;  <xsl:value-of select = "@name"/>;
	      </xsl:when>
	      <xsl:otherwise> -->
		      class <xsl:value-of select = "@name"/> {
			public:
			  <xsl:apply-templates select = "field" mode = "DECLARE"/>
			  <xsl:value-of select = "@name"/>() {
			    <xsl:apply-templates select = "field" mode = "CONSTRUCTOR"/>
			  };
		      };
		      Array&lt;class <xsl:value-of select = "@name"/>,1&gt; <xsl:value-of select = "@name"/>;
	      <!--</xsl:otherwise>
	</xsl:choose>-->
    </xsl:when>
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
