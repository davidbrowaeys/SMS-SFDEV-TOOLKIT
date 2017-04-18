public class ApexPage{
	public static String getParameter(String p){
		return Apexpages.currentPage().getParameters().get(p);
	}
	public static String getUserAgent(){
		return Apexpages.currentPage().getHeaders().get('User-Agent');
	}
	public static String getHost(){
		return Apexpages.currentPage().getHeaders().get('Host');
	}
	public static String getRelativeUrl(){
		return Apexpages.currentPage().getUrl();
	}
	public static String getFullUrl(){
		return 'https://'+getHost()+getRelativeUrl();
	}
}