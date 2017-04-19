/**
  * Date         :  13-Apr-2017
  * Author       :  SMS Management & Technology
  * Description  :  Class register to use across controller extensions
  */
public class Register{
    
    //variables
    private static Register instance;
    private Map<Type,Object> objMap = new Map<Type,Object>();
    
    /*
        @description : Singleton pattern to create instance for a transaction
    */
    public static Register getInstance(){
        if(instance == null){
            instance = new Register();
        }
        return instance;
    }

    public void add(Type key,Object value){
        objMap.put(key,value);
    }
    
    public Object get(Type key){
        return objMap.get(key);
    }
}