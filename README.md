# Stylesheet-Interpolator
A XSLT replacing placeholders in a XML with values from another XML.

This project is intended to provide a blueprint.
The explanation should help to adapt this to
your own project.

## Preparations

To perform the interpolation process an executor for the stylesheet is necessary.
Here [xmlstarlet](https://xmlstar.sourceforge.net/)
is used.

### Windows choco

```shell
choco install -y xmlstarlet
```

After installation the program can be found here:
```
%ChocolateyInstall%\lib\xmlstarlet.portable\tools\xmlstarlet-1.6.1\xml
```
### Linux apt

```shell
sudo apt update && sudo apt -y install xmlstarlet
```
## Structure

This project consist in three XML files:
* a file containing properties in nodes like this
  * `<property key="region" value="se" />` 
* a destination file with placeholders to replace
  * `<option atti="${region}"/>`
* a stylesheet which picks the values from the properties and insert them in the destination file.

### Properties XML

```xml
<properties>
    <property key="key1" value="value1" />
    <property key="region" value="se" />
    <property key="currency" value="SEK" />
</properties>
```
### XML with placeholders

Placeholder conforms the pattern `${`name of variable`}`. In this project they are only used in attributes values.
```xml
<expressions>
    <option atti="${key}" text="no matching key"/>
    <dontcare stringliteral="abc-${currency}-def-${region}-ghi" text="multiple variable substitution"/>
</expressions>
```
The name of the variable hat to exists in the lookup document as key. 
### Stylesheet

The stylesheet exists in three parts:
* reference the properties and define a key for access
* iterate over every placeholder
* just deep copy everything else

Load the file containing the values of the variables.
Define a key which reflects the structure of the key-value-entries in that file.
```xml
    <xsl:variable name="lookupDoc" select="document('./properties.xml')"/>
```
```xml
    <xsl:key name="k1" match="property" use="@key"/>
```

The identity transformation copies every node and every attribute not containing a placeholder.
```xml
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
```

The second template overrides the identity transformation on any attribute (`@*`) potentially containing a placeholder (`${` and `}`).
It reconstructs the attribute just caught, but with variables substituted.
This is the entry point for a recursion which iterates over the placeholders.
```xml
<xsl:template match="@*[contains(.,'${') and contains(.,'}')]">
  <xsl:attribute name="{name()}">
    <xsl:call-template name="variableExpansion">
      <xsl:with-param name="pStrIterate" select="."/>
    </xsl:call-template>
  </xsl:attribute>
</xsl:template>
```
The value of the match attribute is obviously far from perfect. A pattern that match only if
`${` and `} ` occur pairwise would be handy.

The variable interpolation take place in a template called '`variableExpansion`'.

The template considers three parts in the string literal (`<xsl:param name="pStrIterate"/>`)
* the string before `${`
  * just keep that part in the result string
* the string after a `${` `}` combination
  * let keep that part for the next iteration
* the string in between `${` `}`
  * let's see if we are lucky and find a replacement for that part

The lookup part seek into the document with key-value-pairs and perform the substitution or otherwise keep the placeholder string.

If the rest (the part after `${` `}`) contains further potential placeholders iterate, otherwise just keep the rest.
```xml
<xsl:template name="variableExpansion">
  <xsl:param name="pStrIterate"/>

  <xsl:variable name="vDefaultPre"  select="substring-before($pStrIterate,'${')"/>
  <xsl:value-of select="$vDefaultPre"/>

  <xsl:variable name="vDefaultPost" select="substring-after(substring-after($pStrIterate,'${'),'}')"/>

  <xsl:variable name="vKeyName" select="substring-before(substring-after($pStrIterate,'${'),'}')"/>
  <xsl:for-each select="$lookupDoc">
    <xsl:choose>
      <xsl:when test="key('k1', $vKeyName)/@value">
        <xsl:value-of select="key('k1', $vKeyName)/@value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>no key found - reconstruct the placeholder</xsl:message>
        <xsl:text>${</xsl:text><xsl:value-of select="$vKeyName"/><xsl:text>}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>

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
```

To make this easier to understand the following partly template contains comments on a example.
```xml
<xsl:template name="variableExpansion">
  <xsl:param name="pStrIterate"/>
  <!-- 1.Iteration: $pStrIterate = 'abc-${currency1}-def-${region}-ghi' -->
  <!-- 2.Iteration: $pStrIterate = '-def-${region}-ghi' -->

  <xsl:variable name="vDefaultPre"  select="substring-before($pStrIterate,'${')"/>
  <xsl:value-of select="$vDefaultPre"/>
  <!-- 1.Iteration: $vDefaultPre = 'abc-' -->
  <!-- 2.Iteration: $vDefaultPre = '-def-' -->

  <xsl:variable name="vDefaultPost" select="substring-after(substring-after($pStrIterate,'${'),'}')"/>
  <!-- 1.Iteration: $vDefaultPost = '-def-${region}-ghi' -->
  <!-- 2.Iteration: $vDefaultPost = '-ghi' -->

  <xsl:variable name="vKeyName" select="substring-before(substring-after($pStrIterate,'${'),'}')"/>
  <!-- 1.Iteration: $vKeyName = 'currency1' -->
  <!-- 2.Iteration: $vKeyName = 'region' -->
 ...
</xsl:template>
```
## Introduce Schemas

To ensure that `${` and `} ` occur pairwise in the text containing placeholders a XSD is used.

The crucial part in the `expressions.xsd` may look like this:
```XML
    <xs:attribute name="stringLiteral" use="required">
        <xs:simpleType>
            <xs:restriction base="xs:token">
                <xs:pattern value="[^${}]*(\$\{[^${}]+\}[^${}]*)*"/>
            </xs:restriction>
        </xs:simpleType>
    </xs:attribute>
```
The schema can be referenced in the destination xml.
```XML
<expressions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:noNamespaceSchemaLocation="expressions.xsd">
```


## References

"Personal performance is based on social achievements."

- https://stackoverflow.com/questions/8945645/how-to-map-values-of-an-xml-attribute-to-some-other-values 
- https://stackoverflow.com/questions/4994919/how-to-use-attribute-values-from-another-xml-file-as-an-element-value-selection 
- https://stackoverflow.com/questions/615875/xslt-how-to-change-an-attribute-value-during-xslcopy
- https://stackoverflow.com/questions/13682326/doing-an-if-else-condition-match-in-xslt


## Run

`
C:\ProgramData\chocolatey\lib\xmlstarlet.portable\tools\xmlstarlet-1.6.1\xml tr interpol.xslt expressions.xml
`
