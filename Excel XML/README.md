<div style="text-align:right;top: 10px;position: absolute;right: 10px;" markdown="1">
	<img align="right" src="http://www.smsmt.com/hs-fs/hubfs/SMS_Logo-1.png?t=1490163156935&amp;width=300&amp;name=SMS_Logo-1.png"/>
</div>

# Excel XML with Visualforce #
Until now, when you needed to export data into Excel, you probably have been creating viaulforce render as CSV. But at the end of the day, it's just a html page render as csv with a lot of limitations. Well here is a nice solution to create real Excel spreadsheet by using Excel XML. You will be able to create complex and real spreadsheet like you never did before in Visualforce and bring your skills to another level. It seems very complex to build but once you get the trick it's pretty cool. 

Before to start, there are 2 main issues you need to be aware of when you develop XML in Visualforce : 
1. `<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>`, which define xml version, must be set in a public variable on your controller. The reason is because Visualforce required a closing tag that is not required for this in XML. 
2. If you data contains sepcial characters, it won't be supported by XML, you need to use `HTMLENCODE`. 

Another thing I found very difficult when developping XML in Visualforce is the fact there is no proper way to debug. I would strongly recommend you to go one step at a time before you get lost in your code.  

### Setup Visualforce ###
The code below define the basic config for your VF page where your contentType must be set as `application/vnd.ms-excel#filename.xls`
```xml
<apex:page id="pg" standardStylesheets="false" controller="ExportToXLSController" 
    contenttype="application/vnd.ms-excel#TestExport_{!TODAY()}.xls">
{!xmlheader}
<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:o="urn:schemas-microsoft-com:office:office"
 xmlns:x="urn:schemas-microsoft-com:office:excel"
 xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:html="http://www.w3.org/TR/REC-html40">
</Workbook>
</apex:page>
```

### Define document properties ###
```xml
<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">
	<Author>David Browaeys</Author>
	<LastAuthor>David Browaeys</LastAuthor>
  	<Company>SMS</Company>
  	<Version>1.0</Version>
</DocumentProperties>

<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">
	<WindowHeight>16000</WindowHeight>
	<WindowWidth>20480</WindowWidth>
	<WindowTopX>400</WindowTopX>
	<WindowTopY>400</WindowTopY>
	<ProtectStructure>False</ProtectStructure>
	<ProtectWindows>False</ProtectWindows>
</ExcelWorkbook>
```

### Define multiple worksheets ###
The example below will define 2 tabs in your worksheet
```xml
<Worksheet ss:Name="Opportunities">
	<ss:Table>
    </ss:Table>
</Worksheet>
<Worksheet ss:Name="Cases">
	<ss:Table>
    </ss:Table>
</Worksheet>
```

### Adding Header ###
The code below define a worksheet with 3 columns
```xml
<Worksheet ss:Name="Opportunities">
	<ss:Table>
		<ss:Row>
            <ss:Cell>
                <ss:Data ss:Type=”String”>Opportunity Name</ss:Data>
            </ss:Cell>
            <ss:Cell>
                <ss:Data ss:Type=”String”>Amount</ss:Data>
            </ss:Cell>
            <ss:Cell>
                <ss:Data ss:Type=”String”>Date</ss:Data>
            </ss:Cell>
        </ss:Row>
    </ss:Table>
</ss:Worksheet>
```

### Adding Data ###
```xml
<Worksheet ss:Name="Opportunities">
  	<ss:Table>
		<ss:Row>
            <ss:Cell>
                <ss:Data ss:Type=”String”>Opportunity Name</ss:Data>
            </ss:Cell>
            <ss:Cell>
                <ss:Data ss:Type=”String”>Amount</ss:Data>
            </ss:Cell>
            <ss:Cell>
                <ss:Data ss:Type=”String”>Stage</ss:Data>
            </ss:Cell>
        </ss:Row>
		<apex:repeat value="{!opportunities}" var="opp">
			<Row>
				<Cell>
					<Data ss:Type="String">{!HTMLENCODE(opp.Name)}</Data>
				</Cell>
				<Cell>
					<Data ss:Type="Number">{!opp.Amount}</Data>
				</Cell>
				<Cell>
					<Data ss:Type="String">{!HTMLENCODE(opp.StageName)}</Data>
				</Cell>
			</Row>
		</apex:repeat>
	</Table>
</Worksheet>
```

### Define a bit of style ###
```xml
<Styles>
	<ss:Style ss:ID=”1″>
        <ss:Font ss:Bold=”1″/>
    </ss:Style>
</Styles>
```
Link style to a row/cell
```xml
<Worksheet ss:Name="Opportunities">
	<ss:Table>
		<ss:Row ss:StyleID=”1″>
            <ss:Cell>
                <ss:Data ss:Type=”String”>Opportunity Name</ss:Data>
            </ss:Cell>
            <ss:Cell>
                <ss:Data ss:Type=”String”>Amount</ss:Data>
            </ss:Cell>
            <ss:Cell>
                <ss:Data ss:Type=”String”>Date</ss:Data>
            </ss:Cell>
        </ss:Row>
    </ss:Table>
</ss:Worksheet>
```
You will find in the code more things like formula, cell selections, etc...

### Tip ###
Another way to work is instead of working on visualforce and get your head around styling and formula which might get complex very quickly. You can also work in Excel directly, save your document as Excel 2004 XML Spreasheet (.xml), then open your document in a Text Editor(Sublime) and copy the xml code into visualforce. 
