# Stylesheet-Interpolator
A XSLT replacing placeholders in a XML with values from another XML.

This project is intended to provide a blueprint.
The explanation should help to adapt this to
your own project.

## Precautions

To perform the interpolation process an executor for the stylesheet is necessary.
Here [xmlstarlet](https://xmlstar.sourceforge.net/)
is used.

### Windows

`
choco install -y xmlstarlet
`

C:\ProgramData\chocolatey\lib\xmlstarlet.portable\tools\xmlstarlet-1.6.1\xml
### Linux

...

## Structure

### Properties XML

### XML with placeholders

### Stylesheet

## Run

`
C:\ProgramData\chocolatey\lib\xmlstarlet.portable\tools\xmlstarlet-1.6.1\xml tr interpol.xslt expressions.xml
`