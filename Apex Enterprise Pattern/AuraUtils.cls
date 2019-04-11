/**
* @author David Browaeys[JS]
* @date 30-Dec-18
* @group Aura
* @description This utility class includes methtods specific to Aura
*/
public class AuraUtils {
    /**
    * @author David Browaeys[JS]
    * @date 30-Dec-18
    * @group Aura
    * @description Aura error classes
    */
    public class AuraError{
        public String errorId;
        public String type;
        public String message;
        public AuraError(String errorId, String type, String message){
            this.errorId = errorId;
            this.type = type;
            this.message = message;
        }
    }
    /**
    * @author David Browaeys[JS]
    * @date 30-Dec-18
    * @description Throw an AuraHandledException
    * @paramm message string of the error message
    * @example AuraUtils.throwError('My error!');
    */
    public static void throwError(String message){
        AuraHandledException e  = new AuraHandledException(message);
        e.setMessage(message);
        throw e;   
    }
    /**
    * @author David Browaeys[JS]
    * @date 30-Dec-18
    * @description Throw an AuraHandledException
    * @paramm type string of the error type
    * @paramm message string of the error message
    * @example AuraUtils.throwError('UNKNOWN_ERROR','My error is important!');
    */
    public static void throwError(String type, String message){
        throwError(null,type,message);
    }
    /**
    * @author David Browaeys[JS]
    * @date 30-Dec-18
    * @description Throw an AuraHandledException
    * @param errorId string of the error id
    * @param type string of the error type
    * @param message string of the error message
    * @example AuraUtils.throwError('A_1234','UNKNOWN_ERROR','My error is important!');
    */
    public static void throwError(String errorId, String type, String message){
        throwError(JSON.serialize( new AuraError(errorId,type,message)));
    }

    /**
    * @author Bayani Cruz[JS]
    * @date 4-Mar-18
    * @description Throw an AuraHandledException
    * @param Exception object
    * @param SystemLog object
    * @param message string of the error message
    * @example AuraUtils.throwError('A_1234','UNKNOWN_ERROR','My error is important!');
    */
    public static void throwError(Exception e, SystemLog syslog, String message){
        syslog.addLogEvent(
                null,
                null,
                null,
                e.getMessage(), 
                SystemLog.Severity.ERROR, 
                e.getStackTraceString());

        syslog.insertLogEvents();

        throwError(null,Constants.SYS_ERR,message);
    }

}
