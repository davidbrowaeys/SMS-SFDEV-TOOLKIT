public with sharing class ExportToXLSController {
    //Opportunity
    public Opportunity[] opportunities {get;set;}
    public Integer oppSize {get;set;}
    //Case
    public Case[] cases {get;set;}
    public Integer caseSize {get;set;}    

    //xls variables:
    public String xmlheader {get;set;}
    public String endfile{get;set;}

    public ExportToXLSController() {

        xmlheader ='<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
        endfile = '</Workbook>';

        opportunities = [SELECT Id, Name, StageName, Amount FROM Opportunity LIMIT 10];
        oppSize = opportunities.size();

        cases = [SELECT Id, CaseNumber, Priority FROM Case LIMIT 10];
        caseSize = cases.size();
    }
}