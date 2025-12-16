<?xml version="1.0" encoding="UTF-8"?>
<!--
    XSLT Transformation: DataCite 4.x to DDI Codebook 2.5 Application Profile from CESSDA Version:
v3.0.0
    https://cmv.cessda.eu/profiles/cdc/ddi-2.5/3.0.0/profile.xml
    
    This stylesheet transforms XML metadata from DataCite schema (kernel-4.x)
    to DDI Codebook 2.5 format following the CESSDA Data Catalogue profile Version: v3.0.0.
    
    Input:  DataCite XML (http://datacite.org/schema/kernel-4)
    Output: DDI Codebook 2.5 (ddi:codebook:2_5) XML
    
    Author: Lovable AI, Noemi Betancort
    Created: 2025-12-04
    
-->
<!-- 
    PURPOSE and USAGE
    This XSLT may benefit small data producers who want to create harvestable metadata for the 
    CESSDA data catalogue. Please note that DataCite does not provide variable information, 
    so the produced DDI Codebook instances only provide descriptions at the dataset/study level.

    The official distributions of this XSLT will be published in the dedicated GitHub
    repository: https://github.com/MetadataTransform/ddi-xslt/

    Progress can be followed at: https://github.com/ddi-developers/.github/issues/24
    Please use this issue to leave any comments or suggestions.

    This XSLT is work on progress.
-->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dtct4="http://datacite.org/schema/kernel-4"
    xmlns:dct="http://purl.org/dc/terms/"
    xmlns:dctype="http://purl.org/dc/dcmitype/"
    xmlns="ddi:codebook:2_5"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="dtct4">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <!-- Vars used for transforming strings into upper/lowercase -->

    <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

    <xsl:strip-space elements="*"/>

    <!-- Root template -->
    <xsl:template match="/">
        <xsl:apply-templates select="dtct4:resource"/>
    </xsl:template>

    <!-- Main resource template -->
    <xsl:template match="dtct4:resource">
        <codeBook xmlns="ddi:codebook:2_5"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="ddi:codebook:2_5 https://ddialliance.org/Specification/DDI-Codebook/2.5/XMLSchema/codebook.xsd"
            version="2.5">

            <!-- Document Description -->
            <docDscr>
                <citation>
                    <titlStmt>
                        <titl>
                            <xsl:choose>
                                <xsl:when test="@xml:lang">
                                    <xsl:attribute name="xml:lang">
                                        <xsl:value-of select="@xml:lang"/>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise><xsl:attribute name="xml:lang">en</xsl:attribute></xsl:otherwise>
                            </xsl:choose>CDC DDI Codebook 2.5. XML document for <xsl:value-of select="dtct4:titles/dtct4:title[not(@titleType)][1]"/>
                        </titl>
                        <xsl:call-template name="output-idno"/>
                    </titlStmt>
                    <distStmt>
                        <distrbtr source="archive">
                            <xsl:value-of select="dtct4:publisher"/>
                        </distrbtr>
                        <xsl:if test="dtct4:dates/dtct4:date[@dateType='Available']">
                            <distDate>
                                <xsl:value-of select="dtct4:dates/dtct4:date[@dateType='Available']"/>
                            </distDate>
                        </xsl:if>
                    </distStmt>
                    <verStmt source="archive">
                        <version>
                            <xsl:attribute name="date">
                                <xsl:choose>
                                    <xsl:when test="dtct4:dates/dtct4:date[@dateType='Available']">
                                        <xsl:value-of select="dtct4:dates/dtct4:date[@dateType='Available']"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="dtct4:publicationYear"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:attribute name="type">Available</xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="dtct4:version">
                                    <xsl:value-of select="dtct4:version"/>
                                </xsl:when>
                                <xsl:otherwise>1.0</xsl:otherwise>
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
                        <xsl:for-each select="dtct4:titles/dtct4:title[not(@titleType)][1]">
                            <titl>
                                <xsl:if test="@xml:lang">
                                    <xsl:attribute name="xml:lang">
                                        <xsl:value-of select="@xml:lang"/>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:value-of select="."/>
                            </titl>
                        </xsl:for-each>
                        <xsl:for-each select="dtct4:titles/dtct4:title[@titleType='Subtitle']">
                            <subTitl>
                                <xsl:if test="@xml:lang">
                                    <xsl:attribute name="xml:lang">
                                        <xsl:value-of select="@xml:lang"/>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:value-of select="."/>
                            </subTitl>
                        </xsl:for-each>
                        <xsl:for-each select="dtct4:titles/dtct4:title[@titleType='AlternativeTitle']">
                            <altTitl>
                                <xsl:if test="@xml:lang">
                                    <xsl:attribute name="xml:lang">
                                        <xsl:value-of select="@xml:lang"/>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:value-of select="."/>
                            </altTitl>
                        </xsl:for-each>
                        <xsl:call-template name="output-idno"/>
                    </titlStmt>

                    <!-- Responsibility Statement (Authors) -->
                    <xsl:if test="dtct4:creators/dtct4:creator">
                        <rspStmt>
                            <xsl:for-each select="dtct4:creators/dtct4:creator">
                                <AuthEnty>
                                    <xsl:if test="dtct4:affiliation">
                                        <xsl:attribute name="affiliation">
                                            <xsl:value-of select="dtct4:affiliation"/>
                                        </xsl:attribute>
                                    </xsl:if>
                                    <xsl:choose>
                                        <xsl:when test="dtct4:creatorName">
                                            <xsl:value-of select="dtct4:creatorName"/>
                                        </xsl:when>
                                        <xsl:when test="dtct4:familyName and dtct4:givenName">
                                            <xsl:value-of select="dtct4:familyName"/>
                                            <xsl:text>, </xsl:text>
                                            <xsl:value-of select="dtct4:givenName"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </AuthEnty>
                            </xsl:for-each>
                        </rspStmt>
                    </xsl:if>

                    <!-- Production Statement -->
                    <prodStmt>
                        <xsl:if test="dtct4:dates/dtct4:date[@dateType='Created']">
                            <prodDate>
                                <xsl:value-of select="dtct4:dates/dtct4:date[@dateType='Created']"/>
                            </prodDate>
                        </xsl:if>
                        <xsl:for-each select="dtct4:fundingReferences/dtct4:fundingReference">
                            <fundAg>
                                <xsl:if test="dtct4:awardNumber">
                                    <xsl:attribute name="abbr">
                                        <xsl:value-of select="dtct4:awardNumber"/>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:value-of select="dtct4:funderName"/>
                            </fundAg>
                            <xsl:if test="dtct4:awardTitle">
                                <grantNo>
                                    <xsl:value-of select="dtct4:awardTitle"/>
                                </grantNo>
                            </xsl:if>
                        </xsl:for-each>
                    </prodStmt>

                    <!-- Distribution Statement -->
                    <distStmt>
                        <distrbtr source="archive">
                            <xsl:choose>
                                <xsl:when test="@xml:lang">
                                    <xsl:attribute name="xml:lang">
                                        <xsl:value-of select="@xml:lang"/>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise><xsl:attribute name="xml:lang">en</xsl:attribute></xsl:otherwise>
                            </xsl:choose>
                            <xsl:value-of select="dtct4:publisher"/>
                        </distrbtr>
                        <xsl:for-each select="dtct4:contributors/dtct4:contributor[@contributorType='ContactPerson']">
                            <contact>
                                <xsl:choose>
                                    <xsl:when test="dtct4:contributorName">
                                        <xsl:value-of select="dtct4:contributorName"/>
                                    </xsl:when>
                                    <xsl:when test="dtct4:familyName and dtct4:givenName">
                                        <xsl:value-of select="dtct4:familyName"/>
                                        <xsl:text>, </xsl:text>
                                        <xsl:value-of select="dtct4:givenName"/>
                                    </xsl:when>
                                </xsl:choose>
                            </contact>
                        </xsl:for-each>
                        <xsl:for-each select="dtct4:dates/dtct4:date">
                            <xsl:if test="@dateType='Submitted'">
                                <depDate>
                                    <xsl:attribute name="date"><xsl:value-of select="."/></xsl:attribute>
                                    <!--<xsl:value-of select="."/> datacite always provide standardised dates? -->
                                </depDate>
                            </xsl:if>
                            <xsl:if test="@dateType='Available'">
                                <distDate>
                                    <xsl:attribute name="date"><xsl:value-of select="."/></xsl:attribute>
                                    <!--<xsl:value-of select="."/> datacite always provide standardised dates? -->
                                </distDate>
                            </xsl:if>
                        </xsl:for-each>
                    </distStmt>

                    <!-- Holdings (link) -->
                    <holdings>
                        <xsl:attribute name="URI">
                            <xsl:call-template name="identifier-URI">
                                <xsl:with-param name="identifier" select="normalize-space(.)"/>
                                <xsl:with-param name="type" select="normalize-space(translate(@identifierType,$uppercase, $lowercase))"/>
                            </xsl:call-template>
                        </xsl:attribute>
                    </holdings>
                </citation>

                <!-- Study Information -->
                <stdyInfo>
                    <!-- Subject/Keywords -->
                    <xsl:if test="dtct4:subjects/dtct4:subject">
                        <subject>
                            <xsl:for-each select="dtct4:subjects/dtct4:subject[not(@subjectScheme='CESSDA')]">
                                <keyword>
                                    <xsl:if test="@xml:lang">
                                        <xsl:attribute name="xml:lang">
                                            <xsl:value-of select="@xml:lang"/>
                                        </xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="."/>
                                </keyword>
                            </xsl:for-each>
                            <xsl:for-each select="dtct4:subjects/dtct4:subject[contains(@subjectScheme, 'CESSDA')]">
                                <topcClas>
                                    <xsl:if test="@xml:lang">
                                        <xsl:attribute name="xml:lang">
                                            <xsl:value-of select="@xml:lang"/>
                                        </xsl:attribute>
                                    </xsl:if>
                                    <xsl:attribute name="vocab">CESSDA Topic Classification</xsl:attribute>
                                    <xsl:if test="@schemeURI">
                                        <xsl:attribute name="vocabURI">
                                            <xsl:value-of select="@schemeURI"/>
                                        </xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="."/>
                                </topcClas>
                            </xsl:for-each>
                        </subject>
                    </xsl:if>

                    <!-- Abstract -->
                    <xsl:for-each select="dtct4:descriptions/dtct4:description[@descriptionType='Abstract']">
                        <abstract>
                            <xsl:if test="@xml:lang">
                                <xsl:attribute name="xml:lang">
                                    <xsl:value-of select="@xml:lang"/>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:if test="//dtct4:dates/dtct4:date[@dateType='Submitted']">
                                <xsl:attribute name="date">
                                    <xsl:value-of select="//dtct4:dates/dtct4:date[@dateType='Submitted']"/>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="."/>
                        </abstract>
                    </xsl:for-each>

                    <!-- Time Period Covered -->
                    <xsl:if test="dtct4:dates/dtct4:date[@dateType='Collected']">
                        <sumDscr>
                            <timePrd>
                                <xsl:attribute name="event">start</xsl:attribute>
                                <xsl:value-of select="dtct4:dates/dtct4:date[@dateType='Collected']"/>
                            </timePrd>
                        </sumDscr>
                    </xsl:if>

                    <!-- Geographic Coverage -->
                    <xsl:if test="dtct4:geoLocations/dtct4:geoLocation">
                        <sumDscr>
                            <xsl:for-each select="dtct4:geoLocations/dtct4:geoLocation">
                                <xsl:if test="dtct4:geoLocationPlace">
                                    <geogCover>
                                        <xsl:value-of select="dtct4:geoLocationPlace"/>
                                    </geogCover>
                                </xsl:if>
                                <xsl:if test="dtct4:geoLocationBox">
                                    <geoBndBox>
                                        <westBL>
                                            <xsl:value-of select="dtct4:geoLocationBox/dtct4:westBoundLongitude"/>
                                        </westBL>
                                        <eastBL>
                                            <xsl:value-of select="dtct4:geoLocationBox/dtct4:eastBoundLongitude"/>
                                        </eastBL>
                                        <southBL>
                                            <xsl:value-of select="dtct4:geoLocationBox/dtct4:southBoundLatitude"/>
                                        </southBL>
                                        <northBL>
                                            <xsl:value-of select="dtct4:geoLocationBox/dtct4:northBoundLatitude"/>
                                        </northBL>
                                    </geoBndBox>
                                </xsl:if>
                                <xsl:if test="dtct4:geoLocationPoint">
                                    <geogUnit>
                                        <xsl:value-of select="dtct4:geoLocationPoint/dtct4:pointLatitude"/>
                                        <xsl:text>, </xsl:text>
                                        <xsl:value-of select="dtct4:geoLocationPoint/dtct4:pointLongitude"/>
                                    </geogUnit>
                                </xsl:if>
                            </xsl:for-each>
                        </sumDscr>
                    </xsl:if>
                </stdyInfo>

                <!-- Method -->
                <xsl:if test="dtct4:descriptions/dtct4:description[@descriptionType='Methods']">
                    <method>
                        <dataColl>
                            <xsl:for-each select="dtct4:descriptions/dtct4:description[@descriptionType='Methods']">
                                <collMode>
                                    <xsl:if test="@xml:lang">
                                        <xsl:attribute name="xml:lang">
                                            <xsl:value-of select="@xml:lang"/>
                                        </xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="."/>
                                </collMode>
                            </xsl:for-each>
                        </dataColl>
                    </method>
                </xsl:if>

                <!-- Data Access -->
                <dataAccs>
                    <xsl:if test="dtct4:rightsList/dtct4:rights">
                        <useStmt>
                            <xsl:for-each select="dtct4:rightsList/dtct4:rights">
                                <xsl:if test="text() or @rightsURI">
                                    <restrctn>
                                        <xsl:if test="@xml:lang">
                                            <xsl:attribute name="xml:lang">
                                                <xsl:value-of select="@xml:lang"/>
                                            </xsl:attribute>
                                        </xsl:if>
                                        <xsl:choose>
                                            <xsl:when test="text() and @rightsURI"><xsl:value-of select="@rightsURI"/> = <xsl:value-of select="."/></xsl:when>
                                            <xsl:otherwise><xsl:value-of select="."/><xsl:value-of select="@rightsURI"/></xsl:otherwise>
                                        </xsl:choose>
                                    </restrctn>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:for-each select="dtct4:rightsList/dtct4:rights[contains(@rightsURI, 'eu-repo') or contains(., 'eu-repo')]">
                                <conditions xml:lang="en" elementVersion="info:eu-repo-Access-Terms vocabulary">
                                    <xsl:value-of select="@rightsURI"/>
                                </conditions>
                            </xsl:for-each>
                        </useStmt>
                    </xsl:if>
                </dataAccs>


                <!-- Other Study Materials (Related Identifiers) -->
                <xsl:if test="dtct4:relatedIdentifiers/dtct4:relatedIdentifier">
                    <othrStdyMat>
                        <xsl:for-each select="dtct4:relatedIdentifiers/dtct4:relatedIdentifier">
                            <xsl:choose>
                                <xsl:when test="@relationType='IsSupplementTo' or @relationType='IsSupplementedBy' or @relationType='References' or @relationType='IsReferencedBy'">
                                    <relMat>
                                        <xsl:call-template name="identifier-URI">
                                            <xsl:with-param name="identifier" select="normalize-space(.)"/>
                                            <xsl:with-param name="type" select="normalize-space(translate(@relatedIdentifierType,$uppercase, $lowercase))"/>
                                        </xsl:call-template>
                                    </relMat>
                                </xsl:when>
                                <xsl:when test="@relationType='IsCitedBy' or @relationType='Cites'">
                                    <relPubl>
                                        <xsl:call-template name="identifier-URI">
                                            <xsl:with-param name="identifier" select="normalize-space(.)"/>
                                            <xsl:with-param name="type" select="normalize-space(translate(@relatedIdentifierType, $uppercase, $lowercase))"/>
                                        </xsl:call-template>
                                    </relPubl>
                                </xsl:when>
                                <xsl:when test="@relationType='IsPartOf' or @relationType='HasPart' or @relationType='IsVersionOf' or @relationType='HasVersion'">
                                    <relStdy>
                                        <xsl:call-template name="identifier-URI">
                                            <xsl:with-param name="identifier" select="normalize-space(.)"/>
                                            <xsl:with-param name="type" select="normalize-space(translate(@relatedIdentifierType, $uppercase, $lowercase))"/>
                                        </xsl:call-template>
                                    </relStdy>
                                </xsl:when>
                                <xsl:otherwise>
                                    <othRefs>
                                        <xsl:call-template name="identifier-URI">
                                            <xsl:with-param name="identifier" select="normalize-space(.)"/>
                                            <xsl:with-param name="type" select="normalize-space(translate(@relatedIdentifierType, $uppercase, $lowercase))"/>
                                        </xsl:call-template>
                                    </othRefs>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </othrStdyMat>
                </xsl:if>
            </stdyDscr>

            <!-- File Description -->
            <xsl:if test="dtct4:formats/dtct4:format or dtct4:sizes/dtct4:size">
                <fileDscr>
                    <fileTxt>
                        <xsl:if test="dtct4:formats/dtct4:format">
                            <xsl:for-each select="dtct4:formats/dtct4:format">
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
        <xsl:if test="//dtct4:identifier[@identifierType='DOI']">
            <IDNo agency="DOI"><xsl:text>doi:</xsl:text><xsl:value-of select="//dtct4:identifier[@identifierType='DOI']"/></IDNo>
        </xsl:if>
        <xsl:for-each select="//dtct4:alternateIdentifiers/dtct4:alternateIdentifier">
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
        <xsl:for-each select="dtct4:creators/dtct4:creator">
            <xsl:choose>
                <xsl:when test="dtct4:creatorName">
                    <xsl:value-of select="dtct4:creatorName"/>
                </xsl:when>
                <xsl:when test="dtct4:familyName and dtct4:givenName">
                    <xsl:value-of select="dtct4:familyName"/>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="dtct4:givenName"/>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="position() != last()">
                <xsl:text>; </xsl:text>
            </xsl:if>
        </xsl:for-each>

        <!-- Year -->
        <xsl:text>, </xsl:text>
        <xsl:value-of select="dtct4:publicationYear"/>

        <!-- Title -->
        <xsl:text>, "</xsl:text>
        <xsl:value-of select="dtct4:titles/dtct4:title[not(@titleType)][1]"/>
        <xsl:text>"</xsl:text>

        <!-- DOI -->
        <xsl:if test="dtct4:identifier[@identifierType='DOI']">
            <xsl:text>, https://doi.org/</xsl:text>
            <xsl:value-of select="dtct4:identifier[@identifierType='DOI']"/>
        </xsl:if>

        <!-- Publisher -->
        <xsl:text>, </xsl:text>
        <xsl:value-of select="dtct4:publisher"/>

        <!-- Version -->
        <xsl:if test="dtct4:version">
            <xsl:text>, V</xsl:text>
            <xsl:value-of select="translate(dtct4:version, '.', '')"/>
        </xsl:if>
    </xsl:template>

    <!-- Helper template: Format related identifier -->
    <xsl:template name="identifier-URI">
        <xsl:param name="identifier"/>
        <xsl:param name="type"/>
        <xsl:choose>
            <xsl:when test="$type = 'doi'">
                <xsl:text>https://doi.org/</xsl:text><xsl:value-of select="$identifier"/>
            </xsl:when>
            <xsl:when test="$type='url' or $type='purl' or $type='urn' or $type='lsid'">
                <xsl:value-of select="$identifier"/>
            </xsl:when>
            <xsl:when test="$type = 'handle'">
                <xsl:text>https://hdl.handle.net/</xsl:text><xsl:value-of select="$identifier"/>
            </xsl:when>
            <xsl:when test="$type = 'ark'">
                <xsl:text>https://n2t.net/</xsl:text><xsl:value-of select="$identifier"/>
            </xsl:when>
            <xsl:when test="$type = 'orcid'">
                <xsl:text>https://orcid.org/</xsl:text><xsl:value-of select="$identifier"/>
            </xsl:when>
            <xsl:when test="$type = 'isni'">
                <xsl:text>https://www.isni.org/</xsl:text><xsl:value-of select="$identifier"/>
            </xsl:when>
            <xsl:when test="$type = 'grid'">
                <xsl:text>https://www.grid.ac/institutes/</xsl:text><xsl:value-of select="$identifier"/>
            </xsl:when>
            <xsl:when test="contains($type, 'crossref') and contains($type, 'funder')">
                <xsl:text>https://doi.org/</xsl:text><xsl:value-of select="$identifier"/>
            </xsl:when>
            <xsl:when test="$type = 'ror'">
                <xsl:text>https://ror.org/</xsl:text><xsl:value-of select="$identifier"/>
            </xsl:when>
            <xsl:when test="$type = 'arxiv'">
                <xsl:text>http://arxiv.org/abs/</xsl:text><xsl:value-of select="$identifier"/>
            </xsl:when>
            <xsl:when test="$type = 'bibcode'">
                <xsl:text>http://adsabs.harvard.edu/abs/</xsl:text><xsl:value-of select="$identifier"/>
            </xsl:when>
            <xsl:when test="$type = 'pmid'">
                <xsl:text>http://www.ncbi.nlm.nih.gov/pubmed/</xsl:text><xsl:value-of select="$identifier"/>
            </xsl:when>
            <xsl:when test="$type = 'igsn'">
                <xsl:text>https://hdl.handle.net/10273/</xsl:text><xsl:value-of select="$identifier"/>
            </xsl:when>
            <xsl:when test="$type = 'istc'">
                <xsl:text>http://istc-search-beta.peppertag.com/ptproc/IstcSearch?tFrame=IstcListing&amp;tForceNewQuery=Yes&amp;esfIstc=</xsl:text><xsl:value-of select="$identifier"/>
            </xsl:when>
            <xsl:when test="$type = 'issn'">
                <xsl:text>http://issn.org/resource/ISSN/</xsl:text><xsl:value-of select="$identifier"/>
            </xsl:when>
            <xsl:when test="$type = 'lissn'">
                <xsl:text>http://issn.org/resource/ISSN-L/</xsl:text><xsl:value-of select="$identifier"/>
            </xsl:when>
            <xsl:when test="$type = 'isbn'">
                <xsl:text>urn:isbn:</xsl:text><xsl:value-of select="$identifier"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$type"/>
                <xsl:text>: </xsl:text>
                <xsl:value-of select="$identifier"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
