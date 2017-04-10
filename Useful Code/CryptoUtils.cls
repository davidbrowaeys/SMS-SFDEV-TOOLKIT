/**
* @author davidbrowaeys[SMS]
* @description Utility class that deals with cryptographic functions.
*/
public abstract class CryptoUtils {
	/**
	 * @description Encrypte data using an encryption key defined in a Label
	 * @usage EncodingUtil.urlEncode(CryptoUtils.encryptedData(record.Id),'UTF-8');
	*/	
	public static String encryptedData(String value){
       Blob cryptoKey = Blob.valueOf(Label.Encryption_Key);
	        
        // Generate the data to be encrypted.
        Blob data = Blob.valueOf(value);
        // Encrypt the data and have Salesforce.com generate the initialization vector
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', cryptoKey,data);
        
        return Encodingutil.base64Encode(encryptedData);
    }
    /**
	 * @description Decrypte data using an encryption key defined in a Label
	 * @usage String contactId = CryptoUtil.decryptedData(encryptedContactId);
	*/
    public static String decryptedData(String value){
        Blob cryptoKey = Blob.valueOf(Label.Encryption_Key);
        
        Blob data = EncodingUtil.base64Decode(value);
        
        // Decrypt the data - the first 16 bytes contain the initialization vector
        Blob decryptedData = Crypto.decryptWithManagedIV('AES128', cryptoKey, data);
        
        // Decode the decrypted data for subsequent use
        return decryptedData.toString();
    }
	/** 
	 * @description Field separator for the hash. 
	*/
	public static final String SEP = '|';
	/**
	 * @description Generates a strong, unguessable, globally unique hash for the given piece of identifier data (e.g. a SF ID).
	 *
	 * According to this page:
	 * http://stackoverflow.com/questions/4014090/is-it-safe-to-ignore-the-possibility-of-sha-collisions-in-practice
	 *
	 * The probability of the below hash function generating a single collision in practice will be
	 * much less than 1*10^(-60).
	 *
	 * "If we have a "perfect" hash function with output size n, and we have p messages to
	 * hash (individual message length is not important), then probability of collision is
	 * about (p^2)/(2^(n+1)) (this is an approximation which is valid for "small" p, i.e. substantially
	 * smaller than 2^(n/2)). For instance, with SHA-256 (n=256) and one billion messages (p=10^9)
	 * then the probability is about 4.3*10-60."
	 *
	 * This function will generate unique hashes without unique input, but you probably want to use unique input
	 * to be extra paranoid.
	 *
	 * The output of this function is case-sensitive, and contains alphanumeric mixed case characters. A total of
	 * less than 60 characters are generated (usually 51 or 52, but that's implementation detail).
	 */
	public static String generateHashFor(String inputData) {
		// longs are 64-bit, so to generate 256 bits of entropy I need 4 of them.
		Long rand = Crypto.getRandomLong();
		Long rand2 = Crypto.getRandomLong();
		Long rand3 = Crypto.getRandomLong();
		Long rand4 = Crypto.getRandomLong();
		Long rand5 = Math.mod(Crypto.getRandomLong(), 1000000); // somewhat gratuitous
		String input = inputData + SEP + rand + SEP + rand2 + SEP + rand3 + SEP + rand4 + SEP + System.currentTimeMillis();
		String ret = EncodingUtil.base64Encode(Crypto.generateDigest('SHA-256', Blob.valueOf(input))) + EncodingUtil.base64Encode(Blob.valueOf('' + rand5));
		ret = ret.replace('=', '').replace('/', '8').replace('+', '7').replace('-', '6'); // for URL safety
		return ret;
	}
	/**
	 * @description Generates a 67-bit, 12 character, lowercase hash. Less secure than generateHashFor but still has a space of 1.5 x 10^20.
	 */
	public static String generateShortHashFor(String inputData) {
		// longs are 64-bit
		Long rand = Crypto.getRandomLong();
		Long rand2 = Crypto.getRandomLong();
		String input = inputData + SEP + rand + SEP + rand2 + SEP + System.currentTimeMillis();
		String ret = EncodingUtil.base64Encode(Crypto.generateDigest('SHA-256', Blob.valueOf(input)));
		ret = ret.replace('=', '').replace('/', '8').replace('+', '7').replace('-', '6'); // for URL safety
		return ret.substring(2, 14).toLowerCase();
	}
	/**
	 * @description Generates a strong, unguessable, globally unique ID for the given item.
	 */
	private static String generateUniqueId(SObject rec, String fieldName) {
		return CryptoUtils.generateHashFor(rec.get(fieldName) + CryptoUtils.SEP + System.currentTimeMillis());
	}
	/**
	 * @description Generates a random number in the given range (inclusive).
	 * @usage Long myRandom = CryptoUtils.getRandom(0,1000000);
	 */
	public static Long getRandom(Long min, Long max) {
		return Math.abs(Math.mod(Crypto.getRandomLong(), max - min + 1)) + min;
	}
}