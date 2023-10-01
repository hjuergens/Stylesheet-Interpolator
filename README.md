# Stylesheet-Interpolator
A XSLT replacing placeholders in a XML with values from another XML.

This project is intended to provide a blueprint.
The explanation should help to adapt this to
your own project.

## Precautions

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

```xml
<expressions>
    <option atti="${key}" text="no matching key"/>
    <dontcare stringliteral="abc-${currency}-def-${region}-ghi" text="multiple variable substitution"/>
</expressions>
```

### Stylesheet

Load the file containing the values of the variables.
Define a key which reflects the structure of the key-value-entries in that file.
```xml
    <xsl:variable name="lookupDoc" select="document('./properties.xml')"/>
    <xsl:key name="k1" match="property" use="@key"/>
```

The identity transformation copies every node not containing a placeholder.
```xml
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
```

The second template overrides the identity transformation.
```
<expressions>
    <option atti="${key}" text="no matching key"/>
    <dontcare stringliteral="abc-${currency}-def-${region}-ghi" text="multiple variable substitution"/>
</expressions>
```
## References

- https://stackoverflow.com/questions/8945645/how-to-map-values-of-an-xml-attribute-to-some-other-values 
- https://stackoverflow.com/questions/4994919/how-to-use-attribute-values-from-another-xml-file-as-an-element-value-selection 
- https://stackoverflow.com/questions/615875/xslt-how-to-change-an-attribute-value-during-xslcopy
- https://stackoverflow.com/questions/13682326/doing-an-if-else-condition-match-in-xslt


## Run

`
C:\ProgramData\chocolatey\lib\xmlstarlet.portable\tools\xmlstarlet-1.6.1\xml tr interpol.xslt expressions.xml
`