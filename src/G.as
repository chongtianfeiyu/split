package
{
	import flash.net.SharedObject;

	public class G
	{
		public static function SO(key:String,val:*=null):*{
			var so:SharedObject = flash.net.SharedObject.getLocal("split");
			if(val!=null){
				so.data[key] = val;
			}else{
				return so.data[key];
			}
		}
	}
}