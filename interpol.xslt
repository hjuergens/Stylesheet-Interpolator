<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <!-- https://stackoverflow.com/questions/8945645/how-to-map-values-of-an-xml-attribute-to-some-other-values -->

    <!-- https://stackoverflow.com/questions/4994919/how-to-use-attribute-values-from-another-xml-file-as-an-element-value-selection -->
    <xsl:key name="k1" match="property" use="@key"/>

    <xsl:variable name="lookupDoc" select="document('./properties.xml')"/>

    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <!--
    <xsl:template match="@*[and(starts-with(.,'${'),ends-with(.,'}'))   contains(.,'$')]">
    -->

    <!-- https://stackoverflow.com/questions/615875/xslt-how-to-change-an-attribute-value-during-xslcopy
    https://stackoverflow.com/questions/13682326/doing-an-if-else-condition-match-in-xslt
    -->

    <xsl:template match="@*[contains(.,'$')]">
        <xsl:attribute name="{name()}">
            <xsl:call-template name="replaceTokenDelims">
                <xsl:with-param name="pStrIterate" select="."/>
            </xsl:call-template>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="replaceTokenDelims">
        <xsl:param name="pStrIterate"/>

        <xsl:variable name="vDefaultPre"  select="substring-before($pStrIterate,'${')"/>
        <xsl:value-of select="$vDefaultPre"/>

        <xsl:variable name="vDefaultPost" select="substring-after($pStrIterate,'}')"/>

        <xsl:variable name="vKeyName" select="substring-before(substring-after($pStrIterate,'${'),'}')"/>
        <xsl:for-each select="$lookupDoc">
            <xsl:value-of select="key('k1', $vKeyName)/@value"/>
        </xsl:for-each>

        <xsl:choose>
            <xsl:when test="contains($vDefaultPost,'$')">
                <xsl:call-template name="replaceTokenDelims">
                    <xsl:with-param name="pStrIterate" select="$vDefaultPost"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$vDefaultPost"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


</xsl:stylesheet>
