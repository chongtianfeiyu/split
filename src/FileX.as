package
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	/**
	 * 二进制或者字符串到文件的互转。
	 * 参数支持String类型的路径或者File类型，用法：
	 * 
	 * var str = FileX.FileToString( "c:/t.txt" );
	 * 	或：
	 * var str = FileX.FileToString(  new File("c:/t.txt")  );
	 */
	public class FileX
	{
		public static function bytesToFile(b:ByteArray,path:*):void{
			var f:File = (path is String)? new File(path):path;
			try{
				var s:FileStream = new FileStream();
				s.open(f,FileMode.WRITE);
				s.writeBytes(b);
				s.close();
			}catch(e:Error){
				trace(e);
			}
		}
		public static function stringToFile(str:String,path:*):void{
			var f:File = (path is String)? new File(path):path;
			var s:FileStream = new FileStream();
			try{
				s.open(f,FileMode.WRITE);
				s.writeUTFBytes(str);
				s.close();
			}catch(e:Error){
				s.close();
				trace(e);
			}
		}
		public static function FileToBytes(path:*):ByteArray{
			var f:File = (path is String)? new File(path):path;
			var s:FileStream = new FileStream();
			var b:ByteArray = new ByteArray();
			try{
				s.open(f,FileMode.READ);
				s.readBytes(b);
			}catch(e:Error){
				trace(e);
				return null;
			}
			return b;
		}
		public static function FileToString(path:*):String{
			var f:File = (path is String)? new File(path):path;
			var s:FileStream = new FileStream();
			var b:ByteArray = new ByteArray();
			try{
				s.open(f,FileMode.READ);
			}catch(e:Error){
				trace(e);
				return null;
			}
			return s.readUTFBytes(b.bytesAvailable);
		}
	}
}