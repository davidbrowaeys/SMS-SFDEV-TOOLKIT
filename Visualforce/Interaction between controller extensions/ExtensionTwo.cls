/**
  * Date         :  13-Apr-2017
  * Author       :  SMS Management & Technology
  * Description  :  Class register to use across controller extensions
  */
public with sharing class ExtensionTwo{
    
    private Register objRegister; // extension register instance
    
    public ExtensionOne extnOne {
        get{
            return getExtensionOne();
        }set;
    }
    
    /*
        @description : set the instance of second controller extension in register
    */
    public ExtensionTwo(ApexPages.StandardController stdController){
        objRegister = Register.getInstance();
        objRegister.add(ExtensionTwo.class, this);
    }
    
    /*
        @description : get instance of other extension to access its variables/methods
    */
    private ExtensionOne getExtensionOne() {
        return (ExtensionOne) objRegister.get(ExtensionOne.class);
    }
    
    public void debugAccountInfo(){
        // use extension one variables or methods
        System.debug('** Extension ==>'+extnOne);
        System.debug('** Account ==>'+extnOne.acc);
        extnOne.debugAccount();
    }
}