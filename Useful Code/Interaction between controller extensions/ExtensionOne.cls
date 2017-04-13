/**
  * Date         :  13-Apr-2017
  * Author       :  SMS Management & Technology
  * Description  :  Class register to use across controller extensions
  */
public with sharing class ExtensionOne{
    
    //variables
    private Register objRegister; // extension register instance
    public Account acc {get;set;}
    
    public ExtensionTwo extnTwo {
        get{
            return getExtensionTwo();
        }set;
    }
    
    /*
        @description : set the instance of second controller extension in register
    */
    public ExtensionOne(ApexPages.StandardController stdController){       
        Id accountId = stdController.getId();
        acc = (Account) stdController.getRecord();
        objRegister = Register.getInstance();
        objRegister.add(ExtensionOne.class, this);
    }
    
    /*
        @description : get instance of other extension to access its variables/methods
    */
    private ExtensionTwo getExtensionTwo() {
        return (ExtensionTwo) objRegister.get(ExtensionTwo .class);
    }
    
    public void debugAccount(){
        System.debug('** Account from ExtensionOne ==>'+ acc);
    }
}