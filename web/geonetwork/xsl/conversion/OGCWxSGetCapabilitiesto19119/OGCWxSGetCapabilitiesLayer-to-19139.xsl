<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns    ="http://www.isotc211.org/2005/gmd"
										xmlns:gco="http://www.isotc211.org/2005/gco"
										xmlns:gts="http://www.isotc211.org/2005/gts"
										xmlns:gml="http://www.opengis.net/gml"
										xmlns:srv="http://www.isotc211.org/2005/srv"
										xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
										xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
										xmlns:wfs="http://www.opengis.net/wfs"
										xmlns:ows="http://www.opengis.net/ows"
										xmlns:wcs="http://www.opengis.net/wcs"
										xmlns:xlink="http://www.w3.org/1999/xlink"
										xmlns:date="http://exslt.org/dates-and-times"
										extension-element-prefixes="date wcs ows wfs srv">

	<!-- ============================================================================= -->

	<xsl:param name="uuid"/>
	<xsl:param name="Name"/>
	<xsl:param name="lang"/>
	<xsl:param name="topic"/>

	<!-- ============================================================================= -->

	<xsl:include href="resp-party.xsl"/>
	<xsl:include href="ref-system.xsl"/>
	<xsl:include href="identification.xsl"/>
	
	<!-- ============================================================================= -->

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
	
	<!-- ============================================================================= -->

	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>

	<!-- ============================================================================= -->
	<xsl:template match="WMT_MS_Capabilities[//Layer/Name=$Name]|wfs:WFS_Capabilities[//wfs:FeatureType/wfs:Name=$Name]|wcs:WCS_Capabilities[//wcs:CoverageOfferingBrief/wcs:name=$Name]">
		
		<xsl:variable name="ows">
			<xsl:choose>
				<xsl:when test="name(.)='wfs:WFS_Capabilities'">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		
		<MD_Metadata>
			
			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

			<fileIdentifier>
				<gco:CharacterString><xsl:value-of select="$uuid"/></gco:CharacterString>
			</fileIdentifier>
		
			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

			<language>
				<gco:CharacterString><xsl:value-of select="$lang"/></gco:CharacterString>
			</language>

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

			<characterSet>
				<MD_CharacterSetCode codeList="./resources/codeList.xml#MD_CharacterSetCode" codeListValue="utf8" />
			</characterSet>

			<!-- parentIdentifier -->
			<!-- mdHrLv -->
            <hierarchyLevel>
                <MD_ScopeCode
                    codeList="./resources/codeList.xml#MD_ScopeCode"
                    codeListValue="dataset" />
            </hierarchyLevel>
      
			<!-- mdHrLvName -->

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

			<xsl:for-each select="//ContactInformation|//wcs:responsibleParty">
				<contact>
					<CI_ResponsibleParty>
						<xsl:apply-templates select="." mode="RespParty"/>
					</CI_ResponsibleParty>
				</contact>
			</xsl:for-each>
			<xsl:for-each select="//ows:ServiceProvider">
				<contact>
					<CI_ResponsibleParty>
						<xsl:apply-templates select="." mode="RespParty"/>
					</CI_ResponsibleParty>
				</contact>
			</xsl:for-each>
					

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
			<xsl:variable name="df">yyyy-MM-dd'T'HH:mm:ss</xsl:variable>
			<dateStamp>
				<xsl:choose> <!-- //FIXME function date-format is not always available -->
					<xsl:when test="function-available('date:date-format')">
						<gco:DateTime><xsl:value-of select="date:format-date(date:date-time(),$df)"/></gco:DateTime>
					</xsl:when>
					<xsl:otherwise>
						<gco:DateTime>
							<xsl:value-of select="date:date-time()"/>
						</gco:DateTime>
					</xsl:otherwise>
				</xsl:choose>
			</dateStamp>

			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

			<metadataStandardName>
				<gco:CharacterString>ISO 19115:2003/19139</gco:CharacterString>
			</metadataStandardName>

			<metadataStandardVersion>
				<gco:CharacterString>1.0</gco:CharacterString>
			</metadataStandardVersion>

			<!-- spatRepInfo-->
			<!-- TODO - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

			<xsl:for-each select="refSysInfo">
				<referenceSystemInfo>
					<MD_ReferenceSystem>
						<xsl:apply-templates select="." mode="RefSystemTypes"/>
					</MD_ReferenceSystem>
				</referenceSystemInfo>
			</xsl:for-each>

			<!--mdExtInfo-->
			<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

			<identificationInfo>
				<MD_DataIdentification>
					<xsl:apply-templates select="." mode="LayerDataIdentification">
						<xsl:with-param name="Name"><xsl:value-of select="$Name"/></xsl:with-param>
						<xsl:with-param name="topic"><xsl:value-of select="$topic"/></xsl:with-param>	
						<xsl:with-param name="ows"><xsl:value-of select="$ows"/></xsl:with-param>					
					</xsl:apply-templates>
				</MD_DataIdentification>
			</identificationInfo>
		
			<!--contInfo-->
			<!--distInfo -->
			<distributionInfo>
				<MD_Distribution>
					<distributionFormat>
						<MD_Format>
							<name gco:nilReason="missing">
								<gco:CharacterString/>
							</name>
							<version gco:nilReason="missing">
								<gco:CharacterString/>
							</version>
						</MD_Format>
					</distributionFormat>
					<transferOptions>
						<MD_DigitalTransferOptions>
							<onLine>
								<CI_OnlineResource>
									<linkage>
										<URL>
											<xsl:choose>
												<xsl:when test="$ows='true'">
													<xsl:value-of select="//ows:Operation[@name='GetFeature']/ows:DCP/ows:HTTP/ows:Get/@xlink:href"/>
												</xsl:when>
												<xsl:when test="name(.)='WFS_Capabilities'">
													<xsl:value-of select="//wfs:GetFeature/wfs:DCPType/wfs:HTTP/wfs:Get/@onlineResource"/>
												</xsl:when>
												<xsl:when test="name(.)='WMT_MS_Capabilities'">
													<xsl:value-of select="//GetMap/DCPType/HTTP/Get/OnlineResource/@xlink:href"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="//wcs:GetCoverage/wcs:DCPType/wcs:HTTP/wcs:Get/wcs:OnlineResource/@xlink:href"/>
												</xsl:otherwise>
											</xsl:choose>
										</URL>										
									</linkage>
									<protocol>
									<xsl:choose>
										<xsl:when test="name(.)='WMT_MS_Capabilities'">
											<gco:CharacterString>OGC:WMS-1.1.1-http-get-map</gco:CharacterString>
										</xsl:when>
										<xsl:when test="$ows='true'">
											<gco:CharacterString>OGC:WFS-1.1.0-http-get-feature</gco:CharacterString>
										</xsl:when>
										<xsl:when test="name(.)='WFS_Capabilities'">
											<gco:CharacterString>OGC:WMS-1.0.0-http-get-feature</gco:CharacterString>
										</xsl:when>
										<xsl:otherwise>
											<gco:CharacterString>OGC:WCS-1.0.0-http-get-coverage</gco:CharacterString>
										</xsl:otherwise>
									</xsl:choose>
									</protocol>
									<name>
										<gco:CharacterString><xsl:value-of select="$Name"/></gco:CharacterString>
									</name>
									<description>
										<gco:CharacterString>
											<xsl:choose>
												<xsl:when test="name(.)='WFS_Capabilities' or $ows='true'">
													<xsl:value-of select="//wfs:FeatureType[wfs:Name=$Name]/wfs:Title"/>
												</xsl:when>
												<xsl:when test="name(.)='WMT_MS_Capabilities'">
													<xsl:value-of select="//Layer[Name=$Name]/Title"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="//wcs:CoverageOfferingBrief[wcs:name=$Name]/wcs:description"/>
												</xsl:otherwise>
											</xsl:choose>
										</gco:CharacterString>
									</description>
								</CI_OnlineResource>
							</onLine>
						</MD_DigitalTransferOptions>
					</transferOptions>
				</MD_Distribution>
			</distributionInfo>
		
			<!--dqInfo-->
			<dataQualityInfo>
				<DQ_DataQuality>
					<scope>
						<DQ_Scope>
							<level>
								<MD_ScopeCode codeListValue="dataset"
									codeList="./resources/codeList.xml#MD_ScopeCode" />
							</level>
						</DQ_Scope>
					</scope>
					<lineage>
						<LI_Lineage>
							<statement gco:nilReason="missing">
								<gco:CharacterString/>
							</statement>
						</LI_Lineage>
					</lineage>
				</DQ_DataQuality>
			</dataQualityInfo>
			<!--mdConst -->
			<!--mdMaint-->

		</MD_Metadata>
	</xsl:template>
	
	<!-- ============================================================================= -->

</xsl:stylesheet>
