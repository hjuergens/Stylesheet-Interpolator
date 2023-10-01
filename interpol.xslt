<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:variable name="lookupDoc" select="document('./properties.xml')"/>
    <xsl:key name="k1" match="property" use="@key"/>

    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <!--
    <xsl:template match="@*[and(starts-with(.,'${'),ends-with(.,'}'))   contains(.,'$')]">
    -->

    <xsl:template match="@*[contains(.,'${') and contains(.,'}')]">
        <xsl:attribute name="{name()}">
            <xsl:call-template name="variableExpansion">
                <xsl:with-param name="pStrIterate" select="."/>
            </xsl:call-template>
        </xsl:attribute>
    </xsl:template>

    <!-- https://www.data2type.de/xml-xslt-xslfo/xslt/xslt-und-xpath-referenz/alphabetische-liste/substring-after -->
    <xsl:template name="variableExpansion">
        <xsl:param name="pStrIterate"/>

        <xsl:variable name="vDefaultPre"  select="substring-before($pStrIterate,'${')"/>
        <xsl:value-of select="$vDefaultPre"/>

        <!--xsl:variable name="vDefaultPost">
        <xsl:if test="string-length($vDefaultPre) > 0">
            <xsl:value-of select="substring-after($pStrIterate,'}')"/>
        </xsl:if>
        </xsl:variable-->
        <xsl:variable name="vDefaultPost" select="substring-after($pStrIterate,'}')"/>

        <xsl:variable name="vKeyName" select="substring-before(substring-after($pStrIterate,'${'),'}')"/>
        <xsl:for-each select="$lookupDoc">
            <xsl:value-of select="key('k1', $vKeyName)/@value"/>
        </xsl:for-each>

        <!--
        <xsl:if test="$vDefaultPost">
            <xsl:call-template name="variableExpansion">
                <xsl:with-param name="pStrIterate" select="$vDefaultPost"/>
            </xsl:call-template>
        </xsl:if>
    -->

        <xsl:choose>
            <xsl:when test="contains($vDefaultPost,'${') and contains($vDefaultPost,'}')">
                <xsl:call-template name="variableExpansion">
                    <xsl:with-param name="pStrIterate" select="$vDefaultPost"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$vDefaultPost"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


</xsl:stylesheet>