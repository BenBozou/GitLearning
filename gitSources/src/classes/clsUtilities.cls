public class clsUtilities{


    public static String generateGUID(String format){
 
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        
        String guid = '';
        
        for(Integer i = 0; i < format.length(); i++){
            guid += (format.charAt(i) == 97 ? h.subString(i, i+1) : format.subString(i, i+1));
        }
        
        //String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        
        return guid;
    }
}