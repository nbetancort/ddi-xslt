<?xml version="1.0" encoding="UTF-8"?>
<!--
    XSLT Transformation: DataCite 4.x to DDI Codebook 2.5
    
    This stylesheet transforms XML metadata from DataCite schema (kernel-4.x)
    to DDI Codebook 2.5 format following the CESSDA Data Catalogue profile.
    
    Input:  DataCite XML (http://datacite.org/schema/kernel-4)
    Output: DDI Codebook 2.5 (ddi:codebook:2_5)
    
    Author: Lovable AI
    Date: 2024
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dc="http://datacite.org/schema/kernel-4"
    xmlns="ddi:codebook:2_5"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="dc">
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <!-- Root template -->
    <xsl:template match="/">
        <xsl:apply-templates select="dc:resource"/>
    </xsl:template>
    
    <!-- Main resource template -->
    <xsl:template match="dc:resource">
        <codeBook xmlns="ddi:codebook:2_5"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                  xsi:schemaLocation="ddi:codebook:2_5 https://ddialliance.org/Specification/DDI-Codebook/2.5/XMLSchema/codebook.xsd"
                  version="2.5">
            
            <!-- Document Description -->
            <docDscr>
                <citation>
                    <titlStmt>
                        <titl>
                            <xsl:value-of select="dc:titles/dc:title[not(@titleType)][1]"/>
                        </titl>
                        <xsl:call-template name="output-idno"/>
                    </titlStmt>
                    <distStmt>
                        <distrbtr source="archive">
                            <xsl:value-of select="dc:publisher"/>
                        </distrbtr>
                        <xsl:if test="dc:dates/dc:date[@dateType='Available']">
                            <distDate>
                                <xsl:value-of select="dc:dates/dc:date[@dateType='Available']"/>
                            </distDate>
                        </xsl:if>
                    </distStmt>
                    <verStmt source="archive">
                        <version>
                            <xsl:attribute name="date">
                                <xsl:choose>
                                    <xsl:when test="dc:dates/dc:date[@dateType='Available']">
                                        <xsl:value-of select="dc:dates/dc:date[@dateType='Available']"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="dc:publicationYear"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:attribute name="type">RELEASED</xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="dc:version">
                                    <xsl:value-of select="translate(dc:version, '.', '')"/>
                                </xsl:when>
                                <xsl:otherwise>1</xsl:otherwise>
                            </xsl:choose>
                        </version>
                    </verStmt>
                    <biblCit>
                        <xsl:call-template name="generate-citation"/>
                    </biblCit>
                </citation>
            </docDscr>
            
            <!-- Study Description -->
            <stdyDscr>
                <citation>
                    <titlStmt>
                        <titl>
                            <xsl:value-of select="dc:titles/dc:title[not(@titleType)][1]"/>
                        </titl>
                        <xsl:for-each select="dc:titles/dc:title[@titleType='Subtitle']">
                            <subTitl>
                                <xsl:value-of select="."/>
                            </subTitl>
                        </xsl:for-each>
                        <xsl:for-each select="dc:titles/dc:title[@titleType='AlternativeTitle']">
                            <altTitl>
                                <xsl:value-of select="."/>
                            </altTitl>
                        </xsl:for-each>
                        <xsl:call-template name="output-idno"/>
                    </titlStmt>
                    
                    <!-- Responsibility Statement (Authors) -->
                    <xsl:if test="dc:creators/dc:creator">
                        <rspStmt>
                            <xsl:for-each select="dc:creators/dc:creator">
                                <AuthEnty>
                                    <xsl:if test="dc:affiliation">
                                        <xsl:attribute name="affiliation">
                                            <xsl:value-of select="dc:affiliation"/>
                                        </xsl:attribute>
                                    </xsl:if>
                                    <xsl:choose>
                                        <xsl:when test="dc:creatorName">
                                            <xsl:value-of select="dc:creatorName"/>
                                        </xsl:when>
                                        <xsl:when test="dc:familyName and dc:givenName">
                                            <xsl:value-of select="dc:familyName"/>
                                            <xsl:text>, </xsl:text>
                                            <xsl:value-of select="dc:givenName"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </AuthEnty>
                            </xsl:for-each>
                        </rspStmt>
                    </xsl:if>
                    
                    <!-- Production Statement -->
                    <prodStmt>
                        <xsl:if test="dc:dates/dc:date[@dateType='Created']">
                            <prodDate>
                                <xsl:value-of select="dc:dates/dc:date[@dateType='Created']"/>
                            </prodDate>
                        </xsl:if>
                        <xsl:for-each select="dc:fundingReferences/dc:fundingReference">
                            <fundAg>
                                <xsl:if test="dc:awardNumber">
                                    <xsl:attribute name="abbr">
                                        <xsl:value-of select="dc:awardNumber"/>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:value-of select="dc:funderName"/>
                            </fundAg>
                            <xsl:if test="dc:awardTitle">
                                <grantNo>
                                    <xsl:value-of select="dc:awardTitle"/>
                                </grantNo>
                            </xsl:if>
                        </xsl:for-each>
                    </prodStmt>
                    
                    <!-- Distribution Statement -->
                    <distStmt>
                        <distrbtr source="archive">
                            <xsl:value-of select="dc:publisher"/>
                        </distrbtr>
                        <xsl:for-each select="dc:contributors/dc:contributor[@contributorType='ContactPerson']">
                            <contact>
                                <xsl:choose>
                                    <xsl:when test="dc:contributorName">
                                        <xsl:value-of select="dc:contributorName"/>
                                    </xsl:when>
                                    <xsl:when test="dc:familyName and dc:givenName">
                                        <xsl:value-of select="dc:familyName"/>
                                        <xsl:text>, </xsl:text>
                                        <xsl:value-of select="dc:givenName"/>
                                    </xsl:when>
                                </xsl:choose>
                            </contact>
                        </xsl:for-each>
                        <xsl:if test="dc:dates/dc:date[@dateType='Submitted']">
                            <depDate>
                                <xsl:value-of select="dc:dates/dc:date[@dateType='Submitted']"/>
                            </depDate>
                        </xsl:if>
                        <xsl:if test="dc:dates/dc:date[@dateType='Available']">
                            <distDate>
                                <xsl:value-of select="dc:dates/dc:date[@dateType='Available']"/>
                            </distDate>
                        </xsl:if>
                    </distStmt>
                    
                    <!-- Holdings (DOI link) -->
                    <xsl:if test="dc:identifier[@identifierType='DOI']">
                        <holdings>
                            <xsl:attribute name="URI">
                                <xsl:text>https://doi.org/</xsl:text>
                                <xsl:value-of select="dc:identifier[@identifierType='DOI']"/>
                            </xsl:attribute>
                        </holdings>
                    </xsl:if>
                </citation>
                
                <!-- Study Information -->
                <stdyInfo>
                    <!-- Subject/Keywords -->
                    <xsl:if test="dc:subjects/dc:subject">
                        <subject>
                            <xsl:for-each select="dc:subjects/dc:subject">
                                <xsl:choose>
                                    <xsl:when test="@subjectScheme">
                                        <topcClas>
                                            <xsl:if test="@subjectScheme">
                                                <xsl:attribute name="vocab">
                                                    <xsl:value-of select="@subjectScheme"/>
                                                </xsl:attribute>
                                            </xsl:if>
                                            <xsl:if test="@schemeURI">
                                                <xsl:attribute name="vocabURI">
                                                    <xsl:value-of select="@schemeURI"/>
                                                </xsl:attribute>
                                            </xsl:if>
                                            <xsl:value-of select="."/>
                                        </topcClas>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <keyword>
                                            <xsl:if test="@xml:lang">
                                                <xsl:attribute name="xml:lang">
                                                    <xsl:value-of select="@xml:lang"/>
                                                </xsl:attribute>
                                            </xsl:if>
                                            <xsl:value-of select="."/>
                                        </keyword>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </subject>
                    </xsl:if>
                    
                    <!-- Abstract -->
                    <xsl:for-each select="dc:descriptions/dc:description[@descriptionType='Abstract']">
                        <abstract>
                            <xsl:if test="@xml:lang">
                                <xsl:attribute name="xml:lang">
                                    <xsl:value-of select="@xml:lang"/>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:if test="//dc:dates/dc:date[@dateType='Submitted']">
                                <xsl:attribute name="date">
                                    <xsl:value-of select="//dc:dates/dc:date[@dateType='Submitted']"/>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="."/>
                        </abstract>
                    </xsl:for-each>
                    
                    <!-- Time Period Covered -->
                    <xsl:if test="dc:dates/dc:date[@dateType='Collected']">
                        <sumDscr>
                            <timePrd>
                                <xsl:attribute name="event">start</xsl:attribute>
                                <xsl:value-of select="dc:dates/dc:date[@dateType='Collected']"/>
                            </timePrd>
                        </sumDscr>
                    </xsl:if>
                    
                    <!-- Geographic Coverage -->
                    <xsl:if test="dc:geoLocations/dc:geoLocation">
                        <sumDscr>
                            <xsl:for-each select="dc:geoLocations/dc:geoLocation">
                                <xsl:if test="dc:geoLocationPlace">
                                    <geogCover>
                                        <xsl:value-of select="dc:geoLocationPlace"/>
                                    </geogCover>
                                </xsl:if>
                                <xsl:if test="dc:geoLocationBox">
                                    <geoBndBox>
                                        <westBL>
                                            <xsl:value-of select="dc:geoLocationBox/dc:westBoundLongitude"/>
                                        </westBL>
                                        <eastBL>
                                            <xsl:value-of select="dc:geoLocationBox/dc:eastBoundLongitude"/>
                                        </eastBL>
                                        <southBL>
                                            <xsl:value-of select="dc:geoLocationBox/dc:southBoundLatitude"/>
                                        </southBL>
                                        <northBL>
                                            <xsl:value-of select="dc:geoLocationBox/dc:northBoundLatitude"/>
                                        </northBL>
                                    </geoBndBox>
                                </xsl:if>
                                <xsl:if test="dc:geoLocationPoint">
                                    <geogUnit>
                                        <xsl:value-of select="dc:geoLocationPoint/dc:pointLatitude"/>
                                        <xsl:text>, </xsl:text>
                                        <xsl:value-of select="dc:geoLocationPoint/dc:pointLongitude"/>
                                    </geogUnit>
                                </xsl:if>
                            </xsl:for-each>
                        </sumDscr>
                    </xsl:if>
                </stdyInfo>
                
                <!-- Method -->
                <xsl:if test="dc:descriptions/dc:description[@descriptionType='Methods']">
                    <method>
                        <dataColl>
                            <xsl:for-each select="dc:descriptions/dc:description[@descriptionType='Methods']">
                                <collMode>
                                    <xsl:value-of select="."/>
                                </collMode>
                            </xsl:for-each>
                        </dataColl>
                    </method>
                </xsl:if>
                
                <!-- Data Access -->
                <dataAccs>
                    <xsl:if test="dc:rightsList/dc:rights">
                        <useStmt>
                            <xsl:for-each select="dc:rightsList/dc:rights">
                                <xsl:if test="text()">
                                    <conditions>
                                        <xsl:if test="@xml:lang">
                                            <xsl:attribute name="xml:lang">
                                                <xsl:value-of select="@xml:lang"/>
                                            </xsl:attribute>
                                        </xsl:if>
                                        <xsl:value-of select="."/>
                                    </conditions>
                                </xsl:if>
                                <xsl:if test="@rightsURI">
                                    <restrctn>
                                        <xsl:value-of select="@rightsURI"/>
                                    </restrctn>
                                </xsl:if>
                            </xsl:for-each>
                        </useStmt>
                    </xsl:if>
                </dataAccs>
                
                <!-- Other Study Materials (Related Identifiers) -->
                <xsl:if test="dc:relatedIdentifiers/dc:relatedIdentifier">
                    <othrStdyMat>
                        <xsl:for-each select="dc:relatedIdentifiers/dc:relatedIdentifier">
                            <xsl:choose>
                                <xsl:when test="@relationType='IsSupplementTo' or @relationType='IsSupplementedBy' or @relationType='References' or @relationType='IsReferencedBy'">
                                    <relMat>
                                        <xsl:call-template name="format-related-identifier">
                                            <xsl:with-param name="identifier" select="."/>
                                            <xsl:with-param name="type" select="@relatedIdentifierType"/>
                                        </xsl:call-template>
                                    </relMat>
                                </xsl:when>
                                <xsl:when test="@relationType='IsCitedBy' or @relationType='Cites'">
                                    <relPubl>
                                        <xsl:call-template name="format-related-identifier">
                                            <xsl:with-param name="identifier" select="."/>
                                            <xsl:with-param name="type" select="@relatedIdentifierType"/>
                                        </xsl:call-template>
                                    </relPubl>
                                </xsl:when>
                                <xsl:when test="@relationType='IsPartOf' or @relationType='HasPart' or @relationType='IsVersionOf' or @relationType='HasVersion'">
                                    <relStdy>
                                        <xsl:call-template name="format-related-identifier">
                                            <xsl:with-param name="identifier" select="."/>
                                            <xsl:with-param name="type" select="@relatedIdentifierType"/>
                                        </xsl:call-template>
                                    </relStdy>
                                </xsl:when>
                                <xsl:otherwise>
                                    <othRefs>
                                        <xsl:call-template name="format-related-identifier">
                                            <xsl:with-param name="identifier" select="."/>
                                            <xsl:with-param name="type" select="@relatedIdentifierType"/>
                                        </xsl:call-template>
                                    </othRefs>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </othrStdyMat>
                </xsl:if>
            </stdyDscr>
            
            <!-- File Description -->
            <xsl:if test="dc:formats/dc:format or dc:sizes/dc:size">
                <fileDscr>
                    <fileTxt>
                        <xsl:if test="dc:formats/dc:format">
                            <xsl:for-each select="dc:formats/dc:format">
                                <fileType>
                                    <xsl:value-of select="."/>
                                </fileType>
                            </xsl:for-each>
                        </xsl:if>
                    </fileTxt>
                </fileDscr>
            </xsl:if>
            
        </codeBook>
    </xsl:template>
    
    <!-- Helper template: Output IDNo -->
    <xsl:template name="output-idno">
        <xsl:if test="//dc:identifier[@identifierType='DOI']">
            <IDNo agency="DOI">
                <xsl:text>doi:</xsl:text>
                <xsl:value-of select="//dc:identifier[@identifierType='DOI']"/>
            </IDNo>
        </xsl:if>
        <xsl:for-each select="//dc:alternateIdentifiers/dc:alternateIdentifier">
            <IDNo>
                <xsl:if test="@alternateIdentifierType">
                    <xsl:attribute name="agency">
                        <xsl:value-of select="@alternateIdentifierType"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
            </IDNo>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Helper template: Generate citation string -->
    <xsl:template name="generate-citation">
        <!-- Authors -->
        <xsl:for-each select="dc:creators/dc:creator">
            <xsl:choose>
                <xsl:when test="dc:creatorName">
                    <xsl:value-of select="dc:creatorName"/>
                </xsl:when>
                <xsl:when test="dc:familyName and dc:givenName">
                    <xsl:value-of select="dc:familyName"/>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="dc:givenName"/>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="position() != last()">
                <xsl:text>; </xsl:text>
            </xsl:if>
        </xsl:for-each>
        
        <!-- Year -->
        <xsl:text>, </xsl:text>
        <xsl:value-of select="dc:publicationYear"/>
        
        <!-- Title -->
        <xsl:text>, "</xsl:text>
        <xsl:value-of select="dc:titles/dc:title[not(@titleType)][1]"/>
        <xsl:text>"</xsl:text>
        
        <!-- DOI -->
        <xsl:if test="dc:identifier[@identifierType='DOI']">
            <xsl:text>, https://doi.org/</xsl:text>
            <xsl:value-of select="dc:identifier[@identifierType='DOI']"/>
        </xsl:if>
        
        <!-- Publisher -->
        <xsl:text>, </xsl:text>
        <xsl:value-of select="dc:publisher"/>
        
        <!-- Version -->
        <xsl:if test="dc:version">
            <xsl:text>, V</xsl:text>
            <xsl:value-of select="translate(dc:version, '.', '')"/>
        </xsl:if>
    </xsl:template>
    
    <!-- Helper template: Format related identifier -->
    <xsl:template name="format-related-identifier">
        <xsl:param name="identifier"/>
        <xsl:param name="type"/>
        <xsl:choose>
            <xsl:when test="$type = 'DOI'">
                <xsl:text>https://doi.org/</xsl:text>
                <xsl:value-of select="$identifier"/>
            </xsl:when>
            <xsl:when test="$type = 'URL'">
                <xsl:value-of select="$identifier"/>
            </xsl:when>
            <xsl:when test="$type = 'Handle'">
                <xsl:text>https://hdl.handle.net/</xsl:text>
                <xsl:value-of select="$identifier"/>
            </xsl:when>
            <xsl:when test="$type = 'ARK'">
                <xsl:text>https://n2t.net/</xsl:text>
                <xsl:value-of select="$identifier"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$type"/>
                <xsl:text>: </xsl:text>
                <xsl:value-of select="$identifier"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>

