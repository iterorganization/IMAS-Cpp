<?xml version="1.0" encoding="UTF-8"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./%24GET%5Bstylesheet%5D" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<!-- Generating  C++ access layer code from Data Dictionary IDSDef.xml -->
<!-- -->
<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"  version="2.0" extension-element-prefixes="yaslt">

<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="/IDSs">
<xsl:result-document href="src/UALMethods.cpp" standalone="yes" method="text">

#include "UALClasses.h"

using namespace blitz;
using namespace IdsNs;
<!--
#define NON_TIMED    0
#define TIMED       1
#define TIMED_CLEAR 2
/*#define DEBUG*/


#ifdef DEBUG
void checkStatus(int status) {if(status) printf("%s\n", // imas_last_errmsg());}
#else
void checkStatus(int status){}
#endif
-->

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
pulseCtx = -1;
}
IdsNs::IDS::IDS(int pulseCtx)
{
	treeName = "ids";
	connected = true;
//this-&gt; shot = ual_get_shot(idx);
//this-&gt;run = ual_get_run(idx);
//this-&gt;refShot =  ual_get_shot(idx);
//this-&gt;refRun = ual_get_run(idx);
	this->pulseCtx = pulseCtx;
	this->setPulseCtx(pulseCtx);
}

void IdsNs::IDS::setPulseCtx(int pulseCtx)
{
<xsl:apply-templates select="IDS" mode="SET_PULSE_CTX"/>
}



int IdsNs::IDS::open()
{
	int pulseCtx;
	int status = -1;

  	pulseCtx = ual_begin_pulse_action(MDSPLUS_BACKEND, this->shot, this->run, "", "", ""); 
  	if (pulseCtx &lt; 0)
	{
		printf("Error opening imas shot %d, run %d: %s\n", shot, run, "ual_begin_pulse_action");
    		return pulseCtx;
	}
 

    	status = ual_open_pulse(pulseCtx, OPEN_PULSE, "");
	if(status != 0)
	{
		printf("Error opening imas shot %d, run %d: %s\n", shot, run, "ual_open_pulse");
		return status;
	}
	this->pulseCtx = pulseCtx;
	this->connected = true;
	this->setPulseCtx(pulseCtx);
}


int IdsNs::IDS::openEnv(char *user, char *tokamak, char *version)
{
	int pulseCtx;
	int status = -1;

  	pulseCtx = ual_begin_pulse_action(MDSPLUS_BACKEND, this->shot, this->run, user, tokamak, version); 
  	if (pulseCtx &lt; 0)
	{
		printf("Error opening imas shot %d, run %d: %s\n", shot, run, "ual_begin_pulse_action");
    		return pulseCtx;
	}
 

    	status = ual_open_pulse(pulseCtx, OPEN_PULSE, "");
	if(status != 0)
	{
		printf("Error opening imas shot %d, run %d: %s\n", shot, run, "ual_open_pulse");
		return status;
	}
	this->pulseCtx = pulseCtx;
	this->connected = true;
	this->setPulseCtx(pulseCtx);
}



int IdsNs::IDS::openHdf5()
{
	printf("ERROR: Deprecated method: openHdf5()!");
    	return -1;
}

void IdsNs::IDS::openPublic(const char* expName)
{
int pulseCtx;
int status = 1;// imas_open_public("ids", shot, run, &amp;idx, expName);
if(status != 0)
{
//printf("Error opening imas shot %d, run %d: %s\n", shot, run, // imas_last_errmsg());
}
else
{
this->pulseCtx = pulseCtx;
connected = true;
this->setPulseCtx(pulseCtx);
}

}
int IdsNs::IDS::create()
{
	int pulseCtx = -1;
	int status = 1;

	pulseCtx = ual_begin_pulse_action(MDSPLUS_BACKEND, this->shot, this->run, "", "", ""); 
  	if (pulseCtx &lt; 0)
	{
		printf("Error opening imas shot %d, run %d: %s\n", shot, run, "ual_begin_pulse_action");
    		return pulseCtx;
	}
 


	status = ual_open_pulse(pulseCtx, FORCE_CREATE_PULSE, "");
	if(status != 0)
	{
		printf("Error opening imas shot %d, run %d: %s\n", shot, run, "ual_open_pulse");
		return status;
	}

	this->pulseCtx = pulseCtx;
	this->connected = true;
	this->setPulseCtx(pulseCtx);

}

int IdsNs::IDS::createEnv(char *user, char *tokamak, char *version)
{
	int pulseCtx = -1;
	int status = 1;

	pulseCtx = ual_begin_pulse_action(MDSPLUS_BACKEND, this->shot, this->run, user, tokamak, version); 
  	if (pulseCtx &lt; 0)
	{
		printf("Error opening imas shot %d, run %d: %s\n", shot, run, "ual_begin_pulse_action");
    		return pulseCtx;
	}
 


	status = ual_open_pulse(pulseCtx, FORCE_CREATE_PULSE, "");
	if(status != 0)
	{
		printf("Error opening imas shot %d, run %d: %s\n", shot, run, "ual_open_pulse");
		return status;
	}

	this->pulseCtx = pulseCtx;
	this->connected = true;
	this->setPulseCtx(pulseCtx);

}




int IdsNs::IDS::createHdf5()
{

	printf("ERROR: Deprecated method: openHdf5()!");
    	return -1;
}

void IdsNs::IDS::createPublic(const char* expName)
{
int idx;
int status = 1;// imas_create_public("ids", shot, run, refShot, refRun, &amp; idx, expName);
if(status != 0)
{
//printf("Error opening imas shot %d, run %d: %s\n", shot, run, // imas_last_errmsg());
}
else
{
this->pulseCtx = pulseCtx;
connected = true;
this->setPulseCtx(pulseCtx);
}
}

int IdsNs::IDS::close()
{
  	int status = ual_close_pulse(this->pulseCtx, CLOSE_PULSE, "");
	if(status != 0)
	{
		printf("Error opening imas shot %d, run %d: %s\n", shot, run, "ual_close_pulse");
		return status;
	}
    	return ual_end_action(this->pulseCtx);
}

void IdsNs::IDS::enableMemCache()
{
if(!connected) return;
if(this->pulseCtx != -1)
;// imas_enable_mem_cache(expIdx);
}

void IdsNs::IDS::disableMemCache()
{
if(!connected) return;
if(this->pulseCtx != -1)
;// imas_disable_mem_cache(expIdx);
}


void IdsNs::IDS::flushAll()
{
	if(!connected) return;
	if(this->pulseCtx != -1)
;// imas_flush_mem_cache(expIdx);
}

void IdsNs::IDS::discardAll()
{
	if(!connected) return;
	if(this->pulseCtx != -1)
;// imas_discard_mem_cache(expIdx);
}

int IdsNs::IDS::getTime(char *path, Array&lt;double,1&gt; &amp;time)
{
int retSamples;
double *doubleArray;
int dim;

if(!connected) return -1;
int status ;//= beginIdsGet(expIdx,path,TIMED,&amp;retSamples);
//checkStatus(status);
if(status) return status;
////status = getVect1DDouble(expIdx, path, "time", &amp;doubleArray, &amp;dim);
//checkStatus(status);
if(!status) {
Array&lt;double,1&gt; newArray(doubleArray, shape(dim), duplicateData, fortranArray);
time.resize(newArray.shape());
time = newArray;
free(doubleArray);
}
////endIdsGet(expIdx, path);
return status;
}

IdsNs::IDS::~IDS()
{
/*if(expIdx != -1)
// imas_close(expIdx);*/
}
<!--
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
-->

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

 </xsl:result-document>
</xsl:template>

        <!--Documentation for a single field-->
    <xsl:template name = "COMMENT_FIELD">
        <xsl:text>&#xA;</xsl:text>
	<xsl:text>/*-----------------------------------------------------------------------------------------*/&#xA;</xsl:text>
	<xsl:text>//  </xsl:text><xsl:value-of select="@name"/>:<xsl:value-of select="@path"/>:<xsl:value-of select="@data_type"/>:<xsl:value-of select="@type"/>:<xsl:text>&#xA;</xsl:text>
	<xsl:text>/*-----------------------------------------------------------------------------------------*/&#xA;</xsl:text>

	  <xsl:if test="@type='dynamic' and @maxoccur='unbounded' and @data_type='struct_array'">
		<xsl:text>//  ARRAY of TYPE 3 &#xA;</xsl:text>
		<xsl:text>/*-----------------------------------------------------------------------------------------*/&#xA;</xsl:text>

	  </xsl:if>
     <xsl:if test="(not(@type) or @type!='dynamic') and @maxoccur='unbounded' and @data_type='struct_array'">
		<xsl:text>//  ARRAY of TYPE 2  &#xA;</xsl:text>
		<xsl:text>/*-----------------------------------------------------------------------------------------*/&#xA;</xsl:text>

	  </xsl:if>

	       <xsl:if test="@maxoccur!='unbounded' and @data_type='struct_array'">
		<xsl:text>//  ARRAY of TYPE 1  &#xA;</xsl:text>
		<xsl:text>/*-----------------------------------------------------------------------------------------*/&#xA;</xsl:text>

	  </xsl:if>
    </xsl:template>


<!--=================================================-->
<!--                 set idx in IDS                  -->
<!--=================================================-->

<xsl:template match="IDS" mode="SET_PULSE_CTX">
_<xsl:value-of select="@name"/>.setPulseCtx(this->pulseCtx);
</xsl:template>

<!--=================================================-->
<!--               print IDS content                 -->
<!--=================================================-->
<!--YBYBDUMP -->
<xsl:template match="IDS" mode="DUMP">
ostream &amp;IdsNs::operator &lt;&lt; (ostream &amp;os, const <xsl:value-of select="@name"/>_IDSBase &amp;obj)
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
<xsl:result-document href="src/ids/{@name}_IDSBase.cpp" standalone="yes" method="text">
#include &lt;blitz/array.h&gt;
#include "UALDef.h"
#include "<xsl:value-of select="@name"/>_IDSBase.h"

using namespace IdsNs;

IdsNs::<xsl:value-of select="@name"/>_IDSBase::<xsl:value-of select="@name"/>_IDSBase()
{
connected = false;
<xsl:apply-templates select="field" mode="CONSTRUCTOR"/>
}

int IdsNs::<xsl:value-of select="@name"/>_IDSBase::isHomogeneous(int ctx, bool&amp; isIdsHomogeneous )
{
    	int homogenousTime = -1;
	int status = -1;
	
    	status = IdsNs::Ids::readData(ctx, "ids_properties/homogeneous_time", "", homogenousTime);
	if (status)
        	return status;
	
	if(homogenousTime == 1)
		isIdsHomogeneous = true;
	else
		isIdsHomogeneous = false;

	return 0;
}


int IdsNs::<xsl:value-of select="@name"/>_IDSBase::get()
{
	return this->get(0);
}

int IdsNs::<xsl:value-of select="@name"/>_IDSBase::get(int iOccurrence)
{
int status;
char *str;
char *idsName = "<xsl:value-of select="@name"/>";
char idsFullName[strlen(idsName)+4];

int pulseCtx = this->pulseCtx;
int getOpCtx = -1;
int ctx = -1;
int aosCtx = -1;
std::string fieldPath;
std::string timeBasePath;
bool isIdsHomogeneous = false;
int arraySize;

	if(!connected) 
		return -1;

	if(iOccurrence &lt; 1)
		sprintf(idsFullName, "%s", idsName);
	else
		sprintf(idsFullName, "%s/%d", idsName, iOccurrence);

	// Open get context
	getOpCtx = ual_begin_global_action(pulseCtx, idsFullName, READ_OP);

	if(getOpCtx &lt; 0) 
		return getOpCtx;

	ctx = getOpCtx;

	status = this->isHomogeneous(ctx,isIdsHomogeneous );
	if(status &lt; 0) 
		return status;

 	<xsl:apply-templates select="field" mode="GET_SINGLE"/> 
	ual_end_action(getOpCtx);
	
	return 0;
}

int IdsNs::<xsl:value-of select="@name"/>_IDSBase::put()
{
	return this->put(0);
}

int IdsNs::<xsl:value-of select="@name"/>_IDSBase::put(int iOccurrence)
{

int status;
char *idsName = "<xsl:value-of select="@name"/>";
char idsFullName[strlen(idsName)+4];


int pulseCtx = this->pulseCtx;
int putOpCtx = -1;
int ctx = -1;
int aosCtx = -1;
std::string fieldPath;
std::string timeBasePath;
bool isIdsHomogeneous = false;
int arraySize;

if(!connected) return -1;

if(iOccurrence &lt; 1)
sprintf(idsFullName, "%s", idsName);
else
sprintf(idsFullName, "%s/%d", idsName, iOccurrence);

deleteAll(iOccurrence);



	// Open put context
	putOpCtx = ual_begin_global_action(pulseCtx, idsFullName, WRITE_OP);

	if(putOpCtx &lt; 0) return putOpCtx;


ctx = putOpCtx;
isIdsHomogeneous = ids_properties.homogeneous_time;
<xsl:apply-templates select="field" mode="PUT_SINGLE">
		<xsl:with-param name="dynamic_only" select="'no'"/>
	</xsl:apply-templates>

	ual_end_action(putOpCtx);
	
return 0;
}

int IdsNs::<xsl:value-of select="@name"/>_IDSBase::putSlice()
{
	return this->putSlice(0);
}

int IdsNs::<xsl:value-of select="@name"/>_IDSBase::putSlice(int iOccurrence)
{
	int status;
	char *idsName = "<xsl:value-of select="@name"/>";
	char idsFullName[strlen(idsName)+4];


	int pulseCtx = this->pulseCtx;
	int putSliceOpCtx = -1;
	int ctx = -1;
	int aosCtx = -1;
	std::string fieldPath;
	std::string timeBasePath;
	bool isIdsHomogeneous = false;
	int arraySize;
	double sliceTime = -1.0;


	if(!connected) 
		return -1;

	if(iOccurrence &lt; 1)
		sprintf(idsFullName, "%s", idsName);
	else
		sprintf(idsFullName, "%s/%d", idsName, iOccurrence);

	isIdsHomogeneous = ids_properties.homogeneous_time;

	sliceTime = this->time(0);

	// Open put context
	putSliceOpCtx = ual_begin_slice_action(pulseCtx, idsFullName, WRITE_OP, sliceTime, UNDEFINED_INTERP);

	if(putSliceOpCtx &lt; 0) 
		return putSliceOpCtx;

	ctx = putSliceOpCtx;

	<xsl:apply-templates select="field" mode="PUT_SINGLE">
		<xsl:with-param name="dynamic_only" select="'yes'"/>
	</xsl:apply-templates>
	ual_end_action(putSliceOpCtx);


return 0;
}



int IdsNs::<xsl:value-of select="@name"/>_IDSBase::remove(int idx)
{
string lepath;
char * clepath; <xsl:for-each select=".//field[@data_type='struct_array' and @maxoccur!='unbounded']">
int  i<xsl:value-of select="concat(@name,generate-id(.))"/>; </xsl:for-each>
if(!connected) return -1;
char *basePath = "<xsl:value-of select="@name"/>";
char path[strlen(basePath)+4];
if(idx &lt; 1)
sprintf(path, "%s", basePath);
else
sprintf(path, "%s/%d", basePath, idx);
<!-- <xsl:apply-templates select="field" mode="DELETE"/>  -->
return 0;
}

int IdsNs::<xsl:value-of select="@name"/>_IDSBase::remove()
{
	return this->remove(0);
}

int IdsNs::<xsl:value-of select="@name"/>_IDSBase::deleteAll(int idx)
{
string lepath;
char * clepath; <xsl:for-each select=".//field[@data_type='struct_array' and @maxoccur!='unbounded']">
int i<xsl:value-of select="concat(@name,generate-id(.))"/>; </xsl:for-each>
if(!connected) return -1;
char *basePath = "<xsl:value-of select="@name"/>";
char path[strlen(basePath)+4];
if(idx &lt; 1)
sprintf(path, "%s", basePath);
else
sprintf(path, "%s/%d", basePath, idx);
<!-- <xsl:apply-templates select="field" mode="DELETE"/>  -->
return 0;
}

int IdsNs::<xsl:value-of select="@name"/>_IDSBase::deleteAll()
{
	return this->deleteAll(0);
}

int IdsNs::<xsl:value-of select="@name"/>_IDSBase::putNonTimed()
{
	return this->putNonTimed(0);
}

int IdsNs::<xsl:value-of select="@name"/>_IDSBase::putNonTimed(int idx)
{
	printf("ERROR: Deprecated method: putNonTimed()! Use put() instead...");
    	return -1;

}

int IdsNs::<xsl:value-of select="@name"/>_IDSBase::getSlice(double inTime, char interpolMode)
{
	return this->getSlice(0, inTime, interpolMode);
}

int IdsNs::<xsl:value-of select="@name"/>_IDSBase::getSlice(int iOccurrence, double inTime, char interpolMode)
{
	int status;
	char *idsName = "<xsl:value-of select="@name"/>";
	char idsFullName[strlen(idsName)+4];


	int pulseCtx = this->pulseCtx;
	int getSliceOpCtx = -1;
	int ctx = -1;
	int aosCtx = -1;
	std::string fieldPath;
	std::string timeBasePath;
	bool isIdsHomogeneous = false;
	int arraySize;


	if(!connected) 
		return -1;

	if(iOccurrence &lt; 1)
		sprintf(idsFullName, "%s", idsName);
	else
		sprintf(idsFullName, "%s/%d", idsName, iOccurrence);

	
	

	// Open put context
	getSliceOpCtx = ual_begin_slice_action(pulseCtx, idsFullName, READ_OP, inTime, interpolMode);

	if(getSliceOpCtx &lt; 0) 
		return getSliceOpCtx;

	ctx = getSliceOpCtx;

	status = this->isHomogeneous(ctx,isIdsHomogeneous );
	if(status &lt; 0) 
		return status;

	<xsl:apply-templates select="field" mode="GET_SINGLE">
		<xsl:with-param name="dynamic_only" select="'yes'"/>
	</xsl:apply-templates>
	ual_end_action(getSliceOpCtx);

	return 0;
}
 <xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_PUT"/> 
<xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_GET"/> 

  <xsl:apply-templates select=".//field[@data_type='structure' or @data_type='struct_array']" mode="METHOD_PUT_SLICE"/>


<!--<xsl:apply-templates select="." mode="DUMP"/>
--> </xsl:result-document>



</xsl:template>


<xsl:template match="field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_PUT">
     <xsl:text>&#xA;&#xA;</xsl:text>
    <xsl:call-template name="COMMENT_FIELD"/>
<xsl:text> int IdsNs::</xsl:text> <xsl:value-of select="ancestor::IDS/@name"/>_IDSBase::<xsl:value-of select="fn:replace(@path,'/','::')"/><xsl:text>::put(int ctx, bool isIdsHomogeneous)&#xA;</xsl:text>
{
	int status = -1;
	int arraySize = -1;
	int aosCtx = -1;
	std::string fieldPath = "";
	std::string timeBasePath = "";

	<xsl:apply-templates select="field" mode="PUT_SINGLE">
		<xsl:with-param name="dynamic_only" select="'no'"/>
	</xsl:apply-templates>

	return 0;
}
</xsl:template>



<xsl:template match="field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_PUT_SLICE">
<xsl:if test="descendant-or-self::field[@type='dynamic'] or ancestor::field[@type='dynamic' and @data_type='struct_array']">
     <xsl:text>&#xA;&#xA;</xsl:text>
    <xsl:call-template name="COMMENT_FIELD"/>
<xsl:text> int IdsNs::</xsl:text> <xsl:value-of select="ancestor::IDS/@name"/>_IDSBase::<xsl:value-of select="fn:replace(@path,'/','::')"/><xsl:text>::putSlice(int ctx, bool isIdsHomogeneous)&#xA;</xsl:text>
{
	int status = -1;
	int arraySize = -1;
	int aosCtx = -1;
	std::string fieldPath = "";
	std::string timeBasePath = "";

	<xsl:apply-templates select="field" mode="PUT_SINGLE">
		<xsl:with-param name="dynamic_only" select="'yes'"/>
	</xsl:apply-templates>

	return 0;
}
</xsl:if>
</xsl:template>


<xsl:template match="field[@data_type='struct_array' or @data_type='structure']" mode="METHOD_GET">
     <xsl:text>&#xA;&#xA;</xsl:text>
    <xsl:call-template name="COMMENT_FIELD"/>
<xsl:text> int IdsNs::</xsl:text> <xsl:value-of select="ancestor::IDS/@name"/>_IDSBase::<xsl:value-of select="fn:replace(@path,'/','::')"/><xsl:text>::get(int ctx, bool isIdsHomogeneous)&#xA;</xsl:text>
{
	int status = -1;
	int arraySize = -1;
	int aosCtx = -1;
	std::string fieldPath = "";
	std::string timeBasePath = "";

	<xsl:apply-templates select="field" mode="GET_SINGLE"/>


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
				for (i<xsl:value-of select="concat(@name,generate-id(.))"/> = 0;i<xsl:value-of select="concat(@name,generate-id(.))"/>&lt;<xsl:value-of select="@maxoccur"/>; i<xsl:value-of select="concat(@name,generate-id(.))"/>++){
				<xsl:apply-templates select="field" mode="DELETE">
					<xsl:with-param name="variable_path" select="concat($variable_path,'.',@name,'(i',@name,generate-id(.),')')"/>
					<xsl:with-param name="mds_path" select="concat($mds_path,' + ','string(&quot;/',@name,'/&quot;) + int2str(i',@name,generate-id(.),',1)')"/>
				</xsl:apply-templates>
				}
			</xsl:when>
			<xsl:otherwise>
				for (i<xsl:value-of select="concat(@name,generate-id(.))"/> = 0;i<xsl:value-of select="concat(@name,generate-id(.))"/>&lt;<xsl:value-of select="@maxoccur"/>; i<xsl:value-of select="concat(@name,generate-id(.))"/>++){
				<xsl:apply-templates select="field" mode="DELETE">
					<xsl:with-param name="variable_path" select="concat(@name,'(i',@name,generate-id(.),')')"/>
					<xsl:with-param name="mds_path" select="concat('&quot;',@name,'/&quot; + int2str(i',@name,generate-id(.),',1)')"/>
				</xsl:apply-templates>
				}
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:otherwise>
		<xsl:choose>
			<xsl:when test="$mds_path">
				//lepath =  <xsl:value-of select="$mds_path"/>  + string("/<xsl:value-of select="@name"/>");
				//clepath =   const_cast&lt;char *&gt; (lepath.c_str());
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
		// imas_discard_old_mem(expIdx, path, "<xsl:value-of select="@path"/>", time);
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
		// imas_discard_mem(expIdx, path, "<xsl:value-of select="@path"/>");
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
<!--       put field       -->
<!--=================================================-->

<xsl:template match="field" mode="PUT_SINGLE">
<xsl:param name="dynamic_only"/>
    <xsl:call-template name="COMMENT_FIELD"/>
<xsl:if test="$dynamic_only !='yes' or descendant-or-self::field[@type='dynamic'] or ancestor::field[@type='dynamic' and @data_type='struct_array']">

<xsl:variable name="methodName">
	        <xsl:choose>
		        <xsl:when test="$dynamic_only !='yes'" >
	                	<xsl:value-of select="'put'" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'putSlice'" />
	                </xsl:otherwise>
	        </xsl:choose>
	</xsl:variable>
<xsl:choose>
<!--========== Regular structures ==========-->
    <!-- YB 2014 -->
		<xsl:when test="@data_type='structure'">
		status = <xsl:value-of select="@name"/>.<xsl:value-of select="$methodName"/>(ctx, isIdsHomogeneous);
		if (status != 0)
			return status;
		</xsl:when>

<!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
		<xsl:when test="@data_type='struct_array' and @maxoccur!='unbounded'">
			<xsl:text>/*-----------------------------------------------------------------------------------------*/&#xA;</xsl:text>
			<xsl:choose>
				<xsl:when test="ancestor::field[@data_type='struct_array']">
					fieldPath = &quot;<xsl:call-template  name="printAosRelativePath"/>&quot;;
				</xsl:when>
  				<xsl:otherwise>
   			 		fieldPath = &quot;<xsl:value-of select="@path"/>&quot;;
  				</xsl:otherwise>
			</xsl:choose>
			timeBasePath = "";
			arraySize = <xsl:value-of select = "@name"/>.extent(0);
			if(arraySize > 0)
			{
				aosCtx = ual_begin_arraystruct_action(ctx, fieldPath.c_str(), timeBasePath.c_str(), &amp;arraySize);
				if (aosCtx &lt; 0)  
					return aosCtx; 
			
				for( int i = 0; i &lt;arraySize; i++){
					status = <xsl:value-of select="@name"/>(i).<xsl:value-of select="$methodName"/>(aosCtx, isIdsHomogeneous);
					if (status != 0)
						return status;
					status = ual_iterate_over_arraystruct(aosCtx, 1);
					if (status != 0)
						return status;
				}
				status = ual_end_action(aosCtx);
				if (status != 0)  
					return status; 
			}
		</xsl:when>
 		<xsl:when  test="@data_type='struct_array' and @maxoccur='unbounded' and (@type!='dynamic' or not(@type))">
		
			<xsl:text>/*-----------------------------------------------------------------------------------------*/&#xA;</xsl:text>
			<xsl:choose>
				<xsl:when test="ancestor::field[@data_type='struct_array']">
					fieldPath = &quot;<xsl:call-template  name="printAosRelativePath"/>&quot;;
	//<xsl:value-of select="ancestor::field[@data_type='struct_array'][1]/@path"/>

	//<xsl:value-of  select="@path"/>
				</xsl:when>
  				<xsl:otherwise>
   			 		fieldPath = &quot;<xsl:value-of select="@path"/>&quot;;
  				</xsl:otherwise>
			</xsl:choose>
			timeBasePath = "";
			arraySize = <xsl:value-of select = "@name"/>.extent(0);
			if(arraySize > 0)
			{	
				aosCtx = ual_begin_arraystruct_action(ctx, fieldPath.c_str(), timeBasePath.c_str(), &amp;arraySize);
				if (aosCtx &lt; 0)  
					return aosCtx; 
				for( int i = 0; i &lt;arraySize; i++){
					status = <xsl:value-of select="@name"/>(i).<xsl:value-of select="$methodName"/>(aosCtx, isIdsHomogeneous);
					if (status != 0)
						return status;
					status = ual_iterate_over_arraystruct(aosCtx, 1);
					if (status != 0)
						return status;
				}
				status = ual_end_action(aosCtx);
				if (status != 0)  
					return status; 
 			}
		</xsl:when>
		<xsl:when test="@data_type='struct_array' and @maxoccur='unbounded' and @type='dynamic'">

			<xsl:text>/*-----------------------------------------------------------------------------------------*/&#xA;</xsl:text>
			<xsl:choose>
				<xsl:when test="ancestor::field[@data_type='struct_array']">
					fieldPath = &quot;<xsl:call-template  name="printAosRelativePath"/>&quot;;
					if (isIdsHomogeneous) 
          					timeBasePath = "/time";
       					else
						timeBasePath = &quot;<xsl:call-template  name="printAosRelativePath"/>/time&quot;;
	//<xsl:value-of select="ancestor::field[@data_type='struct_array'][1]/@path"/>
	//<xsl:value-of select="@path"/>
				</xsl:when>
  				<xsl:otherwise>
   			 		fieldPath = &quot;<xsl:value-of select="@path"/>&quot;;
					if (isIdsHomogeneous) 
          					timeBasePath = "/time";
       					else
						timeBasePath = &quot;<xsl:value-of select="@path"/>/time&quot;;
  				</xsl:otherwise>
			</xsl:choose>
			arraySize = <xsl:value-of select = "@name"/>.extent(0);
			if(arraySize > 0)
			{	
				aosCtx = ual_begin_arraystruct_action(ctx, fieldPath.c_str(), timeBasePath.c_str(), &amp;arraySize);
				if (aosCtx &lt; 0)  
					return aosCtx; 
				for( int i = 0; i &lt;arraySize; i++){
					status = <xsl:value-of select="@name"/>(i).<xsl:value-of select="$methodName"/>(aosCtx, isIdsHomogeneous);
					if (status != 0)
						return status;
					status = ual_iterate_over_arraystruct(aosCtx, 1);
					if (status != 0)
						return status;
				}
				status = ual_end_action(aosCtx);
				if (status != 0)  
					return status; 
 			}
		</xsl:when>

	<xsl:when test="
		   @data_type='str_type' or @data_type='STR_0D'
		or @data_type='str_1d_type' or @data_type='STR_1D'
		or @data_type='int_type' or @data_type='INT_0D'
		or @data_type='flt_type' or @data_type='FLT_0D' 
		or @data_type='flt_1d_type' or @data_type='FLT_1D'
		or @data_type='int_1d_type' or @data_type='INT_1D'
		or @data_type='FLT_2D' or @data_type='INT_2D'
		or @data_type='FLT_3D'	or @data_type='INT_3D'
		or @data_type='FLT_4D'	or @data_type='INT_4D'
		or @data_type='FLT_5D'or @data_type='INT_5D'
		or @data_type='FLT_6D'or @data_type='INT_6D'">
		<xsl:choose>
			<xsl:when test="ancestor::field[@data_type='struct_array']">
				fieldPath = &quot;<xsl:call-template  name="printAosRelativePath"/>&quot;;
			</xsl:when>
  			<xsl:otherwise>
   			 	fieldPath = &quot;<xsl:value-of select="@path"/>&quot;;
  			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="@type='dynamic' and not(ancestor::field[@type='dynamic' and @data_type='struct_array'])">
    		if (isIdsHomogeneous) 
			timeBasePath="/time";
    		else
       			timeBasePath=&quot;<xsl:value-of select="@timebasepath"/>&quot;;
  			</xsl:when>
  			<xsl:otherwise>
    				timeBasePath = "";
  			</xsl:otherwise>
		</xsl:choose>
		status = IdsNs::Ids::writeData(ctx, fieldPath, timeBasePath, this-><xsl:value-of select="@name"/>);
		if (status) 
			return status;
	</xsl:when>
		<xsl:otherwise>
			//Doc Put <xsl:value-of select="@path"/> : PROBLEM : UNIDENTIFIED TYPE !!! <!-- for comment only -->
		</xsl:otherwise>
	</xsl:choose>
</xsl:if>
</xsl:template>




<!-- 2014 YBYB-->
<!--=================================================-->
<!--       put field of a time-independent IDS       -->
<!--=================================================-->

<xsl:template match="field" mode="GET_SINGLE">
    <xsl:call-template name="COMMENT_FIELD"/>
<xsl:choose>
<!--========== Regular structures ==========-->
    <!-- YB 2014 -->
		<xsl:when test="@data_type='structure'">
		status = <xsl:value-of select="@name"/>.get(ctx, isIdsHomogeneous);
		if (status != 0)
			return status;
		</xsl:when>

<!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
		<xsl:when test="@data_type='struct_array' and @maxoccur!='unbounded'">
			<xsl:text>/*-----------------------------------------------------------------------------------------*/&#xA;</xsl:text>
			<xsl:choose>
				<xsl:when test="ancestor::field[@data_type='struct_array']">
					fieldPath = &quot;<xsl:call-template  name="printAosRelativePath"/>&quot;;	
	//<xsl:value-of select="ancestor::field[@data_type='struct_array'][1]/@path"/>
	//<xsl:value-of select="@path"/>
				</xsl:when>
  				<xsl:otherwise>
   			 		fieldPath = &quot;<xsl:value-of select="@path"/>&quot;;
  				</xsl:otherwise>
			</xsl:choose>
			timeBasePath = "";
			aosCtx = ual_begin_arraystruct_action(ctx, fieldPath.c_str(), timeBasePath.c_str(), &amp;arraySize);
			if (aosCtx &lt; 0)  
				return aosCtx; 

			if(arraySize > 0)
			{	
				<xsl:value-of select="@name"/>.resize(arraySize);
				for( int i = 0; i &lt;arraySize; i++){
					status = <xsl:value-of select="@name"/>(i).get(aosCtx, isIdsHomogeneous);
					if (status != 0)
						return status;
					status = ual_iterate_over_arraystruct(aosCtx, 1);
					if (status != 0)
						return status;
				}
				status = ual_end_action(aosCtx);
				if (status != 0)  
					return status; 
 			}
		</xsl:when>
 		<xsl:when  test="@data_type='struct_array' and @maxoccur='unbounded' and (@type!='dynamic' or not(@type))">	
			<xsl:text>/*-----------------------------------------------------------------------------------------*/&#xA;</xsl:text>
			<xsl:choose>
				<xsl:when test="ancestor::field[@data_type='struct_array']">
					fieldPath = &quot;<xsl:call-template  name="printAosRelativePath"/>&quot;;
	//<xsl:value-of select="ancestor::field[@data_type='struct_array'][1]/@path"/>
	//<xsl:value-of select="@path"/>
				</xsl:when>
  				<xsl:otherwise>
   			 		fieldPath = &quot;<xsl:value-of select="@path"/>&quot;;
  				</xsl:otherwise>
			</xsl:choose>
			timeBasePath = "";
			aosCtx = ual_begin_arraystruct_action(ctx, fieldPath.c_str(), timeBasePath.c_str(), &amp;arraySize);
			if (aosCtx &lt; 0)  
				return aosCtx; 

			if(arraySize > 0)
			{	
				<xsl:value-of select="@name"/>.resize(arraySize);
				for( int i = 0; i &lt;arraySize; i++){
					status = <xsl:value-of select="@name"/>(i).get(aosCtx, isIdsHomogeneous);
					if (status != 0)
						return status;
					status = ual_iterate_over_arraystruct(aosCtx, 1);
					if (status != 0)
						return status;
				}
				status = ual_end_action(aosCtx);
				if (status != 0)  
					return status; 
 			}
		</xsl:when>
		<xsl:when test="@data_type='struct_array' and @maxoccur='unbounded' and @type='dynamic'">
			<xsl:text>/*-----------------------------------------------------------------------------------------*/&#xA;</xsl:text>
			<xsl:choose>
				<xsl:when test="ancestor::field[@data_type='struct_array']">
					fieldPath = &quot;<xsl:call-template  name="printAosRelativePath"/>&quot;;
					if (isIdsHomogeneous) 
          					timeBasePath = "/time";
       					else
						timeBasePath = &quot;<xsl:call-template  name="printAosRelativePath"/>/time&quot;;
	//<xsl:value-of select="ancestor::field[@data_type='struct_array'][1]/@path"/>
	//<xsl:value-of select="@path"/>
				</xsl:when>
  				<xsl:otherwise>
   			 		fieldPath = &quot;<xsl:value-of select="@path"/>&quot;;
					if (isIdsHomogeneous) 
          					timeBasePath = "/time";
       					else
						timeBasePath = &quot;<xsl:value-of select="@path"/>/time&quot;;
  				</xsl:otherwise>
			</xsl:choose>
			aosCtx = ual_begin_arraystruct_action(ctx, fieldPath.c_str(), timeBasePath.c_str(), &amp;arraySize);
			if (aosCtx &lt; 0)  
				return aosCtx; 

			if(arraySize > 0)
			{	
				<xsl:value-of select="@name"/>.resize(arraySize);
				for( int i = 0; i &lt;arraySize; i++){
					status = <xsl:value-of select="@name"/>(i).get(aosCtx, isIdsHomogeneous);
					if (status != 0)
						return status;
					status = ual_iterate_over_arraystruct(aosCtx, 1);
					if (status != 0)
						return status;
				}
				status = ual_end_action(aosCtx);
				if (status != 0)  
					return status; 
 			}
		</xsl:when>

	<xsl:when test="
		   @data_type='str_type' or @data_type='STR_0D'
		or @data_type='str_1d_type' or @data_type='STR_1D'
		or @data_type='int_type' or @data_type='INT_0D'
		or @data_type='flt_type' or @data_type='FLT_0D' 
		or @data_type='flt_1d_type' or @data_type='FLT_1D'
		or @data_type='int_1d_type' or @data_type='INT_1D'
		or @data_type='FLT_2D' or @data_type='INT_2D'
		or @data_type='FLT_3D'	or @data_type='INT_3D'
		or @data_type='FLT_4D'	or @data_type='INT_4D'
		or @data_type='FLT_5D'or @data_type='INT_5D'
		or @data_type='FLT_6D'or @data_type='INT_6D'">
		<xsl:choose>
			<xsl:when test="ancestor::field[@data_type='struct_array']">
				fieldPath = &quot;<xsl:call-template  name="printAosRelativePath"/>&quot;;
			</xsl:when>
  			<xsl:otherwise>
   			 	fieldPath = &quot;<xsl:value-of select="@path"/>&quot;;
  			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="@type='dynamic' and not(ancestor::field[@type='dynamic' and @data_type='struct_array'])">
    		if (isIdsHomogeneous) 
			timeBasePath="/time";
    		else
       			timeBasePath=&quot;<xsl:value-of select="@timebasepath"/>&quot;;
  			</xsl:when>
  			<xsl:otherwise>
    				timeBasePath = "";
  			</xsl:otherwise>
		</xsl:choose>
		status = IdsNs::Ids::readData(ctx, fieldPath, timeBasePath, this-><xsl:value-of select="@name"/>);
		if (status) 
			return status;
	</xsl:when>
		<xsl:otherwise>
			//Doc GET <xsl:value-of select="@path"/> : PROBLEM : UNIDENTIFIED TYPE !!! <!-- for comment only -->
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>








<xsl:template name="printtimepath">
<xsl:if test="@type = 'dynamic'">
	<xsl:choose>
<xsl:when test="contains(@coordinate7,'time')"> <xsl:value-of select="translate(replace(@coordinate7,'(itime)',''),'()','')"/></xsl:when> <!-- We remove the (itime) pattern from the coordinate attribute in IDSDef, which is documentation-oriented -->
<xsl:when test="contains(@coordinate6,'time')"> <xsl:value-of select="translate(replace(@coordinate6,'(itime)',''),'()','')"/></xsl:when>
<xsl:when test="contains(@coordinate5,'time')"> <xsl:value-of select="translate(replace(@coordinate5,'(itime)',''),'()','')"/></xsl:when>
<xsl:when test="contains(@coordinate4,'time')"> <xsl:value-of select="translate(replace(@coordinate4,'(itime)',''),'()','')"/></xsl:when>
<xsl:when test="contains(@coordinate3,'time')"> <xsl:value-of select="translate(replace(@coordinate3,'(itime)',''),'()','')"/></xsl:when>
<xsl:when test="contains(@coordinate2,'time')"> <xsl:value-of select="translate(replace(@coordinate2,'(itime)',''),'()','')"/></xsl:when>
<xsl:when test="contains(@coordinate1,'time')"> <xsl:value-of select="translate(replace(@coordinate1,'(itime)',''),'()','')"/></xsl:when>
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


<xsl:template name ="printtimepathrelative">
<xsl:if test="@type = 'dynamic'">
<xsl:choose>
<xsl:when test="contains(@coordinate7_AosParent_relative,'time')"> <xsl:value-of select="@coordinate7_AosParent_relative"/></xsl:when> <!-- We remove the (itime) pattern from the coordinate attribute in IDSDef, which is documentation-oriented -->
<xsl:when test="contains(@coordinate6_AosParent_relative,'time')"> <xsl:value-of select="@coordinate6_AosParent_relative"/></xsl:when>
<xsl:when test="contains(@coordinate5_AosParent_relative,'time')"> <xsl:value-of select="@coordinate5_AosParent_relative"/></xsl:when>
<xsl:when test="contains(@coordinate4_AosParent_relative,'time')"> <xsl:value-of select="@coordinate4_AosParent_relative"/></xsl:when>
<xsl:when test="contains(@coordinate3_AosParent_relative,'time')"> <xsl:value-of select="@coordinate3_AosParent_relative"/></xsl:when>
<xsl:when test="contains(@coordinate2_AosParent_relative,'time')"> <xsl:value-of select="@coordinate2_AosParent_relative"/></xsl:when>
<xsl:when test="contains(@coordinate1_AosParent_relative,'time')"> <xsl:value-of select="@coordinate1_AosParent_relative"/></xsl:when>
</xsl:choose>
</xsl:if>
<xsl:if test="@name='time'"><xsl:value-of select="@path"/></xsl:if>  <!-- If the field itself IS time, then it is its own time coordinate -->
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

<xsl:template name ="printAosRelativePath">
	<xsl:variable name="AoSPath" select="ancestor::field[@data_type='struct_array'][1]/@path"/>
	<xsl:variable name="elementPath" select="@path"/>

	<xsl:value-of select="replace($elementPath,concat($AoSPath,'/'),'')"/>
</xsl:template>


</xsl:stylesheet>
