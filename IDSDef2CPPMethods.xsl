<?xml version="1.0" encoding="UTF-8"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./%24GET%5Bstylesheet%5D" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<!-- Jo Lister, CRPP-EPFL, 2005, Generating  Fortran 90 code calls from XSD schemas -->
<!-- -->
<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.orng/2005/02/xpath-functions" version="1.0" extension-element-prefixes="yaslt">

<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="/IDSs">
#include "UALClasses.h"

using namespace blitz;
using namespace IdsNs;

#define NON_TIMED    0
#define TIMED       1
#define TIMED_CLEAR 2
/*#define DEBUG*/

#ifdef DEBUG
void checkStatus(int status) {if(status) printf("%s\n", imas_last_errmsg());}
#else
void checkStatus(int status){}
#endif

IdsNs::IDS::IDS()
{
treeName = "ids";
connected = false;
shot = refShot = run = refRun = -1;
}
IdsNs::IDS::IDS(int shot, int run, int refShot, int refRun)
{
treeName = "ids";
connected = false;
this-&gt; shot = shot;
this-&gt;run = run;
this-&gt;refShot = refShot;
this-&gt;refRun = refRun;
expIdx = -1;
}
IdsNs::IDS::IDS(int idx)
{
treeName = "ids";
connected = true;
this-&gt; shot = ual_get_shot(idx);
this-&gt;run = ual_get_run(idx);
this-&gt;refShot =  ual_get_shot(idx);
this-&gt;refRun = ual_get_run(idx);
expIdx = idx;
<xsl:apply-templates select="IDS" mode="SET_IDX"/>
}
void IdsNs::IDS::open() 
{
int idx;
int status = imas_open("ids", shot, run, &amp;idx);
if(status != 0)
{
printf("Error opening imas shot %d, run %d: %s\n", shot, run, imas_last_errmsg());
}
else
{
expIdx = idx;
connected = true;
<xsl:apply-templates select="IDS" mode="SET_IDX"/>
} 
}
void IdsNs::IDS::openEnv(char *user, char *tokamak, char *version) 
{
int idx;
int status = imas_open_env("ids", shot, run, &amp;idx, user, tokamak, version);
if(status != 0)
{
printf("Error opening imas shot %d, run %d: %s\n", shot, run, imas_last_errmsg());
}
else
{
expIdx = idx;
connected = true;
<xsl:apply-templates select="IDS" mode="SET_IDX"/>
}

}
void IdsNs::IDS::openHdf5() 
{
int idx;
int status = imas_open_hdf5("ids", shot, run, &amp;idx);
if(status != 0)
{
printf("Error opening imas shot %d, run %d: %s\n", shot, run, imas_last_errmsg());
}
else
{
expIdx = idx;
connected = true;
<xsl:apply-templates select="IDS" mode="SET_IDX"/>
}

}

void IdsNs::IDS::create()
{
int idx;
int status = imas_create("ids", shot, run, refShot, refRun, &amp; idx);
if(status != 0)
{
printf("Error opening imas shot %d, run %d: %s\n", shot, run, imas_last_errmsg());
}
else
{
expIdx = idx;
connected = true;
<xsl:apply-templates select="IDS" mode="SET_IDX"/>
}
}

void IdsNs::IDS::createEnv(char *user, char *tokamak, char *version)
{
int idx;
int status = imas_create_env("ids", shot, run, refShot, refRun, &amp; idx, user, tokamak, version);
if(status != 0)
{
printf("Error opening imas shot %d, run %d: %s\n", shot, run, imas_last_errmsg());
}
else
{
expIdx = idx;
connected = true;
<xsl:apply-templates select="IDS" mode="SET_IDX"/>
}
}

void IdsNs::IDS::createHdf5()
{
int idx;
int status = imas_create_hdf5("ids", shot, run, refShot, refRun, &amp; idx);
if(status != 0)
{
printf("Error opening imas shot %d, run %d: %s\n", shot, run, imas_last_errmsg());
}
else
{
expIdx = idx;
connected = true;
<xsl:apply-templates select="IDS" mode="SET_IDX"/>
}
}

void IdsNs::IDS::close()
{
if(!connected) return;
if(expIdx != -1)
imas_close(expIdx);
connected = false;
}

void IdsNs::IDS::enableMemCache()
{
if(!connected) return;
if(expIdx != -1)
imas_enable_mem_cache(expIdx);
}

void IdsNs::IDS::disableMemCache()
{
if(!connected) return;
if(expIdx != -1)
imas_disable_mem_cache(expIdx);
}


void IdsNs::IDS::flushAll()
{
if(!connected) return;
if(expIdx != -1)
imas_flush_mem_cache(expIdx);
}

void IdsNs::IDS::discardAll()
{
if(!connected) return;
if(expIdx != -1)
imas_discard_mem_cache(expIdx);
}

int IdsNs::IDS::getTime(char *path, Array&lt;double,1&gt; &amp;time)
{
int retSamples;
double *doubleArray;
int dim;

if(!connected) return -1;
int status = beginIdsGet(expIdx,path,TIMED,&amp;retSamples);
checkStatus(status);
if(status) return status;
status = getVect1DDouble(expIdx, path, "time", &amp;doubleArray, &amp;dim);
checkStatus(status);
if(!status) {
Array&lt;double,1&gt; newArray(doubleArray, shape(dim), duplicateData, fortranArray);
time.resize(newArray.shape());
time = newArray;
free(doubleArray);
}
endIdsGet(expIdx, path);
return status;
}

IdsNs::IDS::~IDS()
{
/*if(expIdx != -1)
imas_close(expIdx);*/
}

char * str2char(string str)
{  
char *cyb;
cyb = new char[512];
strcpy(cyb, str.c_str());
return cyb;
}

string int2str(int i, int j)
{  
int r;
r= i+j;
ostringstream convert;   // stream used for the conversion
convert &lt;&lt; r;      // insert the textual representation of 'Number' in the characters in the stream

return(convert.str());
}

<xsl:apply-templates select="IDS" mode="CLASS_DEFINITION"/>

ostream &amp;IdsNs::operator &lt;&lt; (ostream &amp;os, const IDS &amp;obj)
{
os &lt;&lt; "TreeName: ";
os &lt;&lt; obj.treeName;
os &lt;&lt; "\nShot: ";
os &lt;&lt;obj.shot;
os &lt;&lt;"\nRun: ";
os &lt;&lt;obj.run;
os &lt;&lt;"\nRef Shot: ";
os &lt;&lt;obj.refShot;
os &lt;&lt;"\nRef Run: ";
os &lt;&lt;obj.refRun;
os &lt;&lt;((obj.connected)?"Connected":"Not Connected");
return os;
}
<xsl:apply-templates select="IDS" mode="DUMP"/>
<!--
with stringstream:
string int2string(int i)
{
stringstream ss;
ss << number;
return ss.str();
} 
-->
</xsl:template>

<!--=================================================-->
<!--                 set idx in IDS                  -->
<!--=================================================-->

<xsl:template match="IDS" mode="SET_IDX">
<!--YBYB   <xsl:choose>
<xsl:when test = "@timed = 'no'">
YBYB-->
_<xsl:value-of select="@name"/>.setExpIdx(expIdx);    
<!--YBYB       </xsl:when>
<xsl:otherwise>
_<xsl:value-of select="@name"/>.setExpIdx(expIdx);    
_<xsl:value-of select="@name"/>Array.setExpIdx(expIdx);    
</xsl:otherwise>
</xsl:choose>
YBYB-->
</xsl:template>

<!--=================================================-->
<!--               print IDS content                 -->
<!--=================================================-->
<!--YBYBDUMP -->
<xsl:template match="IDS" mode="DUMP">
ostream &amp;IdsNs::operator &lt;&lt; (ostream &amp;os, const IDS::<xsl:value-of select="@name"/> &amp;obj)
{ 
<xsl:apply-templates select="field" mode="DUMP">
	<xsl:with-param name="level" select="1"/>
	<xsl:with-param name="idxpath" select="'obj'"/>
</xsl:apply-templates>
return os;
}
</xsl:template>
<!--   -->
<!--=================================================-->
<!--               define IDS content                -->
<!--=================================================-->

<xsl:template match="IDS" mode="CLASS_DEFINITION">
<!--YBYB <xsl:choose> -->
<!--============ Define time-independent IDSs ============-->
<!-- YBYBYB  <xsl:when test = "@timed = 'no'"> -->
IdsNs::IDS::<xsl:value-of select="@name"/>::<xsl:value-of select="@name"/>()
{
connected = false;
<xsl:apply-templates select="field" mode="CONSTRUCTOR"/>
}

int IDS::<xsl:value-of select="@name"/>::get()
{
if(!connected) return -1;
double *times, double0d;
void * obj_all_times;
int i, _i, numSamples,dim1, dim2, dim3, dim4, dim5, dim6, dim7, status, int0d;
int dim1In, dim2In, dim3In, dim4In, dim5In, dim6In, dim7In;
int *intArray;
char **stringArray;
double *doubleArray;
char *str;
char *path = "<xsl:value-of select="@name"/>";
char *clepath;
string lepath; <xsl:for-each select=".//field[@data_type='struct_array']">
int i<xsl:value-of select="@name"/>; </xsl:for-each>
status = beginIdsGet(expIdx, "<xsl:value-of select="@name"/>", NON_TIMED, &amp;numSamples);
checkStatus(status);
if (status) return status;
<xsl:apply-templates select="field" mode="GET_SINGLE"/>
endIdsGet(expIdx, "<xsl:value-of select="@name"/>");
return 0;
}

int IDS::<xsl:value-of select="@name"/>::get(int idx)
{
if(!connected) return -1;
double *times, double0d;
void * obj_all_times;
int i, _i, numSamples, dim1, dim2, dim3, dim4, dim5, dim6, dim7, status, int0d;
int dim1In, dim2In, dim3In, dim4In, dim5In, dim6In, dim7In;
int *intArray;
char **stringArray;
double *doubleArray;
char *str;
char *basePath = "<xsl:value-of select="@name"/>";
char *clepath;
string lepath; <xsl:for-each select=".//field[@data_type='struct_array']">
int i<xsl:value-of select="@name"/>; </xsl:for-each>
char path[strlen(basePath)+4];
if(idx &lt; 1)
sprintf(path, "%s", basePath);
else
sprintf(path, "%s/%d", basePath, idx);
status = beginIdsGet(expIdx, path, NON_TIMED, &amp;numSamples);
checkStatus(status);
if (status) return status;
<xsl:apply-templates select="field" mode="GET_SINGLE"/>
endIdsGet(expIdx, path);
return 0;
}

int IDS::<xsl:value-of select="@name"/>::put()
{
if(!connected) return -1;
int status, dim1, dim2, dim3, dim4, dim5, dim6, dim7, _i, _j, _k, _h, _l, _m, _n;
int dim1In, dim2In, dim3In, dim4In, dim5In, dim6In, dim7In;
double *doubleArray;
int *intArray;
char **stringArray;
char *path = "<xsl:value-of select="@name"/>";
char *clepath;
string lepath, timepath;
string timebasepath; <xsl:for-each select=".//field[@data_type='struct_array']">
int i<xsl:value-of select="@name"/>; </xsl:for-each>
deleteAll();
status = beginIdsPut(expIdx, "<xsl:value-of select="@name"/>");
checkStatus(status);
if(status) return status;
<xsl:apply-templates select="field" mode="PUT_SINGLE"/>
endIdsPut(expIdx, "<xsl:value-of select="@name"/>");
return 0;
}

int IDS::<xsl:value-of select="@name"/>::put(int idx)
{
if(!connected) return -1;
int status, dim1, dim2, dim3, dim4, dim5, dim6, dim7, _i, _j, _k, _h, _l, _m, _n, h;
int dim1In, dim2In, dim3In, dim4In, dim5In, dim6In, dim7In;
double *doubleArray;
int *intArray;
char **stringArray;
char *basePath = "<xsl:value-of select="@name"/>";
char path[strlen(basePath)+4];
char *clepath;
string lepath,  timepath;
string timebasepath; <xsl:for-each select=".//field[@data_type='struct_array']">
int i<xsl:value-of select="@name"/>; </xsl:for-each>
if(idx &lt; 1)
sprintf(path, "%s", basePath);
else
sprintf(path, "%s/%d", basePath, idx);
deleteAll(idx);
status = beginIdsPut(expIdx, path);
checkStatus(status);
if(status) return status;
<xsl:apply-templates select="field" mode="PUT_SINGLE"/>
endIdsPut(expIdx, path);
return 0;
}

int IdsNs::IDS::<xsl:value-of select="@name"/>::putSlice(int idx)
{
if(!connected) return -1;
int dim1, dim2, dim3, dim4, dim5, dim6, dim7;
int dim1In, dim2In, dim3In, dim4In, dim5In, dim6In, dim7In;
int *intArray;
double *doubleArray;
int _i, _j, _k, _h, _l, _m, _n;
char *str;
char *basePath = "<xsl:value-of select="@name"/>";
char path[strlen(basePath)+4];
char *clepath;
string lepath, timepath;
string timebasepath; <xsl:for-each select=".//field[@data_type='struct_array']">
int i<xsl:value-of select="@name"/>; </xsl:for-each>
if(idx &lt; 1)
sprintf(path, "%s", basePath);
else
sprintf(path, "%s/%d", basePath, idx);
double retTime;
if (ids_properties.homogeneous_time != 1) {
puts("ERROR : the PUT_SLICE routine works only for homogeneous timebase IDS");
return (-99);
}
timebasepath = "time";
int status = beginIdsPutSlice(expIdx,  path);
checkStatus(status);
if(status) return status;
<xsl:apply-templates select="field" mode="PUT_SLICE"/>
endIdsPutSlice(expIdx, path);
return 0;
}

int IdsNs::IDS::<xsl:value-of select="@name"/>::putSlice()
{
if(!connected) return -1;
int dim1, dim2, dim3, dim4, dim5, dim6, dim7;
int dim1In, dim2In, dim3In, dim4In, dim5In, dim6In, dim7In;
int *intArray;
double *doubleArray;
int _i, _j, _k, _h, _l, _m, _n;
char *str;
char *path = "<xsl:value-of select="@name"/>";
double retTime;
char *clepath;
string lepath;
string timebasepath; <xsl:for-each select=".//field[@data_type='struct_array']">
int i<xsl:value-of select="@name"/>; </xsl:for-each>
if (ids_properties.homogeneous_time != 1) {
puts("ERROR : the PUT_SLICE routine works only for homogeneous timebase IDS");
return (-99);
}
timebasepath = "time";
int status = beginIdsPutSlice(expIdx,  "<xsl:value-of select="@name"/>");
checkStatus(status);
if(status) return status;
<xsl:apply-templates select="field" mode="PUT_SLICE"/>
endIdsPutSlice(expIdx, path);
return 0;
}

int IdsNs::IDS::<xsl:value-of select="@name"/>::remove(int idx)
{
string lepath;
char * clepath; <xsl:for-each select=".//field[@data_type='struct_array']">
int  i<xsl:value-of select="@name"/>; </xsl:for-each>
if(!connected) return -1;
char *basePath = "<xsl:value-of select="@name"/>";
char path[strlen(basePath)+4];
if(idx &lt; 1)
sprintf(path, "%s", basePath);
else
sprintf(path, "%s/%d", basePath, idx);
<xsl:apply-templates select="field" mode="DELETE"/>
return 0;
}

int IdsNs::IDS::<xsl:value-of select="@name"/>::remove()
{
string lepath;
char * clepath; <xsl:for-each select=".//field[@data_type='struct_array']">
int i<xsl:value-of select="@name"/>; </xsl:for-each>
if(!connected) return -1;
char *path = "<xsl:value-of select="@name"/>";
<xsl:apply-templates select="field" mode="DELETE"/>
return 0;
}

int IdsNs::IDS::<xsl:value-of select="@name"/>::deleteAll(int idx)
{
string lepath;
char * clepath; <xsl:for-each select=".//field[@data_type='struct_array']">
int i<xsl:value-of select="@name"/>; </xsl:for-each>
if(!connected) return -1;
char *basePath = "<xsl:value-of select="@name"/>";
char path[strlen(basePath)+4];
if(idx &lt; 1)
sprintf(path, "%s", basePath);
else
sprintf(path, "%s/%d", basePath, idx);
<xsl:apply-templates select="field" mode="DELETE"/>
return 0;
}

int IdsNs::IDS::<xsl:value-of select="@name"/>::deleteAll()
{
string lepath;
char * clepath; <xsl:for-each select=".//field[@data_type='struct_array']">
int i<xsl:value-of select="@name"/>; </xsl:for-each>
if(!connected) return -1;
char *path = "<xsl:value-of select="@name"/>";
<xsl:apply-templates select="field" mode="DELETE"/>
return 0;
}

int IdsNs::IDS::<xsl:value-of select="@name"/>::putNonTimed()
{
if(!connected) return -1;
string lepath, timebasepath, timepath;
char * clepath;
int dim1, dim2, dim3, dim4, dim5, dim6, dim7;
int dim1In, dim2In, dim3In, dim4In, dim5In, dim6In, dim7In;
int *intArray;
double *doubleArray;
int _i, _j, _k, _h, _l, _m, numSamples;
char **stringArray;
char *path = "<xsl:value-of select="@name"/>";
char *str; <xsl:for-each select=".//field[@data_type='struct_array']">
int i<xsl:value-of select="@name"/>; </xsl:for-each>
double retTime;
deleteAll();
int status = beginIdsPutNonTimed(expIdx,  "<xsl:value-of select="@name"/>");
checkStatus(status);
if(status) return status;
<xsl:apply-templates select="field" mode="PUT_SINGLE">
	<xsl:with-param name="non_timed" select="yes"/>
</xsl:apply-templates>
endIdsPutNonTimed(expIdx, path);
return 0;
}

int IdsNs::IDS::<xsl:value-of select="@name"/>::putNonTimed(int idx)
{
if(!connected) return -1;
string lepath, timebasepath, timepath;
char * clepath;
int dim1, dim2, dim3, dim4, dim5, dim6, dim7;
int dim1In, dim2In, dim3In, dim4In, dim5In, dim6In, dim7In;
int *intArray;
double *doubleArray;
int _i, _j, _k, _h, _l, _m, numSamples;
char *str;
char **stringArray;
char *basePath = "<xsl:value-of select="@name"/>";
char path[strlen(basePath)+4];
if(idx &lt; 1)
sprintf(path, "%s", basePath);
else
sprintf(path, "%s/%d", basePath, idx);
double retTime; <xsl:for-each select=".//field[@data_type='struct_array']">
int i<xsl:value-of select="@name"/>; </xsl:for-each>
deleteAll(idx);
int status = beginIdsPutNonTimed(expIdx,  path);
checkStatus(status);
if(status) return status;
<xsl:apply-templates select="field" mode="PUT_SINGLE">
	<xsl:with-param name="non_timed" select="yes"/>
</xsl:apply-templates>
endIdsPutNonTimed(expIdx, path);
return 0;
}

int IdsNs::IDS::<xsl:value-of select="@name"/>::getSlice(double inTime, char interpolMode)
{
if(!connected) return -1;
int dim1, dim2, dim3, dim4, dim5, dim6, dim7, _i, int0d, numDims;
int dim1In, dim2In, dim3In, dim4In, dim5In, dim6In, dim7In;
int *intArray;
double *doubleArray, double0d;
char **stringArray;
char *str;
char *clepath;
string timepath,timebasepath;
string lepath; <xsl:for-each select=".//field[@data_type='struct_array']">
int i<xsl:value-of select="@name"/>; </xsl:for-each>
char *path = "<xsl:value-of select="@name"/>";
double retTime;
int status = beginIdsGetSlice(expIdx,  "<xsl:value-of select="@name"/>", inTime);
checkStatus(status);
if(status) return status;
<xsl:apply-templates select="field" mode="GET_SLICE"/>
endIdsGetSlice(expIdx, path);
return 0;
}

int IdsNs::IDS::<xsl:value-of select="@name"/>::getSlice(int idx, double inTime, char interpolMode)
{
if(!connected) return -1;
int dim1, dim2, dim3, dim4, dim5, dim6,  dim7, _i, int0d, numDims;
int dim1In, dim2In, dim3In, dim4In, dim5In, dim6In, dim7In;
int *intArray;
double *doubleArray, double0d;
char **stringArray;
char *str;
char *clepath;
string timepath,timebasepath;
string lepath; <xsl:for-each select=".//field[@data_type='struct_array']">
int i<xsl:value-of select="@name"/>; </xsl:for-each>
char *basePath = "<xsl:value-of select="@name"/>";
char path[strlen(basePath)+4];
if(idx &lt; 1)
sprintf(path, "%s", basePath);
else
sprintf(path, "%s/%d", basePath, idx);
double retTime;
int status = beginIdsGetSlice(expIdx,  path, inTime);
checkStatus(status);
if(status) return status;
<xsl:apply-templates select="field" mode="GET_SLICE"/>
endIdsGetSlice(expIdx, path);
return 0;
}
</xsl:template>

<!--=================================================-->
<!--              field initialization               -->
<!--=================================================-->
<xsl:template match="field" mode="CONSTRUCTOR">
<xsl:choose>
	<xsl:when test="@data_type='int_type' or @data_type='INT_0D'">
		<xsl:value-of select="translate(@path,'/','.')"/>=EMPTY_INT;
	</xsl:when>
	<xsl:when test="@name='xs:double'">
		<xsl:value-of select="translate(@path,'/','.')"/>=EMPTY_DOUBLE;
	</xsl:when>
	<xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
		<xsl:value-of select="translate(@path,'/','.')"/>=EMPTY_DOUBLE;
	</xsl:when>
	<!-- Note that this template only initializes scalar field that are at the upper tree level.
Scalar fields that are inside structures and arrays of structures
are initialized by the constructors of the respective subclasses.
See IDSDef2Classes.xsl  -->
</xsl:choose>
</xsl:template>

<!--=================================================-->
<!--                 delete fields                   -->
<!--=================================================-->

<xsl:template match="field" mode="DELETE">
<xsl:param name="variable_path"/>
<xsl:param name="mds_path"/>
<xsl:choose>
	<xsl:when test="@data_type='structure'">
		<xsl:choose>
			<xsl:when test="$variable_path">
				<xsl:apply-templates select="field" mode="DELETE">
					<xsl:with-param name="variable_path" select="concat($variable_path,'.',@name)"/>
					<xsl:with-param name="mds_path" select="concat($mds_path,'+string(&quot;/',@name,'&quot;)')"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="field" mode="DELETE">
					<xsl:with-param name="variable_path" select="@name"/>
					<xsl:with-param name="mds_path" select="concat('&quot;',@name,'&quot;')"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<!--========== Arrays of structures ==========-->
  <xsl:when test="@data_type='struct_array' and @maxoccur!='unbounded'"> 
		<xsl:choose>
			<xsl:when test="$mds_path">
				for (i<xsl:value-of select="@name"/> = 0;i<xsl:value-of select="@name"/>&lt;<xsl:value-of select="@maxoccur"/>; i<xsl:value-of select="@name"/>++){
				<xsl:apply-templates select="field" mode="DELETE">
					<xsl:with-param name="variable_path" select="concat($variable_path,'.',@name,'(i',@name,')')"/>
					<xsl:with-param name="mds_path" select="concat($mds_path,' + ','string(&quot;/',@name,'/&quot;) + int2str(i',@name,',1)')"/>
				</xsl:apply-templates>
				}
			</xsl:when>
			<xsl:otherwise>
				for (i<xsl:value-of select="@name"/> = 0;i<xsl:value-of select="@name"/>&lt;<xsl:value-of select="@maxoccur"/>; i<xsl:value-of select="@name"/>++){
				<xsl:apply-templates select="field" mode="DELETE">
					<xsl:with-param name="variable_path" select="concat(@name,'(i',@name,')')"/>
					<xsl:with-param name="mds_path" select="concat('&quot;',@name,'/&quot; + int2str(i',@name,',1)')"/>
				</xsl:apply-templates>
				}
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:otherwise>
		<xsl:choose>
			<xsl:when test="$mds_path">
				lepath = <xsl:value-of select="$mds_path"/>  + string("/<xsl:value-of select="@name"/>");
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				deleteData(expIdx, path, clepath);
			</xsl:when>
			<xsl:otherwise>
				deleteData(expIdx, path, "<xsl:value-of select="@path"/>");
			</xsl:otherwise>
		</xsl:choose>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!--=================================================-->
<!--               discard old cache                 -->
<!--=================================================-->

<xsl:template match="field" mode="DISCARD_OLD_CACHE">
<xsl:choose>
	<xsl:when test="@timed = 'yes'">
		imas_discard_old_mem(expIdx, path, "<xsl:value-of select="@path"/>", time);
	</xsl:when>
</xsl:choose>
<xsl:choose>
	<xsl:when test="@data_type='structure'">
		<xsl:apply-templates select="field" mode="DISCARD_OLD_CACHE"/>
	</xsl:when>
</xsl:choose>
</xsl:template>

<!--=================================================-->
<!--                 discard cache                   -->
<!--=================================================-->

<xsl:template match="field" mode="DISCARD_CACHE">
<xsl:choose>
	<xsl:when test="@data_type='structure'">
		<xsl:apply-templates select="field" mode="DISCARD_CACHE"/>
	</xsl:when>
	<xsl:otherwise>
		imas_discard_mem(expIdx, path, "<xsl:value-of select="@path"/>");
	</xsl:otherwise>    
</xsl:choose>
</xsl:template>


<!--=================================================-->
<!--              print field content                -->
<!--=================================================-->
<!-- YBYBDUMP -->
<xsl:template match="field" mode="DUMP">
<xsl:param name="level"/>   
<xsl:param name="idxpath"/> 

<xsl:param name="currentidxpath" select="concat($idxpath,'.',@name)"/>

<xsl:choose>
	<xsl:when test="@data_type='str_type' or @data_type='STR_0D'">
		os &lt;&lt; "\n<xsl:value-of select="$currentidxpath"/>: ";
		if(<xsl:value-of select="$currentidxpath"/>.empty())
		os &lt;&lt; "EMPTY";
		else
		os &lt;&lt; <xsl:value-of select="$currentidxpath"/>;
	</xsl:when>
	<xsl:when test="@data_type='int_type' or @data_type='INT_0D'">
		os &lt;&lt; "\n<xsl:value-of select="$currentidxpath"/>: ";
		if(<xsl:value-of select="$currentidxpath"/> == EMPTY_INT)
		os &lt;&lt; "EMPTY";
		else
		os &lt;&lt; <xsl:value-of select="$currentidxpath"/>;
	</xsl:when>
	<xsl:when test="@name='xs:boolean'">
		os &lt;&lt; "\n<xsl:value-of select="$currentidxpath"/>: ";
		if(<xsl:value-of select="$currentidxpath"/> == EMPTY_INT)
		os &lt;&lt; "EMPTY";
		else
		os &lt;&lt; <xsl:value-of select="$currentidxpath"/>;
	</xsl:when>
	<xsl:when test="@name='xs:double'">
		os &lt;&lt; "\n<xsl:value-of select="$currentidxpath"/>: ";
		if(<xsl:value-of select="$currentidxpath"/> == EMPTY_DOUBLE)
		os &lt;&lt; "EMPTY";
		else
		os &lt;&lt; <xsl:value-of select="$currentidxpath"/>;
	</xsl:when>
	<xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
		os &lt;&lt; "\n<xsl:value-of select="$currentidxpath"/>: ";
		if(<xsl:value-of select="$currentidxpath"/> == EMPTY_DOUBLE)
		os &lt;&lt; "EMPTY";
		else
		os &lt;&lt; <xsl:value-of select="$currentidxpath"/>;
	</xsl:when>
	<xsl:when test="@data_type='structure'">
		<xsl:apply-templates select="field" mode="DUMP">
			<xsl:with-param name="level" select="$level"/>
			<xsl:with-param name="idxpath" select="$currentidxpath"/>
		</xsl:apply-templates>
	</xsl:when>
	<xsl:when test="@data_type='struct_array'">
		for (int i<xsl:value-of select="$level"/> = 0; i<xsl:value-of select="$level"/> &lt; <xsl:value-of select="$idxpath"/>.<xsl:value-of select="@name"/>.extent(0); i<xsl:value-of select="$level"/>++) {
		<xsl:apply-templates select="field" mode="DUMP">
			<xsl:with-param name="level" select="$level + 1"/>
			<xsl:with-param name="idxpath" select="concat($currentidxpath,'(i',$level,')')"/>
		</xsl:apply-templates>
		}
	</xsl:when>
	<xsl:otherwise>
		os &lt;&lt; "\n<xsl:value-of select="$currentidxpath"/>: ";
		if(<xsl:value-of select="$currentidxpath"/>.extent(0) == 0)
		os &lt;&lt; "EMPTY";
		else
		os &lt;&lt; <xsl:value-of select="$currentidxpath"/>;

	</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--=================================================-->
<!--       get field of a time-independent IDS       -->
<!--=================================================-->
<xsl:template match="field" mode="GET_SINGLE">
<xsl:param name="variable_path"/>
<xsl:param name="mds_path"/>
<xsl:choose>
	<xsl:when test="@data_type='structure'">
		<xsl:choose>
			<xsl:when test="$variable_path">
				<xsl:apply-templates select="field" mode="GET_SINGLE">
					<xsl:with-param name="variable_path" select="concat($variable_path,'.',@name)"/>
					<xsl:with-param name="mds_path" select="concat($mds_path,'+string(&quot;/',@name,'&quot;)')"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="field" mode="GET_SINGLE">
					<xsl:with-param name="variable_path" select="@name"/>
					<xsl:with-param name="mds_path" select="concat('&quot;',@name,'&quot;')"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
  <xsl:when test="@data_type='struct_array' and @maxoccur!='unbounded' ">
    <!-- Type 1 arrays of structure, with potentially multiple time bases -->
		// Doc  Get <xsl:value-of select="@path"/>
		<xsl:choose>
			<xsl:when test="$variable_path">
				lepath = <xsl:value-of select="$mds_path"/>  + string("/<xsl:value-of select="@name"/>/Shape_of");
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getInt(expIdx,path, clepath,&amp;int0d);
				if (status == 0) {
				<xsl:value-of select="concat($variable_path,'.',@name)"/>.resize(int0d);
				for (i<xsl:value-of select="@name"/>=0; i<xsl:value-of select="@name"/>&lt;<xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0); i<xsl:value-of select="@name"/>++) {
				<xsl:apply-templates select="field" mode="GET_SINGLE">
					<xsl:with-param name="variable_path" select="concat($variable_path,'.',@name,'(i',@name,')')"/>
					<xsl:with-param name="mds_path" select="concat($mds_path,'+','string(&quot;/',@name,'/&quot;) + int2str(i',@name,',1)')"/>
				</xsl:apply-templates>
				}
				}
			</xsl:when>
			<xsl:otherwise>
				status= getInt(expIdx,path, "<xsl:value-of select="@name"/>/Shape_of",&amp;int0d);
				if (status == 0) {
				<xsl:value-of select="@name"/>.resize(int0d);
				for( i<xsl:value-of select="@name"/>=0; i<xsl:value-of select="@name"/> &lt;<xsl:value-of select="@name"/>.extent(0); i<xsl:value-of select="@name"/>++) {
				<xsl:apply-templates select="field" mode="GET_SINGLE">
					<xsl:with-param name="variable_path" select="concat(@name,'(i',@name,')')"/>
					<xsl:with-param name="mds_path" select="concat('&quot;',@name,'/&quot; + int2str(i',@name,',1)')"/>
				</xsl:apply-templates>
				}
				}
			</xsl:otherwise>
		</xsl:choose>
		<!-- OLD
{/*    Array of structure    */
void *obj1;
status = getObject(expIdx, path, "<xsl:value-of select = "@path"/>", &amp;obj1,0); // read the whole block
checkStatus(status);
if (!status) {
<xsl:value-of select = "translate(@path,'/','.')"/>.resize(getObjectDim(expIdx,obj1));
for (int i1 = 0; i1 &lt; getObjectDim(expIdx,obj1); i1++) {  // process array elements
<xsl:apply-templates select = "field" mode = "GET_FROM_OBJECT">
<xsl:with-param name="level" select="1"/>
<xsl:with-param name="objpath" select="@name"/>
<xsl:with-param name="idxpath" select="concat(translate(@path,'/','.'),'(i1)')"/>
<xsl:with-param name="timed" select="'no'"/>
</xsl:apply-templates>
}
releaseObject(expIdx,obj1);
}
}
-->
	</xsl:when>
  <xsl:when test="@data_type='struct_array' and @maxoccur='unbounded' and @type='dynamic'">
    <!-- Type 3 arrays of structure, with a unique time base -->
    <xsl:choose>
      <xsl:when test="$variable_path">
        // Structure array of type 3 nested below a Type 1 : <xsl:value-of select = "concat($variable_path,'%',@name)"/>
        lepath = <xsl:value-of select="$mds_path"/>  + string("/<xsl:value-of select="@name"/>");
        clepath = const_cast&lt;char *&gt; (lepath.c_str());
        status = getObject(expIdx, path, clepath, &amp;obj_all_times, TIMED); // read the whole non-timed block
				checkStatus(status);
        if(!status) {
          dim1 = getObjectDim(expIdx,obj_all_times);
          <xsl:value-of select="concat($variable_path,'.',@name)"/>.resize(dim1);
          //if (ual_debug =='yes') write(*,*) &amp; 'Get ids%<xsl:value-of select = "concat($variable_path,'%',@name)"/>, lentime =', lentime
          for (int i1 = 0; i1 &lt; dim1; i1++) {  // fill every time slice
          void *obj1;
          status = getObjectFromObject(expIdx,obj_all_times, "ALLTIMES", i1, &amp;obj1);  // extract a single time
          checkStatus(status);
           if (!status) {
          <xsl:apply-templates select = "field" mode = "GET_FROM_OBJECT">
            <xsl:with-param name="level" select="1"/>
            <xsl:with-param name="objpath" select="@name"/>
            <xsl:with-param name="idxpath" select="concat($variable_path,'.',@name,'(i1)')"/>
            <xsl:with-param name="timed" select="'yes'"/>
          </xsl:apply-templates>
          }
          }
          releaseObject(expIdx,obj_all_times);
          }
        </xsl:when>
      <xsl:otherwise>
        //Structure array of type 3 : <xsl:value-of select = "@path"/>
        status = getObject(expIdx, path, "<xsl:value-of select = "@path"/>", &amp;obj_all_times, TIMED); // read the whole non-timed block
        if(!status) {
          dim1 = getObjectDim(expIdx,obj_all_times);
          <xsl:value-of select="translate(@path,'/','.')"/>.resize(dim1);

          //  YBYB14 if (ual_debug =='yes') write(*,*) &amp; 'Get ids%<xsl:value-of select="translate(@path,'/','%')"/>, lentime =', lentime
          for (int i1 = 0; i1 &lt; dim1; i1++) {  // fill every time slice
          void *obj1;
          status = getObjectFromObject(expIdx,obj_all_times, "ALLTIMES", i1, &amp;obj1);  // extract a single time
          checkStatus(status);
           if (!status) {
            <xsl:apply-templates select = "field" mode = "GET_FROM_OBJECT">
            <xsl:with-param name="level" select="1"/>
            <xsl:with-param name="objpath" select="@name"/>
            <xsl:with-param name="idxpath" select="concat(translate(@path,'/','.'),'(i1)')"/>
            <xsl:with-param name="timed" select="'yes'"/>
          </xsl:apply-templates>
          }
          }
          releaseObject(expIdx,obj_all_times);
          }

        </xsl:otherwise>
        </xsl:choose>
      </xsl:when>





	<xsl:when test="@data_type='str_type' or @data_type='STR_0D'">
		//Doc Get <xsl:value-of select="@path"/>
		<xsl:choose>
			<xsl:when test="$variable_path">
				lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getString(expIdx, path, clepath, &amp;str);
				checkStatus(status);
				if(!status) {
				<xsl:value-of select="concat($variable_path,'.',@name)"/>.assign(str);
				free(str);
				}
			</xsl:when>
			<xsl:otherwise>
				lepath = "<xsl:value-of select="@name"/>";
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getString(expIdx, path, clepath, &amp;str);
				checkStatus(status);
				if(!status) {
				<xsl:value-of select="@name"/>.assign(str);
				free(str);
				}
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:when test="@data_type='int_type' or @data_type='INT_0D'">
		//Doc Get <xsl:value-of select="@path"/>
		<xsl:choose>
			<xsl:when test="$variable_path">
				lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getInt(expIdx, path, clepath, &amp;int0d);
				checkStatus(status);
				if(!status) {
				<xsl:value-of select="concat($variable_path,'.',@name)"/>=int0d;
				}
			</xsl:when>
			<xsl:otherwise>
				lepath = "<xsl:value-of select="@name"/>";
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getInt(expIdx, path, clepath, &amp;int0d);
				checkStatus(status);
				if(!status) {
				<xsl:value-of select="@name"/>=int0d;
				}
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<!--- OLD
<xsl:when test="@name='xs:boolean'">
status = getInt(expIdx, path, "<xsl:value-of select="@path"/>", &amp;<xsl:value-of select = "translate(@path,'/','.')"/>);
checkStatus(status);
</xsl:when>
<xsl:when test="@name='xs:double'">
status = getDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;<xsl:value-of select = "translate(@path,'/','.')"/>);
checkStatus(status);
</xsl:when>
-->
	<xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
		//Doc Get <xsl:value-of select="@path"/>
		<xsl:choose>
			<xsl:when test="$variable_path">
				lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getDouble(expIdx, path, clepath, &amp;double0d);
				checkStatus(status);
				if(!status) {
				<xsl:value-of select="concat($variable_path,'.',@name)"/> = double0d;
				}
			</xsl:when>
			<xsl:otherwise>
				lepath = "<xsl:value-of select="@name"/>";
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getDouble(expIdx, path, clepath, &amp;double0d);
				checkStatus(status);
				if(!status) {
				<xsl:value-of select="translate(@path,'/','.')"/> = double0d;
				}
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>

	<xsl:when test="@data_type='str_1d_type' or @data_type='STR_1D'">
		//Doc Get <xsl:value-of select="@path"/>
		<xsl:choose>
			<xsl:when test="$variable_path">
				lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getVect1DString(expIdx, path, clepath, &amp;stringArray, &amp;dim1);
				checkStatus(status);
				if(!status) {
				<xsl:value-of select="concat($variable_path,'.',@name)"/>.resize(dim1);
				for(_i = 0; _i &lt; dim1; _i++)
				<xsl:value-of select="concat($variable_path,'.',@name)"/>(_i).assign(stringArray[_i]);
				for(_i = 0; _i &lt; dim1; _i++)
				free(stringArray[_i]);
				free((char *)stringArray);
				}
			</xsl:when>
			<xsl:otherwise>
				lepath = "<xsl:value-of select="@name"/>";
				status = getVect1DString(expIdx, path, clepath, &amp;stringArray, &amp;dim1);
				checkStatus(status);
				if(!status) {
				<xsl:value-of select="@name"/>.resize(dim1);
				for(_i = 0; _i &lt; dim1; _i++)
				<xsl:value-of select="@name"/>(_i).assign(stringArray[_i]);
				for(_i = 0; _i &lt; dim1; _i++)
				free(stringArray[_i]);
				free((char *)stringArray);
				}
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>

	<xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">
		//Doc Get <xsl:value-of select="@path"/>
		<xsl:choose>
			<xsl:when test="$variable_path">
				lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getVect1DDouble(expIdx, path, clepath, &amp;doubleArray, &amp;dim1);
				checkStatus(status);
				if(!status)  {
				setArray(<xsl:value-of select="concat($variable_path,'.',@name)"/>,doubleArray, dim1);
				free(doubleArray);
				}
			</xsl:when>
			<xsl:otherwise>
				lepath = "<xsl:value-of select="@path"/>";
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getVect1DDouble(expIdx, path, clepath, &amp;doubleArray, &amp;dim1);
				checkStatus(status);
				if(!status)  {
				setArray(<xsl:value-of select="translate(@path,'/','.')"/>,doubleArray, dim1);
				free(doubleArray);
				}
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<!--
<xsl:when test="@name='vecdbl_type'">
status = getVect1DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray), &amp;dim1);
checkStatus(status);
if(!status)  {
setArray(<xsl:value-of select = "translate(@path,'/','.')"/>,doubleArray, dim1);
free(doubleArray);
}
</xsl:when>
-->
	<xsl:when test="@data_type='int_1d_type' or @data_type='INT_1D'">
		//Doc Get <xsl:value-of select="@path"/>
		<xsl:choose>
			<xsl:when test="$variable_path">
				lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
				status = getVect1DInt(expIdx, path, clepath, &amp;intArray, &amp;dim1);
				checkStatus(status);
				if(!status) {
				setArray(<xsl:value-of select="concat($variable_path,'.',@name)"/>,intArray, dim1);
				free(intArray);
				}
			</xsl:when>
			<xsl:otherwise>
				lepath = "<xsl:value-of select="@path"/>";
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getVect1DInt(expIdx, path, clepath, &amp;intArray, &amp;dim1);
				checkStatus(status);
				if(!status) {
				setArray(<xsl:value-of select="translate(@path,'/','.')"/>,intArray, dim1);
				free(intArray);
				}
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>

	<xsl:when test="@data_type='FLT_2D'">
		//Doc Get <xsl:value-of select="@path"/>
		<xsl:choose>
			<xsl:when test="$variable_path">
				lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getVect2DDouble(expIdx, path, clepath, &amp;doubleArray, &amp;dim1, &amp;dim2);
				checkStatus(status);
				if(!status) {
				setArray(<xsl:value-of select="concat($variable_path,'.',@name)"/>,doubleArray, dim1, dim2);
				free(doubleArray);
				}
			</xsl:when>
			<xsl:otherwise>
				lepath = "<xsl:value-of select="@path"/>";
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getVect2DDouble(expIdx, path, clepath, &amp;doubleArray, &amp;dim1, &amp;dim2);
				checkStatus(status);
				if(!status) {
				setArray(<xsl:value-of select="translate(@path,'/','.')"/>,doubleArray, dim1, dim2);
				free(doubleArray);
				}
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<!--
<xsl:when test="@name='matdbl_type'">
status = getVect2DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2);
checkStatus(status);
if(!status) {
setArray(<xsl:value-of select = "translate(@path,'/','.')"/>,doubleArray, dim1, dim2);
free(doubleArray);
}
</xsl:when>
-->
	<xsl:when test="@data_type='INT_2D'">
		//Doc Get <xsl:value-of select="@path"/>
		<xsl:choose>
			<xsl:when test="$variable_path">
				lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getVect2DInt(expIdx, path, clepath, &amp;intArray, &amp;dim1, &amp;dim2);
				checkStatus(status);
				if(!status) {
				setArray(<xsl:value-of select="concat($variable_path,'.',@name)"/>,intArray, dim1, dim2);
				free(intArray);
				}
			</xsl:when>
			<xsl:otherwise>
				lepath = "<xsl:value-of select="@path"/>";
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getVect2DInt(expIdx, path, clepath, &amp;intArray, &amp;dim1, &amp;dim2);
				checkStatus(status);
				if(!status) {
				setArray(<xsl:value-of select="translate(@path,'/','.')"/>,intArray, dim1, dim2);
				free(intArray);
				}
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>

	<xsl:when test="@data_type='FLT_3D'">
		//Doc Get <xsl:value-of select="@path"/>
		<xsl:choose>
			<xsl:when test="$variable_path">
				lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getVect3DDouble(expIdx, path, clepath, &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3);
				checkStatus(status);
				if(!status) {
				setArray(<xsl:value-of select="concat($variable_path,'.',@name)"/>,doubleArray, dim1, dim2, dim3);
				free(doubleArray);
				}
			</xsl:when>
			<xsl:otherwise>
				lepath = "<xsl:value-of select="@path"/>";
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getVect3DDouble(expIdx, path, clepath, &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3);
				checkStatus(status);
				if(!status) {
				setArray(<xsl:value-of select="translate(@path,'/','.')"/>,doubleArray, dim1, dim2, dim3);
				free(doubleArray);
				}
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>

	<xsl:when test="@data_type='INT_3D'">
		//Doc Get <xsl:value-of select="@path"/>
		<xsl:choose>
			<xsl:when test="$variable_path">
				lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getVect3DInt(expIdx, path, clepath, &amp;intArray, &amp;dim1, &amp;dim2, &amp;dim3);
				checkStatus(status);
				if(!status) {
				setArray(<xsl:value-of select="concat($variable_path,'.',@name)"/>,intArray, dim1, dim2, dim3);
				free(intArray);
				}
			</xsl:when>
			<xsl:otherwise>
				lepath = "<xsl:value-of select="@path"/>";
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getVect3DInt(expIdx, path, clepath, &amp;intArray, &amp;dim1, &amp;dim2, &amp;dim3);
				checkStatus(status);
				if(!status) {
				setArray(<xsl:value-of select="translate(@path,'/','.')"/>,intArray, dim1, dim2, dim3);
				free(intArray);
				}
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<!--
<xsl:when test="@name='array3ddbl_type'">
status = getVect3DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3);
checkStatus(status);
if(!status) {
setArray(<xsl:value-of select = "translate(@path,'/','.')"/>,doubleArray, dim1, dim2, dim3);
free(doubleArray);
}
</xsl:when>
-->     
	<xsl:when test="@data_type='FLT_4D'">
		//Doc GetICI <xsl:value-of select="@path"/>
		<xsl:choose>
			<xsl:when test="$variable_path">
				lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getVect4DDouble(expIdx, path, clepath, &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4);
				checkStatus(status);
				if(!status) {
        //1OK
         setArray(<xsl:value-of select="concat($variable_path,'.',@name)"/>,doubleArray, dim1, dim2, dim3,dim4);
         //setArray(<xsl:value-of select="translate(@path,'/','.')"/>,doubleArray, dim1, dim2, dim3, dim4);
				free(doubleArray);
				}
			</xsl:when>
			<xsl:otherwise>
				lepath = "<xsl:value-of select="@path"/>";
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getVect4DDouble(expIdx, path, clepath, &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4);
				checkStatus(status);
				if(!status) {
        //2OK
				setArray(<xsl:value-of select="translate(@path,'/','.')"/>,doubleArray, dim1, dim2, dim3, dim4);
				free(doubleArray);
				}
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<!--
<xsl:when test="@name='array4dint_type'">
status = getVect4DInt(expIdx, path, "<xsl:value-of select="@path"/>", &amp;intArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4);
checkStatus(status);
if(!status) {
setArray(<xsl:value-of select = "translate(@path,'/','.')"/>,intArray, dim1, dim2, dim3, dim4);
free(intArray);
}
</xsl:when>

<xsl:when test="@name='array4ddbl_type'">
status = getVect4DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4);
checkStatus(status);
if(!status) {
setArray(<xsl:value-of select = "translate(@path,'/','.')"/>,doubleArray, dim1, dim2, dim3, dim4);
free(doubleArray);
}
</xsl:when>
-->
	<xsl:when test="@data_type='FLT_5D'">
		//Doc Get <xsl:value-of select="@path"/>
		<xsl:choose>
			<xsl:when test="$variable_path">
				lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getVect5DDouble(expIdx, path, clepath, &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5);
				checkStatus(status);
				if(!status) {
				setArray(<xsl:value-of select="concat($variable_path,'.',@name)"/>,doubleArray, dim1, dim2, dim3, dim4, dim5);
				free(doubleArray);
				}
			</xsl:when>
			<xsl:otherwise>
				lepath = "<xsl:value-of select="@path"/>";
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getVect5DDouble(expIdx, path, clepath, &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5);
				checkStatus(status);
				if(!status) {
				setArray(<xsl:value-of select="translate(@path,'/','.')"/>,doubleArray, dim1, dim2, dim3, dim4, dim5);
				free(doubleArray);
				}
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<!--
<xsl:when test="@name='array5dint_type'">
status = getVect5DInt(expIdx, path, "<xsl:value-of select="@path"/>", &amp;intArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim4);
checkStatus(status);
if(!status) {
setArray(<xsl:value-of select = "translate(@path,'/','.')"/>,intArray, dim1, dim2, dim3, dim4, dim5);
free(intArray);
}
</xsl:when>
<xsl:when test="@name='array5ddbl_type'">
status = getVect45Double(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim4);
checkStatus(status);
if(!status) {
setArray(<xsl:value-of select = "translate(@path,'/','.')"/>,doubleArray, dim1, dim2, dim3, dim4, dim5);
free(doubleArray);
}
</xsl:when>
-->
	<xsl:when test="@data_type='FLT_6D'">
		//Doc Get <xsl:value-of select="@path"/>
		<xsl:choose>
			<xsl:when test="$variable_path">
				lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getVect6DDouble(expIdx, path, clepath, &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5, &amp;dim6);
				checkStatus(status);
				if(!status) {
				setArray(<xsl:value-of select="concat($variable_path,'.',@name)"/>,doubleArray, dim1, dim2, dim3, dim4, dim5, dim6);
				free(doubleArray);
				}
			</xsl:when>
			<xsl:otherwise>
				lepath = "<xsl:value-of select="@path"/>";
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status = getVect6DDouble(expIdx, path, clepath, &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5, &amp;dim6);
				checkStatus(status);
				if(!status) {
				setArray(<xsl:value-of select="translate(@path,'/','.')"/>,doubleArray, dim1, dim2, dim3, dim4, dim5, dim6);
				free(doubleArray);
				}
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<!--
<xsl:when test="@name='array6dint_type'">
status = getVect6DInt(expIdx, path, "<xsl:value-of select="@path"/>", &amp;intArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5, &amp;dim6);
checkStatus(status);
if(!status) {
setArray(<xsl:value-of select = "translate(@path,'/','.')"/>,intArray, dim1, dim2, dim3, dim4, dim5, dim6);
free(intArray);
}
</xsl:when>

<xsl:when test="@name='array6ddbl_type'">
status = getVect6Double(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5, &amp;dim6);
checkStatus(status);
if(!status) {
setArray(<xsl:value-of select = "translate(@path,'/','.')"/>,doubleArray, dim1, dim2, dim3, dim4, dim5, dim6);
free(doubleArray);
}
</xsl:when>
-->
	<xsl:otherwise>
		//   Get <xsl:value-of select="@path"/> : PROBLEM : UNIDENTIFIED TYPE !!! <!-- for comment only -->
	</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--=================================================-->
<!--          get a full time-dependent IDS          -->
<!--=================================================-->
<!--YBYB
<xsl:template match = "field" mode = "GET_FULL">
<xsl:choose>


<xsl:when test = "@timed = 'yes'">
<xsl:choose>


<xsl:when test="@data_type='int_type' or @data_type='INT_0D'">
status = getVect1DInt(expIdx, path, "<xsl:value-of select="@path"/>", &amp;intArray, &amp;dim1);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; dim1; _i++)
array(_i).<xsl:value-of select = "translate(@path,'/','.')"/> = intArray[_i];
free((char *)intArray);
}
</xsl:when>
<xsl:when test="@data_type='str_type' or @data_type='STR_0D'">
status = getVect1DString(expIdx, path, "<xsl:value-of select="@path"/>", &amp;stringArray, &amp;dim1);
checkStatus(status);
if(!status) {
for(_i = 0; _i &lt; dim1; _i++)
array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>.assign(stringArray[_i]);
for(_i = 0; _i &lt; dim1; _i++)
free(stringArray[_i]);
free((char *)stringArray);
}
</xsl:when>
<xsl:when test="@name='xs:boolean'">
status = getVect1DInt(expIdx, path, "<xsl:value-of select="@path"/>", &amp;intArray, &amp;dim1);
checkStatus(status);
if(!status) {
for(_i = 0; _i &lt; dim1; _i++)
array(_i).<xsl:value-of select = "translate(@path,'/','.')"/> = intArray[_i];
free((char *)intArray);
}
</xsl:when>
<xsl:when test="@name='xs:double'">
status = getVect1DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; dim1; _i++)
array(_i).<xsl:value-of select = "translate(@path,'/','.')"/> = doubleArray[_i];
free((char *)doubleArray);
}
</xsl:when>
<xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
status = getVect1DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; dim1; _i++)
array(_i).<xsl:value-of select = "translate(@path,'/','.')"/> = doubleArray[_i];
free((char *)doubleArray);
}
</xsl:when>


<xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">
status = getVect2DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; dim2; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,&amp;doubleArray[_i*dim1], dim1);
free(doubleArray);
}
</xsl:when>
<xsl:when test="@data_type='int_1d_type' or @data_type='INT_1D'">
status = getVect2DInt(expIdx, path, "<xsl:value-of select="@path"/>", &amp;intArray, &amp;dim1, &amp;dim2);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; dim2; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,&amp;intArray[_i*dim1], dim1);
free(intArray);
}
</xsl:when>
<xsl:when test="@name='vecdbl_type'">
status = getVect2DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; dim2; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,&amp;doubleArray[_i*dim1], dim1);
free(doubleArray);
}
</xsl:when>


<xsl:when test="@data_type='FLT_2D'">
status = getVect3DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; dim3; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,&amp;doubleArray[_i*dim1*dim2], dim1, dim2);
free(doubleArray);
}
</xsl:when>
<xsl:when test="@data_type='INT_2D'">
status = getVect3DInt(expIdx, path, "<xsl:value-of select="@path"/>", &amp;intArray, &amp;dim1, &amp;dim2, &amp;dim3);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; dim3; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,&amp;intArray[_i*dim1*dim2], dim1, dim2);
free(intArray);
}
</xsl:when>
<xsl:when test="@name='matdbl_type'">
status = getVect3DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; dim3; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,&amp;doubleArray[_i*dim1*dim2], dim1, dim2);
free(doubleArray);
}
</xsl:when>


<xsl:when test="@data_type='FLT_3D'">
status = getVect4DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; dim4; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,&amp;doubleArray[_i*dim1*dim2*dim3], dim1, dim2, dim3);
free(doubleArray);
}
</xsl:when>
<xsl:when test="@data_type='INT_3D'">
status = getVect4DInt(expIdx, path, "<xsl:value-of select="@path"/>", &amp;intArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; dim4; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,&amp;intArray[_i*dim1*dim2*dim3], dim1, dim2, dim3);
free(intArray);
}
</xsl:when>
<xsl:when test="@name='array3ddbl_type'">
status = getVect4DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; dim4; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,&amp;doubleArray[_i*dim1*dim2*dim3], dim1, dim2, dim3);
free(doubleArray);
}
</xsl:when>


<xsl:when test="@data_type='FLT_4D'">
status = getVect5DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; dim5; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,&amp;doubleArray[_i*dim1*dim2*dim3*dim4], dim1, dim2, dim3, dim4);
free(doubleArray);
}
</xsl:when>
<xsl:when test="@name='array4dint_type'">
status = getVect5DInt(expIdx, path, "<xsl:value-of select="@path"/>", &amp;intArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; dim5; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,&amp;intArray[_i*dim1*dim2*dim3*dim4], dim1, dim2, dim3, dim4);
free(intArray);
}
</xsl:when>
<xsl:when test="@name='array4ddbl_type'">
status = getVect5DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5, &amp;dim6);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; dim5; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,&amp;doubleArray[_i*dim1*dim2*dim3*dim4], dim1, dim2, dim3, dim4);
free(doubleArray);
}
</xsl:when>


<xsl:when test="@data_type='FLT_5D'">
status = getVect6DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5, &amp;dim6);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; dim6; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,&amp;doubleArray[_i*dim1*dim2*dim3*dim4*dim5], dim1, dim2, dim3, dim4, dim5);
free(doubleArray);
}
</xsl:when>
<xsl:when test="@name='array5dint_type'">
status = getVect6DInt(expIdx, path, "<xsl:value-of select="@path"/>", &amp;intArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5, &amp;dim6);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; dim6; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,&amp;intArray[_i*dim1*dim2*dim3*dim4*dim5], dim1, dim2, dim3, dim4, dim5);
free(intArray);
}
</xsl:when>
<xsl:when test="@name='array5ddbl_type'">
status = getVect6DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; dim6; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,&amp;doubleArray[_i*dim1*dim2*dim3*dim4*dim5], dim1, dim2, dim3, dim4, dim5);
free(doubleArray);
}
</xsl:when>


<xsl:when test="@data_type='FLT_6D'">
status = getVect7DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5, &amp;dim6, &amp;dim7);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; dim7; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,&amp;doubleArray[_i*dim1*dim2*dim3*dim4*dim5*dim6], dim1, dim2, dim3, dim4, dim5,dim6);
free(doubleArray);
}
</xsl:when>
<xsl:when test="@name='array6dint_type'">
status = getVect7DInt(expIdx, path, "<xsl:value-of select="@path"/>", &amp;intArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5, &amp;dim6, &amp;dim7);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; dim7; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,&amp;intArray[_i*dim1*dim2*dim3*dim4*dim5*dim6], dim1, dim2, dim3, dim4, dim5,dim6);
free(intArray);
}
</xsl:when>
<xsl:when test="@name='array6ddbl_type'">
status = getVect7DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5, &amp;dim6, &amp;dim7);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; dim7; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,&amp;doubleArray[_i*dim1*dim2*dim3*dim4*dim5*dim6], dim1, dim2, dim3, dim4, dim5,dim6);
free(doubleArray);
}
</xsl:when>


<xsl:when test="@data_type='struct_array'">
{/*     Timed array of structure     */
/*    Read timed content     */
void *obj_all_times;
status = getObject(expIdx, path, "<xsl:value-of select = "@path"/>", &amp;obj_all_times,1); // read the whole timed block
checkStatus(status);
if (!status) {
if (getObjectDim(expIdx,obj_all_times) != numSamples) {  // object must contain the right number of times
printf("Error in get: array of structures is missing time slices\n");
return -1;
}
for (int i0 = 0; i0 &lt; numSamples; i0++) {  // fill every time slice
void *obj1;
status = getObjectFromObject(expIdx,obj_all_times, "ALLTIMES", i0, &amp;obj1);  // extract a single time
checkStatus(status);
if (!status) {
array(i0).<xsl:value-of select = "translate(@path,'/','.')"/>.resize(getObjectDim(expIdx,obj1));
for (int i1 = 0; i1 &lt; getObjectDim(expIdx,obj1); i1++) {     // process array elements
<xsl:apply-templates select = "field" mode = "GET_FROM_OBJECT">
<xsl:with-param name="level" select="1"/>
<xsl:with-param name="objpath" select="@name"/>
<xsl:with-param name="idxpath" select="concat('array(i0).',translate(@path,'/','.'),'(i1)')"/>
<xsl:with-param name="timed" select="'yes'"/>
</xsl:apply-templates>
}
}
}
releaseObject(expIdx,obj_all_times);
}
/*    Read non-timed content    */
void *obj1;
status = getObject(expIdx, path, "<xsl:value-of select = "@path"/>", &amp;obj1,0); // read the whole non-timed block
checkStatus(status);
if (!status) {
for (int i0 = 0; i0 &lt; numSamples; i0++) {  // fill every time slice
// must have same number of non-timed elements and timed elements
if (getObjectDim(expIdx,obj1) !=0 &amp;&amp; array(i0).<xsl:value-of select = "translate(@path,'/','.')"/>.extent(0) != getObjectDim(expIdx,obj1)) {
printf("Error in get: array of structures has different number of timed and nontimed elements for <xsl:value-of select = "@path"/>\n");
return -1;
}
for (int i1 = 0; i1 &lt; getObjectDim(expIdx,obj1); i1++) {  // process array elements
<xsl:apply-templates select = "field" mode = "GET_FROM_OBJECT">
<xsl:with-param name="level" select="1"/>
<xsl:with-param name="objpath" select="@name"/>
<xsl:with-param name="idxpath" select="concat('array(i0).',translate(@path,'/','.'),'(i1)')"/>
<xsl:with-param name="timed" select="'no'"/>
</xsl:apply-templates>
}
}
releaseObject(expIdx,obj1);
}
}
</xsl:when>


<xsl:when test="@data_type='structure'">
<xsl:apply-templates select = "field" mode = "GET_FULL"/>
</xsl:when>
</xsl:choose>
</xsl:when>


<xsl:otherwise>
<xsl:choose>


<xsl:when test="@data_type='str_type' or @data_type='STR_0D'">
status = getString(expIdx, path, "<xsl:value-of select="@path"/>", &amp;str);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; numSamples; _i++)
array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>.assign(str);
free(str);
}
</xsl:when>
<xsl:when test="@data_type='int_type' or @data_type='INT_0D'">
status = getInt(expIdx, path, "<xsl:value-of select="@path"/>", &amp;array(0).<xsl:value-of select = "translate(@path,'/','.')"/>);
checkStatus(status);
if(!status)
for(_i = 0; _i &lt; numSamples; _i++)
array(_i).<xsl:value-of select = "translate(@path,'/','.')"/> = array(0).<xsl:value-of select = "translate(@path,'/','.')"/> ;
</xsl:when>
<xsl:when test="@name='xs:boolean'">
status = getInt(expIdx, path, "<xsl:value-of select="@path"/>", &amp;array(0).<xsl:value-of select = "translate(@path,'/','.')"/>);
checkStatus(status);
if(!status)
for(_i = 0; _i &lt; numSamples; _i++)
array(_i).<xsl:value-of select = "translate(@path,'/','.')"/> = array(0).<xsl:value-of select = "translate(@path,'/','.')"/>;
</xsl:when>
<xsl:when test="@name='xs:double'">
status = getDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;array(0).<xsl:value-of select = "translate(@path,'/','.')"/>);
checkStatus(status);
if(!status)
for(_i = 0; _i &lt; numSamples; _i++)
array(_i).<xsl:value-of select = "translate(@path,'/','.')"/> = array(0).<xsl:value-of select = "translate(@path,'/','.')"/>;
</xsl:when>
<xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
status = getDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;array(0).<xsl:value-of select = "translate(@path,'/','.')"/>);
checkStatus(status);
if(!status)
for(_i = 0; _i &lt; numSamples; _i++)
array(_i).<xsl:value-of select = "translate(@path,'/','.')"/> = array(0).<xsl:value-of select = "translate(@path,'/','.')"/>;
</xsl:when>


<xsl:when test="@data_type='str_1d_type' or @data_type='STR_1D'">
status = getVect1DString(expIdx, path, "<xsl:value-of select="@path"/>", &amp;stringArray, &amp;dim1);
checkStatus(status);
if(!status) {
for(_i = 0; _i &lt; numSamples; _i++)
{
array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>.resize(dim1);
for(_j = 0; _j &lt; dim1; _j++)
array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>(_j).assign(stringArray[_j]);
}
for(_i = 0; _i &lt; dim1; _i++)
free(stringArray[_i]);
free((char *)stringArray);
}
</xsl:when>
<xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">
status = getVect1DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; numSamples; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,doubleArray, dim1);
free(doubleArray);
}
</xsl:when>
<xsl:when test="@name='vecdbl_type'">
status = getVect1DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1);
checkStatus(status);
if(!status) {
for(_i = 0; _i &lt; numSamples; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,doubleArray, dim1);
free(doubleArray);
}
</xsl:when>
<xsl:when test="@data_type='int_1d_type' or @data_type='INT_1D'">
status = getVect1DInt(expIdx, path, "<xsl:value-of select="@path"/>", &amp;intArray, &amp;dim1);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; numSamples; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,intArray, dim1);
free(intArray);
}
</xsl:when>


<xsl:when test="@data_type='FLT_2D'">
status = getVect2DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; numSamples; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,doubleArray, dim1, dim2);
free(doubleArray);
}
</xsl:when>
<xsl:when test="@name='matdbl_type'">
status = getVect2DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; numSamples; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,doubleArray, dim1, dim2);
free(doubleArray);
}
</xsl:when>
<xsl:when test="@data_type='INT_2D'">
status = getVect2DInt(expIdx, path, "<xsl:value-of select="@path"/>", &amp;intArray, &amp;dim1, &amp;dim2);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; numSamples; _i++)
setArray( array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,intArray, dim1, dim2);
free(intArray);
}
</xsl:when>


<xsl:when test="@data_type='FLT_3D'">
status = getVect3DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; numSamples; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,doubleArray, dim1, dim2, dim3);
free(doubleArray);
}
</xsl:when>
<xsl:when test="@data_type='INT_3D'">
status = getVect3DInt(expIdx, path, "<xsl:value-of select="@path"/>", &amp;intArray, &amp;dim1, &amp;dim2, &amp;dim3);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; numSamples; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,intArray, dim1, dim2, dim3);
free(intArray);
}
</xsl:when>
<xsl:when test="@name='array3ddbl_type'">
status = getVect3DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; numSamples; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,doubleArray, dim1, dim2, dim3);
free(doubleArray);
}
</xsl:when>


<xsl:when test="@data_type='FLT_4D'">
status = getVect4DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; numSamples; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,doubleArray, dim1, dim2, dim3, dim4);
free(doubleArray);
}
</xsl:when>
<xsl:when test="@name='array4dint_type'">
status = getVect4DInt(expIdx, path, "<xsl:value-of select="@path"/>", &amp;intArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; numSamples; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,intArray, dim1, dim2, dim3, dim4);
free(intArray);
}
</xsl:when>
<xsl:when test="@name='array4ddbl_type'">
status = getVect4DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; numSamples; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,doubleArray, dim1, dim2, dim3, dim4);
free(doubleArray);
}
</xsl:when>


<xsl:when test="@data_type='FLT_5D'">
status = getVect5DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; numSamples; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,doubleArray, dim1, dim2, dim3, dim4, dim5);
free(doubleArray);
}
</xsl:when>
<xsl:when test="@name='array5dint_type'">
status = getVect5DInt(expIdx, path, "<xsl:value-of select="@path"/>", &amp;intArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; numSamples; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,intArray, dim1, dim2, dim3, dim4, dim5);
free(intArray);
}
</xsl:when>
<xsl:when test="@name='array5ddbl_type'">
status = getVect5DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; numSamples; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,doubleArray, dim1, dim2, dim3, dim4, dim5);
free(doubleArray);
}
</xsl:when>


<xsl:when test="@data_type='FLT_6D'">
status = getVect6DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5, &amp;dim6);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; numSamples; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,doubleArray, dim1, dim2, dim3, dim4, dim5,dim6);
free(doubleArray);
}
</xsl:when>
<xsl:when test="@name='array6dint_type'">
status = getVect6DInt(expIdx, path, "<xsl:value-of select="@path"/>", &amp;intArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5, &amp;dim6);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; numSamples; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,intArray, dim1, dim2, dim3, dim4, dim5, dim6);
free(intArray);
}
</xsl:when>
<xsl:when test="@name='array6ddbl_type'">
status = getVect6DDouble(expIdx, path, "<xsl:value-of select="@path"/>", &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5, &amp;dim6);
checkStatus(status);
if(!status){
for(_i = 0; _i &lt; numSamples; _i++)
setArray(array(_i).<xsl:value-of select = "translate(@path,'/','.')"/>,doubleArray, dim1, dim2, dim3, dim4, dim5,dim6);
free(doubleArray);
}
</xsl:when>


<xsl:when test="@data_type='struct_array'">
{/*    Non-timed array of structure    */
void *obj1;
status = getObject(expIdx, path, "<xsl:value-of select = "@path"/>", &amp;obj1,0); // read the whole block
checkStatus(status);
if (!status) {
for (int i0 = 0; i0 &lt; numSamples; i0++) {  // fill every time slice
array(i0).<xsl:value-of select = "translate(@path,'/','.')"/>.resize(getObjectDim(expIdx,obj1));
for (int i1 = 0; i1 &lt; getObjectDim(expIdx,obj1); i1++) {  // process array elements
<xsl:apply-templates select = "field" mode = "GET_FROM_OBJECT">
<xsl:with-param name="level" select="1"/>
<xsl:with-param name="objpath" select="@name"/>
<xsl:with-param name="idxpath" select="concat('array(i0).',translate(@path,'/','.'),'(i1)')"/>
<xsl:with-param name="timed" select="'no'"/>
</xsl:apply-templates>
}
}
releaseObject(expIdx,obj1);
}
}
</xsl:when>

<xsl:when test="@data_type='structure'">
<xsl:apply-templates select = "field" mode = "GET_FULL"/>
</xsl:when>
</xsl:choose>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
YBYB-->
<!--=================================================-->
<!--               get field from a slice            -->
<!--=================================================-->
<!-- YBYBGETSLICE -->

<!--=================================================-->
<!--            get fields from an object            -->
<!--=================================================-->
<!--YBYB 2014 -->
<xsl:template match = "field" mode = "GET_FROM_OBJECT">
<xsl:param name="level"/>    
<xsl:param name="objpath"/>  
<xsl:param name="idxpath"/>  
<xsl:param name="timed"/>   

<xsl:param name="currentobjpath" select="concat($objpath,'/',@name)"/>
<xsl:param name="currentidxpath" select="concat($idxpath,'.',@name)"/>
<xsl:choose>
<!--========== Arrays of structures ==========-->
<xsl:when test="@data_type='struct_array'">
  // Get_from_object  <xsl:value-of select="@path"/>
   <xsl:choose>
<xsl:when test="$timed='yes' "> 
   <!-- We are scanning the children of a Type 3 AoS, so we extract the child object at index 0 of the parent object -->
  { /*    1Array of structure     */
void *obj<xsl:value-of select="$level + 1"/>;
status = getObjectFromObject(expIdx, obj<xsl:value-of select="$level"/>, "<xsl:value-of select = "$currentobjpath"/>", 0,&amp;obj<xsl:value-of select="$level + 1"/>);
</xsl:when>
<xsl:otherwise>
<!-- Otherwise we assume it is a Type 2 AoS, so we extract the child object at index iobject -->
{ /*    2Array of structure     */
void *obj<xsl:value-of select="$level + 1"/>;
 status = getObjectFromObject(expIdx, obj<xsl:value-of select="$level"/>, "<xsl:value-of select = "$currentobjpath"/>", i<xsl:value-of select="$level"/>, &amp;obj<xsl:value-of select="$level + 1"/>);
 </xsl:otherwise>
 </xsl:choose>
checkStatus(status);
if (!status) {
if (<xsl:value-of select="$currentidxpath"/>.extent(0)>0) { // does this array already exist? (timed and non timed parts can share the same array)
if (getObjectDim(expIdx,obj<xsl:value-of select="$level + 1"/>) != 0 &amp;&amp; <xsl:value-of select="$currentidxpath"/>.extent(0) != getObjectDim(expIdx,obj<xsl:value-of select="$level + 1"/>)) { // then it must have the right number of elements
printf("Error in get: array of structures has different number of timed and nontimed elements for <xsl:value-of select = "@path"/>\n");
return -1;
}
} else { // else allocate it
<xsl:value-of select="$currentidxpath"/>.resize(getObjectDim(expIdx,obj<xsl:value-of select="$level + 1"/>));
}
//getfromobject  <xsl:value-of select="$currentidxpath"/>)
dim1In=getObjectDim(expIdx,obj<xsl:value-of select="$level + 1"/>); //YBYB
for (int i<xsl:value-of select="$level + 1"/> = 0; i<xsl:value-of select="$level + 1"/> &lt; getObjectDim(expIdx,obj<xsl:value-of select="$level + 1"/>); i<xsl:value-of select="$level + 1"/>++) {
<xsl:apply-templates select = "field" mode = "GET_FROM_OBJECT">
<xsl:with-param name="level" select="$level + 1"/>
<xsl:with-param name="objpath" select="@name"/>
<xsl:with-param name="idxpath" select="concat($currentidxpath,'(i',$level + 1,')')"/>
<xsl:with-param name="timed" select="'no'"/>  <!-- We assume the nested children are necessarily Type 2 -->
</xsl:apply-templates>
}
}
}
<!-- </xsl:if> -->
</xsl:when>
 <!--========== Regular structure ==========-->
<xsl:when test="@data_type='structure'">
<xsl:apply-templates select = "field" mode = "GET_FROM_OBJECT">
<xsl:with-param name="level" select="$level"/>
<xsl:with-param name="objpath" select="$currentobjpath"/>
<xsl:with-param name="idxpath" select="$currentidxpath"/>
<xsl:with-param name="timed" select="$timed"/>
</xsl:apply-templates>
</xsl:when>

<xsl:otherwise>
  <!--========== select either timed or non-timed fields ==========-->
  <!-- <xsl:if test="@timed=$timed"> -->
<xsl:choose>

<xsl:when test="@data_type='str_type' or @data_type='STR_0D'">
  status = getStringFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;str);
checkStatus(status);
if(!status) {<xsl:value-of select="$currentidxpath"/>.assign(str); free(str);
}
</xsl:when>
<xsl:when test="@data_type='int_type' or @data_type='INT_0D'">
  status = getIntFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;<xsl:value-of select="$currentidxpath"/>);
checkStatus(status);
</xsl:when>
<xsl:when test="@name='xs:boolean'">
  status = getIntFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;<xsl:value-of select="$currentidxpath"/>);
checkStatus(status);
</xsl:when>
<xsl:when test="@name='xs:double'">
  status = getDoubleFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;<xsl:value-of select="$currentidxpath"/>);
checkStatus(status);
</xsl:when>
<xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
  status = getDoubleFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;<xsl:value-of select="$currentidxpath"/>);
checkStatus(status);
</xsl:when>


<xsl:when test="@data_type='str_1d_type' or @data_type='STR_1D'">
  status = getVect1DStringFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;stringArray, &amp;dim1In);
checkStatus(status);
if(!status) {
<xsl:value-of select="$currentidxpath"/>.resize(dim1In);
for(_i = 0; _i &lt; dim1In; _i++)
<xsl:value-of select="$currentidxpath"/>(_i).assign(stringArray[_i]);
for(_i = 0; _i &lt; dim1In; _i++)
free(stringArray[_i]);
free((char *)stringArray);
}
</xsl:when>
<xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">
  status = getVect1DDoubleFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;doubleArray, &amp;dim1In);
checkStatus(status);
if(!status) {
if (dim1In >0) {
setArray(<xsl:value-of select="$currentidxpath"/>,doubleArray, dim1In);
free(doubleArray);
}
}
</xsl:when>
<xsl:when test="@data_type='int_1d_type' or @data_type='INT_1D'">
  status = getVect1DIntFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;intArray, &amp;dim1In);
checkStatus(status);
if(!status) {
if (dim1In >0) {
setArray(<xsl:value-of select="$currentidxpath"/>,intArray, dim1In);
free(intArray);
}
}
</xsl:when>
<xsl:when test="@name='vecdbl_type'">
  status = getVect1DDoubleFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;doubleArray, &amp;dim1In);
checkStatus(status);
if(!status) {
if (dim1In >0) {
setArray(<xsl:value-of select="$currentidxpath"/>,doubleArray, dim1In);
free(doubleArray);
}
}
</xsl:when>

<xsl:when test="@data_type='FLT_2D'">
  status = getVect2DDoubleFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;doubleArray, &amp;dim1In, &amp;dim2In);
checkStatus(status);
if(!status) {
if (dim1In >0) {
setArray(<xsl:value-of select="$currentidxpath"/>,doubleArray, dim1In, dim2In);
free(doubleArray);
}
}
</xsl:when>
<xsl:when test="@name='matdbl_type'">
  status = getVect2DDoubleFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;doubleArray, &amp;dim1In, &amp;dim2In);
checkStatus(status);
if(!status) {
setArray(<xsl:value-of select="$currentidxpath"/>,doubleArray, dim1In, dim2In);
free(doubleArray);
}
</xsl:when>
<xsl:when test="@data_type='INT_2D'">
  status = getVect2DIntFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;intArray, &amp;dim1In, &amp;dim2In);
checkStatus(status);
if(!status) {
if (dim1In >0) {
setArray(<xsl:value-of select="$currentidxpath"/>,intArray, dim1In, dim2In);
free(intArray);
}
}
</xsl:when>

<xsl:when test="@data_type='FLT_3D'">
  status = getVect3DDoubleFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;doubleArray, &amp;dim1In, &amp;dim2In, &amp;dim3In);
checkStatus(status);
if(!status) {
if (dim1In >0) {
setArray(<xsl:value-of select="$currentidxpath"/>,doubleArray, dim1In, dim2In, dim3In);
free(doubleArray);
}
}
</xsl:when>
<xsl:when test="@name='array3ddbl_type'">
  status = getVect3DDoubleFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;doubleArray, &amp;dim1In, &amp;dim2In, &amp;dim3In);
checkStatus(status);
if(!status) {
if (dim1In >0) {
setArray(<xsl:value-of select="$currentidxpath"/>,doubleArray, dim1In, dim2In, dim3In);
free(doubleArray);
}
}
</xsl:when>
<xsl:when test="@data_type='INT_3D'">
  status = getVect3DIntFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;intArray, &amp;dim1In, &amp;dim2In, &amp;dim3In);
checkStatus(status);
if(!status) {
if (dim1In >0) {
setArray(<xsl:value-of select="$currentidxpath"/>,intArray, dim1In, dim2In, dim3In);
free(intArray);
}
}
</xsl:when>

<xsl:when test="@data_type='FLT_4D'">
  status = getVect4DDoubleFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;doubleArray, &amp;dim1In, &amp;dim2In, &amp;dim3In, &amp;dim4In);
checkStatus(status);
if(!status) {
if (dim1In >0) {
setArray(<xsl:value-of select="$currentidxpath"/>,doubleArray, dim1In, dim2In, dim3In, dim4In);
free(doubleArray);
}
}
</xsl:when>
<xsl:when test="@name='array4ddbl_type'">
  status = getVect4DDoubleFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;doubleArray, &amp;dim1In, &amp;dim2In, &amp;dim3In, &amp;dim4In);
checkStatus(status);
if(!status) {
setArray(<xsl:value-of select="$currentidxpath"/>,doubleArray, dim1In, dim2In, dim3In, dim4In);
free(doubleArray);
}
</xsl:when>
<xsl:when test="@name='array4dint_type'">
  status = getVect4DIntFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;intArray, &amp;dim1In, &amp;dim2In, &amp;dim3In, &amp;dim4In);
checkStatus(status);
if(!status) {
setArray(<xsl:value-of select="$currentidxpath"/>,intArray, dim1In, dim2In, dim3In, dim4In);
free(intArray);
}
</xsl:when>

<xsl:when test="@data_type='FLT_5D'">
  status = getVect5DDoubleFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;doubleArray, &amp;dim1In, &amp;dim2In, &amp;dim3In, &amp;dim4In, &amp;dim5In);
checkStatus(status);
if(!status) {
if (dim1In >0) {
setArray(<xsl:value-of select="$currentidxpath"/>,doubleArray, dim1In, dim2In, dim3In, dim4In, dim5In);
free(doubleArray);
}
}
</xsl:when>
<xsl:when test="@name='array5ddbl_type'">
  status = getVect5DDoubleFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;doubleArray, &amp;dim1In, &amp;dim2In, &amp;dim3In, &amp;dim4In, &amp;dim5In);
checkStatus(status);
if(!status) {
setArray(<xsl:value-of select="$currentidxpath"/>,doubleArray, dim1In, dim2In, dim3In, dim4In, dim5In);
free(doubleArray);
}
</xsl:when>
<xsl:when test="@name='array5dint_type'">
  status = getVect5DIntFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;intArray, &amp;dim1In, &amp;dim2In, &amp;dim3In, &amp;dim4In, &amp;dim5In);
checkStatus(status);
if(!status) {
setArray(<xsl:value-of select="$currentidxpath"/>,intArray, dim1In, dim2In, dim3In, dim4In, dim5In);
free(intArray);
}
</xsl:when>

<xsl:when test="@data_type='FLT_6D'">
  status = getVect6DDoubleFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;doubleArray, &amp;dim1In, &amp;dim2In, &amp;dim3In, &amp;dim4In, &amp;dim5In, &amp;dim6In);
checkStatus(status);
if(!status) {
if (dim1In >0) {
setArray(<xsl:value-of select="$currentidxpath"/>,doubleArray, dim1In, dim2In, dim3In, dim4In, dim5In, dim6In);
free(doubleArray);
}
}
</xsl:when>
<xsl:when test="@name='array6ddbl_type'">
  status = getVect6DDoubleFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;doubleArray, &amp;dim1In, &amp;dim2In, &amp;dim3In, &amp;dim4In, &amp;dim5In, &amp;dim6In);
checkStatus(status);
if(!status) {
setArray(<xsl:value-of select="$currentidxpath"/>,doubleArray, dim1In, dim2In, dim3In, dim4In, dim5In, dim6In);
free(doubleArray);
}
</xsl:when>
<xsl:when test="@name='array6dint_type'">
  status = getVect6DIntFromObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:choose><xsl:when test="$timed='yes'">0</xsl:when><xsl:otherwise>i<xsl:value-of select="$level"/></xsl:otherwise></xsl:choose>, &amp;intArray, &amp;dim1In, &amp;dim2In, &amp;dim3In, &amp;dim4In, &amp;dim5In, &amp;dim6In);
checkStatus(status);
if(!status) {
setArray(<xsl:value-of select="$currentidxpath"/>,intArray, dim1In, dim2In, dim3In, dim4In, dim5In, dim6In);
free(intArray);
}
</xsl:when>
</xsl:choose>
<!-- 2014</xsl:if> -->
</xsl:otherwise>
</xsl:choose>

</xsl:template>

<!-- 2014 YBYB-->
<!--=================================================-->
<!--       put field of a time-independent IDS       -->
<!--=================================================-->

<xsl:template match="field" mode="PUT_SINGLE">
<xsl:param name="variable_path"/>
<xsl:param name="mds_path"/>
<xsl:param name="non_timed"/>
<xsl:if test="$non_timed !='yes' or @type !='dynamic' or not(@type) or @data_type='structure' or (@data_type='struct_array' and  @type !='dynamic')">
	<xsl:choose>
		<!--========== Regular structures ==========-->
    <!-- YB 2014 -->
		<xsl:when test="@data_type='structure'">
			<xsl:choose>
				<xsl:when test="$variable_path">
					<xsl:apply-templates select="field" mode="PUT_SINGLE">
						<xsl:with-param name="variable_path" select="concat($variable_path,'.',@name)"/>
						<xsl:with-param name="mds_path" select="concat($mds_path,'+string(&quot;/',@name,'&quot;)')"/>
            <xsl:with-param name="non_timed" select="$non_timed"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="field" mode="PUT_SINGLE">
						<xsl:with-param name="variable_path" select="@name"/>
						<xsl:with-param name="mds_path" select="concat('&quot;',@name,'&quot;')"/>
             <xsl:with-param name="non_timed" select="$non_timed"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<!--========== Arrays of structures ==========-->
		<xsl:when test="@data_type='struct_array' and @maxoccur!='unbounded'">
       <!-- Type 1 arrays of structure, with potentially multiple time bases -->
			//Doc Put Typ1 <xsl:value-of select="@path"/>
			<xsl:choose>
				<xsl:when test="$variable_path">
        if ( <xsl:value-of select = "concat($variable_path,'.',@name)"/>.extent(0) &gt; 0) {
					lepath = <xsl:value-of select="$mds_path"/>  + string("/<xsl:value-of select="@name"/>/Shape_of");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					status = putInt(expIdx,path,clepath,<xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0));
					checkStatus(status);
					if (status) return status;
					for (i<xsl:value-of select="@name"/> = 0;i<xsl:value-of select="@name"/>&lt;<xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0); i<xsl:value-of select="@name"/>++){
					<xsl:apply-templates select="field" mode="PUT_SINGLE">
						<xsl:with-param name="variable_path" select="concat($variable_path,'.',@name,'(i',@name,')')"/>
						<xsl:with-param name="mds_path" select="concat($mds_path,' + ','string(&quot;/',@name,'/&quot;) + int2str(i',@name,',1)')"/>
             <xsl:with-param name="non_timed" select="$non_timed"/>
					</xsl:apply-templates>
					}
        }
				</xsl:when>
				<xsl:otherwise>
         if ( <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0) &gt; 0) {  
					lepath =  "<xsl:value-of select="@name"/>/Shape_of";
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					status = putInt(expIdx,path, clepath, <xsl:value-of select="@name"/>.extent(0));
					checkStatus(status);
					if (status) return status;
					for ( i<xsl:value-of select="@name"/> = 0;i<xsl:value-of select="@name"/>&lt;<xsl:value-of select="@name"/>.extent(0);i<xsl:value-of select="@name"/>++){
					  <xsl:apply-templates select="field" mode="PUT_SINGLE">
						<xsl:with-param name="variable_path" select="concat(@name,'(i',@name,')')"/>
						<xsl:with-param name="mds_path" select="concat('&quot;',@name,'/&quot; + int2str(i',@name,',1)')"/>
            <xsl:with-param name="non_timed" select="$non_timed"/>
					</xsl:apply-templates>
					}
         }  
				</xsl:otherwise>
			</xsl:choose>
			<!--YBYB Avant
{ /*     Array of structure     */
char fullpath[1024]; sprintf(fullpath,"%s/<xsl:value-of select = "@path"/>",path);
void *obj1 = beginObject(expIdx,NULL,0,fullpath,NON_TIMED);
for (int i1 = 0; i1 &lt; <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0); i1++) {
<xsl:apply-templates select = "field" mode = "PUT_IN_OBJECT">
<xsl:with-param name="level" select="1"/>
<xsl:with-param name="objpath" select="@name"/>
<xsl:with-param name="idxpath" select="concat(translate(@path,'/','.'),'(i1)')"/>
<xsl:with-param name="timed" select="'no'"/>
</xsl:apply-templates>
}
status = putObject(expIdx, path, "<xsl:value-of select = "@path"/>", obj1, NON_TIMED);
checkStatus(status);
if (status) return status;
}
-->
    </xsl:when>

 <xsl:when test="@data_type='struct_array' and @maxoccur='unbounded' and @type='dynamic'">
   //-- Type 3 arrays of structure, with a unique time base 3OK
    <xsl:choose>
      <xsl:when test="$variable_path">
     // Structure array of type 3 nested below a Type 1 : <xsl:value-of select = "concat($variable_path,'.',@name)"/>
       if (<xsl:value-of select = "concat($variable_path,'.',@name)"/>.extent(0) &gt; 0) {
       // char fullpath[1024];
       lepath = "path<xsl:value-of select="concat('/',substring($mds_path,2))"/> + string("/<xsl:value-of select="@name"/>");
       clepath = const_cast&lt;char *&gt; (lepath.c_str()); 
       void *obj_all_times = beginObject(expIdx,(void *) -1,0,clepath,TIMED_CLEAR);
       for (int i1 = 0; i1 &lt; <xsl:value-of select = "concat($variable_path,'.',@name)"/>.extent(0); i1++) {
       void *obj1 = beginObject(expIdx,obj_all_times,i1,"ALLTIMES",TIMED);
        <xsl:apply-templates select = "field" mode = "PUT_IN_OBJECT">
         <xsl:with-param name="level" select="1"/>
         <xsl:with-param name="objpath" select="@name"/>
         <xsl:with-param name="idxpath" select="concat($variable_path,'.',@name,'(0)')"/>
         <xsl:with-param name="child_index" select="0"/>
       </xsl:apply-templates>
       void *obj = putObjectInObject(expIdx,obj_all_times, "ALLTIMES", i1, obj1);
       }
        // Store time of the array of structure (hidden variable for the user, but used by the UAL for future get_slice operations)
        // A temporary "time" vector is filled then put as a regular variable (outside of the object) as AoS%time
        dim1= <xsl:value-of select = "concat($variable_path,'.',@name)"/>.extent(0);
        double *timeh = new double[dim1];
        if (<xsl:value-of select = "concat($variable_path,'.',@name)"/>(0).time == EMPTY_DOUBLE) {
        // Check the presence of a time vector at the root of the  AoS (on the first index only)
        if (ids_properties.homogeneous_time == 1) {
        for (int i1 = 0; i1 &lt; dim1; i1++)
         timeh[i1] = time(i1);
         }
          else {
          puts("ERROR : the time vector of the type 3 array of structure <xsl:value-of select = "translate(@path,'/','.')"/> must be filled");
          return (-1);
          }
          }
          else {
          for( int i1 = 0; i1 &lt;<xsl:value-of select = "concat($variable_path,'.',@name)"/>.extent(0); i1++){// the AoS time vector is there, fill time with it
          timeh[i1] = <xsl:value-of select = "concat($variable_path,'.',@name)"/>(i1).time;
          }
          }
           // Start to put time1
           timepath = <xsl:value-of select="$mds_path"/> + string("/<xsl:value-of select="@name"/>/time");
           clepath = const_cast&lt;char *&gt; (timepath.c_str());
           beginIdsPutTimed(expIdx, path,dim1, timeh);
           status = putVect1DDouble(expIdx, path, clepath,(char *)timepath.c_str(), timeh, dim1, 1);
           checkStatus(status);
           if (status) return status;
           endIdsPutTimed(expIdx, path);
           timepath=<xsl:value-of select = "concat($mds_path,' + &quot;/',@name)"/>";
           clepath = const_cast&lt;char *&gt; (timepath.c_str());
           putObject(expIdx,path,clepath, obj_all_times,1);
          }
        </xsl:when>

        <xsl:otherwise>
          // Structure array of type 3 : <xsl:value-of select = "@path"/>
          if (<xsl:value-of select = "translate(@path,'/','.')"/>.extent(0) &gt; 0) {
           char fullpath[1024];
           //sprintf(fullpath,"path/<xsl:value-of select = "@path"/>"); //BYY
           sprintf(fullpath,"%s/<xsl:value-of select = "@path"/>",path);
           dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
           void *obj_all_times = beginObject(expIdx,(void *) -1,0,fullpath,TIMED_CLEAR);
           for (int i1 = 0; i1 &lt; dim1; i1++){
           void *obj1 = beginObject(expIdx,obj_all_times,i1,"ALLTIMES",TIMED);
            <xsl:apply-templates select = "field" mode="PUT_IN_OBJECT">
            <xsl:with-param name="level" select="1"/>
            <xsl:with-param name="objpath" select="@name"/>
            <xsl:with-param name="idxpath" select="concat(translate(@path,'/','.'),'(i1)')"/>
            <xsl:with-param name="child_index" select="0"/>
          </xsl:apply-templates>
       void *obj = putObjectInObject(expIdx,obj_all_times, "ALLTIMES", i1, obj1);
       }
        // Store time of the array of structure (hidden variable for the user, but used by the UAL for future get_slice operations)
        dim1= <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
        double *timeh = new double[dim1];
        if (<xsl:value-of select = "translate(@path,'/','.')"/>(0).time == EMPTY_DOUBLE) { 
        // Check the presence of a time vector at the root of the AoS (on the first index only)
        if (ids_properties.homogeneous_time == 1) {
        for (int i1 = 0; i1 &lt; dim1; i1++)
            timeh[i1] = time(i1); // Use the general time vector of the IDS to fill time
        }
        else {
        puts("ERROR : the time vector of the type 3 array of structure <xsl:value-of select = "translate(@path,'/','.')"/> must be filled");
        return(-1);
        }
        }
         else {
         for (int i1 = 0; i1 &lt; dim1; i1++){
          // the AoS time vector is there, fill time with it
          timeh[i1]=<xsl:value-of select = "translate(@path,'/','.')"/>(i1).time;
         }
         }
          timepath=&quot;<xsl:call-template name="printtimepath"/>&quot;;
          clepath = const_cast&lt;char *&gt; (timepath.c_str());
           beginIdsPutTimed(expIdx, path,dim1, timeh);
           status = putVect1DDouble(expIdx, path, clepath,(char *)timepath.c_str(), timeh, dim1, 1);
           checkStatus(status);
           if (status) return status;

          endIdsPutTimed(expIdx, path);
          //if (ual_debug.equals("yes")) puts("Put <xsl:call-template name="printtimevariable"/> " + time);
          //deallocate(time)
          timepath=&quot;<xsl:value-of select = "@path"/>&quot;;
           clepath = const_cast&lt;char *&gt; (timepath.c_str());
           putObject(expIdx,path,clepath, obj_all_times,1);
           }
           </xsl:otherwise>
           </xsl:choose>
         </xsl:when> 
          <xsl:when test="@data_type='struct_array' and @maxoccur='unbounded' and @type!='dynamic'">
            <!-- Type 2 arrays of structure-->
            <xsl:choose>
              <xsl:when test="$variable_path">
            // Structure array of type 2 nested below a Type 1 : ERROR: NOT HANDLED YET <xsl:value-of select = "concat($variable_path,'.',@name)"/>
            </xsl:when>
            <xsl:otherwise>
            // Structure array of type 2 : <xsl:value-of select = "@path"/>
           <!-- Handle only non-timed descendants of type 2 AoS for the moment -->
           <!-- Type 2 structure arrays not handled yet, I put here a copy of the ITM treatment for recall -->
           // Write non-timed fields 
            char fullpath[1024];
            sprintf(fullpath,"path/<xsl:value-of select = "@path"/>");
            void *obj1=beginObject(expIdx,-1,1,fullpath,NON_TIMED);
            dim1=<xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
            if (dim1 &gt; 0) {
            for (int i1 = 0; i1 &lt; dim1; i1++) {
            <xsl:apply-templates select = "field" mode = "PUT_IN_OBJECT"> 
              <!-- Select at this level dynamic fields only ? (how does it behave in time-dependent structures ? -->
             <xsl:with-param name="level" select="1"/>
             <xsl:with-param name="objpath" select="@name"/>
             <xsl:with-param name="idxpath" select="concat(translate(@path,'/','.'),'(i1)')"/>
             <xsl:with-param name="child_index" select="0"/> <!--Not sure here, maybe i1 is the correct way... -->
             </xsl:apply-templates>
             }
             }
            timepath=<xsl:value-of select = "@path"/>;
            clepath = const_cast&lt;char *&gt; (timepath.c_str());
            putObject(expIdx,path,clepath, obj1,0);
       </xsl:otherwise>
       </xsl:choose>
       </xsl:when>
       <!--end of  June 2014  -->







		<!--========== Simple types ==========-->
		<xsl:when test="@data_type='str_type' or @data_type='STR_0D'">
			//Doc Put <xsl:value-of select="@path"/>
			<xsl:choose>
				<xsl:when test="$variable_path">
					lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					status = putString(expIdx, path,  clepath,
					(char *)<xsl:value-of select="translate(concat($variable_path,'/',@name),'/','.')"/>.data(),
					<xsl:value-of select="translate(concat($variable_path,'/',@name),'/','.')"/>.size()); 
					checkStatus(status);
					if (status) return status;
				</xsl:when>
				<xsl:otherwise>
					lepath = "<xsl:value-of select="@name"/>";
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					status = putString(expIdx, path, clepath, (char *)<xsl:value-of select="@name"/>.data(), <xsl:value-of select="@name"/>.size());
					checkStatus(status);
					if (status) return status;
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>

		<xsl:when test="@data_type='str_1d_type' or @data_type='STR_1D'">
			//Doc! Put <xsl:value-of select="@path"/>
			<xsl:choose>
				<xsl:when test="$variable_path">
					<xsl:choose>
						<xsl:when test="@type='dynamic'">
							if (ids_properties.homogeneous_time == 0) {
							<xsl:choose>
								<xsl:when test="(@name='data' and ../field[@name='time']) or (@name='time' and ../field[@name='data'])">
									timebasepath=<xsl:value-of select="$mds_path"/>+string("/time");
									dim1= <xsl:value-of select="concat($variable_path,'.time')"/>.extent(0);
									doubleArray = new double[dim1];
									for(_i = 0; _i &lt;  dim1; _i++)
									doubleArray[_i] = <xsl:value-of select="concat($variable_path,'.time')"/>(_i);
									beginIdsPutTimed(expIdx, path,dim1,doubleArray);
									delete[]doubleArray;
								</xsl:when>
								<xsl:otherwise>
									timebasepath="<xsl:call-template name="printtimepath"/>";
									dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
									doubleArray = new double[dim1];
									for(_i = 0; _i &lt;  dim1; _i++)
									doubleArray[_i] = <xsl:call-template name="printtimevariable"/>(_i);
									beginIdsPutTimed(expIdx, path,dim1,doubleArray);
									delete[]doubleArray;
								</xsl:otherwise>
							</xsl:choose>
							}  else  {
							timebasepath="time";
							dim1= time.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = time(_i);
							beginIdsPutTimed(expIdx, path,dim1,doubleArray);
							delete[]doubleArray;
							}
						</xsl:when>
						<xsl:otherwise>
							timebasepath = "";
						</xsl:otherwise>
					</xsl:choose>   
					<!-- dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0); -->
					dim1 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0);
          if (dim1 > 0) {
					stringArray = new char*[dim1];
					for(_i = 0; _i &lt;  dim1; _i++)
					stringArray[_i] = (char *)<xsl:value-of select="concat($variable_path,'.',@name)"/>(_i).c_str();
					lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					status = putVect1DString(expIdx, path, clepath,(char *)timebasepath.c_str(), stringArray, dim1, <xsl:call-template name="printIsTimed"/>);
					delete[] stringArray;
					checkStatus(status);
					if (status) return status;
          }
					<xsl:if test="@type='dynamic'">
						endIdsPutTimed(expIdx, path);
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="@type='dynamic'">
							if (ids_properties.homogeneous_time == 0) {
							timebasepath="<xsl:call-template name="printtimepath"/>";
							dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = <xsl:call-template name="printtimevariable"/>(_i);
							beginIdsPutTimed(expIdx, path,dim1,doubleArray);
							delete [] doubleArray;
							} else {
							timebasepath="time";
							dim1= time.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = time(_i);
							beginIdsPutTimed(expIdx, path, dim1,time);
							delete [] doubleArray;
							}
						</xsl:when>
						<xsl:otherwise>
							timebasepath = "";
						</xsl:otherwise>
					</xsl:choose>
					dim1 = <xsl:value-of select="@name"/>.extent(0);
          if (dim1 > 0) {
					stringArray = new char*[dim1];
					for(_i = 0; _i &lt;  dim1; _i++)
					stringArray[_i] = (char *)<xsl:value-of select="@name"/>(_i).c_str();
					lepath =  "<xsl:value-of select="@name"/>";
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					status = putVect1DString(expIdx, path, clepath,(char *) timebasepath.c_str(), stringArray, dim1, <xsl:call-template name="printIsTimed"/>);
					delete[] stringArray;
					checkStatus(status);
					if (status) return status;
          }
					<xsl:if test="@type='dynamic'">
						endIdsPutTimed(expIdx, path);
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="@data_type='int_type' or @data_type='INT_0D'">
			//Doc  <xsl:value-of select="@path"/>
			<xsl:choose>
				<xsl:when test="$variable_path">
					lepath =  <xsl:value-of select="$mds_path"/> +  string("/<xsl:value-of select="@name"/>");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					status = putInt(expIdx,path,clepath, <xsl:value-of select="concat($variable_path,'.',@name)"/>);
					checkStatus(status);
					if (status)  return status;
				</xsl:when>
				<xsl:otherwise>
					status = putInt(expIdx, path, "<xsl:value-of select="@path"/>", <xsl:value-of select="translate(@path,'/','.')"/>);
					checkStatus(status);
					if (status) return status;
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<!--YBYB
<xsl:when test="@name='xs:boolean'">
status = putInt(expIdx, path, "<xsl:value-of select = "@path"/>", <xsl:value-of select = "translate(@path,'/','.')"/>);
checkStatus(status);
if (status) return status;
</xsl:when>

<xsl:when test="@name='xs:double'">
status = putDouble(expIdx, path, "<xsl:value-of select = "@path"/>", <xsl:value-of select = "translate(@path,'/','.')"/>); 
checkStatus(status);
if (status) return status;
</xsl:when>
YBYB-->
		<xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
			<xsl:choose>
				<xsl:when test="$variable_path">
					lepath =  <xsl:value-of select="$mds_path"/> +  string("/<xsl:value-of select="@name"/>");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					status = putDouble(expIdx,path,clepath, <xsl:value-of select="concat($variable_path,'.',@name)"/>);
					checkStatus(status);
					if (status) return status;
				</xsl:when>
				<xsl:otherwise>
					lepath = "<xsl:value-of select="@path"/>";
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					status = putDouble(expIdx,path, clepath,<xsl:value-of select="translate(@path,'/','.')"/>);
					checkStatus(status);
					if (status) return status;
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>

		<!--========== Vectors ==========-->
		<xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">
			//Doc <xsl:value-of select="@path"/>
			<xsl:choose>
				<xsl:when test="$variable_path">
					<xsl:choose>
						<xsl:when test="@type='dynamic'">
							if (ids_properties.homogeneous_time == 0) {
							<!--XSLtest whether this is a data/time structure, otherwise assume that the timepath attribute from IDSDef is correct-->
							<xsl:choose>
								<xsl:when test="(@name='data' and ../field[@name='time']) or (@name='time' and ../field[@name='data'])">
									timebasepath=<xsl:value-of select="$mds_path"/>+string("/time");

									dim1= <xsl:value-of select="concat($variable_path,'.time')"/>.extent(0); 
									doubleArray = new double[dim1];
									for(_i = 0; _i &lt;  dim1; _i++)
									doubleArray[_i] = <xsl:value-of select="concat($variable_path,'.time')"/>(_i);
									beginIdsPutTimed(expIdx, path, dim1,doubleArray);
									delete [] doubleArray;
								</xsl:when>
								<xsl:otherwise>
									timebasepath="<xsl:call-template name="printtimepath"/>";
									<!--  dim1= <xsl:value-of select = "translate($variable_path,'/','.')"/>.extent(0); -->
									dim1= <xsl:call-template name="printtimevariable"/>.extent(0); 
									doubleArray = new double[dim1];
									for(_i = 0; _i &lt;  dim1; _i++)
									doubleArray[_i] =<xsl:call-template name="printtimevariable"/>(_i);
									beginIdsPutTimed(expIdx, path,dim1,doubleArray);
									delete [] doubleArray;
								</xsl:otherwise>
							</xsl:choose>
							} else {
							timebasepath="time";
							dim1= time.extent(0); 
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = time(_i);
							beginIdsPutTimed(expIdx, path, dim1,doubleArray);
							delete [] doubleArray;
							}
						</xsl:when>
						<xsl:otherwise>
							timebasepath = "";
						</xsl:otherwise>
					</xsl:choose>   
					lepath =  <xsl:value-of select="$mds_path"/> +  string("/<xsl:value-of select="@name"/>");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					dim1= <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0); 
					doubleArray = new double[dim1];
					for(_i = 0; _i &lt;  dim1; _i++)
					doubleArray[_i] = <xsl:value-of select="concat($variable_path,'.',@name)"/>(_i);
					status = putVect1DDouble(expIdx, path, clepath,(char *)timebasepath.c_str(), doubleArray, dim1, <xsl:call-template name="printIsTimed"/>);
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;

					<xsl:if test="@type='dynamic'">
						endIdsPutTimed(expIdx, path);
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="@type='dynamic'">
							if (ids_properties.homogeneous_time == 0) {
							timebasepath="<xsl:call-template name="printtimepath"/>";
							dim1= <xsl:call-template name="printtimevariable"/>.extent(0); 
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = <xsl:call-template name="printtimevariable"/>(_i);
							beginIdsPutTimed(expIdx, path, dim1,doubleArray);
							delete[] doubleArray;
							} else {
							timebasepath="time";
							dim1= <xsl:call-template name="printtimevariable"/>.extent(0); 
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = <xsl:call-template name="printtimevariable"/>(_i);
							beginIdsPutTimed(expIdx, path, dim1,doubleArray);
							delete[] doubleArray;
							}
						</xsl:when>
						<xsl:otherwise>
							timebasepath = "";
						</xsl:otherwise>
					</xsl:choose>
					lepath =  "<xsl:value-of select="@path"/>";
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					dim1= <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					doubleArray = new double[dim1];
					for(_i = 0; _i &lt;  dim1; _i++)
					doubleArray[_i] = <xsl:value-of select="translate( @path,'/','.')"/>(_i);
					status = putVect1DDouble(expIdx, path, clepath,(char *)timebasepath.c_str(), doubleArray, dim1, <xsl:call-template name="printIsTimed"/>);
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
					<xsl:if test="@type='dynamic'">
						endIdsPutTimed(expIdx, path);
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>   
		</xsl:when>
		<!--    -->

		<xsl:when test="@data_type='int_1d_type' or @data_type='INT_1D'">
			//Doc <xsl:value-of select="@path"/>
			<xsl:choose>
				<xsl:when test="$variable_path">
					<xsl:choose>
						<xsl:when test="@type='dynamic'">
							if (ids_properties.homogeneous_time == 0) {
							<xsl:choose>
								<xsl:when test="(@name='data' and ../field[@name='time']) or (@name='time' and ../field[@name='data'])">
									timebasepath=<xsl:value-of select="$mds_path"/>+ string("/time");
									dim1= <xsl:value-of select="concat($variable_path,'.time')"/>.extent(0);
									doubleArray = new double[dim1];
									for(_i = 0; _i &lt;  dim1; _i++)
									doubleArray[_i] = <xsl:value-of select="concat($variable_path,'.time')"/>(_i);
									beginIdsPutTimed(expIdx, path,dim1,doubleArray);
									delete[] doubleArray;
								</xsl:when>
								<xsl:otherwise>
									timebasepath="<xsl:call-template name="printtimepath"/>";
									dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
									doubleArray = new double[dim1];
									for(_i = 0; _i &lt;  dim1; _i++)
									doubleArray[_i] = <xsl:call-template name="printtimevariable"/>(_i);
									beginIdsPutTimed(expIdx, path, dim1,doubleArray);
									delete[] doubleArray;
								</xsl:otherwise>
							</xsl:choose>
							} else {
							timebasepath="time";
							dim1= time.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = time(_i);
							beginIdsPutTimed(expIdx, path, dim1,doubleArray);
							delete[] doubleArray;
							}
						</xsl:when>
						<xsl:otherwise>
							timebasepath = "";
						</xsl:otherwise>
					</xsl:choose>   
					lepath = <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					dim1= <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0);
					intArray = new int[dim1];
					for(_i = 0; _i &lt;  dim1; _i++)
					intArray[_i] = <xsl:value-of select="concat($variable_path,'.',@name)"/>(_i);
					status = putVect1DInt(expIdx, path, clepath, (char *) timebasepath.c_str(), intArray, dim1, <xsl:call-template name="printIsTimed"/>);
					delete[] intArray;
					checkStatus(status);
					if (status) return status;
					<xsl:if test="@type='dynamic'">
						endIdsPutTimed(expIdx, path);
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="@type='dynamic'">
							if (ids_properties.homogeneous_time == 0) {
							timebasepath="<xsl:call-template name="printtimepath"/>";
							dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = <xsl:call-template name="printtimevariable"/>(_i);
							beginIdsPutTimed(expIdx, path, dim1,doubleArray);
							delete[]doubleArray;
							}  else {
							timebasepath="time";
							dim1= time.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = time(_i);
							beginIdsPutTimed(expIdx, path, dim1,doubleArray);
							delete[]doubleArray;
							}
						</xsl:when>
						<xsl:otherwise>
							timebasepath = "";
						</xsl:otherwise>
					</xsl:choose>        
					lepath = "<xsl:value-of select="@path"/>";
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					dim1= <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					intArray = new int[dim1];
					for(_i = 0; _i &lt;  dim1; _i++)
					intArray[_i] = <xsl:value-of select="translate(@path,'/','.')"/>(_i);
					status = putVect1DInt(expIdx, path, clepath, (char *) timebasepath.c_str(), intArray, dim1, <xsl:call-template name="printIsTimed"/>);
					delete[] intArray;
					<xsl:if test="@type='dynamic'">
						endIdsPutTimed(expIdx, path);
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<!--
<xsl:when test="@name='vecdbl_type'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
doubleArray = new double[dim1];
for(_i = 0; _i &lt;  dim1; _i++)
doubleArray[_i] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i);
status = PUTVECT1DDOUBLE(expIdx, path, "<xsl:value-of select = "@path"/>", doubleArray, dim1, 0);
delete[] doubleArray;
checkStatus(status);
if (status) return status;
</xsl:when>

-->
		<!--========== Matrices ==========-->
		<xsl:when test="@data_type='FLT_2D'">
			//Doc <xsl:value-of select="@path"/>
			<xsl:choose>
				<xsl:when test="$variable_path">
					<xsl:choose>
						<xsl:when test="@type='dynamic'">
							if (ids_properties.homogeneous_time == 0) {
							<xsl:choose>
								<xsl:when test="(@name='data' and ../field[@name='time']) or (@name='time' and ../field[@name='data'])">
									timebasepath=<xsl:value-of select="$mds_path"/>+string("/time");
									dim1= <xsl:value-of select="concat($variable_path,'.time')"/>.extent(0);
									doubleArray = new double[dim1];
									for(_i = 0; _i &lt;  dim1; _i++)
									doubleArray[_i] = <xsl:value-of select="concat($variable_path,'.time')"/>(_i);
									beginIdsPutTimed(expIdx, path, dim1,doubleArray);
									delete [] doubleArray;
								</xsl:when>
								<xsl:otherwise>
									timebasepath="<xsl:call-template name="printtimepath"/>";
									dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
									doubleArray = new double[dim1];
									for(_i = 0; _i &lt;  dim1; _i++)
									doubleArray[_i] =<xsl:call-template name="printtimevariable"/>(_i);
									beginIdsPutTimed(expIdx, path, dim1,doubleArray);
									delete [] doubleArray;
								</xsl:otherwise>
							</xsl:choose>
							} else {
							timebasepath="time";
							dim1= time.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = time(_i);
							beginIdsPutTimed(expIdx, path, dim1,doubleArray);
							delete [] doubleArray;
							}
						</xsl:when>
						<xsl:otherwise>
							timebasepath = "";
						</xsl:otherwise>
					</xsl:choose>   
					lepath =  <xsl:value-of select="$mds_path"/> +  string("/<xsl:value-of select="@name"/>");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					dim1 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0);
					dim2 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(1);
					doubleArray = new double[dim1*dim2];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					doubleArray[_i + _j*dim1] = <xsl:value-of select="concat($variable_path,'.',@name)"/>(_i,_j);
					status = putVect2DDouble(expIdx, path, clepath, (char *) timebasepath.c_str(), doubleArray, dim1, dim2, <xsl:call-template name="printIsTimed"/>);
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
					<xsl:if test="@type='dynamic'">
						endIdsPutTimed(expIdx, path);
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="@type='dynamic'">
							if (ids_properties.homogeneous_time == 0) {
							timebasepath="<xsl:call-template name="printtimepath"/>";
							dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = <xsl:call-template name="printtimevariable"/>(_i);
							beginIdsPutTimed(expIdx, path, dim1,doubleArray);
							delete[] doubleArray;
							} else {
							timebasepath="time";
							dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = <xsl:call-template name="printtimevariable"/>(_i);
							beginIdsPutTimed(expIdx, path, dim1,doubleArray);
							delete[] doubleArray;
							}
						</xsl:when>
						<xsl:otherwise>
							timebasepath = "";
						</xsl:otherwise>
					</xsl:choose>           
					lepath =  "<xsl:value-of select="@path"/>";
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					dim1 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
					doubleArray = new double[dim1*dim2];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					doubleArray[_i + _j*dim1] = <xsl:value-of select="translate(@path,'/','.')"/>(_i,_j);
					status = putVect2DDouble(expIdx, path, clepath, (char *) timebasepath.c_str(), doubleArray, dim1, dim2, <xsl:call-template name="printIsTimed"/>);
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
					<xsl:if test="@type='dynamic'">
						endIdsPutTimed(expIdx, path);
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<!--
<xsl:when test="@name='matdbl_type'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
doubleArray = new double[dim1*dim2];
for(_i = 0; _i &lt;  dim1; _i++)
for(_j = 0; _j &lt;  dim2; _j++)
doubleArray[_i + _j*dim1] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i,_j);
status = putVect2DDouble(expIdx, path, "<xsl:value-of select = "@path"/>", doubleArray, dim1, dim2, 0);
delete[] doubleArray;
checkStatus(status);
if (status) return status;
</xsl:when>
-->
		<xsl:when test="@data_type='INT_2D'">
			//Doc  <xsl:value-of select="@path"/>
			<xsl:choose>
				<xsl:when test="$variable_path">
					<xsl:choose>
						<xsl:when test="@type='dynamic'">
							if (ids_properties.homogeneous_time == 0) {
							<!--XSLtest whether this is a data/time structure, otherwise assume that the timepath attribute from IDSDef is correct-->
							<xsl:choose>
								<xsl:when test="(@name='data' and ../field[@name='time']) or (@name='time' and ../field[@name='data'])">
									timebasepath=<xsl:value-of select="$mds_path"/>+string("/time");
									dim1= <xsl:value-of select="concat($variable_path,'.time')"/>.extent(0);
									doubleArray = new double[dim1];
									for(_i = 0; _i &lt;  dim1; _i++)
									doubleArray[_i] = <xsl:value-of select="concat($variable_path,'.time')"/>(_i);
									beginIdsPutTimed(expIdx, path, dim1,doubleArray);
									delete [] doubleArray;
								</xsl:when>
								<xsl:otherwise>
									timebasepath="<xsl:call-template name="printtimepath"/>";
									dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
									doubleArray = new double[dim1];
									for(_i = 0; _i &lt;  dim1; _i++)
									doubleArray[_i] =<xsl:call-template name="printtimevariable"/>(_i);
									beginIdsPutTimed(expIdx, path, dim1,doubleArray);
									delete [] doubleArray;
								</xsl:otherwise>
							</xsl:choose>
							} else {
							dim1= time.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = time(_i);
							beginIdsPutTimed(expIdx, path, dim1,doubleArray);
							delete [] doubleArray;
							}
						</xsl:when>
						<xsl:otherwise>
							timebasepath = "";
						</xsl:otherwise>
					</xsl:choose>
					lepath =  <xsl:value-of select="$mds_path"/> +  string("/<xsl:value-of select="@name"/>");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					dim1 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0);
					dim2 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(1);
					intArray = new int[dim1*dim2];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					intArray[_i + _j*dim1] = <xsl:value-of select="concat($variable_path,'.',@name)"/>(_i,_j);
					status = putVect2DInt(expIdx, path, clepath,(char *)timebasepath.c_str(), intArray, dim1, dim2, <xsl:call-template name="printIsTimed"/>);
					delete[] intArray;
					checkStatus(status);
					if (status) return status;
					<xsl:if test="@type='dynamic'">
						endIdsPutTimed(expIdx, path);
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="@type='dynamic'">
							if (ids_properties.homogeneous_time == 0) {
							timebasepath="<xsl:call-template name="printtimepath"/>";
							dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = <xsl:call-template name="printtimevariable"/>(_i);
							beginIdsPutTimed(expIdx, path, dim1,doubleArray);
							delete[] doubleArray;
							} else {
							timebasepath="time";
							dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = <xsl:call-template name="printtimevariable"/>(_i);
							beginIdsPutTimed(expIdx, path, dim1,doubleArray);
							delete[] doubleArray;
							}
						</xsl:when>
						<xsl:otherwise>
							timebasepath = "";
						</xsl:otherwise>
					</xsl:choose>
					lepath =  "<xsl:value-of select="@path"/>";
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					dim1 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
					intArray = new int[dim1*dim2];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					intArray[_i + _j*dim1] = <xsl:value-of select="translate(@path,'/','.')"/>(_i,_j);
					status = putVect2DInt(expIdx, path, clepath,(char *)timebasepath.c_str(), intArray, dim1, dim2, <xsl:call-template name="printIsTimed"/>);
					delete[] intArray;
					checkStatus(status);
					if (status) return status;
					<xsl:if test="@type='dynamic'">
						endIdsPutTimed(expIdx, path);
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<!--========== 3D arrays ==========-->
		<xsl:when test="@data_type='FLT_3D'">
			//Doc <xsl:value-of select="@path"/>
			<xsl:choose>
				<xsl:when test="$variable_path">
					<xsl:choose>
						<xsl:when test="@type='dynamic'">
							if (ids_properties.homogeneous_time == 0) {
							<!--XSLtest whether this is a data/time structure, otherwise assume that the timepath attribute from IDSDef is correct-->
							<xsl:choose>
								<xsl:when test="(@name='data' and ../field[@name='time']) or (@name='time' and ../field[@name='data'])">
									timebasepath=<xsl:value-of select="$mds_path"/>+string("/time");
									dim1= <xsl:value-of select="concat($variable_path,'.time')"/>.extent(0);
									doubleArray = new double[dim1];
									for(_i = 0; _i &lt;  dim1; _i++)
									doubleArray[_i] = <xsl:value-of select="concat($variable_path,'.time')"/>(_i);
									beginIdsPutTimed(expIdx, path,dim1,doubleArray);
									delete [] doubleArray;
								</xsl:when>
								<xsl:otherwise>
									timebasepath="<xsl:call-template name="printtimepath"/>";
									<!--  dim1= <xsl:value-of select = "translate($variable_path,'/','.')"/>.extent(0); -->
									dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
									doubleArray = new double[dim1];
									for(_i = 0; _i &lt;  dim1; _i++)
									doubleArray[_i] =<xsl:call-template name="printtimevariable"/>(_i);
									beginIdsPutTimed(expIdx, path, dim1,doubleArray);
									delete [] doubleArray;
								</xsl:otherwise>
							</xsl:choose>
							} else {
							timebasepath="time";
							dim1= time.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = time(_i);
							beginIdsPutTimed(expIdx, path,dim1,doubleArray);
							delete [] doubleArray;
							}
						</xsl:when>
						<xsl:otherwise>
							timebasepath = "";
						</xsl:otherwise>
					</xsl:choose>
					lepath =  <xsl:value-of select="$mds_path"/> +  string("/<xsl:value-of select="@name"/>");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					dim1 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0);
					dim2 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(1);
					dim3 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(2);
					doubleArray = new double[dim1*dim2*dim3];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					for(_k = 0; _k &lt;  dim3; _k++)
					doubleArray[_i+ _j*dim1 + _k*dim1*dim2] = <xsl:value-of select="concat($variable_path,'.',@name)"/>(_i, _j, _k);
					status = putVect3DDouble(expIdx, path, clepath,(char *) timebasepath.c_str(), doubleArray, dim1, dim2, dim3, <xsl:call-template name="printIsTimed"/>);
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
					<xsl:if test="@type='dynamic'">
						endIdsPutTimed(expIdx, path);
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="@type='dynamic'">
							if (ids_properties.homogeneous_time == 0) {
							timebasepath="<xsl:call-template name="printtimepath"/>";
							dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = <xsl:call-template name="printtimevariable"/>(_i);
							beginIdsPutTimed(expIdx, path, dim1,doubleArray);
							delete[] doubleArray;
							} else {
							timebasepath="time";
							dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = <xsl:call-template name="printtimevariable"/>(_i);
							beginIdsPutTimed(expIdx, path, dim1,doubleArray);
							delete[] doubleArray;
							}
						</xsl:when>
						<xsl:otherwise>
							timebasepath = "";
						</xsl:otherwise>
					</xsl:choose>
					lepath =  "<xsl:value-of select="@path"/>";
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					dim1 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
					dim3 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
					doubleArray = new double[dim1*dim2*dim3];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					for(_k = 0; _k &lt;  dim3; _k++)
					doubleArray[_i+ _j*dim1 + _k*dim1*dim2] = <xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k);
					status = putVect3DDouble(expIdx, path, clepath,(char *) timebasepath.c_str(), doubleArray, dim1, dim2, dim3, <xsl:call-template name="printIsTimed"/>);
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
					<xsl:if test="@type='dynamic'">
						endIdsPutTimed(expIdx, path);
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<!-- SUPPRIME

<xsl:when test="@name='array3ddbl_type'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
dim3 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(2);
doubleArray = new double[dim1*dim2*dim3];
for(_i = 0; _i &lt;  dim1; _i++)
for(_j = 0; _j &lt;  dim2; _j++)
for(_k = 0; _k &lt;  dim3; _k++)
doubleArray[_i+ _j*dim1 + _k*dim1*dim2] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i, _j, _k);
status = putVect3DDouble(expIdx, path, "<xsl:value-of select = "@path"/>", doubleArray, dim1, dim2, dim3, 0);
delete[] doubleArray;
checkStatus(status);
if (status) return status;
</xsl:when>
-->
		<xsl:when test="@data_type='INT_3D'">
			//Doc <xsl:value-of select="@path"/>
			<xsl:choose>
				<xsl:when test="$variable_path">
					<xsl:choose>
						<xsl:when test="@type='dynamic'">
							if (ids_properties.homogeneous_time == 0) {
							<!--XSLtest whether this is a data/time structure, otherwise assume that the timepath attribute from IDSDef is correct-->
							<xsl:choose>
								<xsl:when test="(@name='data' and ../field[@name='time']) or (@name='time' and ../field[@name='data'])">
									timebasepath=<xsl:value-of select="$mds_path"/>+string("/time");
									dim1= <xsl:value-of select="concat($variable_path,'.time')"/>.extent(0);
									doubleArray = new double[dim1];
									for(_i = 0; _i &lt;  dim1; _i++)
									doubleArray[_i] = <xsl:value-of select="concat($variable_path,'.time')"/>(_i);
									beginIdsPutTimed(expIdx, path,dim1,doubleArray);
									delete [] doubleArray;
								</xsl:when>
								<xsl:otherwise>
									timebasepath="<xsl:call-template name="printtimepath"/>";
									<!--  dim1= <xsl:value-of select = "translate($variable_path,'/','.')"/>.extent(0); -->
									dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
									doubleArray = new double[dim1];
									for(_i = 0; _i &lt;  dim1; _i++)
									doubleArray[_i] =<xsl:call-template name="printtimevariable"/>(_i);
									beginIdsPutTimed(expIdx, path, dim1,doubleArray);
									delete [] doubleArray;
								</xsl:otherwise>
							</xsl:choose>
							} else {
							timebasepath="time";
							dim1= time.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = time(_i);
							beginIdsPutTimed(expIdx, path,dim1,doubleArray);
							delete [] doubleArray;
							}
						</xsl:when>
						<xsl:otherwise>
							timebasepath = "";
						</xsl:otherwise>
					</xsl:choose>
					lepath =  <xsl:value-of select="$mds_path"/> +  string("/<xsl:value-of select="@name"/>");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					dim1 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0);
					dim2 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(1);
					dim3 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(2);
					intArray = new int[dim1*dim2*dim3];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					for(_k = 0; _k &lt;  dim3; _k++)
           intArray[_i + _j*dim1 + _k*dim1*dim2] = <xsl:value-of select="concat($variable_path,'.',@name)"/>(_i, _j, _k);
					status = putVect3DInt(expIdx, path, clepath,(char *) timebasepath.c_str(), intArray, dim1, dim2, dim3, <xsl:call-template name="printIsTimed"/>);
					delete[] intArray;
					checkStatus(status);
					if (status) return status;
					<xsl:if test="@type='dynamic'">
						endIdsPutTimed(expIdx, path);
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="@type='dynamic'">
							if (ids_properties.homogeneous_time == 0) {
							timebasepath="<xsl:call-template name="printtimepath"/>";
							dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = <xsl:call-template name="printtimevariable"/>(_i);
							beginIdsPutTimed(expIdx, path, dim1,doubleArray);
							delete[] doubleArray;
							} else {
							timebasepath="time";
							dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = <xsl:call-template name="printtimevariable"/>(_i);
							beginIdsPutTimed(expIdx, path, dim1,doubleArray);
							delete[] doubleArray;
							}
						</xsl:when>
						<xsl:otherwise>
							timebasepath = "";
						</xsl:otherwise>
					</xsl:choose>
					lepath =  "<xsl:value-of select="@path"/>";
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					dim1 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
					dim3 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
					intArray = new int[dim1*dim2*dim3];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					for(_k = 0; _k &lt;  dim3; _k++)
          //old intArray[_i + _j*dim1 + _k*dim1*dim2] = <xsl:value-of select="concat(@path,'.',@name)"/>(_i, _j, _k);
					intArray[_i + _j*dim1 + _k*dim1*dim2] = <xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k);
					status = putVect3DInt(expIdx, path, clepath,(char *) timebasepath.c_str(), intArray, dim1, dim2, dim3, <xsl:call-template name="printIsTimed"/>);
					delete[] intArray;
					checkStatus(status);
					if (status) return status;
					if (status) return status;
					<xsl:if test="@type='dynamic'">
						endIdsPutTimed(expIdx, path);
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<!--========== 4D arrays ==========-->
		<xsl:when test="@data_type='FLT_4D'">
			//Doc Put <xsl:value-of select="@path"/>
			<xsl:choose>
				<xsl:when test="$variable_path">
					<xsl:choose>
						<xsl:when test="@type='dynamic'">
							if (ids_properties.homogeneous_time == 0) {
							<!--XSLtest whether this is a data/time structure, otherwise assume that the timepath attribute from IDSDef is correct-->
							<xsl:choose>
								<xsl:when test="(@name='data' and ../field[@name='time']) or (@name='time' and ../field[@name='data'])">
									timebasepath=<xsl:value-of select="$mds_path"/>+string("/time");
									dim1= <xsl:value-of select="concat($variable_path,'.time')"/>.extent(0);
									doubleArray = new double[dim1];
									for(_i = 0; _i &lt;  dim1; _i++)
									doubleArray[_i] = <xsl:value-of select="concat($variable_path,'.time')"/>(_i);
									beginIdsPutTimed(expIdx, path,dim1,doubleArray);
									delete [] doubleArray;
								</xsl:when>
								<xsl:otherwise>
									timebasepath="<xsl:call-template name="printtimepath"/>";
									<!--  dim1= <xsl:value-of select = "translate($variable_path,'/','.')"/>.extent(0); -->
									dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
									doubleArray = new double[dim1];
									for(_i = 0; _i &lt;  dim1; _i++)
									doubleArray[_i] =<xsl:call-template name="printtimevariable"/>(_i);
									beginIdsPutTimed(expIdx, path, dim1,doubleArray);
									delete [] doubleArray;
								</xsl:otherwise>
							</xsl:choose>
							} else {
							timebasepath="time";
							dim1= time.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = time(_i);
							beginIdsPutTimed(expIdx, path,dim1,doubleArray);
							delete [] doubleArray;
							}
						</xsl:when>
						<xsl:otherwise>
							timebasepath = "";
						</xsl:otherwise>
					</xsl:choose>
					lepath =  <xsl:value-of select="$mds_path"/> +  string("/<xsl:value-of select="@name"/>");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					dim1 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0);
					dim2 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(1);
					dim3 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(2);
					dim4 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(3);
					doubleArray = new double[dim1*dim2*dim3*dim4];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					for(_k = 0; _k &lt;  dim3; _k++)
					for(_h = 0; _h &lt;  dim4; _h++)
					doubleArray[_i+ _j*dim1 + _k*dim1*dim2 + _h*dim1*dim2*dim3] = <xsl:value-of select="concat($variable_path,'.',@name)"/>(_i, _j, _k, _h);
					status = putVect4DDouble(expIdx, path, clepath,(char *) timebasepath.c_str(), doubleArray, dim1, dim2, dim3, dim4, <xsl:call-template name="printIsTimed"/>);
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
					<xsl:if test="@type='dynamic'">
						endIdsPutTimed(expIdx, path);
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="@type='dynamic'">
							if (ids_properties.homogeneous_time == 0) {
							timebasepath="<xsl:call-template name="printtimepath"/>";
							dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = <xsl:call-template name="printtimevariable"/>(_i);
							beginIdsPutTimed(expIdx, path, dim1,doubleArray);
							delete[] doubleArray;
							} else {
							timebasepath="time";
							dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = <xsl:call-template name="printtimevariable"/>(_i);
							beginIdsPutTimed(expIdx, path, dim1,doubleArray);
							delete[] doubleArray;
							}
						</xsl:when>
						<xsl:otherwise>
							timebasepath = "";
						</xsl:otherwise>
					</xsl:choose>
					lepath =  "<xsl:value-of select="@path"/>";
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					dim1 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
					dim3 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
					dim4 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
					doubleArray = new double[dim1*dim2*dim3*dim4];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					for(_k = 0; _k &lt;  dim3; _k++)
					for(_h = 0; _h &lt;  dim4; _h++)
					doubleArray[_i+ _j*dim1 + _k*dim1*dim2 + _h*dim1*dim2*dim3] = <xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k, _h);
					status = putVect4DDouble(expIdx, path,clepath,(char *) timebasepath.c_str() , doubleArray, dim1, dim2, dim3, dim4, <xsl:call-template name="printIsTimed"/> );
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
					<xsl:if test="@type='dynamic'">
						endIdsPutTimed(expIdx, path);
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<!-- SUPPRIME

<xsl:when test="@name='array4ddbl_type'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
dim3 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(2);
dim4 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(3);
doubleArray = new double[dim1*dim2*dim3*dim4];
for(_i = 0; _i &lt;  dim1; _i++)
for(_j = 0; _j &lt;  dim2; _j++)
for(_k = 0; _k &lt;  dim3; _k++)
for(_h = 0; _h &lt;  dim4; _h++)
doubleArray[_i+ _j*dim1 + _k*dim1*dim2 + _h*dim1*dim2*dim3] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i, _j, _k, _h);
status = putVect4DDouble(expIdx, path, "<xsl:value-of select = "@path"/>", doubleArray, dim1, dim2, dim3, dim4, 0);
delete[] doubleArray;
checkStatus(status);
if (status) return status;
</xsl:when>

<xsl:when test="@name='array4dint_type'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
dim3 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(2);
dim4 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(3);
intArray = new int[dim1*dim2*dim3*dim4];
for(_i = 0; _i &lt;  dim1; _i++)
for(_j = 0; _j &lt;  dim2; _j++)
for(_k = 0; _k &lt;  dim3; _k++)
for(_h = 0; _h &lt;  dim4; _h++)
intArray[_i + _j*dim1 + _k*dim1*dim2 + _h*dim1*dim2*dim3] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i, _j, _k, _h);
status = putVect4DInt(expIdx, path, "<xsl:value-of select = "@path"/>", intArray, dim1, dim2, dim3, dim4, 0);
delete[] intArray;
checkStatus(status);
if (status) return status;
</xsl:when>
-->
		<!--========== 5D arrays ==========-->
		<xsl:when test="@data_type='FLT_5D'">
			//Doc <xsl:value-of select="@path"/>
			<xsl:choose>
				<xsl:when test="$variable_path">
					<xsl:choose>
						<xsl:when test="@type='dynamic'">
							if (ids_properties.homogeneous_time == 0) {
							<!--XSLtest whether this is a data/time structure, otherwise assume that the timepath attribute from IDSDef is correct-->
							<xsl:choose>
								<xsl:when test="(@name='data' and ../field[@name='time']) or (@name='time' and ../field[@name='data'])">
									timebasepath=<xsl:value-of select="$mds_path"/>+string("/time");
									dim1= <xsl:value-of select="concat($variable_path,'.time')"/>.extent(0);
									doubleArray = new double[dim1];
									for(_i = 0; _i &lt;  dim1; _i++)
									doubleArray[_i] = <xsl:value-of select="concat($variable_path,'.time')"/>(_i);
									beginIdsPutTimed(expIdx, path,dim1,doubleArray);
									delete [] doubleArray;
								</xsl:when>
								<xsl:otherwise>
									timebasepath="<xsl:call-template name="printtimepath"/>";
									<!--  dim1= <xsl:value-of select = "translate($variable_path,'/','.')"/>.extent(0); -->
									dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
									doubleArray = new double[dim1];
									for(_i = 0; _i &lt;  dim1; _i++)
									doubleArray[_i] =<xsl:call-template name="printtimevariable"/>(_i);
									beginIdsPutTimed(expIdx, path, dim1,doubleArray);
									delete [] doubleArray;
								</xsl:otherwise>
							</xsl:choose>
							} else {
							timebasepath="time";
							dim1= time.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = time(_i);
							beginIdsPutTimed(expIdx, path,dim1,doubleArray);
							delete [] doubleArray;
							}
						</xsl:when>
						<xsl:otherwise>
							timebasepath = "";
						</xsl:otherwise>
					</xsl:choose>
					lepath =  <xsl:value-of select="$mds_path"/> +  string("/<xsl:value-of select="@name"/>");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					dim1 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0);
					dim2 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(1);
					dim3 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(2);
					dim4 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(3);
					dim5 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(4);
					doubleArray = new double[dim1*dim2*dim3*dim4*dim5];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					for(_k = 0; _k &lt;  dim3; _k++)
					for(_h = 0; _h &lt;  dim4; _h++)
					for(_l = 0; _l &lt;  dim5; _l++)
					doubleArray[_i+ _j*dim1 + _k*dim1*dim2 + _h*dim1*dim2*dim3 + _l*dim1*dim2*dim3*dim4] = <xsl:value-of select="concat($variable_path,'.',@name)"/>(_i, _j, _k, _h, _l);
					status = putVect5DDouble(expIdx, path, clepath, (char *) timebasepath.c_str(), doubleArray, dim1, dim2, dim3, dim4, dim5, <xsl:call-template name="printIsTimed"/>);
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
					<xsl:if test="@type='dynamic'">
						endIdsPutTimed(expIdx, path);
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="@type='dynamic'">
							if (ids_properties.homogeneous_time == 0) {
							timebasepath="<xsl:call-template name="printtimepath"/>";
							dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = <xsl:call-template name="printtimevariable"/>(_i);
							beginIdsPutTimed(expIdx, path, dim1,doubleArray);
							delete[] doubleArray;
							} else {
							timebasepath="time";
							dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = <xsl:call-template name="printtimevariable"/>(_i);
							beginIdsPutTimed(expIdx, path, dim1,doubleArray);
							delete[] doubleArray;
							}
						</xsl:when>
						<xsl:otherwise>
							timebasepath = "";
						</xsl:otherwise>
					</xsl:choose>
					lepath =  "<xsl:value-of select="@path"/>";
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					dim1 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
					dim3 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
					dim4 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
					dim5 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(4);
					doubleArray = new double[dim1*dim2*dim3*dim4*dim5];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					for(_k = 0; _k &lt;  dim3; _k++)
					for(_h = 0; _h &lt;  dim4; _h++)
					for(_l = 0; _l &lt;  dim5; _l++)
					doubleArray[_i+ _j*dim1 + _k*dim1*dim2 + _h*dim1*dim2*dim3 + _l*dim1*dim2*dim3*dim4] = <xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k, _h, _l);
					status = putVect5DDouble(expIdx, path, clepath, (char *) timebasepath.c_str(), doubleArray, dim1, dim2, dim3, dim4, dim5, <xsl:call-template name="printIsTimed"/>);
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
					<xsl:if test="@type='dynamic'">
						endIdsPutTimed(expIdx, path);
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<!--

<xsl:when test="@name='array5ddbl_type'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
dim3 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(2);
dim4 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(3);
dim5 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(4);
doubleArray = new double[dim1*dim2*dim3*dim4*dim5];
for(_i = 0; _i &lt;  dim1; _i++)
for(_j = 0; _j &lt;  dim2; _j++)
for(_k = 0; _k &lt;  dim3; _k++)
for(_h = 0; _h &lt;  dim4; _h++)
for(_l = 0; _l &lt;  dim5; _l++)
doubleArray[_i+ _j*dim1 + _k*dim1*dim2 + _h*dim1*dim2*dim3 + _l*dim1*dim2*dim3*dim4] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i, _j, _k, _h, _l);
status = putVect5DDouble(expIdx, path, "<xsl:value-of select = "@path"/>", doubleArray, dim1, dim2, dim3, dim4, dim5, 0);
delete[] doubleArray;
checkStatus(status);
if (status) return status;
</xsl:when>



<xsl:when test="@name='array5dint_type'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
dim3 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(2);
dim4 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(3);
dim5 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(4);
intArray = new int[dim1*dim2*dim3*dim4*dim5];
for(_i = 0; _i &lt;  dim1; _i++)
for(_j = 0; _j &lt;  dim2; _j++)
for(_k = 0; _k &lt;  dim3; _k++)
for(_h = 0; _h &lt;  dim4; _h++)
for(_l = 0; _l &lt;  dim5; _l++)
intArray[_i+ _j*dim1 + _k*dim1*dim2 + _h*dim1*dim2*dim3 + _l*dim1*dim2*dim3*dim4] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i, _j, _k, _h, _l);
status = putVect5DInt(expIdx, path, "<xsl:value-of select = "@path"/>", intArray, dim1, dim2, dim3, dim4, dim5, 0);
delete[] intArray;
checkStatus(status);
if (status) return status;
</xsl:when>
-->

		<!--========== 6D arrays ==========-->
		<xsl:when test="@data_type='FLT_6D'">
			//Doc <xsl:value-of select="@path"/>
			<xsl:choose>
				<xsl:when test="$variable_path">
					<xsl:choose>
						<xsl:when test="@type='dynamic'">
							if (ids_properties.homogeneous_time == 0) {
							<!--XSLtest whether this is a data/time structure, otherwise assume that the timepath attribute from IDSDef is correct-->
							<xsl:choose>
								<xsl:when test="(@name='data' and ../field[@name='time']) or (@name='time' and ../field[@name='data'])">
									timebasepath=<xsl:value-of select="$mds_path"/>+string("/time");
									dim1= <xsl:value-of select="concat($variable_path,'.time')"/>.extent(0);
									doubleArray = new double[dim1];
									for(_i = 0; _i &lt;  dim1; _i++)
									doubleArray[_i] = <xsl:value-of select="concat($variable_path,'.time')"/>(_i);
									beginIdsPutTimed(expIdx, path,dim1,doubleArray);
									delete [] doubleArray;
								</xsl:when>
								<xsl:otherwise>
									timebasepath="<xsl:call-template name="printtimepath"/>";
									dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
									doubleArray = new double[dim1];
									for(_i = 0; _i &lt;  dim1; _i++)
									doubleArray[_i] =<xsl:call-template name="printtimevariable"/>(_i);
									beginIdsPutTimed(expIdx, path, dim1,doubleArray);
									delete [] doubleArray;
								</xsl:otherwise>
							</xsl:choose>
							} else {
							timebasepath="time";
							dim1= time.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = time(_i);
							beginIdsPutTimed(expIdx, path,dim1,doubleArray);
							delete [] doubleArray;
							}
						</xsl:when>
						<xsl:otherwise>
							timebasepath = "";
						</xsl:otherwise>
					</xsl:choose>
					lepath =  <xsl:value-of select="$mds_path"/> +  string("/<xsl:value-of select="@name"/>");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					dim1 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0);
					dim2 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(1);
					dim3 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(2);
					dim4 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(3);
					dim5 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(4);
					dim6 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(5);
					doubleArray = new double[dim1*dim2*dim3*dim4*dim5*dim6];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					for(_k = 0; _k &lt;  dim3; _k++)
					for(_h = 0; _h &lt;  dim4; _h++)
					for(_l = 0; _l &lt;  dim5; _l++)
					for(_m = 0; _m &lt;  dim6; _m++)
					doubleArray[_i+ _j*dim1 + _k*dim1*dim2 + _h*dim1*dim2*dim3 + _l*dim1*dim2*dim3*dim4 + _m*dim1*dim2*dim3*dim4*dim5] = <xsl:value-of select="concat($variable_path,'.',@name)"/>(_i, _j, _k, _h, _l, _m);
					status = putVect6DDouble(expIdx, path, clepath,(char *) timebasepath.c_str(), doubleArray, dim1, dim2, dim3, dim4, dim5, dim6, <xsl:call-template name="printIsTimed"/>);
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
					<xsl:if test="@type='dynamic'">
						endIdsPutTimed(expIdx, path);
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="@type='dynamic'">
							if (ids_properties.homogeneous_time == 0) {
							timebasepath="<xsl:call-template name="printtimepath"/>";
							dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = <xsl:call-template name="printtimevariable"/>(_i);
							beginIdsPutTimed(expIdx, path, dim1,doubleArray);
							delete[] doubleArray;
							} else {
							timebasepath="time";
							dim1= <xsl:call-template name="printtimevariable"/>.extent(0);
							doubleArray = new double[dim1];
							for(_i = 0; _i &lt;  dim1; _i++)
							doubleArray[_i] = <xsl:call-template name="printtimevariable"/>(_i);
							beginIdsPutTimed(expIdx, path, dim1,doubleArray);
							delete[] doubleArray;
							}
						</xsl:when>
						<xsl:otherwise>
							timebasepath = "";
						</xsl:otherwise>
					</xsl:choose>
					lepath =  "<xsl:value-of select="@path"/>";
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					dim1 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
					dim3 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
					dim4 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
					dim5 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(4);
					dim6 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(5);
					doubleArray = new double[dim1*dim2*dim3*dim4*dim5*dim6];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					for(_k = 0; _k &lt;  dim3; _k++)
					for(_h = 0; _h &lt;  dim4; _h++)
					for(_l = 0; _l &lt;  dim5; _l++)
					for(_m = 0; _m &lt;  dim6; _m++)
					doubleArray[_i+ _j*dim1 + _k*dim1*dim2 + _h*dim1*dim2*dim3 + _l*dim1*dim2*dim3*dim4 + _m*dim1*dim2*dim3*dim4*dim5] = <xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k, _h, _l, _m);
					status = putVect6DDouble(expIdx, path, clepath,(char *) timebasepath.c_str(), doubleArray, dim1, dim2, dim3, dim4, dim5, dim6, <xsl:call-template name="printIsTimed"/>);
					delete[] doubledoubleArrayArray;
					checkStatus(status);
					if (status) return status;
					<xsl:if test="@type='dynamic'">
						endIdsPutTimed(expIdx, path);
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<!-- SUPPRIME
<xsl:when test="@name='array6ddbl_type'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
dim3 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(2);
dim4 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(3);
dim5 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(4);
dim6 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(5);
doubleArray = new double[dim1*dim2*dim3*dim4*dim5*dim6];
for(_i = 0; _i &lt;  dim1; _i++)
for(_j = 0; _j &lt;  dim2; _j++)
for(_k = 0; _k &lt;  dim3; _k++)
for(_h = 0; _h &lt;  dim4; _h++)
for(_l = 0; _l &lt;  dim5; _l++)
for(_m = 0; _m &lt;  dim6; _m++)
doubleArray[_i+ _j*dim1 + _k*dim1*dim2 + _h*dim1*dim2*dim3 + _l*dim1*dim2*dim3*dim4+ _m*dim1*dim2*dim3*dim4*dim6] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i, _j, _k, _h, _l, _m);
status = putVect6DDouble(expIdx, path, "<xsl:value-of select = "@path"/>", doubleArray, dim1, dim2, dim3, dim4, dim5, dim6, 0);
delete[] doubleArray;
checkStatus(status);
if (status) return status;
</xsl:when>
-->
		<!-- SUPPRIME
<xsl:when test="@name='array6dint_type'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
dim3 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(2);
dim4 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(3);
dim5 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(4);
dim6 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(5);
intArray = new int[dim1*dim2*dim3*dim4*dim5*dim6];
for(_i = 0; _i &lt;  dim1; _i++)
for(_j = 0; _j &lt;  dim2; _j++)
for(_k = 0; _k &lt;  dim3; _k++)
for(_h = 0; _h &lt;  dim4; _h++)
for(_l = 0; _l &lt;  dim5; _l++)
for(_m = 0; _m &lt;  dim6; _m++)
intArray[_i+ _j*dim1 + _k*dim1*dim2 + _h*dim1*dim2*dim3 + _l*dim1*dim2*dim3*dim4+ _m*dim1*dim2*dim3*dim4*dim6] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i, _j, _k, _h, _l, _m);
status = putVect6DInt(expIdx, path, "<xsl:value-of select = "@path"/>", intArray, dim1, dim2, dim3, dim4, dim5, dim6, 0);
delete[] intArray;
checkStatus(status);
if (status) return status;
</xsl:when>
--> 
		<xsl:otherwise>
			//Doc Put <xsl:value-of select="@path"/> : PROBLEM : UNIDENTIFIED TYPE !!! <!-- for comment only -->
		</xsl:otherwise>

	</xsl:choose>
</xsl:if>
</xsl:template>
<!--=================================================-->
<!--       put field of full time-dependent IDS      -->
<!--=================================================-->
<xsl:template match="field" mode="PUT_TIMED">
<xsl:choose>
	<xsl:when test="@timed = 'yes'">
		<!--************ Time-dependent fields ************-->
		<xsl:choose>
			<!--========== Simple types ==========-->
			<xsl:when test="@data_type='str_type' or @data_type='STR_0D'">
				stringArray = new char*[numElements];
				for(_i = 0; _i &lt; numElements; _i++)
				stringArray[_i] = (char *)array(_i).<xsl:value-of select="translate(@path,'/','.')"/>.data();
				status = PUTVECT1DSTRING(expIdx, path, "<xsl:value-of select="@path"/>", stringArray, numElements, 1);
				checkStatus(status);
				delete[] stringArray;
				if (status) return status;
			</xsl:when>
			<xsl:when test="@data_type='int_type' or @data_type='INT_0D'">
				intArray = new int[numElements];
				for(_i = 0; _i &lt; numElements; _i++)
				intArray[_i] = array(_i).<xsl:value-of select="translate(@path,'/','.')"/>; 
				status = PUTVECT1DINT(expIdx, path, "<xsl:value-of select="@path"/>", intArray, numElements, 1);
				checkStatus(status);
				delete[] intArray;
				if (status) return status;
			</xsl:when>
			<xsl:when test="@name='xs:boolean'">
				intArray = new int[numElements];
				for(_i = 0; _i &lt; numElements; _i++)
				intArray[_i] = array(_i).<xsl:value-of select="translate(@path,'/','.')"/>; 
				status = PUTVECT1DINT(expIdx, path, "<xsl:value-of select="translate(@path,'/','.')"/>", intArray, numElements, 1);
				checkStatus(status);
				delete[] intArray;
				if (status) return status;
			</xsl:when>
			<xsl:when test="@name='xs:double'">
				doubleArray = new double[numElements];
				for(_i = 0; _i &lt; numElements; _i++)
				doubleArray[_i] = array(_i).<xsl:value-of select="translate(@path,'/','.')"/>; 
				status = PUTVECT1DDOUBLE(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, numElements, 1);
				checkStatus(status);
				delete[] doubleArray;
				if (status) return status;
			</xsl:when>
			<xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
				doubleArray = new double[numElements];
				for(_i = 0; _i &lt; numElements; _i++)
				doubleArray[_i] = array(_i).<xsl:value-of select="translate(@path,'/','.')"/>; 
				status = PUTVECT1DDOUBLE(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, numElements, 1);
				checkStatus(status);
				delete[] doubleArray;
				if (status) return status;
			</xsl:when>
			<!--========== Vectors ==========-->
			<xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">
				numSamples = numElements*array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				doubleArray = new double[numSamples];
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				for(_i = 0; _i &lt;  dim1; _i++)
				for(_j = 0; _j &lt;  numElements; _j++)
				doubleArray[_i+_j*dim1] = array(_j).<xsl:value-of select="translate(@path,'/','.')"/>(_i);
				status = putVect2DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, numElements, 1);
				checkStatus(status);
				delete[] doubleArray;
				if (status) return status;
			</xsl:when>
			<xsl:when test="@name='vecdbl_type'">
				numSamples = numElements*array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				doubleArray = new double[numSamples];
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				for(_i = 0; _i &lt;  dim1; _i++)
				for(_j = 0; _j &lt;  numElements; _j++)
				doubleArray[_i+_j*dim1] = array(_j).<xsl:value-of select="translate(@path,'/','.')"/>(_i);
				status = putVect2DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, numElements, 1);
				checkStatus(status);
				delete[] doubleArray;
				if (status) return status;
			</xsl:when>
			<xsl:when test="@data_type='int_1d_type' or @data_type='INT_1D'">
				numSamples = numElements*array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				intArray = new int[numSamples];
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				for(_i = 0; _i &lt;  dim1; _i++)
				for(_j = 0; _j &lt;  numElements; _j++)
				intArray[_i+_j*dim1] = array(_j).<xsl:value-of select="translate(@path,'/','.')"/>(_i);
				status = putVect2DInt(expIdx, path, "<xsl:value-of select="@path"/>", intArray, dim1, numElements, 1);
				checkStatus(status);
				delete[] intArray;
				if (status) return status;
			</xsl:when>
			<!--========== Matrices ==========-->
			<xsl:when test="@data_type='FLT_2D'">
				numSamples = numElements*array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1) ;
				doubleArray = new double[numSamples];
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; numElements; _k++)
				doubleArray[_i+_j*dim1+_k*dim1*dim2] = array(_k).<xsl:value-of select="translate(@path,'/','.')"/>(_i,_j);
				status = putVect3DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, numElements, 1);
				checkStatus(status);
				delete[] doubleArray;
				if (status) return status;
			</xsl:when>
			<xsl:when test="@name='matdbl_type'">
				numSamples = numElements*array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1) ;
				doubleArray = new double[numSamples];
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; numElements; _k++)
				doubleArray[_i+_j*dim1+_k*dim1*dim2] = array(_k).<xsl:value-of select="translate(@path,'/','.')"/>(_i,_j);
				status = putVect3DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, numElements, 1);
				checkStatus(status);
				delete[] doubleArray;
				if (status) return status;
			</xsl:when>
			<xsl:when test="@data_type='INT_2D'">
				numSamples = numElements*array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1) ;
				intArray = new int[numSamples];
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; numElements; _k++)
				intArray[_i+_j*dim1+_k*dim1*dim2] = array(_k).<xsl:value-of select="translate(@path,'/','.')"/>(_i,_j);
				status = putVect3DInt(expIdx, path, "<xsl:value-of select="@path"/>", intArray, dim1, dim2, numElements, 1);
				checkStatus(status);
				delete[] intArray;
				if (status) return status;
			</xsl:when>
			<!--========== 3D arrays ==========-->
			<xsl:when test="@data_type='FLT_3D'">
				numSamples = numElements*array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				doubleArray = new double[numSamples];
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				dim3 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; dim3; _k++)
				for(_h = 0; _h  &lt; numElements; _h++)
				doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3] = array(_h).<xsl:value-of select="translate(@path,'/','.')"/>(_i,_j,_k);
				status = putVect4DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, numElements, 1);
				checkStatus(status);
				delete[] doubleArray;
				if (status) return status;
			</xsl:when>
			<xsl:when test="@name='array3ddbl_type'">
				numSamples = numElements*array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				doubleArray = new double[numSamples];
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				dim3 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; dim3; _k++)
				for(_h = 0; _h  &lt; numElements; _h++)
				doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3] = array(_h).<xsl:value-of select="translate(@path,'/','.')"/>(_i,_j,_k);
				status = putVect4DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, numElements, 1);
				checkStatus(status);
				delete[] doubleArray;
				if (status) return status;
			</xsl:when>
			<xsl:when test="@data_type='INT_3D'">
				numSamples = numElements*array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				intArray = new int[numSamples];
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				dim3 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; dim3; _k++)
				for(_h = 0; _h  &lt; numElements; _h++)
				intArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3] = array(_h).<xsl:value-of select="translate(@path,'/','.')"/>(_i,_j,_k);
				status = putVect4DInt(expIdx, path, "<xsl:value-of select="@path"/>", intArray, dim1, dim2, dim3, numElements, 1);
				checkStatus(status);
				delete[] intArray;
				if (status) return status;
			</xsl:when>
			<!--========== 4D arrays ==========-->
			<xsl:when test="@data_type='FLT_4D'">
				numSamples = numElements*array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2)* array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
				doubleArray = new double[numSamples];
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				dim3 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				dim4 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; dim3; _k++)
				for(_h = 0; _h &lt; dim4; _h++)
				for(_l = 0; _l  &lt; numElements; _l++)
				doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4] = array(_l).<xsl:value-of select="translate(@path,'/','.')"/>(_i,_j,_k, _h);
				status = putVect5DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, dim4, numElements, 1);
				checkStatus(status);
				delete[] doubleArray;
				if (status) return status;
			</xsl:when>
			<xsl:when test="@name='array4ddbl_type'">
				numSamples = numElements*array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2)* array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
				doubleArray = new double[numSamples];
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				dim3 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				dim4 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; dim3; _k++)
				for(_h = 0; _h &lt; dim4; _h++)
				for(_l = 0; _l  &lt; numElements; _l++)
				doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4] = array(_l).<xsl:value-of select="translate(@path,'/','.')"/>(_i,_j,_k, _h);
				status = putVect5DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, dim4, numElements, 1);
				checkStatus(status);
				delete[] doubleArray;
				if (status) return status;
			</xsl:when>
			<xsl:when test="@name='array4dint_type'">
				numSamples = numElements*array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2)* array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
				intArray = new int[numSamples];
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				dim3 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				dim4 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; dim3; _k++)
				for(_h = 0; _h &lt; dim4; _h++)
				for(_l = 0; _l  &lt; numElements; _l++)
				intArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4] = array(_l).<xsl:value-of select="translate(@path,'/','.')"/>(_i,_j,_k, _h);
				status = putVect5DInt(expIdx, path, "<xsl:value-of select="@path"/>", intArray, dim1, dim2, dim3, dim4, numElements, 1);
				checkStatus(status);
				delete[] intArray;
				if (status) return status;
			</xsl:when>
			<!--========== 5D arrays ==========-->
			<xsl:when test="@data_type='FLT_5D'">
				numSamples = numElements*array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2)* array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3)* array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(4);
				doubleArray = new double[numSamples];
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				dim3 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				dim4 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
				dim5 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(4);
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; dim3; _k++)
				for(_h = 0; _h &lt; dim4; _h++)
				for(_l = 0; _l  &lt; dim5; _l++)
				for(_m = 0; _m  &lt; numElements; _m++)
				doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4+_m*dim1*dim2*dim3*dim4*dim5] = array(_m).<xsl:value-of select="translate(@path,'/','.')"/>(_i,_j,_k, _h, _l);
				status = putVect6DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, dim4, dim5, numElements, 1);
				checkStatus(status);
				delete[] doubleArray;
				if (status) return status;
			</xsl:when>
			<xsl:when test="@name='array5ddbl_type'">
				numSamples = numElements*array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2)* array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3)* array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(4);
				doubleArray = new double[numSamples];
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				dim3 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				dim4 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
				dim5 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(4);
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; dim3; _k++)
				for(_h = 0; _h &lt; dim4; _h++)
				for(_l = 0; _l  &lt; dim5; _l++)
				for(_m = 0; _m  &lt; numElements; _m++)
				doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4+_m*dim1*dim2*dim3*dim4*dim5] = array(_m).<xsl:value-of select="translate(@path,'/','.')"/>(_i,_j,_k, _h, _l);
				status = putVect6DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, dim4, dim5, numElements, 1);
				checkStatus(status);
				delete[] doubleArray;
				if (status) return status;
			</xsl:when>
			<xsl:when test="@name='array5dint_type'">
				numSamples = numElements*array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2)* array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3)* array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(4);
				intArray = new int[numSamples];
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				dim3 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				dim4 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
				dim5 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(4);
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; dim3; _k++)
				for(_h = 0; _h &lt; dim4; _h++)
				for(_l = 0; _l  &lt; dim5; _l++)
				for(_m = 0; _m  &lt; numElements; _m++)
				intArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4+_m*dim1*dim2*dim3*dim4*dim5] = array(_m).<xsl:value-of select="translate(@path,'/','.')"/>(_i,_j,_k, _h, _l);
				status = putVect6DInt(expIdx, path, "<xsl:value-of select="@path"/>", intArray, dim1, dim2, dim3, dim4, dim5, numElements, 1);
				checkStatus(status);
				delete[] intArray;
				if (status) return status;
			</xsl:when>
			<!--========== 6D arrays ==========-->
			<xsl:when test="@data_type='FLT_6D'">
				numSamples = numElements*array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2)* array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3)* array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(4) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(5);
				doubleArray = new double[numSamples];
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				dim3 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				dim4 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
				dim5 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(4);
				dim6 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(5);
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; dim3; _k++)
				for(_h = 0; _h &lt; dim4; _h++)
				for(_l = 0; _l  &lt; dim5; _l++)
				for(_m = 0; _m  &lt; dim6; _m++)
				for(_n = 0; _n  &lt; numElements; _n++)
				doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4+_m*dim1*dim2*dim3*dim4*dim5+_n*dim1*dim2*dim3*dim4*dim5*dim6] = array(_n).<xsl:value-of select="translate(@path,'/','.')"/>(_i,_j,_k, _h, _l, _m);
				status = putVect7DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, dim4, dim5, dim6,numElements, 1);
				checkStatus(status);
				delete[] doubleArray;
				if (status) return status;
			</xsl:when>
			<xsl:when test="@name='array6ddbl_type'">
				numSamples = numElements*array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2)* array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3)* array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(4) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(5);
				doubleArray = new double[numSamples];
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				dim3 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				dim4 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
				dim5 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(4);
				dim6 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(5);
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; dim3; _k++)
				for(_h = 0; _h &lt; dim4; _h++)
				for(_l = 0; _l  &lt; dim5; _l++)
				for(_m = 0; _m  &lt; dim6; _m++)
				for(_n = 0; _n  &lt; numElements; _n++)
				doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4+_m*dim1*dim2*dim3*dim4*dim5+_n*dim1*dim2*dim3*dim4*dim5*dim6] = array(_n).<xsl:value-of select="translate(@path,'/','.')"/>(_i,_j,_k, _h, _l, _m);
				status = putVect7DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, dim4, dim5, dim6, numElements, 1);
				checkStatus(status);
				delete[] doubleArray;
				if (status) return status;
			</xsl:when>
			<xsl:when test="@name='array6dint_type'">
				numSamples = numElements*array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2)* array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3)* array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(4) * array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(5);
				intArray = new int[numSamples];
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				dim3 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				dim4 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
				dim5 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(4);
				dim6 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(5);
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; dim3; _k++)
				for(_h = 0; _h &lt; dim4; _h++)
				for(_l = 0; _l  &lt; dim5; _l++)
				for(_m = 0; _m  &lt; dim6; _m++)
				for(_n = 0; _n  &lt; numElements; _n++)
				intArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4+_m*dim1*dim2*dim3*dim4*dim5+_n*dim1*dim2*dim3*dim4*dim5*dim6] = array(_n).<xsl:value-of select="translate(@path,'/','.')"/>(_i,_j,_k, _h, _l, _m);
				status = putVect7DInt(expIdx, path, "<xsl:value-of select="@path"/>", intArray, dim1, dim2, dim3, dim4, dim5, dim6, numElements, 1);
				checkStatus(status);
				delete[] intArray;
				if (status) return status;
			</xsl:when>
			<!--========== Arrays of structures ==========-->
			<xsl:when test="@data_type='struct_array'">
				{ /*     3Array of structure     */
				/*     Write timed fields    */
				char fullpath[1024]; sprintf(fullpath,"%s/<xsl:value-of select="@path"/>",path);
				void *obj_all_times = beginObject(expIdx,NULL,0,fullpath,TIMED_CLEAR);
				for (int i0 = 0; i0 &lt; numElements; i0++) {
				void *obj1 = beginObject(expIdx,obj_all_times,i0,"ALLTIMES",TIMED);
				for (int i1 = 0; i1 &lt; array(i0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0); i1++) {
				<xsl:apply-templates select="field" mode="PUT_IN_OBJECT">
					<xsl:with-param name="level" select="1"/>
					<xsl:with-param name="objpath" select="@name"/>
					<xsl:with-param name="idxpath" select="concat('array(i0).',translate(@path,'/','.'),'(i1)')"/>
					<xsl:with-param name="timed" select="'yes'"/>
				</xsl:apply-templates>
				}
				obj_all_times = putObjectInObject(expIdx,obj_all_times, "ALLTIMES", i0, obj1);
				}
				status = putObject(expIdx, path, "<xsl:value-of select="@path"/>", obj_all_times, TIMED);
				checkStatus(status);
				if (status) return status;

				/*     Write non-timed fields    */
				void *obj1 = beginObject(expIdx,NULL,0,fullpath,NON_TIMED);
				for (int i1 = 0; i1 &lt; array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0); i1++) {
				<xsl:apply-templates select="field" mode="PUT_IN_OBJECT">
					<xsl:with-param name="level" select="1"/>
					<xsl:with-param name="objpath" select="@name"/>
					<xsl:with-param name="idxpath" select="concat('array(0).',translate(@path,'/','.'),'(i1)')"/>
					<xsl:with-param name="timed" select="'no'"/>
				</xsl:apply-templates>
				}
				status = putObject(expIdx, path, "<xsl:value-of select="@path"/>", obj1, NON_TIMED);
				checkStatus(status);
				if (status) return status;
				}
			</xsl:when>
			<!--========== Regular structures ==========-->
			<xsl:when test="@data_type='structure'">
				<xsl:apply-templates select="field" mode="PUT_TIMED"/>
			</xsl:when>
		</xsl:choose>
	</xsl:when>
	<!--************ Non-time-dependent fields ************-->
	<xsl:otherwise>
		<xsl:choose>
			<!--========== Simple types ==========-->
			<xsl:when test="@data_type='str_type' or @data_type='STR_0D'">
				status = putString(expIdx, path, "<xsl:value-of select="@path"/>", (char *)array(0).<xsl:value-of select="translate(@path,'/','.')"/>.data(), array(0).<xsl:value-of select="translate(@path,'/','.')"/>.size());
				checkStatus(status);
				if (status) return status;
			</xsl:when>
			<xsl:when test="@data_type='int_type' or @data_type='INT_0D'">
				status = putInt(expIdx, path, "<xsl:value-of select="@path"/>", array(0).<xsl:value-of select="translate(@path,'/','.')"/>);
				checkStatus(status);
				if (status) return status;
			</xsl:when>
			<xsl:when test="@name='xs:boolean'">
				status = putInt(expIdx, path, "<xsl:value-of select="@path"/>", array(0).<xsl:value-of select="translate(@path,'/','.')"/>);
				checkStatus(status);
				if (status) return status;
			</xsl:when>
			<xsl:when test="@name='xs:double'">
				status = putDouble(expIdx, path, "<xsl:value-of select="@path"/>", array(0).<xsl:value-of select="translate(@path,'/','.')"/>);
				checkStatus(status);
				if (status) return status;
			</xsl:when>
			<xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
				status = putDouble(expIdx, path, "<xsl:value-of select="@path"/>", array(0).<xsl:value-of select="translate(@path,'/','.')"/>);
				checkStatus(status);
				if (status) return status;
			</xsl:when>
			<!--========== Vectors ==========-->
			<xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">
				numSamples = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				doubleArray = new double[numSamples];
				for(_i = 0; _i &lt; numSamples; _i++)
				doubleArray[_i] = array(0).<xsl:value-of select="translate(@path,'/','.')"/>(_i); 
				status = PUTVECT1DDOUBLE(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, numSamples, 0);
				delete[] doubleArray;
				checkStatus(status);
				if (status) return status;
			</xsl:when>
			<xsl:when test="@data_type='str_1d_type' or @data_type='STR_1D'">
				numSamples = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				stringArray = new char *[numSamples];
				for(_i = 0; _i &lt; numSamples; _i++)
				stringArray[_i] = (char *)array(0).<xsl:value-of select="translate(@path,'/','.')"/>(_i).c_str(); 
				status = PUTVECT1DSTRING(expIdx, path, "<xsl:value-of select="@path"/>", stringArray, numSamples, 0);
				delete[] stringArray;
				checkStatus(status);
				if (status) return status;
			</xsl:when>
			<xsl:when test="@name='vecdbl_type'">
				numSamples = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				doubleArray = new double[numSamples];
				for(_i = 0; _i &lt; numSamples; _i++)
				doubleArray[_i] = array(0).<xsl:value-of select="translate(@path,'/','.')"/>(_i); 
				status = PUTVECT1DDOUBLE(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, numSamples, 0);
				delete[] doubleArray;
				checkStatus(status);
				if (status) return status;
			</xsl:when>
			<xsl:when test="@data_type='int_1d_type' or @data_type='INT_1D'">
				numSamples = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				intArray = new int[numSamples];
				for(_i = 0; _i &lt; numSamples; _i++)
				intArray[_i] = array(0).<xsl:value-of select="translate(@path,'/','.')"/>(_i); 
				status = PUTVECT1DINT(expIdx, path, "<xsl:value-of select="@path"/>", intArray, numSamples, 0);
				delete[] intArray;
				checkStatus(status);
				if (status) return status;
			</xsl:when>  
			<!--========== Matrices ==========-->
			<xsl:when test="@data_type='FLT_2D'">
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				doubleArray = new double[dim1*dim2];
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				doubleArray[_i+_j*dim1] = array(0).<xsl:value-of select="translate(@path,'/','.')"/>(_i,_j); 
				status = putVect2DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, 0);
				delete[] doubleArray;
				checkStatus(status);
				if (status) return status;
			</xsl:when>
			<xsl:when test="@name='matdbl_type'">
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				doubleArray = new double[dim1*dim2];
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				doubleArray[_i+_j*dim1] = array(0).<xsl:value-of select="translate(@path,'/','.')"/>(_i,_j); 
				status = putVect2DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, 0);
				delete[] doubleArray;
				checkStatus(status);
				if (status) return status;
			</xsl:when>
			<xsl:when test="@data_type='INT_2D'">
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				intArray = new int[dim1*dim2];
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				intArray[_i+_j*dim1] = array(0).<xsl:value-of select="translate(@path,'/','.')"/>(_i,_j); 
				status = putVect2DInt(expIdx, path, "<xsl:value-of select="@path"/>", intArray, dim1, dim2, 0);
				delete[] intArray;
				checkStatus(status);
				if (status) return status;
			</xsl:when>
			<!--========== 3D arrays ==========-->
			<xsl:when test="@data_type='FLT_3D'">
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				dim3 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				doubleArray = new double[dim1*dim2*dim3];
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; dim3; _k++)
				doubleArray[_i+_j*dim1+_k*dim1*dim2] = array(0).<xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k); 
				status = putVect3DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, 0);
				delete[] doubleArray;
				checkStatus(status);
				if (status) return status;
			</xsl:when>
			<xsl:when test="@name='array3ddbl_type'">
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				dim3 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				doubleArray = new double[dim1*dim2*dim3];
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; dim3; _k++)
				doubleArray[_i+_j*dim1+_k*dim1*dim2] = array(0).<xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k); 
				status = putVect3DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, 0);
				delete[] doubleArray;
				checkStatus(status);
				if (status) return status;
			</xsl:when>
			<xsl:when test="@data_type='INT_3D'">
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				dim3 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				intArray = new int[dim1*dim2*dim3];
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; dim3; _k++)
				intArray[_i+_j*dim1+_k*dim1*dim2] = array(0).<xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k); 
				status = putVect3DInt(expIdx, path, "<xsl:value-of select="@path"/>", intArray, dim1, dim2, dim3, 0);
				delete[] intArray;
				checkStatus(status);
				if (status) return status;
			</xsl:when>
			<!--========== 4D arrays ==========-->
			<xsl:when test="@data_type='FLT_4D'">
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				dim3 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				dim4 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
				doubleArray = new double[dim1*dim2*dim3*dim4];
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; dim3; _k++)
				for(_l = 0; _l &lt; dim4; _l++)
				doubleArray[_i+_j*dim1+_k*dim1*dim2+_l*dim1*dim2*dim3] = array(0).<xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k, _l); 
				status = putVect4DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, dim4, 0);
				delete[] doubleArray;
				checkStatus(status);
				if (status) return status;
			</xsl:when>
			<xsl:when test="@name='array4ddbl_type'">
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				dim3 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				dim4 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
				doubleArray = new double[dim1*dim2*dim3*dim4];
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; dim3; _k++)
				for(_l = 0; _l &lt; dim4; _l++)
				doubleArray[_i+_j*dim1+_k*dim1*dim2+_l*dim1*dim2*dim3] = array(0).<xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k, _l); 
				status = putVect4DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, dim4, 0);
				delete[] doubleArray;
				checkStatus(status);
				if (status) return status;
			</xsl:when>
			<xsl:when test="@name='array4dint_type'">
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				dim3 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				dim4 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
				intArray = new int[dim1*dim2*dim3*dim4];
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; dim3; _k++)
				for(_l = 0; _l &lt; dim4; _l++)
				intArray[_i+_j*dim1+_k*dim1*dim2+_l*dim1*dim2*dim3] = array(0).<xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k, _l); 
				status = putVect4DInt(expIdx, path, "<xsl:value-of select="@path"/>", intArray, dim1, dim2, dim3, dim4, 0);
				delete[] intArray;
				checkStatus(status);
				if (status) return status;
			</xsl:when>
			<!--========== 5D arrays ==========-->
			<xsl:when test="@data_type='FLT_5D'">
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				dim3 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				dim4 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
				dim5 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(4);
				doubleArray = new double[dim1*dim2*dim3*dim4*dim5];
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; dim3; _k++)
				for(_l = 0; _l &lt; dim4; _l++)
				for(_m = 0; _m &lt; dim5; _m++)
				doubleArray[_i+_j*dim1+_k*dim1*dim2+_l*dim1*dim2*dim3+_m*dim1*dim2*dim3*dim4] = array(0).<xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k, _l, _m); 
				status = putVect5DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, dim4, dim5, 0);
				delete[] doubleArray;
				checkStatus(status);
				if (status) return status;
			</xsl:when>
			<xsl:when test="@name='array5ddbl_type'">
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				dim3 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				dim4 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
				dim5 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(4);
				doubleArray = new double[dim1*dim2*dim3*dim4*dim5];
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; dim3; _k++)
				for(_l = 0; _l &lt; dim4; _l++)
				for(_m = 0; _m &lt; dim5; _m++)
				doubleArray[_i+_j*dim1+_k*dim1*dim2+_l*dim1*dim2*dim3+_m*dim1*dim2*dim3*dim4] = array(0).<xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k, _l, _m); 
				status = putVect5DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, dim4, dim5, 0);
				delete[] doubleArray;
				checkStatus(status);
				if (status) return status;
			</xsl:when>
			<xsl:when test="@name='array5dint_type'">
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				dim3 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				dim4 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
				dim5 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(4);
				intArray = new int[dim1*dim2*dim3*dim4*dim5];
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; dim3; _k++)
				for(_l = 0; _l &lt; dim4; _l++)
				for(_m = 0; _m &lt; dim5; _m++)
				intArray[_i+_j*dim1+_k*dim1*dim2+_l*dim1*dim2*dim3+_m*dim1*dim2*dim3*dim4] = array(0).<xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k, _l, _m); 
				status = putVect5DInt(expIdx, path, "<xsl:value-of select="@path"/>", intArray, dim1, dim2, dim3, dim4, dim5, 0);
				delete[] intArray;
				checkStatus(status);
				if (status) return status;
			</xsl:when>
			<!--========== 6D arrays ==========-->
			<xsl:when test="@data_type='FLT_6D'">
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				dim3 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				dim4 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
				dim5 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(4);
				dim6 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(5);
				doubleArray = new double[dim1*dim2*dim3*dim4*dim5*dim6];
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; dim3; _k++)
				for(_l = 0; _l &lt; dim4; _l++)
				for(_m = 0; _m &lt; dim5; _m++)
				for(_n = 0; _n &lt; dim6; _n++)
				doubleArray[_i+_j*dim1+_k*dim1*dim2+_l*dim1*dim2*dim3+_m*dim1*dim2*dim3*dim4+_n*dim1*dim2*dim3*dim4*dim5] = array(0).<xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k, _l, _m, _n); 
				status = putVect6DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, dim4, dim5, dim6, 0);
				delete[] doubleArray;
				checkStatus(status);
				if (status) return status;
			</xsl:when>
			<xsl:when test="@name='array6ddbl_type'">
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				dim3 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				dim4 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
				dim5 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(4);
				dim6 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(5);
				doubleArray = new double[dim1*dim2*dim3*dim4*dim5*dim6];
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; dim3; _k++)
				for(_l = 0; _l &lt; dim4; _l++)
				for(_m = 0; _m &lt; dim5; _m++)
				for(_n = 0; _n &lt; dim6; _n++)
				doubleArray[_i+_j*dim1+_k*dim1*dim2+_l*dim1*dim2*dim3+_m*dim1*dim2*dim3*dim4+_n*dim1*dim2*dim3*dim4*dim5] = array(0).<xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k, _l, _m, _n); 
				status = putVect6DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, dim4, dim5, dim6, 0);
				delete[] doubleArray;
				checkStatus(status);
				if (status) return status;
			</xsl:when>
			<xsl:when test="@name='array6dint_type'">
				dim1 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
				dim2 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
				dim3 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
				dim4 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
				dim5 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(4);
				dim6 = array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(5);
				intArray = new int[dim1*dim2*dim3*dim4*dim5*dim6];
				for(_i = 0; _i &lt; dim1; _i++)
				for(_j = 0; _j &lt; dim2; _j++)
				for(_k = 0; _k &lt; dim3; _k++)
				for(_l = 0; _l &lt; dim4; _l++)
				for(_m = 0; _m &lt; dim5; _m++)
				for(_n = 0; _n &lt; dim6; _n++)
				intArray[_i+_j*dim1+_k*dim1*dim2+_l*dim1*dim2*dim3+_m*dim1*dim2*dim3*dim4+_n*dim1*dim2*dim3*dim4*dim5] = array(0).<xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k, _l, _m, _n); 
				status = putVect6DInt(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, dim4, dim5, dim6, 0);
				delete[] intArray;
				checkStatus(status);
				if (status) return status;
			</xsl:when>
			<!--========== Arrays of structures ==========-->
			<xsl:when test="@data_type='struct_array'">
				{ /*     4Array of structure    */
				char fullpath[1024]; sprintf(fullpath,"%s/<xsl:value-of select="@path"/>",path);
				void *obj1 = beginObject(expIdx,NULL,0,fullpath,NON_TIMED);
				for (int i1 = 0; i1 &lt; array(0).<xsl:value-of select="translate(@path,'/','.')"/>.extent(0); i1++) {
				<xsl:apply-templates select="field" mode="PUT_IN_OBJECT">
					<xsl:with-param name="level" select="1"/>
					<xsl:with-param name="objpath" select="@name"/>
					<xsl:with-param name="idxpath" select="concat('array(0).',translate(@path,'/','.'),'(i1)')"/>
					<xsl:with-param name="timed" select="'no'"/>
				</xsl:apply-templates>
				}
				status = putObject(expIdx, path, "<xsl:value-of select="@path"/>", obj1, NON_TIMED);
				checkStatus(status);
				if (status) return status;
				}
			</xsl:when>
			<!--========== Regular structures ==========-->
			<xsl:when test="@data_type='structure'">
				<xsl:apply-templates select="field" mode="PUT_TIMED"/>
			</xsl:when>
		</xsl:choose>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--   -->
<!--!!!!!!!!!!!!!!!!!!!!!!!!!        GET_SLICE for FIELDS       !!!!!!!!!!!!!!!!!!!!!!!!!!!!! -->
<!-- GET_SLICE -->
<xsl:template match="field" mode="GET_SLICE">
<xsl:param name="variable_path"/>
<xsl:param name="mds_path"/>
<xsl:choose>
	<xsl:when test="@data_type='structure'">
		<xsl:choose>
			<xsl:when test="$variable_path">
				<xsl:apply-templates select="field" mode="GET_SLICE">
					<xsl:with-param name="variable_path" select="concat($variable_path,'.',@name)"/>
					<xsl:with-param name="mds_path" select="concat($mds_path,'+ string(&quot;/',@name,'&quot;)')"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="field" mode="GET_SLICE">
					<xsl:with-param name="variable_path" select="@name"/>
					<xsl:with-param name="mds_path" select="concat('&quot;',@name,'&quot;')"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>

	<xsl:when test="@data_type='struct_array' and @maxoccur!='unbounded'">
    <!-- Type 1 arrays of structure, with potentially multiple time bases -->// Get_slice <xsl:value-of select="@path"/>
		<xsl:choose>
			<xsl:when test="$variable_path">
				lepath = <xsl:value-of select="$mds_path"/>  + string("/<xsl:value-of select="@name"/>/Shape_of");
				clepath = const_cast&lt;char *&gt; (lepath.c_str());
				status= getInt(expIdx,path, clepath,&amp;int0d);
				checkStatus(status);
				if (status == 0) {
				<xsl:value-of select="concat($variable_path,'.',@name)"/>.resize(int0d);
				for (i<xsl:value-of select="@name"/>=0; i<xsl:value-of select="@name"/>&lt;<xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0); i<xsl:value-of select="@name"/>++) {
				<xsl:apply-templates select="field" mode="GET_SLICE">
					<xsl:with-param name="variable_path" select="concat($variable_path,'.',@name,'(i',@name,')')"/>
					<xsl:with-param name="mds_path" select="concat($mds_path,'+','string(&quot;/',@name,'/&quot;) + int2str(i',@name,',1)')"/>
				</xsl:apply-templates>
				}
				}
			</xsl:when>
			<xsl:otherwise>
				status= getInt(expIdx,path, "<xsl:value-of select="@name"/>/Shape_of",&amp;int0d);
				if (status == 0) {
				<xsl:value-of select="@name"/>.resize(int0d);
				for( i<xsl:value-of select="@name"/>=0; i<xsl:value-of select="@name"/> &lt;<xsl:value-of select="@name"/>.extent(0); i<xsl:value-of select="@name"/>++) {
				<xsl:apply-templates select="field" mode="GET_SLICE">
					<xsl:with-param name="variable_path" select="concat(@name,'(i',@name,')')"/>
					<xsl:with-param name="mds_path" select="concat('&quot;',@name,'/&quot; + int2str(i',@name,',1)')"/>
				</xsl:apply-templates>
				}
				}
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>


  <xsl:when test="@data_type='struct_array' and @maxoccur='unbounded' and @type='dynamic'">
  <!-- Type 3 arrays of structure, with a unique time base -->
  <xsl:choose>
  <xsl:when test="$variable_path">
  // Structure array of type 3 nested below a Type 1 : <xsl:value-of select = "concat($variable_path,'.%',@name)"/>
   { /*     11 jul  */
   void *obj_single_time;
   void *obj1;
   lepath=<xsl:value-of select = "concat($mds_path,'+&quot;/',@name,'&quot;')"/>; 
   clepath = const_cast&lt;char *&gt; (lepath.c_str());
   status = getObjectSlice(expIdx, path, clepath, inTime, &amp;obj_single_time);
   checkStatus(status);
   if (!status) {
   status = getObjectFromObject(expIdx,obj_single_time,"ALLTIMES",0,&amp;obj1);
   checkStatus(status);
   if (!status) {
     <xsl:value-of select = "concat($variable_path,'.',@name)"/>.resize(1);
     <xsl:apply-templates select = "field" mode = "GET_FROM_OBJECT">
     <xsl:with-param name="level" select="1"/>
     <xsl:with-param name="objpath" select="@name"/>
     <xsl:with-param name="idxpath" select="concat($variable_path,'.',@name,'(0)')"/>
     <xsl:with-param name="timed" select="'yes'"/>
   </xsl:apply-templates>
   }
    releaseObject(expIdx,obj_single_time);
  }
 } 
</xsl:when>
<xsl:otherwise>
  { /* H2 */
   void *obj_single_time;
   void *obj1;
 // Structure array of type 3 : <xsl:value-of select = "@path"/>
 status = getObjectSlice(expIdx, path, "<xsl:value-of select = "@path"/>", inTime, &amp;obj_single_time);
 checkStatus(status);
 if (!status) {
 status = getObjectFromObject(expIdx,obj_single_time,"ALLTIMES",0,&amp;obj1);
 <xsl:value-of select="translate(@path,'/','.')"/>.resize(1);
 <xsl:apply-templates select = "field" mode = "GET_FROM_OBJECT">
 <xsl:with-param name="level" select="1"/>
 <xsl:with-param name="objpath" select="@name"/>
 <xsl:with-param name="idxpath" select="concat(translate(@path,'/','.'),'(0)')"/>
 <xsl:with-param name="timed" select="'yes'"/>
 </xsl:apply-templates>
 }
 releaseObject(expIdx,obj_single_time);
 }
 </xsl:otherwise>
 </xsl:choose>
  </xsl:when>

	<xsl:when test="@type='dynamic'">
		//Doc GetSlice2 <xsl:value-of select="@path"/>
		<xsl:choose>
			<xsl:when test="$variable_path">
				if (ids_properties.homogeneous_time == 0) {
				<xsl:choose>
					<xsl:when test="(@name='data' and ../field[@name='time']) or (@name='time' and ../field[@name='data'])">
						timebasepath=<xsl:value-of select="$mds_path"/>+string("/time");
					</xsl:when>
					<xsl:otherwise>
						timebasepath="<xsl:call-template name="printtimepath"/>";
					</xsl:otherwise>
				</xsl:choose>
				}  else  {
				timebasepath="time";
				}
			</xsl:when>
			<xsl:otherwise>
				if (ids_properties.homogeneous_time == 0) {
				timebasepath="<xsl:call-template name="printtimepath"/>";
				} else 
				timebasepath="time";
			</xsl:otherwise>
		</xsl:choose>

		<xsl:choose>   
			<xsl:when test="@data_type='str_1d_type' or @data_type='STR_1D'">
				//Doc GetSlice2 <xsl:value-of select="@path"/>
				<xsl:choose>
					<xsl:when test="$variable_path">
						lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
						clepath = const_cast&lt;char *&gt; (lepath.c_str());
						getDimension(expIdx, path, clepath, &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
						if (dim1 &gt; 0) {
						status = getStringSlice(expIdx, path, clepath, (char *)timebasepath.c_str(),&amp;str, inTime, &amp;retTime, interpolMode);
						checkStatus(status);
						if(!status) 
						{
						//   setArray(<xsl:value-of select="concat($variable_path,'.',@name)"/>, str,dim1);
						<xsl:value-of select="concat($variable_path,'.',@name)"/>(0).assign(str);
						free(str);
						}
						}
					</xsl:when>
					<xsl:otherwise>
						getDimension(expIdx, path,"<xsl:value-of select="@name"/>", &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
						if (dim1 &gt; 0) {
						status = getStringSlice(expIdx, path, "<xsl:value-of select="@name"/>", (char *)timebasepath.c_str(),&amp;str, inTime, &amp;retTime, interpolMode);
						checkStatus(status);
						if(!status) 
						{
						<xsl:value-of select="@name"/>(0).assign(str);
						free(str);
						}
						}
					</xsl:otherwise>
				</xsl:choose>
				<!-- -->
			</xsl:when>
			<xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">
				//Doc GetSlice2 <xsl:value-of select="@path"/>
				<xsl:choose>
					<xsl:when test="$variable_path">
						lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
						clepath = const_cast&lt;char *&gt; (lepath.c_str());
						getDimension(expIdx, path, clepath, &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
						if (dim1 &gt; 0) {
						<xsl:value-of select="concat($variable_path,'.',@name)"/>.resize(1);
						status = getDoubleSlice(expIdx, path, clepath, (char *)timebasepath.c_str(), &amp;<xsl:value-of select="concat($variable_path,'.',@name)"/>(0) , inTime, &amp;retTime, interpolMode);
						checkStatus(status);
						}
					</xsl:when>
					<xsl:otherwise>
						getDimension(expIdx, path,"<xsl:value-of select="@path"/>", &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
						if (dim1 &gt; 0) {
						<xsl:value-of select="translate(@path,'/','.')"/>.resize(1);
						status = getDoubleSlice(expIdx, path, "<xsl:value-of select="@path"/>", (char *)timebasepath.c_str(), &amp;<xsl:value-of select="translate(@path,'/','.')"/>(0) , inTime, &amp;retTime, interpolMode);
						checkStatus(status);
						}
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<xsl:when test="@data_type='int_1d_type' or @data_type='INT_1D'">
				//Doc GetSlicie2 <xsl:value-of select="@path"/>
				<xsl:choose>
					<xsl:when test="$variable_path">
						lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
						clepath = const_cast&lt;char *&gt; (lepath.c_str());
						getDimension(expIdx, path, clepath, &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
						if (dim1 &gt; 0) {		
						<xsl:value-of select="concat($variable_path,'.',@name)"/>.resize(1);
						status = getIntSlice(expIdx, path, clepath, (char *)timebasepath.c_str(), &amp;<xsl:value-of select="concat($variable_path,'.',@name)"/>(0), inTime, &amp;retTime, interpolMode);
						checkStatus(status);
						}
					</xsl:when>
					<xsl:otherwise>
						getDimension(expIdx, path,"<xsl:value-of select="@path"/>", &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
						if (dim1 &gt; 0) {
						<xsl:value-of select="translate(@path,'/','.')"/>.resize(1);
						status = getIntSlice(expIdx, path,"<xsl:value-of select="@path"/>" , (char *)timebasepath.c_str(), &amp;<xsl:value-of select="translate(@path,'/','.')"/>(0), inTime, &amp;retTime, interpolMode);
						checkStatus(status);
						}
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<xsl:when test="@data_type='FLT_2D'">
				//Doc GetSlice2 <xsl:value-of select="@path"/>
				<xsl:choose>
					<xsl:when test="$variable_path">
						lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
						clepath = const_cast&lt;char *&gt; (lepath.c_str());
						getDimension(expIdx, path, clepath, &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
						if (dim1 &gt; 0) {		  
						//<xsl:value-of select="concat($variable_path,'.',@name)"/>.resize(dim1,1); 
						status = getVect1DDoubleSlice(expIdx, path, clepath, (char *)timebasepath.c_str(), &amp;doubleArray, &amp;dim1, inTime, &amp;retTime, interpolMode);
						checkStatus(status);
						if(!status)  {
						setArray(<xsl:value-of select="concat($variable_path,'.',@name)"/>,doubleArray, dim1,1);
						//    time = retTime;
						free(doubleArray);
						}
						}
					</xsl:when>
					<xsl:otherwise>
						getDimension(expIdx, path,"<xsl:value-of select="@path"/>", &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
						if (dim1 &gt; 0) {		  
						status = getVect1DDoubleSlice(expIdx, path, "<xsl:value-of select="@path"/>", (char *)timebasepath.c_str(), &amp;doubleArray, &amp;dim1, inTime, &amp;retTime, interpolMode);
						checkStatus(status);
						if(!status)  {
						setArray(<xsl:value-of select="translate(@path,'/','.')"/>,doubleArray, dim1,1);
						//    time = retTime;
						free(doubleArray);
						}
						}
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="@data_type='INT_2D'">
				//Doc GetSlice2 <xsl:value-of select="@path"/>
				<xsl:choose>
					<xsl:when test="$variable_path">
						lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
						clepath = const_cast&lt;char *&gt; (lepath.c_str());
						getDimension(expIdx, path, clepath, &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
						if (dim1 &gt; 0) {		  
						status = getVect1DIntSlice(expIdx, path, clepath,(char *)timebasepath.c_str(), &amp;intArray, &amp;dim1, inTime, &amp;retTime, interpolMode);
						checkStatus(status);
						if(!status) {
						//      time = retTime;
						setArray(<xsl:value-of select="concat($variable_path,'.',@name)"/>,intArray, dim1,1);
						free(intArray);
						}
						}
					</xsl:when>
					<xsl:otherwise>
						getDimension(expIdx, path,"<xsl:value-of select="@path"/>", &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
						if (dim1 &gt; 0) {		  
						status = getVect1DIntSlice(expIdx, path, "<xsl:value-of select="@path"/>",(char *)timebasepath.c_str(), &amp;intArray, &amp;dim1, inTime, &amp;retTime, interpolMode);
						checkStatus(status);
						if(!status) {
						//      time = retTime;
						setArray(<xsl:value-of select="translate(@path,'/','.')"/>,intArray, dim1,1);
						free(intArray);
						}
						}
					</xsl:otherwise>
				</xsl:choose>
				<!-- -->
			</xsl:when>
			<xsl:when test="@data_type='FLT_3D'">
				//Doc GetSlice2 <xsl:value-of select="@path"/>
				<xsl:choose>
					<xsl:when test="$variable_path">
						lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
						<!--  clepath = new char[lepath.size()+1];
strcpy(clepath, lepath.c_str());-->
						clepath = const_cast&lt;char *&gt; (lepath.c_str());
						getDimension(expIdx, path, clepath,&amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
						if (dim1 &gt; 0) {
						status = getVect2DDoubleSlice(expIdx, path, clepath,  (char *)timebasepath.c_str(),&amp;doubleArray, &amp;dim1, &amp;dim2, inTime, &amp;retTime, interpolMode);
						checkStatus(status);
						if(!status) {
						//      time = retTime;
						setArray(<xsl:value-of select="concat($variable_path,'.',@name)"/>,doubleArray, dim1, dim2,1);
						free(doubleArray);
						}
						}
						<!--  delete[] clepath; -->
					</xsl:when>
					<xsl:otherwise>
						getDimension(expIdx, path,"<xsl:value-of select="@path"/>", &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
						if (dim1 &gt; 0) {
						status = getVect2DDoubleSlice(expIdx, path, "<xsl:value-of select="@path"/>", (char *)timebasepath.c_str(),&amp;doubleArray, &amp;dim1, &amp;dim2, inTime, &amp;retTime, interpolMode);
						checkStatus(status);
						if(!status) {
						//        time = retTime;
						setArray(<xsl:value-of select="translate(@path,'/','.')"/>,doubleArray, dim1, dim2,1);
						free(doubleArray);
						}
						}		
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>			
			<xsl:when test="@data_type='INT_3D'">
				//Doc GetSlice2 <xsl:value-of select="@path"/>
				<xsl:choose>
					<xsl:when test="$variable_path">
						lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
						clepath = const_cast&lt;char *&gt; (lepath.c_str());
						getDimension(expIdx, path, clepath, &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
						if (dim1 &gt; 0) {
						status = getVect2DIntSlice(expIdx, path, clepath,(char *)timebasepath.c_str(), &amp;intArray, &amp;dim1, &amp;dim2, inTime, &amp;retTime, interpolMode);
						checkStatus(status);
						if(!status) {
						//    time = retTime;
						setArray(<xsl:value-of select="concat($variable_path,'.',@name)"/>,intArray, dim1, dim2,1);
						free(intArray);
						}
						}
					</xsl:when>
					<xsl:otherwise>
						getDimension(expIdx, path,"<xsl:value-of select="@path"/>", &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
						if (dim1 &gt; 0) {
						status = getVect2DIntSlice(expIdx, path, "<xsl:value-of select="@path"/>",(char *)timebasepath.c_str(), &amp;intArray, &amp;dim1, &amp;dim2, inTime, &amp;retTime, interpolMode);
						checkStatus(status);
						if(!status) {
						//     time = retTime;
						setArray(<xsl:value-of select="translate(@path,'/','.')"/>,intArray, dim1, dim2,1);
						free(intArray);
						}
						}
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="@data_type='FLT_4D'">
				//Doc GetSlice2 <xsl:value-of select="@path"/>
				<xsl:choose>
					<xsl:when test="$variable_path">
						lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
						clepath = const_cast&lt;char *&gt; (lepath.c_str());
						getDimension(expIdx, path, clepath,&amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
						if (dim1 &gt; 0) {
						status = getVect3DDoubleSlice(expIdx, path, clepath, (char *)timebasepath.c_str(),&amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, inTime, &amp;retTime, interpolMode);
						checkStatus(status);
						if(!status) {
						//         time = retTime;
						setArray(<xsl:value-of select="concat($variable_path,'.',@name)"/>,doubleArray, dim1, dim2, dim3,1);
						free(doubleArray);
						}
						}
					</xsl:when>
					<xsl:otherwise>	
						getDimension(expIdx, path, "<xsl:value-of select="@path"/>",&amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
						if (dim1 &gt; 0) {
						status = getVect3DDoubleSlice(expIdx, path, "<xsl:value-of select="@path"/>", (char *)timebasepath.c_str(),&amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, inTime, &amp;retTime, interpolMode);
						checkStatus(status);
						if(!status) {
						//      time = retTime;
						setArray(<xsl:value-of select="translate(@path,'/','.')"/>,doubleArray, dim1, dim2, dim3, 1);
						free(doubleArray);
						}
						}
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when> 
			<xsl:when test="@data_type='FLT_5D'">
				//Doc GetSlice2 <xsl:value-of select="@path"/>
				<xsl:choose>
					<xsl:when test="$variable_path">
						lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
						clepath = const_cast&lt;char *&gt; (lepath.c_str());
						getDimension(expIdx, path, clepath, &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
						if (dim1 &gt; 0) {
						status = getVect4DDoubleSlice(expIdx, path, clepath,(char *)timebasepath.c_str(), &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, inTime, &amp;retTime, interpolMode);
						checkStatus(status);
						if(!status) {
						//      time = retTime;
						setArray(<xsl:value-of select="concat($variable_path,'.',@name)"/>,doubleArray, dim1, dim2, dim3, dim4,1);
						free(doubleArray);
						}
						}
					</xsl:when>
					<xsl:otherwise>	
						getDimension(expIdx, path, "<xsl:value-of select="@path"/>",&amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
						if (dim1 &gt; 0) {
						status = getVect4DDoubleSlice(expIdx, path, "<xsl:value-of select="@path"/>",(char *)timebasepath.c_str(), &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, inTime, &amp;retTime, interpolMode);
						checkStatus(status);
						if(!status) {
						//       time = retTime;
						setArray(<xsl:value-of select="translate(@path,'/','.')"/>,doubleArray, dim1, dim2, dim3, dim4,1);
						free(doubleArray);
						}
						}
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="@data_type='FLT_6D'">
				//Doc GetSlice2 <xsl:value-of select="@path"/>
				<xsl:choose>
					<xsl:when test="$variable_path">
						lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
						clepath = const_cast&lt;char *&gt; (lepath.c_str());
						getDimension(expIdx, path, clepath, &amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
						if (dim1 &gt; 0) {
						status = getVect5DDoubleSlice(expIdx, path, clepath,(char *)timebasepath.c_str(), &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5, inTime, &amp;retTime, interpolMode);
						checkStatus(status);
						if(!status) {
						//        time = retTime;
						setArray(<xsl:value-of select="concat($variable_path,'.',@name)"/>,doubleArray, dim1, dim2, dim3, dim4, dim5,1);
						free(doubleArray);
						}
						}
					</xsl:when>
					<xsl:otherwise>	
						getDimension(expIdx, path, "<xsl:value-of select="@path"/>",&amp;numDims, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4,&amp; dim5, &amp;dim6, &amp;dim7);
						if (dim1 &gt; 0) {
						status = getVect5DDoubleSlice(expIdx, path, "<xsl:value-of select="@path"/>",(char *)timebasepath.c_str(), &amp;doubleArray, &amp;dim1, &amp;dim2, &amp;dim3, &amp;dim4, &amp;dim5, inTime, &amp;retTime, interpolMode);
						checkStatus(status);
						if(!status) {
						//       time = retTime;
						setArray(<xsl:value-of select="translate(@path,'/','.')"/>,doubleArray, dim1, dim2, dim3, dim4, dim5, 1);
						free(doubleArray);
						}
					</xsl:otherwise>
				</xsl:choose>
				<!-- -->	
			</xsl:when>					

			<xsl:otherwise>
				//Doc GetSlice2 <xsl:value-of select="@path"/> : PROBLEM : UNIDENTIFIED TYPE !!! <!-- for comment only -->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:otherwise>
		<!-- Get the data from a time-independent field is the same procedure as GET_SINGLE -->
		<xsl:apply-templates select="." mode="GET_SINGLE">
			<xsl:with-param name="variable_path" select="$variable_path"/>
			<xsl:with-param name="mds_path" select="$mds_path"/>
		</xsl:apply-templates>
	</xsl:otherwise>
</xsl:choose>

</xsl:template>

<!--=================================================-->
<!--              put field into a slice             -->
<!--=================================================-->
<xsl:template match="field" mode="PUT_SLICE">
<xsl:param name="variable_path"/>
<xsl:param name="mds_path"/>
<xsl:if test="@type ='dynamic' or @data_type='structure' or @data_type='struct_array'">
	<xsl:choose>
		<!--========== Regular structures ==========-->
		<xsl:when test="@data_type='structure'">
			<xsl:choose>
				<xsl:when test="$variable_path">
					<xsl:apply-templates select="field" mode="PUT_SLICE">
						<xsl:with-param name="variable_path" select="concat($variable_path,'.',@name)"/>
						<xsl:with-param name="mds_path" select="concat($mds_path,'+string(&quot;/',@name,'&quot;)')"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="field" mode="PUT_SLICE">
						<xsl:with-param name="variable_path" select="@name"/>
						<xsl:with-param name="mds_path" select="concat('&quot;',@name,'&quot;')"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>          
		<!--========== Arrays of structures ==========-->
    <xsl:when test="@data_type='struct_array' and @maxoccur!='unbounded'">
       <!-- Type 1 arrays of structure, with potentially multiple time bases -->
			//Doc Put <xsl:value-of select="@path"/>
			<xsl:choose>
				<xsl:when test="$variable_path">
          //H4if(<xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0) > 0) 

     if ( <xsl:value-of select = "concat($variable_path,'.',@name)"/>.extent(0) &gt; 0) {
					lepath = <xsl:value-of select="$mds_path"/>  + string("/<xsl:value-of select="@name"/>/Shape_of");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					status = putInt(expIdx,path,clepath,<xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0));
					checkStatus(status);
					if (status) return status;
					for (i<xsl:value-of select="@name"/> = 0;i<xsl:value-of select="@name"/>&lt;<xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0); i<xsl:value-of select="@name"/>++){  
					<xsl:apply-templates select="field" mode="PUT_SLICE">
						<xsl:with-param name="variable_path" select="concat($variable_path,'.',@name,'(i',@name,')')"/>
						<xsl:with-param name="mds_path" select="concat($mds_path,' + ','string(&quot;/',@name,'/&quot;) + int2str(i',@name,',1)')"/>
					</xsl:apply-templates>
					}
       }
				</xsl:when>
				<xsl:otherwise>
          if ( <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0) &gt; 0) {
					lepath =  "<xsl:value-of select="@name"/>/Shape_of";
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					status = putInt(expIdx,path, clepath, <xsl:value-of select="@name"/>.extent(0));
					checkStatus(status);
					if (status) return status;
					for ( i<xsl:value-of select="@name"/> = 0;i<xsl:value-of select="@name"/>&lt;<xsl:value-of select="@name"/>.extent(0);i<xsl:value-of select="@name"/>++){
					<xsl:apply-templates select="field" mode="PUT_SLICE">
						<xsl:with-param name="variable_path" select="concat(@name,'(i',@name,')')"/>
						<xsl:with-param name="mds_path" select="concat('&quot;',@name,'/&quot; + int2str(i',@name,',1)')"/>
					</xsl:apply-templates>
					}
        } 
				</xsl:otherwise>
			</xsl:choose>
    </xsl:when>
    <xsl:when test="@data_type='struct_array' and @maxoccur='unbounded' and @type='dynamic'">
    <!-- Type 3 arrays of structure, with a unique time base -->
    <xsl:choose>
    <xsl:when test="$variable_path">
     // Structure array of type 3 nested below a Type 1 : <xsl:value-of select = "concat($variable_path,'1',@name)"/>
     if ( <xsl:value-of select = "concat($variable_path,'.',@name)"/>.extent(0) &gt; 0) { 
      lepath = "path<xsl:value-of select="concat('/',substring($mds_path,2))"/> + string("/<xsl:value-of select="@name"/>");
      clepath = const_cast&lt;char *&gt; (lepath.c_str());
      void *obj_single_time = beginObject(expIdx,(void *) -1,0,clepath,TIMED);
      void *obj1 = beginObject(expIdx,obj_single_time,0,"ALLTIMES",TIMED);
      <xsl:apply-templates select = "field" mode = "PUT_IN_OBJECT">
      <xsl:with-param name="level" select="1"/>
      <xsl:with-param name="objpath" select="@name"/>
      <xsl:with-param name="idxpath" select="concat($variable_path,'.',@name,'(0)')"/>
      <xsl:with-param name="child_index" select="0"/>
      </xsl:apply-templates>
      obj_single_time = putObjectInObject(expIdx, obj_single_time, "ALLTIMES", 0, obj1);
      //H7
      lepath = <xsl:value-of select = "concat($mds_path, ' + &quot;/', @name)"/>";
      clepath = const_cast&lt;char *&gt; (lepath.c_str());
      status = putObjectSlice(expIdx, path, clepath, time(0), obj_single_time);
      checkStatus(status);
      if (status) return status;
       // Store time of the array of structure (hidden variable for the user, but used by the UAL for future get_slice operations)
       // A temporary "time" vector is filled then put as a regular variable (outside of the object) as AoS%time
       double *timeh = new double[1];
       if (<xsl:value-of select = "concat($variable_path,'.',@name)"/>(0).time == EMPTY_DOUBLE) {
  // Check the presence of a time vector at the root of the  AoS (on the first index only)
 if (ids_properties.homogeneous_time == 1) {
  timeh[0] = time(0);
  }
  else {
  puts("ERROR : the time vector of the type 3 array of structure <xsl:value-of select = "translate(@path,'/','.')"/> must be filled");
  return (-1);
  }
  }
  else {

  //H5
   for( int i1 = 0; i1 &lt;<xsl:value-of select = "concat($variable_path,'.',@name)"/>.extent(0); i1++){// the AoS time vector is there, fill tim     e with it
   timeh[i1] = <xsl:value-of select = "concat($variable_path,'.',@name)"/>(i1).time;
  }
  }
  timebasepath = <xsl:value-of select="$mds_path"/> + string("/<xsl:value-of select="@name"/>/time"); //Start to put time
  status = putDoubleSlice(expIdx, path, (char *)timebasepath.c_str(), (char *)timebasepath.c_str(), time(0), time(0));
  checkStatus(status);
  if (status) return status;
  }
</xsl:when>
<xsl:otherwise>
  // Structure array of type 3 : <xsl:value-of select = "@path"/>
  char fullpath[1024];
      if (<xsl:value-of select = "translate(@path,'/','.')"/>.extent(0) &gt; 0) {
       sprintf(fullpath,"%s/<xsl:value-of select = "@path"/>",path);
      void *obj_single_time = beginObject(expIdx,(void *) -1,0,fullpath,TIMED);
      void *obj1 = beginObject(expIdx,obj_single_time,0,"ALLTIMES",TIMED);
      <xsl:apply-templates select = "field" mode = "PUT_IN_OBJECT">
      <xsl:with-param name="level" select="1"/>
      <xsl:with-param name="objpath" select="@name"/>
      <xsl:with-param name="idxpath" select="concat(translate(@path,'/','.'),'(0)')"/>
      <xsl:with-param name="child_index" select="0"/>
      </xsl:apply-templates>

      obj_single_time = putObjectInObject(expIdx, obj_single_time, "ALLTIMES", 0, obj1);
      status = putObjectSlice(expIdx, path, "<xsl:value-of select = "@path"/>", time(0), obj_single_time);
      checkStatus(status);
      if (status) return status;
       // Store time of the array of structure (hidden variable for the user, but used by the UAL for future get_slice operations)
       double* timeh = new double(1);
  //H6
       if (<xsl:value-of select = "translate(@path,'/','.')"/>(0).time == EMPTY_DOUBLE) { 
      if (ids_properties.homogeneous_time == 1) {
           timeh[0] = time(0); // Use the general time vector of the IDS to fill time
      }
      else {
      puts("ERROR : the time vector of the type 3 array of structure <xsl:value-of select = "translate(@path,'/','.')"/> must be filled");
      return(-1);
      }
      }
      else {
      for (int i1 = 0; i1 &lt; <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0); i1++){ // the AoS time vector is there, fill time with it
      timeh[i1]=<xsl:value-of select = "translate(@path,'/','.')"/>(i1).time;
      }
      }
      
     timebasepath=&quot;<xsl:call-template name="printtimepath"/>&quot;;
     status = putDoubleSlice(expIdx, path, (char *)timebasepath.c_str(), (char *)timebasepath.c_str(), time(0), time(0));
     checkStatus(status);
     if (status) return status;
     }
      </xsl:otherwise>
      </xsl:choose>

		</xsl:when>
		<!--========== Simple types ==========-->
		<xsl:when test="@data_type='str_1d_type' or @data_type='STR_1D'">
			//Doc! Put <xsl:value-of select="@path"/>
			<xsl:choose>
				<xsl:when test="$variable_path">
				        if(<xsl:value-of select="concat($variable_path,'.',@name)"/>.data()) {
					lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					status = putStringSlice(expIdx, path, clepath,(char *)timebasepath.c_str(), (char *)<xsl:value-of select="concat($variable_path,'.',@name)"/>.data(), time(0));
					checkStatus(status);
					if (status) return status;
					}
				</xsl:when>
				<xsl:otherwise>
					if()<xsl:value-of select="@name"/>,data()) {
					status= putStringSlice(expIdx,path, "<xsl:value-of select="@name"/>", (char *)timebasepath.c_str(),(char *)<xsl:value-of select="@name"/>,data(),time(0));
					checkStatus(status);
					if (status) return status;
					}
				</xsl:otherwise>
			</xsl:choose>
			<!-- -->
		</xsl:when>

		<xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">
			//Doc! PutSlice <xsl:value-of select="@path"/>
			<xsl:choose>
				<xsl:when test="$variable_path">
					lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					if(<xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0) >0 ){
					status = putDoubleSlice(expIdx, path, clepath, (char *)timebasepath.c_str(), <xsl:value-of select="concat($variable_path,'.',@name)"/>(0), time(0));
					checkStatus(status);
					if (status) return status;
					}
				</xsl:when>
				<xsl:otherwise>
					if(<xsl:value-of select="translate(@path,'/','.')"/>.extent(0) > 0){
					status = putDoubleSlice(expIdx, path, "<xsl:value-of select="@path"/>", (char *)timebasepath.c_str(), <xsl:value-of select="translate(@path,'/','.')"/>(0), time(0));
					checkStatus(status);
					if (status) return status;
					}
				</xsl:otherwise>
			</xsl:choose>
			<!-- -->
		</xsl:when>

		<xsl:when test="@data_type='int_1d_type' or @data_type='INT_1D'">
			//! PutSlice <xsl:value-of select="@path"/>
			<xsl:choose>
				<xsl:when test="$variable_path">
					lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					if( <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0) > 0) {
					status = putIntSlice(expIdx, path, clepath, (char *)timebasepath.c_str(), <xsl:value-of select="concat($variable_path,'.',@name)"/>(0), time(0));
					checkStatus(status);
					if (status) return status;
					}
				</xsl:when>
				<xsl:otherwise>
					if( <xsl:value-of select="translate(@path,'/','.')"/>.extent(0) > 0) {
					status = putIntSlice(expIdx, path, "<xsl:value-of select="@path"/>", (char *)timebasepath.c_str(),<xsl:value-of select="translate(@path,'/','.')"/>(0) , time(0));
					checkStatus(status);
					if (status) return status;
					}
				</xsl:otherwise>
			</xsl:choose>
			<!-- -->
		</xsl:when>
		<xsl:when test="@data_type='FLT_2D'">
			//Doc Put <xsl:value-of select="@path"/>
			<xsl:choose>
				<xsl:when test="$variable_path">
					lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					if( <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0) > 0) {
					dim1 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0);
					dim2 = 1;
					doubleArray = new double[dim1*dim2];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					doubleArray[_i+_j*dim1] = <xsl:value-of select="concat($variable_path,'.',@name)"/>(_i,_j);
					status = putVect1DDoubleSlice(expIdx, path, clepath, (char *)timebasepath.c_str(),doubleArray, dim1, time(0));
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
                                        }
				</xsl:when>
				<xsl:otherwise>
					if(<xsl:value-of select="translate(@path,'/','.')"/>.extent(0) > 0) {
					dim1 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					dim2 = 1;
					doubleArray = new double[dim1*dim2];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					doubleArray[_i+_j*dim1] = <xsl:value-of select="translate(@path,'/','.')"/>(_i,_j);
					status = putVect1DDoubleSlice(expIdx, path, "<xsl:value-of select="@path"/>", (char *)timebasepath.c_str(),doubleArray, dim1, time(0));
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
                                        }
				</xsl:otherwise>
			</xsl:choose>
			<!-- -->
		</xsl:when>

		<xsl:when test="@data_type='INT_2D'">
			//Doc Put <xsl:value-of select="@path"/>
			<xsl:choose>
				<xsl:when test="$variable_path">
					lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					if(<xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0) > 0) {
					dim1 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0);
					dim2=1;
					intArray = new int[dim1*dim2];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					intArray[_i+_j*dim1] = <xsl:value-of select="concat($variable_path,'.',@name)"/>(_i,_j);
					status = putVect1DIntSlice(expIdx, path, clepath, (char *)timebasepath.c_str(),intArray, dim1, time(0));
					delete[] intArray;
					checkStatus(status);
					if (status) return status;
                                        }
				</xsl:when>
				<xsl:otherwise>
					if(<xsl:value-of select="translate(@path,'/','.')"/>.extent(0) > 0) {
					dim1 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					dim2=1;
					intArray = new int[dim1*dim2];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					intArray[_i+_j*dim1] = <xsl:value-of select="translate(@path,'/','.')"/>(_i,_j);
					status = putVect1DIntSlice(expIdx, path, "<xsl:value-of select="@path"/>", (char *)timebasepath.c_str(),intArray, dim1, time(0));
					delete[] intArray;
					checkStatus(status);
					if (status) return status;
                                        }
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>

		<xsl:when test="@data_type='FLT_3D'">
			//Doc! Put <xsl:value-of select="@path"/>
			<xsl:choose>
				<xsl:when test="$variable_path">
					lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					if(<xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0) > 0) {
					dim1 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0);
					dim2 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(1);
					dim3 = 1;
					doubleArray = new double[dim1*dim2*dim3];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					for(_k = 0; _k &lt;  dim3; _k++)
					doubleArray[_i+_j*dim1+_k*dim1*dim2] = <xsl:value-of select="concat($variable_path,'.',@name)"/>(_i, _j, _k);
					status = putVect2DDoubleSlice(expIdx, path, clepath,(char *)timebasepath.c_str(), doubleArray, dim1, dim2, time(0));
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
                                        }
				</xsl:when>
				<xsl:otherwise>
					if(<xsl:value-of select = "translate(@path,'/','.')"/>.extent(0) > 0) {
					dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
					dim3 = 1;
					doubleArray = new double[dim1*dim2*dim3];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					for(_k = 0; _k &lt;  dim3; _k++)
					doubleArray[_i+_j*dim1+_k*dim1*dim2] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i, _j, _k);
					status = putVect2DDoubleSlice(expIdx, path, "<xsl:value-of select = "@path"/>",(char *)timebasepath.c_str(), doubleArray, dim1, dim2, time(0));
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
                                        }
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>

		<xsl:when test="@data_type='INT_3D'">
			//! Put <xsl:value-of select="@path"/>
			<xsl:choose>
				<xsl:when test="$variable_path">
					lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					if(<xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0) > 0) {
					dim1 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0);
					dim2 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(1);
					dim3 = 1;
					intArray = new int[dim1*dim2*dim3];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					for(_k = 0; _k &lt;  dim3; _k++)
					intArray[_i+_j*dim1+_k*dim1*dim2] = <xsl:value-of select="concat($variable_path,'.',@name)"/>(_i, _j, _k);
					status = putVect2DIntSlice(expIdx, path, clepath,(char *)timebasepath.c_str(), intArray, dim1, dim2, time(0));
					delete[] intArray;
					checkStatus(status);
					if (status) return status;
                                        }
				</xsl:when>
				<xsl:otherwise>
					if(<xsl:value-of select = "translate(@path,'/','.')"/>.extent(0) > 0) {
					dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
					dim3 = 1;
					intArray = new int[dim1*dim2*dim3];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					for(_k = 0; _k &lt;  dim3; _k++)
					intArray[_i+_j*dim1+_k*dim1*dim2] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i, _j, _k);
					status = putVect2DIntSlice(expIdx, path, "<xsl:value-of select = "@path"/>",(char *)timebasepath.c_str(), intArray, dim1, dim2, time(0));
					delete[] intArray;
					checkStatus(status);
					if (status) return status;
                                        }
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		
		<xsl:when test="@data_type='FLT_4D'">
			//! Put <xsl:value-of select="@path"/>
			<xsl:choose>
				<xsl:when test="$variable_path">
					lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					if(<xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0) > 0) {
					dim1 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0);
					dim2 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(1);
					dim3 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(2);
					dim4 = 1;
					doubleArray = new double[dim1*dim2*dim3*dim4];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					for(_k = 0; _k &lt;  dim3; _k++)
					for(_h = 0; _h &lt;  dim4; _h++)
					doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3] = <xsl:value-of select="concat($variable_path,'.',@name)"/>(_i, _j, _k, _h);
					status = putVect3DDoubleSlice(expIdx, path, clepath,(char *)timebasepath.c_str(), doubleArray, dim1, dim2, dim3, time(0));
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
                                        }
				</xsl:when>
				<xsl:otherwise>
					if(<xsl:value-of select = "translate(@path,'/','.')"/>.extent(0) > 0) {
					dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
					dim3 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(2);
					dim4 = 1;
					doubleArray = new double[dim1*dim2*dim3*dim4];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					for(_k = 0; _k &lt;  dim3; _k++)
					for(_h = 0; _h &lt;  dim4; _h++)
					doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i, _j, _k, _h);
					status = putVect3DDoubleSlice(expIdx, path, "<xsl:value-of select = "@path"/>", (char *)timebasepath.c_str(),doubleArray, dim1, dim2, dim3, time(0));
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
                                        }
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>

		<xsl:when test="@data_type='FLT_5D'">
			//! Put <xsl:value-of select="@path"/>
			<xsl:choose>
				<xsl:when test="$variable_path">
					lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					if(<xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0) > 0) {
					dim1 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0);
					dim2 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(1);
					dim3 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(2);
					dim4 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(3);
					dim5 = 1;
					doubleArray = new double[dim1*dim2*dim3*dim4*dim5];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					for(_k = 0; _k &lt;  dim3; _k++)
					for(_h = 0; _h &lt;  dim4; _h++)
					for(_l = 0; _l &lt;  dim5; _l++)
					doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4] = <xsl:value-of select="concat($variable_path,'.',@name)"/>(_i, _j, _k, _h, _l);
					status = putVect4DDoubleSlice(expIdx, path, clepath,(char *)timebasepath.c_str(), doubleArray, dim1, dim2, dim3, dim4, time(0));
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
                                        }
				</xsl:when>
				<xsl:otherwise>
					if(<xsl:value-of select = "translate(@path,'/','.')"/>.extent(0) > 0) {
					dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
					dim3 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(2);
					dim4 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(3);
					dim5 = 1;
					doubleArray = new double[dim1*dim2*dim3*dim4*dim5];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					for(_k = 0; _k &lt;  dim3; _k++)
					for(_h = 0; _h &lt;  dim4; _h++)
					for(_l = 0; _l &lt;  dim5; _l++)
					doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i, _j, _k, _h, _l);
					status = putVect4DDoubleSlice(expIdx, path, "<xsl:value-of select = "@path"/>", (char *)timebasepath.c_str(),doubleArray, dim1, dim2, dim3, dim4, time(0));
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
                                        }
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>

		<xsl:when test="@data_type='FLT_6D'">
			//! Put <xsl:value-of select="@path"/>
			<xsl:choose>
				<xsl:when test="$variable_path">
					lepath =  <xsl:value-of select="$mds_path"/>+string("/<xsl:value-of select="@name"/>");
					clepath = const_cast&lt;char *&gt; (lepath.c_str());
					if(<xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0) > 0) {
					dim1 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(0);
					dim2 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(1);
					dim3 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(2);
					dim4 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(3);
					dim5 = <xsl:value-of select="concat($variable_path,'.',@name)"/>.extent(4);
					dim6 = 1;
					doubleArray = new double[dim1*dim2*dim3*dim4*dim5*dim6];
					for(_i = 0; _i &lt;  dim1; _i++)
					for(_j = 0; _j &lt;  dim2; _j++)
					for(_k = 0; _k &lt;  dim3; _k++)
					for(_h = 0; _h &lt;  dim4; _h++)
					for(_l = 0; _l &lt;  dim5; _l++)
					for(_m = 0; _m &lt;  dim6; _m++)
					doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4+_m*dim1*dim2*dim3*dim4*dim5] = <xsl:value-of select="concat($variable_path,'.',@name)"/>(_i, _j, _k, _h, _l, _m);
					status = putVect5DDoubleSlice(expIdx, path, clepath,(char *)timebasepath.c_str(), doubleArray, dim1, dim2, dim3, dim4, dim5, time(0));
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
                                        }
				</xsl:when>
				<xsl:otherwise>
					if(<xsl:value-of select = "translate(@path,'/','.')"/>.extent(0) > 0) {
					dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
					dim3 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(2);
					dim4 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(3);
					dim5 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(4);
					dim6 = 1;
					doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4+_m*dim1*dim2*dim3*dim4*dim5] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i, _j, _k, _h, _l, _m);
					status = putVect5DDoubleSlice(expIdx, path, "<xsl:value-of select = "@path"/>",(char *)timebasepath.c_str(), doubleArray, dim1, dim2, dim3, dim4, dim5, time(0));
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
                                        }
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>			
	<!--  AAAAAAAA 
<xsl:when test="@data_type='int_type' or @data_type='INT_0D'">
if(<xsl:value-of select = "translate(@path,'/','.')"/> != EMPTY_INT)
status = putIntSlice(expIdx, path, "<xsl:value-of select="@path"/>", <xsl:value-of select = "translate(@path,'/','.')"/>, (double)time);
checkStatus(status);
if (status) return status;
</xsl:when>
<xsl:when test="@data_type='str_type' or @data_type='STR_0D'">
status = putStringSlice(expIdx, path, "<xsl:value-of select="@path"/>", (char *)<xsl:value-of select = "translate(@path,'/','.')"/>.data(), (double)time);
checkStatus(status);
if (status) return status;
</xsl:when>
<xsl:when test="@name='xs:boolean'">
if(<xsl:value-of select = "translate(@path,'/','.')"/> != EMPTY_INT)
status = putIntSlice(expIdx, path, "<xsl:value-of select="@path"/>", <xsl:value-of select = "translate(@path,'/','.')"/>, (double)time);
checkStatus(status);
if (status) return status;
</xsl:when>
<xsl:when test="@name='xs:double'">
if(<xsl:value-of select = "translate(@path,'/','.')"/> != EMPTY_DOUBLE)
status = putDoubleSlice(expIdx, path, "<xsl:value-of select="@path"/>", <xsl:value-of select = "translate(@path,'/','.')"/>, (double)time);
checkStatus(status);
if (status) return status;
</xsl:when>
<xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
if(<xsl:value-of select = "translate(@path,'/','.')"/> != EMPTY_DOUBLE)
status = putDoubleSlice(expIdx, path, "<xsl:value-of select="@path"/>", <xsl:value-of select = "translate(@path,'/','.')"/>, (double)time);
checkStatus(status);
if (status) return status;
</xsl:when>

========== Vectors ==========
<xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
doubleArray = new double[dim1];
for(_i = 0; _i &lt;  dim1; _i++)
doubleArray[_i] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i);
status = PUTVECT1DDOUBLESlice(expIdx, path, "<xsl:value-of select = "@path"/>", doubleArray, dim1, (double)time);
delete[] doubleArray;
checkStatus(status);
if (status) return status;
</xsl:when>
<xsl:when test="@name='vecdbl_type'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
doubleArray = new double[dim1];
for(_i = 0; _i &lt;  dim1; _i++)
doubleArray[_i] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i);
status = PUTVECT1DDOUBLESlice(expIdx, path, "<xsl:value-of select = "@path"/>", doubleArray, dim1, (double)time);
delete[] doubleArray;
checkStatus(status);
if (status) return status;
</xsl:when>
<xsl:when test="@data_type='int_1d_type' or @data_type='INT_1D'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
intArray = new int[dim1];
for(_i = 0; _i &lt;  dim1; _i++)
intArray[_i] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i);
status = PUTVECT1DINTSlice(expIdx, path, "<xsl:value-of select = "@path"/>", intArray, dim1, (double)time);
delete[] intArray;
checkStatus(status);
if (status) return status;
</xsl:when>

========== Matrices ==========
<xsl:when test="@data_type='FLT_2D'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
doubleArray = new double[dim1*dim2];
for(_i = 0; _i &lt;  dim1; _i++)
for(_j = 0; _j &lt;  dim2; _j++)
doubleArray[_i+_j*dim1] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i,_j);
status = putVect2DDoubleSlice(expIdx, path, "<xsl:value-of select = "@path"/>", doubleArray, dim1, dim2, (double)time);
delete[] doubleArray;
checkStatus(status);
if (status) return status;
</xsl:when>
<xsl:when test="@name='matdbl_type'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
doubleArray = new double[dim1*dim2];
for(_i = 0; _i &lt;  dim1; _i++)
for(_j = 0; _j &lt;  dim2; _j++)
doubleArray[_i+_j*dim1] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i,_j);
status = putVect2DDoubleSlice(expIdx, path, "<xsl:value-of select = "@path"/>", doubleArray, dim1, dim2, (double)time);
delete[] doubleArray;
checkStatus(status);
if (status) return status;
</xsl:when>
<xsl:when test="@data_type='INT_2D'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
intArray = new int[dim1*dim2];
for(_i = 0; _i &lt;  dim1; _i++)
for(_j = 0; _j &lt;  dim2; _j++)
intArray[_i+_j*dim1] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i,_j);
status = putVect2DIntSlice(expIdx, path, "<xsl:value-of select = "@path"/>", intArray, dim1, dim2, (double)time);
delete[] intArray;
checkStatus(status);
if (status) return status;
</xsl:when>

========== 3D arrays ==========
<xsl:when test="@data_type='FLT_3D'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
dim3 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(2);
doubleArray = new double[dim1*dim2*dim3];
for(_i = 0; _i &lt;  dim1; _i++)
for(_j = 0; _j &lt;  dim2; _j++)
for(_k = 0; _k &lt;  dim3; _k++)
doubleArray[_i+_j*dim1+_k*dim1*dim2] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i, _j, _k);
status = putVect3DDoubleSlice(expIdx, path, "<xsl:value-of select = "@path"/>", doubleArray, dim1, dim2, dim3, (double)time);
delete[] doubleArray;
checkStatus(status);
if (status) return status;
</xsl:when>
<xsl:when test="@name='array3ddbl_type'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
dim3 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(2);
doubleArray = new double[dim1*dim2*dim3];
for(_i = 0; _i &lt;  dim1; _i++)
for(_j = 0; _j &lt;  dim2; _j++)
for(_k = 0; _k &lt;  dim3; _k++)
doubleArray[_i+_j*dim1+_k*dim1*dim2] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i, _j, _k);
status = putVect3DDoubleSlice(expIdx, path, "<xsl:value-of select = "@path"/>", doubleArray, dim1, dim2, dim3, (double)time);
delete[] doubleArray;
checkStatus(status);
if (status) return status;
</xsl:when>
<xsl:when test="@data_type='INT_3D'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
dim3 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(2);
intArray = new int[dim1*dim2*dim3];
for(_i = 0; _i &lt;  dim1; _i++)
for(_j = 0; _j &lt;  dim2; _j++)
for(_k = 0; _k &lt;  dim3; _k++)
intArray[_i+_j*dim1+_k*dim1*dim2] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i, _j, _k);
status = putVect3DIntSlice(expIdx, path, "<xsl:value-of select = "@path"/>", intArray, dim1, dim2, dim3, (double)time);
delete[] intArray;
checkStatus(status);
if (status) return status;
</xsl:when>

========== 4D arrays ==========
<xsl:when test="@data_type='FLT_4D'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
dim3 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(2);
dim4 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(3);
doubleArray = new double[dim1*dim2*dim3*dim4];
for(_i = 0; _i &lt;  dim1; _i++)
for(_j = 0; _j &lt;  dim2; _j++)
for(_k = 0; _k &lt;  dim3; _k++)
for(_h = 0; _h &lt;  dim4; _h++)
doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i, _j, _k, _h);
status = putVect4DDoubleSlice(expIdx, path, "<xsl:value-of select = "@path"/>", doubleArray, dim1, dim2, dim3, dim4, (double)time);
delete[] doubleArray;
checkStatus(status);
if (status) return status;
</xsl:when>
<xsl:when test="@name='array4ddbl_type'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
dim3 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(2);
dim4 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(3);
doubleArray = new double[dim1*dim2*dim3*dim4];
for(_i = 0; _i &lt;  dim1; _i++)
for(_j = 0; _j &lt;  dim2; _j++)
for(_k = 0; _k &lt;  dim3; _k++)
for(_h = 0; _h &lt;  dim4; _h++)
doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i, _j, _k, _h);
status = putVect4DDoubleSlice(expIdx, path, "<xsl:value-of select = "@path"/>", doubleArray, dim1, dim2, dim3, dim4, (double)time);
delete[] doubleArray;
checkStatus(status);
if (status) return status;
</xsl:when>
<xsl:when test="@name='array4dint_type'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
dim3 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(2);
dim4 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(3);
intArray = new int[dim1*dim2*dim3*dim4];
for(_i = 0; _i &lt;  dim1; _i++)
for(_j = 0; _j &lt;  dim2; _j++)
for(_k = 0; _k &lt;  dim3; _k++)
for(_h = 0; _h &lt;  dim4; _h++)
intArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i, _j, _k, _h);
status = putVect4DIntSlice(expIdx, path, "<xsl:value-of select = "@path"/>", intArray, dim1, dim2, dim3, dim4, (double)time);
delete[] intArray;
checkStatus(status);
if (status) return status;
</xsl:when>

========== 5D arrays ==========
<xsl:when test="@data_type='FLT_5D'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
dim3 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(2);
dim4 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(3);
dim5 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(4);
doubleArray = new double[dim1*dim2*dim3*dim4*dim5];
for(_i = 0; _i &lt;  dim1; _i++)
for(_j = 0; _j &lt;  dim2; _j++)
for(_k = 0; _k &lt;  dim3; _k++)
for(_h = 0; _h &lt;  dim4; _h++)
for(_l = 0; _l &lt;  dim5; _l++)
doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i, _j, _k, _h, _l);
status = putVect5DDoubleSlice(expIdx, path, "<xsl:value-of select = "@path"/>", doubleArray, dim1, dim2, dim3, dim4, dim5, (double)time);
delete[] doubleArray;
checkStatus(status);
if (status) return status;
</xsl:when>
<xsl:when test="@name='array5ddbl_type'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
dim3 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(2);
dim4 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(3);
dim5 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(4);
doubleArray = new double[dim1*dim2*dim3*dim4*dim5];
for(_i = 0; _i &lt;  dim1; _i++)
for(_j = 0; _j &lt;  dim2; _j++)
for(_k = 0; _k &lt;  dim3; _k++)
for(_h = 0; _h &lt;  dim4; _h++)
for(_l = 0; _l &lt;  dim5; _l++)
doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i, _j, _k, _h, _l);
status = putVect5DDoubleSlice(expIdx, path, "<xsl:value-of select = "@path"/>", doubleArray, dim1, dim2, dim3, dim4, dim5, (double)time);
delete[] doubleArray;
checkStatus(status);
if (status) return status;
</xsl:when>
<xsl:when test="@name='array5dint_type'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
dim3 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(2);
dim4 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(3);
dim5 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(4);
intArray = new int[dim1*dim2*dim3*dim4*dim5];
for(_i = 0; _i &lt;  dim1; _i++)
for(_j = 0; _j &lt;  dim2; _j++)
for(_k = 0; _k &lt;  dim3; _k++)
for(_h = 0; _h &lt;  dim4; _h++)
for(_l = 0; _l &lt;  dim5; _l++)
intArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i, _j, _k, _h, _l);
status = putVect5DIntSlice(expIdx, path, "<xsl:value-of select = "@path"/>", intArray, dim1, dim2, dim3, dim4, dim5, (double)time);
delete[] intArray;
checkStatus(status);
if (status) return status;
</xsl:when>
-->
		<!--========== 6D arrays ==========-->
		<!--dd
<xsl:when test="@data_type='FLT_6D'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
dim3 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(2);
dim4 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(3);
dim5 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(4);
dim6 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(5);
doubleArray = new double[dim1*dim2*dim3*dim4*dim5*dim6];
for(_i = 0; _i &lt;  dim1; _i++)
for(_j = 0; _j &lt;  dim2; _j++)
for(_k = 0; _k &lt;  dim3; _k++)
for(_h = 0; _h &lt;  dim4; _h++)
for(_l = 0; _l &lt;  dim5; _l++)
for(_m = 0; _m &lt;  dim6; _m++)
doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4+_m*dim1*dim2*dim3*dim4*dim5] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i, _j, _k, _h, _l, _m);
status = putVect6DDoubleSlice(expIdx, path, "<xsl:value-of select = "@path"/>", doubleArray, dim1, dim2, dim3, dim4, dim5, dim6,(double)time);
delete[] doubleArray;
checkStatus(status);
if (status) return status;
</xsl:when>
<xsl:when test="@name='array6ddbl_type'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
dim3 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(2);
dim4 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(3);
dim5 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(4);
dim6 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(5);
doubleArray = new double[dim1*dim2*dim3*dim4*dim5*dim6];
for(_i = 0; _i &lt;  dim1; _i++)
for(_j = 0; _j &lt;  dim2; _j++)
for(_k = 0; _k &lt;  dim3; _k++)
for(_h = 0; _h &lt;  dim4; _h++)
for(_l = 0; _l &lt;  dim5; _l++)
for(_m = 0; _m &lt;  dim6; _m++)
doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4+_m*dim1*dim2*dim3*dim4*dim5] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i, _j, _k, _h, _l, _m);
status = putVect6DDoubleSlice(expIdx, path, "<xsl:value-of select = "@path"/>", doubleArray, dim1, dim2, dim3, dim4, dim5, dim6,(double)time);
delete[] doubleArray;
checkStatus(status);
if (status) return status;
</xsl:when>
<xsl:when test="@name='array6dint_type'">
dim1 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(0);
dim2 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(1);
dim3 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(2);
dim4 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(3);
dim5 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(4);
dim6 = <xsl:value-of select = "translate(@path,'/','.')"/>.extent(5);
intArray = new double[dim1*dim2*dim3*dim4*dim5*dim6];
for(_i = 0; _i &lt;  dim1; _i++)
for(_j = 0; _j &lt;  dim2; _j++)
for(_k = 0; _k &lt;  dim3; _k++)
for(_h = 0; _h &lt;  dim4; _h++)
for(_l = 0; _l &lt;  dim5; _l++)
for(_m = 0; _m &lt;  dim6; _m++)
intArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4+_m*dim1*dim2*dim3*dim4*dim5] = <xsl:value-of select = "translate(@path,'/','.')"/>(_i, _j, _k, _h, _l, _m);
status = putVect6DIntSlice(expIdx, path, "<xsl:value-of select = "@path"/>", doubleArray, dim1, dim2, dim3, dim4, dim5, dim6,(double)time);
delete[] intArray;
checkStatus(status);
if (status) return status;
</xsl:when>
-->
		<xsl:otherwise>
			//! Put <xsl:value-of select="@path"/> : PROBLEM : UNIDENTIFIED TYPE !!! <!-- for comment only -->
		</xsl:otherwise>
	</xsl:choose>
</xsl:if>
</xsl:template>
<!--=================================================-->
<!--  put non timed fields of a time-dependent IDS   -->
<!--=================================================-->
<xsl:template match="field" mode="PUT_NON_TIMED">
<xsl:choose>
	<!--========== Arrays of structures ==========-->
	<xsl:when test="@data_type='struct_array'">
		{ /*     5Array of structure     */
		char fullpath[1024]; sprintf(fullpath,"%s/<xsl:value-of select="@path"/>",path);
		void *obj1 = beginObject(expIdx,NULL,0,fullpath,NON_TIMED);
		for (int i1 = 0; i1 &lt; <xsl:value-of select="translate(@path,'/','.')"/>.extent(0); i1++) {
		<xsl:apply-templates select="field" mode="PUT_IN_OBJECT">
			<xsl:with-param name="level" select="1"/>
			<xsl:with-param name="objpath" select="@name"/>
			<xsl:with-param name="idxpath" select="concat(translate(@path,'/','.'),'(i1)')"/>
			<xsl:with-param name="timed" select="'no'"/>
		</xsl:apply-templates>
		}
		status = putObject(expIdx, path, "<xsl:value-of select="@path"/>", obj1, NON_TIMED);
		checkStatus(status);
		if (status) return status;
		}
	</xsl:when>
	<!--========== Regular structures ==========-->
	<xsl:when test="@data_type='structure'">
		<xsl:apply-templates select="field" mode="PUT_NON_TIMED"/>
	</xsl:when>
	<xsl:otherwise>
		<xsl:if test="@timed='no'">
			<xsl:choose>
				<!--========== Simple types ==========-->
				<xsl:when test="@data_type='str_type' or @data_type='STR_0D'">
					status = putString(expIdx, path, "<xsl:value-of select="@path"/>", (char *)<xsl:value-of select="translate(@path,'/','.')"/>.data(), <xsl:value-of select="translate(@path,'/','.')"/>.size());
					checkStatus(status);
					if (status) return status;
				</xsl:when>
				<xsl:when test="@data_type='int_type' or @data_type='INT_0D'">
					status = putInt(expIdx, path, "<xsl:value-of select="@path"/>", <xsl:value-of select="translate(@path,'/','.')"/>);
					checkStatus(status);
					if (status) return status;
				</xsl:when>
				<xsl:when test="@name='xs:boolean'">
					status = putInt(expIdx, path, "<xsl:value-of select="@path"/>", <xsl:value-of select="translate(@path,'/','.')"/>);
					checkStatus(status);
					if (status) return status;
				</xsl:when>
				<xsl:when test="@name='xs:double'">
					status = putDouble(expIdx, path, "<xsl:value-of select="@path"/>", <xsl:value-of select="translate(@path,'/','.')"/>);
					checkStatus(status);
					if (status) return status;
				</xsl:when>
				<xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
					status = putDouble(expIdx, path, "<xsl:value-of select="@path"/>", <xsl:value-of select="translate(@path,'/','.')"/>);
					checkStatus(status);
					if (status) return status;
				</xsl:when>
				<!--========== Vectors ==========-->
				<xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">
					numSamples = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					doubleArray = new double[numSamples];
					for(_i = 0; _i &lt; numSamples; _i++)
					doubleArray[_i] = <xsl:value-of select="translate(@path,'/','.')"/>(_i); 
					status = PUTVECT1DDOUBLE(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, numSamples, 0);
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
				</xsl:when>
				<xsl:when test="@data_type='str_1d_type' or @data_type='STR_1D'">
					numSamples = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					stringArray = new char *[numSamples];
					for(_i = 0; _i &lt; numSamples; _i++)
					stringArray[_i] = (char *)<xsl:value-of select="translate(@path,'/','.')"/>(_i).c_str(); 
					status = PUTVECT1DSTRING(expIdx, path, "<xsl:value-of select="@path"/>", stringArray, numSamples, 0);
					delete[] stringArray;
					checkStatus(status);
					if (status) return status;
				</xsl:when>
				<xsl:when test="@name='vecdbl_type'">
					numSamples = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					doubleArray = new double[numSamples];
					for(_i = 0; _i &lt; numSamples; _i++)
					doubleArray[_i] = <xsl:value-of select="translate(@path,'/','.')"/>(_i); 
					status = PUTVECT1DDOUBLE(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, numSamples, 0);
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
				</xsl:when>
				<xsl:when test="@data_type='int_1d_type' or @data_type='INT_1D'">
					numSamples = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					intArray = new int[numSamples];
					for(_i = 0; _i &lt; numSamples; _i++)
					intArray[_i] = <xsl:value-of select="translate(@path,'/','.')"/>(_i); 
					status = PUTVECT1DINT(expIdx, path, "<xsl:value-of select="@path"/>", intArray, numSamples, 0);
					delete[] intArray;
					checkStatus(status);
					if (status) return status;
				</xsl:when>  
				<!--========== Matrices ==========-->
				<xsl:when test="@data_type='FLT_2D'">
					dim1 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
					doubleArray = new double[dim1*dim2];
					for(_i = 0; _i &lt; dim1; _i++)
					for(_j = 0; _j &lt; dim2; _j++)
					doubleArray[_i+_j*dim1] = <xsl:value-of select="translate(@path,'/','.')"/>(_i,_j); 
					status = putVect2DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, 0);
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
				</xsl:when>
				<xsl:when test="@name='matdbl_type'">
					dim1 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
					doubleArray = new double[dim1*dim2];
					for(_i = 0; _i &lt; dim1; _i++)
					for(_j = 0; _j &lt; dim2; _j++)
					doubleArray[_i+_j*dim1] = <xsl:value-of select="translate(@path,'/','.')"/>(_i,_j); 
					status = putVect2DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, 0);
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
				</xsl:when>
				<xsl:when test="@data_type='INT_2D'">
					dim1 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
					intArray = new int[dim1*dim2];
					for(_i = 0; _i &lt; dim1; _i++)
					for(_j = 0; _j &lt; dim2; _j++)
					intArray[_i+_j*dim1] = <xsl:value-of select="translate(@path,'/','.')"/>(_i,_j); 
					status = putVect2DInt(expIdx, path, "<xsl:value-of select="@path"/>", intArray, dim1, dim2, 0);
					delete[] intArray;
					checkStatus(status);
					if (status) return status;
				</xsl:when>
				<!--========== 3D arrays ==========-->
				<xsl:when test="@data_type='FLT_3D'">
					dim1 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
					dim3 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
					doubleArray = new double[dim1*dim2*dim3];
					for(_i = 0; _i &lt; dim1; _i++)
					for(_j = 0; _j &lt; dim2; _j++)
					for(_k = 0; _k &lt; dim3; _k++)
					doubleArray[_i+_j*dim1+_k*dim1*dim2] = <xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k); 
					status = putVect3DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, 0);
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
				</xsl:when>
				<xsl:when test="@name='array3ddbl_type'">
					dim1 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
					dim3 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
					doubleArray = new double[dim1*dim2*dim3];
					for(_i = 0; _i &lt; dim1; _i++)
					for(_j = 0; _j &lt; dim2; _j++)
					for(_k = 0; _k &lt; dim3; _k++)
					doubleArray[_i+_j*dim1+_k*dim1*dim2] = <xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k); 
					status = putVect3DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, 0);
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
				</xsl:when>
				<xsl:when test="@data_type='INT_3D'">
					dim1 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
					dim3 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
					intArray = new int[dim1*dim2*dim3];
					for(_i = 0; _i &lt; dim1; _i++)
					for(_j = 0; _j &lt; dim2; _j++)
					for(_k = 0; _k &lt; dim3; _k++)
					intArray[_i+_j*dim1+_k*dim1*dim2] = <xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k); 
          //3D5
					status = putVect3DInt(expIdx, path, "<xsl:value-of select="@path"/>", intArray, dim1, dim2, dim3, 0);
					delete[] intArray;
					checkStatus(status);
					if (status) return status;
				</xsl:when>
				<!--========== 4D arrays ==========-->
				<xsl:when test="@data_type='FLT_4D'">
					dim1 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
					dim3 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
					dim4 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
					doubleArray = new double[dim1*dim2*dim3*dim4];
					for(_i = 0; _i &lt; dim1; _i++)
					for(_j = 0; _j &lt; dim2; _j++)
					for(_k = 0; _k &lt; dim3; _k++)
					for(_h = 0; _h &lt; dim4; _h++)
					doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3] = <xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k, _h); 
					status = putVect4DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, dim4, 0);
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
				</xsl:when>
				<xsl:when test="@name='array4ddbl_type'">
					dim1 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
					dim3 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
					dim4 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
					doubleArray = new double[dim1*dim2*dim3*dim4];
					for(_i = 0; _i &lt; dim1; _i++)
					for(_j = 0; _j &lt; dim2; _j++)
					for(_k = 0; _k &lt; dim3; _k++)
					for(_h = 0; _h &lt; dim4; _h++)
					doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3] = <xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k, _h); 
					status = putVect4DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, dim4, 0);
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
				</xsl:when>
				<xsl:when test="@name='array4dint_type'">
					dim1 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
					dim3 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
					dim4 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
					intArray = new int[dim1*dim2*dim3*dim4];
					for(_i = 0; _i &lt; dim1; _i++)
					for(_j = 0; _j &lt; dim2; _j++)
					for(_k = 0; _k &lt; dim3; _k++)
					for(_h = 0; _h &lt; dim4; _h++)
					intArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3] = <xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k, _h); 
					status = putVect4DInt(expIdx, path, "<xsl:value-of select="@path"/>", intArray, dim1, dim2, dim3, dim4, 0);
					delete[] intArray;
					checkStatus(status);
					if (status) return status;
				</xsl:when>
				<!--========== 5D arrays ==========-->
				<xsl:when test="@data_type='FLT_5D'">
					dim1 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
					dim3 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
					dim4 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
					dim5 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(4);
					doubleArray = new double[dim1*dim2*dim3*dim4*dim5];
					for(_i = 0; _i &lt; dim1; _i++)
					for(_j = 0; _j &lt; dim2; _j++)
					for(_k = 0; _k &lt; dim3; _k++)
					for(_h = 0; _h &lt; dim4; _h++)
					for(_l = 0; _l &lt; dim5; _l++)
					doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4] = <xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k, _h, _l); 
					status = putVect5DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, dim4, dim5, 0);
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
				</xsl:when>
				<xsl:when test="@name='array5ddbl_type'">
					dim1 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
					dim3 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
					dim4 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
					dim5 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(4);
					doubleArray = new double[dim1*dim2*dim3*dim4*dim5];
					for(_i = 0; _i &lt; dim1; _i++)
					for(_j = 0; _j &lt; dim2; _j++)
					for(_k = 0; _k &lt; dim3; _k++)
					for(_h = 0; _h &lt; dim4; _h++)
					for(_l = 0; _l &lt; dim5; _l++)
					doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4] = <xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k, _h, _l); 
					status = putVect5DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, dim4, dim5, 0);
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
				</xsl:when>
				<xsl:when test="@name='array5dint_type'">
					dim1 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
					dim3 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
					dim4 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
					dim5 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(4);
					intArray = new int[dim1*dim2*dim3*dim4*dim5];
					for(_i = 0; _i &lt; dim1; _i++)
					for(_j = 0; _j &lt; dim2; _j++)
					for(_k = 0; _k &lt; dim3; _k++)
					for(_h = 0; _h &lt; dim4; _h++)
					for(_l = 0; _l &lt; dim5; _l++)
					intArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4] = <xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k, _h, _l); 
					status = putVect5DInt(expIdx, path, "<xsl:value-of select="@path"/>", intArray, dim1, dim2, dim3, dim4, dim5, 0);
					delete[] intArray;
					checkStatus(status);
					if (status) return status;
				</xsl:when>
				<!--========== 6D arrays ==========-->
				<xsl:when test="@data_type='FLT_6D'">
					dim1 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
					dim3 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
					dim4 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
					dim5 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(4);
					dim6 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(5);
					doubleArray = new double[dim1*dim2*dim3*dim4*dim5*dim6];
					for(_i = 0; _i &lt; dim1; _i++)
					for(_j = 0; _j &lt; dim2; _j++)
					for(_k = 0; _k &lt; dim3; _k++)
					for(_h = 0; _h &lt; dim4; _h++)
					for(_l = 0; _l &lt; dim5; _l++)
					for(_m = 0; _m &lt; dim6; _m++)
					doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4+_m*dim1*dim2*dim3*dim4*dim5] = <xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k, _h, _l, _m); 
					status = putVect6DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, dim4, dim5, dim6, 0);
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
				</xsl:when>
				<xsl:when test="@name='array6ddbl_type'">
					dim1 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
					dim3 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
					dim4 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
					dim5 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(4);
					dim6 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(5);
					doubleArray = new double[dim1*dim2*dim3*dim4*dim5*dim6];
					for(_i = 0; _i &lt; dim1; _i++)
					for(_j = 0; _j &lt; dim2; _j++)
					for(_k = 0; _k &lt; dim3; _k++)
					for(_h = 0; _h &lt; dim4; _h++)
					for(_l = 0; _l &lt; dim5; _l++)
					for(_m = 0; _m &lt; dim6; _m++)
					doubleArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4+_m*dim1*dim2*dim3*dim4*dim5] = <xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k, _h, _l, _m); 
					status = putVect6DDouble(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, dim4, dim5, dim6, 0);
					delete[] doubleArray;
					checkStatus(status);
					if (status) return status;
				</xsl:when>
				<xsl:when test="@name='array6dint_type'">
					dim1 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(0);
					dim2 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(1);
					dim3 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(2);
					dim4 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(3);
					dim5 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(4);
					dim6 = <xsl:value-of select="translate(@path,'/','.')"/>.extent(5);
					intArray = new int[dim1*dim2*dim3*dim4*dim5*dim6];
					for(_i = 0; _i &lt; dim1; _i++)
					for(_j = 0; _j &lt; dim2; _j++)
					for(_k = 0; _k &lt; dim3; _k++)
					for(_h = 0; _h &lt; dim4; _h++)
					for(_l = 0; _l &lt; dim5; _l++)
					for(_m = 0; _m &lt; dim6; _m++)
					intArray[_i+_j*dim1+_k*dim1*dim2+_h*dim1*dim2*dim3+_l*dim1*dim2*dim3*dim4+_m*dim1*dim2*dim3*dim4*dim5] = <xsl:value-of select="translate(@path,'/','.')"/>(_i, _j, _k, _h, _l, _m); 
					status = putVect6DInt(expIdx, path, "<xsl:value-of select="@path"/>", doubleArray, dim1, dim2, dim3, dim4, dim5, dim6, 0);
					delete[] intArray;
					checkStatus(status);
					if (status) return status;
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--=================================================-->
<!--            put fields into an object            -->
<!--=================================================-->
<xsl:template match="field" mode="PUT_IN_OBJECT">
<xsl:param name="level"/> <!-- recursion level -->
<xsl:param name="objpath"/> <!-- path inside the object -->
<xsl:param name="idxpath"/> <!-- full C++ path including indices -->
<xsl:param name="child_index"/>     <!-- Index to use to add a child in the current object -->

<!-- build the path of the current field inside the object -->
<xsl:param name="currentobjpath" select="concat($objpath,'/',@name)"/>
<!-- build the complete path of the current field -->
<xsl:param name="currentidxpath" select="concat($idxpath,'.',@name)"/>

<xsl:choose>
	<!--========== Array of structures ==========-->
	<xsl:when test="@data_type='struct_array'">
    // Put <xsl:value-of select="@path"/>
    <!-- Present implementation assumes that nested AoS are necessarily of level 2, this may need to be upgraded for other cases later (?) -->
    if (<xsl:value-of select = "$currentidxpath"/>.extent(0) &gt; 0) {
    void *obj<xsl:value-of select="$level + 1"/> = beginObject(expIdx,obj<xsl:value-of select="$level"/>,0,"<xsl:value-of select="$currentobjpath"/>",NON_TIMED);
    // Start to declare a nested Type 2 Aos
     for (int i<xsl:value-of select="$level + 1"/> = 0; i<xsl:value-of select="$level + 1"/> &lt; <xsl:value-of select="$currentidxpath"/>.extent(0); i<xsl:value-of select="$level + 1"/>++) {
      <xsl:apply-templates select = "field" mode = "PUT_IN_OBJECT">
      <xsl:with-param name="level" select="$level + 1"/>
      <xsl:with-param name="objpath" select="@name"/>
      <xsl:with-param name="idxpath" select="concat($currentidxpath,'(i',$level + 1,')')"/>
      <xsl:with-param name="child_index" select="concat('i',$level+1)"/>
      </xsl:apply-templates>
      }
      obj<xsl:value-of select="$level"/> = putObjectInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, obj<xsl:value-of select="$level + 1"/>);
			checkObject(obj<xsl:value-of select="$level"/>);
        }
     </xsl:when>

	<!--========== Regular structure ==========-->
	<xsl:when test="@data_type='structure'">
		<xsl:apply-templates select="field" mode="PUT_IN_OBJECT">
			<xsl:with-param name="level" select="$level"/>
			<xsl:with-param name="objpath" select="$currentobjpath"/>
			<xsl:with-param name="idxpath" select="$currentidxpath"/>
      <xsl:with-param name="child_index" select="$child_index"/>
		</xsl:apply-templates>
	</xsl:when>

	<!--========== select either timed or non-timed fields ==========-->
	<xsl:otherwise>
    <!--2014		<xsl:if test="@timed=$timed"> -->
			<xsl:choose>

				<!--========== Simple types ==========-->
				<xsl:when test="@data_type='str_type' or @data_type='STR_0D'">
					obj<xsl:value-of select="$level"/> = putStringInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, (char *)<xsl:value-of select="$currentidxpath"/>.data());
					checkObject(obj<xsl:value-of select="$level"/>);
				</xsl:when>
				<xsl:when test="@data_type='int_type' or @data_type='INT_0D'">
					obj<xsl:value-of select="$level"/> = putIntInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, <xsl:value-of select="$currentidxpath"/>);
					checkObject(obj<xsl:value-of select="$level"/>);
				</xsl:when>
				<xsl:when test="@name='xs:boolean'">
					obj<xsl:value-of select="$level"/> = putIntInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, <xsl:value-of select="$currentidxpath"/>);
					checkObject(obj<xsl:value-of select="$level"/>);
				</xsl:when>
				<xsl:when test="@name='xs:double'">
					obj<xsl:value-of select="$level"/> = putDoubleInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, <xsl:value-of select="$currentidxpath"/>);
					checkObject(obj<xsl:value-of select="$level"/>);
				</xsl:when>
				<xsl:when test="@data_type='flt_type' or @data_type='FLT_0D'">
					obj<xsl:value-of select="$level"/> = putDoubleInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, <xsl:value-of select="$currentidxpath"/>);
					checkObject(obj<xsl:value-of select="$level"/>);
				</xsl:when>

				<!--========== Vectors ==========-->
				<xsl:when test="@data_type='flt_1d_type' or @data_type='FLT_1D'">
					dim1In = <xsl:value-of select="$currentidxpath"/>.extent(0);
          if ( dim1In > 0) {
					doubleArray = new double[dim1In];
					for(_i = 0; _i &lt; dim1In; _i++)
					doubleArray[_i] = <xsl:value-of select="$currentidxpath"/>(_i);
					obj<xsl:value-of select="$level"/> = putVect1DDoubleInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, doubleArray, dim1In);
					delete[] doubleArray;
					checkObject(obj<xsl:value-of select="$level"/>);
          }
				</xsl:when>
				<xsl:when test="@data_type='str_1d_type' or @data_type='STR_1D'">
					dim1In = <xsl:value-of select="$currentidxpath"/>.extent(0);
           if ( dim1In > 0) {
					stringArray = new char *[dim1In];
					for(_i = 0; _i &lt; dim1In; _i++)
					stringArray[_i] = (char *)<xsl:value-of select="$currentidxpath"/>(_i).c_str();
					obj<xsl:value-of select="$level"/> = putVect1DStringInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, stringArray, dim1In);
					delete[] stringArray;
					checkObject(obj<xsl:value-of select="$level"/>);
          }
				</xsl:when>
				<xsl:when test="@name='vecdbl_type'">
					dim1In = <xsl:value-of select="$currentidxpath"/>.extent(0);
          if ( dim1In > 0) {
					doubleArray = new double[dim1In];
					for(_i = 0; _i &lt; dim1In; _i++)
					doubleArray[_i] = <xsl:value-of select="$currentidxpath"/>(_i);
					obj<xsl:value-of select="$level"/> = putVect1DDoubleInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, doubleArray, dim1In);
					delete[] doubleArray;
					checkObject(obj<xsl:value-of select="$level"/>);
          }
				</xsl:when>
				<xsl:when test="@data_type='int_1d_type' or @data_type='INT_1D'">
					dim1In = <xsl:value-of select="$currentidxpath"/>.extent(0);
          if ( dim1In > 0) {
					intArray = new int[dim1In];
					for(_i = 0; _i &lt; dim1In; _i++)
					intArray[_i] = <xsl:value-of select="$currentidxpath"/>(_i);
					obj<xsl:value-of select="$level"/> = putVect1DIntInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, intArray, dim1In);
					delete[] intArray;
					checkObject(obj<xsl:value-of select="$level"/>);
          }
				</xsl:when>

				<!--========== Matrices ==========-->
				<xsl:when test="@data_type='FLT_2D'">
					dim1In = <xsl:value-of select="$currentidxpath"/>.extent(0);
          if ( dim1In > 0) {
					dim2In = <xsl:value-of select="$currentidxpath"/>.extent(1);
					doubleArray = new double[dim1In*dim2In];
					for(_i = 0; _i &lt; dim1In; _i++)
					for(_j = 0; _j &lt; dim2In; _j++)
					doubleArray[_i+_j*dim1In] = <xsl:value-of select="$currentidxpath"/>(_i,_j);
					obj<xsl:value-of select="$level"/> = putVect2DDoubleInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, doubleArray, dim1In, dim2In);
					delete[] doubleArray;
					checkObject(obj<xsl:value-of select="$level"/>);
          }
				</xsl:when>
				<xsl:when test="@name='matdbl_type'">
					dim1In = <xsl:value-of select="$currentidxpath"/>.extent(0);
          if ( dim1In > 0) {
					dim2In = <xsl:value-of select="$currentidxpath"/>.extent(1);
					doubleArray = new double[dim1In*dim2In];
					for(_i = 0; _i &lt; dim1In; _i++)
					for(_j = 0; _j &lt; dim2In; _j++)
					doubleArray[_i+_j*dim1In] = <xsl:value-of select="$currentidxpath"/>(_i,_j);
					obj<xsl:value-of select="$level"/> = putVect2DDoubleInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, doubleArray, dim1In, dim2In);
					delete[] doubleArray;
					checkObject(obj<xsl:value-of select="$level"/>);
          }
				</xsl:when>
				<xsl:when test="@data_type='INT_2D'">
					dim1In = <xsl:value-of select="$currentidxpath"/>.extent(0);
          if ( dim1In > 0) {
					dim2In = <xsl:value-of select="$currentidxpath"/>.extent(1);
					intArray = new int[dim1In*dim2In];
					for(_i = 0; _i &lt; dim1In; _i++)
					for(_j = 0; _j &lt; dim2In; _j++)
					intArray[_i+_j*dim1In] = <xsl:value-of select="$currentidxpath"/>(_i,_j);
					obj<xsl:value-of select="$level"/> = putVect2DIntInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, intArray, dim1In, dim2In);
					delete[] intArray;
					checkObject(obj<xsl:value-of select="$level"/>);
          }
				</xsl:when>

				<!--========== 3D arrays ==========-->
				<xsl:when test="@data_type='FLT_3D'">
					dim1In = <xsl:value-of select="$currentidxpath"/>.extent(0);
          if ( dim1In > 0) {
					dim2In = <xsl:value-of select="$currentidxpath"/>.extent(1);
					dim3In = <xsl:value-of select="$currentidxpath"/>.extent(2);
					doubleArray = new double[dim1In*dim2In*dim3In];
					for(_i = 0; _i &lt; dim1In; _i++)
					for(_j = 0; _j &lt; dim2In; _j++)
					for(_k = 0; _k &lt; dim3In; _k++)
					doubleArray[_i+_j*dim1In+_k*dim1In*dim2In] = <xsl:value-of select="$currentidxpath"/>(_i, _j, _k);
					obj<xsl:value-of select="$level"/> = putVect3DDoubleInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, doubleArray, dim1In, dim2In, dim3In);
					delete[] doubleArray;
					checkObject(obj<xsl:value-of select="$level"/>);
          }
				</xsl:when>
				<xsl:when test="@name='array3ddbl_type'">
					dim1In = <xsl:value-of select="$currentidxpath"/>.extent(0);
          if ( dim1In > 0) {
					dim2In = <xsl:value-of select="$currentidxpath"/>.extent(1);
					dim3In = <xsl:value-of select="$currentidxpath"/>.extent(2);
					doubleArray = new double[dim1In*dim2In*dim3In];
					for(_i = 0; _i &lt; dim1In; _i++)
					for(_j = 0; _j &lt; dim2In; _j++)
					for(_k = 0; _k &lt; dim3In; _k++)
					doubleArray[_i+_j*dim1In+_k*dim1In*dim2In] = <xsl:value-of select="$currentidxpath"/>(_i, _j, _k);
					obj<xsl:value-of select="$level"/> = putVect3DDoubleInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, doubleArray, dim1In, dim2In, dim3In);
					delete[] doubleArray;
					checkObject(obj<xsl:value-of select="$level"/>);
          }
				</xsl:when>
				<xsl:when test="@data_type='INT_3D'">
					dim1In = <xsl:value-of select="$currentidxpath"/>.extent(0);
          if ( dim1In > 0) {
					dim2In = <xsl:value-of select="$currentidxpath"/>.extent(1);
					dim3In = <xsl:value-of select="$currentidxpath"/>.extent(2);
					intArray = new int[dim1In*dim2In*dim3In];
					for(_i = 0; _i &lt; dim1In; _i++)
					for(_j = 0; _j &lt; dim2In; _j++)
					for(_k = 0; _k &lt; dim3In; _k++)
					intArray[_i+_j*dim1In+_k*dim1In*dim2In] = <xsl:value-of select="$currentidxpath"/>(_i, _j, _k);
					obj<xsl:value-of select="$level"/> = putVect3DIntInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, intArray, dim1In, dim2In, dim3In);
					delete[] intArray;
					checkObject(obj<xsl:value-of select="$level"/>);
          }
				</xsl:when>

				<!--========== 4D arrays ==========-->
				<xsl:when test="@data_type='FLT_4D'">
					dim1In = <xsl:value-of select="$currentidxpath"/>.extent(0);
          if ( dim1In > 0) {
					dim2In = <xsl:value-of select="$currentidxpath"/>.extent(1);
					dim3In = <xsl:value-of select="$currentidxpath"/>.extent(2);
					dim4In = <xsl:value-of select="$currentidxpath"/>.extent(3);
					doubleArray = new double[dim1In*dim2In*dim3In*dim4In];
					for(_i = 0; _i &lt; dim1In; _i++)
					for(_j = 0; _j &lt; dim2In; _j++)
					for(_k = 0; _k &lt; dim3In; _k++)
					for(_l = 0; _l &lt; dim4In; _l++)
					doubleArray[_i+_j*dim1In+_k*dim1In*dim2In+_l*dim1In*dim2In*dim3In] = <xsl:value-of select="$currentidxpath"/>(_i, _j, _k, _l);
					obj<xsl:value-of select="$level"/> = putVect4DDoubleInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, doubleArray, dim1In, dim2In, dim3In, dim4In);
					delete[] doubleArray;
					checkObject(obj<xsl:value-of select="$level"/>);
          }
				</xsl:when>
				<xsl:when test="@name='array4ddbl_type'">
					dim1In = <xsl:value-of select="$currentidxpath"/>.extent(0);
          if ( dim1In > 0) {
					dim2In = <xsl:value-of select="$currentidxpath"/>.extent(1);
					dim3In = <xsl:value-of select="$currentidxpath"/>.extent(2);
					dim4In = <xsl:value-of select="$currentidxpath"/>.extent(3);
					doubleArray = new double[dim1In*dim2In*dim3In*dim4In];
					for(_i = 0; _i &lt; dim1In; _i++)
					for(_j = 0; _j &lt; dim2In; _j++)
					for(_k = 0; _k &lt; dim3In; _k++)
					for(_l = 0; _l &lt; dim4In; _l++)
					doubleArray[_i+_j*dim1In+_k*dim1In*dim2In+_l*dim1In*dim2In*dim3In] = <xsl:value-of select="$currentidxpath"/>(_i, _j, _k, _l);
					obj<xsl:value-of select="$level"/> = putVect4DDoubleInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, doubleArray, dim1In, dim2In, dim3In, dim4In);
					delete[] doubleArray;
					checkObject(obj<xsl:value-of select="$level"/>);
          }
				</xsl:when>
				<xsl:when test="@name='array4dint_type'">
					dim1In = <xsl:value-of select="$currentidxpath"/>.extent(0);
          if ( dim1In > 0) {
					dim2In = <xsl:value-of select="$currentidxpath"/>.extent(1);
					dim3In = <xsl:value-of select="$currentidxpath"/>.extent(2);
					dim4In = <xsl:value-of select="$currentidxpath"/>.extent(3);
					intArray = new int[dim1In*dim2In*dim3In*dim4In];
					for(_i = 0; _i &lt; dim1In; _i++)
					for(_j = 0; _j &lt; dim2In; _j++)
					for(_k = 0; _k &lt; dim3In; _k++)
					for(_l = 0; _l &lt; dim4In; _l++)
					intArray[_i+_j*dim1In+_k*dim1In*dim2In+_l*dim1In*dim2In*dim3In] = <xsl:value-of select="$currentidxpath"/>(_i, _j, _k, _l);
					obj<xsl:value-of select="$level"/> = putVect4DIntInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, intArray, dim1In, dim2In, dim3In, dim4In);
					delete[] intArray;
					checkObject(obj<xsl:value-of select="$level"/>);
          }
				</xsl:when>

				<!--========== 5D arrays ==========-->
				<xsl:when test="@data_type='FLT_5D'">
					dim1In = <xsl:value-of select="$currentidxpath"/>.extent(0);
          if ( dim1In > 0) {
					dim2In = <xsl:value-of select="$currentidxpath"/>.extent(1);
					dim3In = <xsl:value-of select="$currentidxpath"/>.extent(2);
					dim4In = <xsl:value-of select="$currentidxpath"/>.extent(3);
					dim5In = <xsl:value-of select="$currentidxpath"/>.extent(4);
					doubleArray = new double[dim1In*dim2In*dim3In*dim4In*dim5In];
					for(_i = 0; _i &lt; dim1In; _i++)
					for(_j = 0; _j &lt; dim2In; _j++)
					for(_k = 0; _k &lt; dim3In; _k++)
					for(_l = 0; _l &lt; dim4In; _l++)
					for(_m = 0; _m &lt; dim5In; _m++)
					doubleArray[_i+_j*dim1In+_k*dim1In*dim2In+_l*dim1In*dim2In*dim3In+_m*dim1In*dim2In*dim3In*dim4In] = <xsl:value-of select="$currentidxpath"/>(_i, _j, _k, _l, _m);
					obj<xsl:value-of select="$level"/> = putVect5DDoubleInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, doubleArray, dim1In, dim2In, dim3In, dim4In, dim5In);
					delete[] doubleArray;
					checkObject(obj<xsl:value-of select="$level"/>);
          }
				</xsl:when>
				<xsl:when test="@name='array5ddbl_type'">
					dim1In = <xsl:value-of select="$currentidxpath"/>.extent(0);
          if ( dim1In > 0) {
					dim2In = <xsl:value-of select="$currentidxpath"/>.extent(1);
					dim3In = <xsl:value-of select="$currentidxpath"/>.extent(2);
					dim4In = <xsl:value-of select="$currentidxpath"/>.extent(3);
					dim5In = <xsl:value-of select="$currentidxpath"/>.extent(4);
					doubleArray = new double[dim1In*dim2In*dim3In*dim4In*dim5In];
					for(_i = 0; _i &lt; dim1In; _i++)
					for(_j = 0; _j &lt; dim2In; _j++)
					for(_k = 0; _k &lt; dim3In; _k++)
					for(_l = 0; _l &lt; dim4In; _l++)
					for(_m = 0; _m &lt; dim5In; _m++)
					doubleArray[_i+_j*dim1In+_k*dim1In*dim2In+_l*dim1In*dim2In*dim3In+_m*dim1In*dim2In*dim3In*dim4In] = <xsl:value-of select="$currentidxpath"/>(_i, _j, _k, _l, _m);
					obj<xsl:value-of select="$level"/> = putVect5DDoubleInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, doubleArray, dim1In, dim2In, dim3In, dim4In, dim5In);
					delete[] doubleArray;
					checkObject(obj<xsl:value-of select="$level"/>);
          }
				</xsl:when>
				<xsl:when test="@name='array5dint_type'">
					dim1In = <xsl:value-of select="$currentidxpath"/>.extent(0);
          if ( dim1In > 0) {
					dim2In = <xsl:value-of select="$currentidxpath"/>.extent(1);
					dim3In = <xsl:value-of select="$currentidxpath"/>.extent(2);
					dim4In = <xsl:value-of select="$currentidxpath"/>.extent(3);
					dim5In = <xsl:value-of select="$currentidxpath"/>.extent(4);
					intArray = new int[dim1In*dim2In*dim3In*dim4In*dim5In];
					for(_i = 0; _i &lt; dim1In; _i++)
					for(_j = 0; _j &lt; dim2In; _j++)
					for(_k = 0; _k &lt; dim3In; _k++)
					for(_l = 0; _l &lt; dim4In; _l++)
					for(_m = 0; _m &lt; dim5In; _m++)
					intArray[_i+_j*dim1In+_k*dim1In*dim2In+_l*dim1In*dim2In*dim3In+_m*dim1In*dim2In*dim3In*dim4In] = <xsl:value-of select="$currentidxpath"/>(_i, _j, _k, _l, _m);
					obj<xsl:value-of select="$level"/> = putVect5DIntInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, intArray, dim1In, dim2In, dim3In, dim4In, dim5In);
					delete[] intArray;
					checkObject(obj<xsl:value-of select="$level"/>);
          }
				</xsl:when>

				<!--========== 6D arrays ==========-->
				<xsl:when test="@data_type='FLT_6D'">
					dim1In = <xsl:value-of select="$currentidxpath"/>.extent(0);
          if ( dim1In > 0) {
					dim2In = <xsl:value-of select="$currentidxpath"/>.extent(1);
					dim3In = <xsl:value-of select="$currentidxpath"/>.extent(2);
					dim4In = <xsl:value-of select="$currentidxpath"/>.extent(3);
					dim5In = <xsl:value-of select="$currentidxpath"/>.extent(4);
					dim6In = <xsl:value-of select="$currentidxpath"/>.extent(5);
					doubleArray = new double[dim1In*dim2In*dim3In*dim4In*dim5In*dim6In];
					for(_i = 0; _i &lt; dim1In; _i++)
					for(_j = 0; _j &lt; dim2In; _j++)
					for(_k = 0; _k &lt; dim3In; _k++)
					for(_l = 0; _l &lt; dim4In; _l++)
					for(_m = 0; _m &lt; dim5In; _m++)
					for(_n = 0; _n &lt; dim6In; _n++)
					doubleArray[_i+_j*dim1In+_k*dim1In*dim2In+_l*dim1In*dim2In*dim3In+_m*dim1In*dim2In*dim3In*dim4In+_n*dim1In*dim2In*dim3In*dim4In*dim5In] = <xsl:value-of select="$currentidxpath"/>(_i, _j, _k, _l, _m, _n);
					obj<xsl:value-of select="$level"/> = putVect6DDoubleInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, doubleArray, dim1In, dim2In, dim3In, dim4In, dim5In, dim6In);
					delete[] doubleArray;
					checkObject(obj<xsl:value-of select="$level"/>);
          }
				</xsl:when>
				<xsl:when test="@name='array6ddbl_type'">
					dim1In = <xsl:value-of select="$currentidxpath"/>.extent(0);
          if ( dim1In > 0) {
					dim2In = <xsl:value-of select="$currentidxpath"/>.extent(1);
					dim3In = <xsl:value-of select="$currentidxpath"/>.extent(2);
					dim4In = <xsl:value-of select="$currentidxpath"/>.extent(3);
					dim5In = <xsl:value-of select="$currentidxpath"/>.extent(4);
					dim6In = <xsl:value-of select="$currentidxpath"/>.extent(5);
					doubleArray = new double[dim1In*dim2In*dim3In*dim4In*dim5In*dim6In];
					for(_i = 0; _i &lt; dim1In; _i++)
					for(_j = 0; _j &lt; dim2In; _j++)
					for(_k = 0; _k &lt; dim3In; _k++)
					for(_l = 0; _l &lt; dim4In; _l++)
					for(_m = 0; _m &lt; dim5In; _m++)
					for(_n = 0; _n &lt; dim6In; _n++)
					doubleArray[_i+_j*dim1In+_k*dim1In*dim2In+_l*dim1In*dim2In*dim3In+_m*dim1In*dim2In*dim3In*dim4In+_n*dim1In*dim2In*dim3In*dim4In*dim5In] = <xsl:value-of select="$currentidxpath"/>(_i, _j, _k, _l, _m, _n);
					obj<xsl:value-of select="$level"/> = putVect6DDoubleInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, doubleArray, dim1In, dim2In, dim3In, dim4In, dim5In, dim6In);
					delete[] doubleArray;
					checkObject(obj<xsl:value-of select="$level"/>);
          }
				</xsl:when>
				<xsl:when test="@name='array6dint_type'">
					dim1In = <xsl:value-of select="$currentidxpath"/>.extent(0);
          if ( dim1In > 0) {
					dim2In = <xsl:value-of select="$currentidxpath"/>.extent(1);
					dim3In = <xsl:value-of select="$currentidxpath"/>.extent(2);
					dim4In = <xsl:value-of select="$currentidxpath"/>.extent(3);
					dim5In = <xsl:value-of select="$currentidxpath"/>.extent(4);
					dim6In = <xsl:value-of select="$currentidxpath"/>.extent(5);
					intArray = new int[dim1In*dim2In*dim3In*dim4In*dim5In*dim6In];
					for(_i = 0; _i &lt; dim1In; _i++)
					for(_j = 0; _j &lt; dim2In; _j++)
					for(_k = 0; _k &lt; dim3In; _k++)
					for(_l = 0; _l &lt; dim4In; _l++)
					for(_m = 0; _m &lt; dim5In; _m++)
					for(_n = 0; _n &lt; dim6In; _n++)
					intArray[_i+_j*dim1In+_k*dim1In*dim2In+_l*dim1In*dim2In*dim3In+_m*dim1In*dim2In*dim3In*dim4In+_n*dim1In*dim2In*dim3In*dim4In*dim5In] = <xsl:value-of select="$currentidxpath"/>(_i, _j, _k, _l, _m, _n);
					obj<xsl:value-of select="$level"/> = putVect6DIntInObject(expIdx,obj<xsl:value-of select="$level"/>, "<xsl:value-of select="$currentobjpath"/>", <xsl:value-of select="$child_index"/>, doubleArray, dim1In, dim2In, dim3In, dim4In, dim5In, dim6In);
					delete[] intArray;
					checkObject(obj<xsl:value-of select="$level"/>);
          }
				</xsl:when>
			</xsl:choose>
      <!--    </xsl:if> -->
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="printtimepath">
<xsl:if test="@type = 'dynamic'">
	<xsl:choose>
  <xsl:when test="contains(@coordinate7,'time')"> <xsl:value-of select="translate(@coordinate7,'(:)','')"/></xsl:when> 
  <xsl:when test="contains(@coordinate6,'time')"> <xsl:value-of select="translate(@coordinate6,'(:)','')"/></xsl:when>
  <xsl:when test="contains(@coordinate5,'time')"> <xsl:value-of select="translate(@coordinate5,'(:)','')"/></xsl:when>
  <xsl:when test="contains(@coordinate4,'time')"> <xsl:value-of select="translate(@coordinate4,'(:)','')"/></xsl:when>
  <xsl:when test="contains(@coordinate3,'time')"> <xsl:value-of select="translate(@coordinate3,'(:)','')"/></xsl:when>
  <xsl:when test="contains(@coordinate2,'time')"> <xsl:value-of select="translate(@coordinate2,'(:)','')"/></xsl:when>
  <xsl:when test="contains(@coordinate1,'time')"> <xsl:value-of select="translate(@coordinate1,'(:)','')"/></xsl:when>
	</xsl:choose>
</xsl:if>
<xsl:if test="@name='time'">
	<xsl:value-of select="@path"/>
</xsl:if>
<!-- If the field itself IS time, then it is its own time coordinate -->
</xsl:template>

<xsl:template name="printtimevariable">
<xsl:if test="@type = 'dynamic'">
	<xsl:choose>
		<xsl:when test="contains(@coordinate7,'time')">
			<xsl:value-of select="translate(@coordinate7,'/','.')"/>
		</xsl:when>
		<xsl:when test="contains(@coordinate6,'time')">
			<xsl:value-of select="translate(@coordinate6,'/','.')"/>
		</xsl:when>
		<xsl:when test="contains(@coordinate5,'time')">
			<xsl:value-of select="translate(@coordinate5,'/','.')"/>
		</xsl:when>
		<xsl:when test="contains(@coordinate4,'time')">
			<xsl:value-of select="translate(@coordinate4,'/','.')"/>
		</xsl:when>
		<xsl:when test="contains(@coordinate3,'time')">
			<xsl:value-of select="translate(@coordinate3,'/','.')"/>
		</xsl:when>
		<xsl:when test="contains(@coordinate2,'time')">
			<xsl:value-of select="translate(@coordinate2,'/','.')"/>
		</xsl:when>
		<xsl:when test="contains(@coordinate1,'time')">
			<xsl:value-of select="translate(@coordinate1,'/','.')"/>
		</xsl:when>
	</xsl:choose>
</xsl:if>
<xsl:if test="@name='time'">
	<xsl:value-of select="translate(@path,'/','.')"/>
</xsl:if>
<!-- If the field itself IS time, then it is its own time coordinate -->
</xsl:template>

<xsl:template name="printIsTimed">
<xsl:choose>
	<xsl:when test="@type = 'dynamic'">
		<xsl:value-of select="1"/>
	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="0"/>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

</xsl:stylesheet>
