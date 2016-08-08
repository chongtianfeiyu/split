package
{
	import com.bit101.components.Style;
	import com.bit101.components.TextArea;
	
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.NativeDragEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.setTimeout;
	
	import Util.png2atfUtil;
	
	public class split extends Sprite
	{

		private var s:Sprite;

		private var process:NativeProcess;
		private var dir:String;

		private var txt:TextArea;
		public function split()
		{
			Style.embedFonts = false;
			Style.fontName = "微软雅黑";
			Style.fontSize = 12;
			addEventListener(Event.ADDED_TO_STAGE,onAdd);
		}
		
		protected function onAdd(event:Event):void
		{
			txt = new TextArea(this,0,0,"请拖拽 png 文件到此窗口");
			txt.setSize(stage.stageWidth,stage.stageHeight);
			
			s = new Sprite();
			s.graphics.beginFill(0xeeeeee,0.1);
			s.graphics.drawRect(0,0,stage.stageWidth-11,stage.stageHeight);
			s.graphics.endFill();
			addChild(s);
			s.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, onDragIn);
			s.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, onDragDrop);
		}
		protected function onDragIn(e:NativeDragEvent):void
		{
			NativeDragManager.acceptDragDrop(e.target as InteractiveObject);
		}
		
		protected function onDragDrop(e:NativeDragEvent):void
		{
			var arr:Array = e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			
			var files:Array = e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			var f:File = files[0] as File;
			if(e.target == s){
				doit2(f);
			}
		}
		
		private function doit(f:File):void
		{
			var file:File = new File();
			file = file.resolvePath("C:/Windows/System32/cmd.exe");
			var nativePath:String = File.applicationDirectory.resolvePath("bat.bat").nativePath;
			
			var processArg:Vector.<String> = new Vector.<String>();
			processArg[0] = "/c";
			processArg[1] = nativePath;
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			info.executable = file;
			info.arguments = processArg;
			process = new NativeProcess();
			process.addEventListener(NativeProcessExitEvent.EXIT,packageOverHandler);
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA,outputHandler);
			process.start(info);
		}
		private function doit2(f:File):void
		{
			var file:File = File.applicationDirectory.resolvePath("split.exe");
			var nativePath:String = File.applicationDirectory.resolvePath("bat.bat").nativePath;
			
			txt.text += "\n\n开始切割:\n"+f.nativePath+"\n\n";
			redraw();
			
			var processArg:Vector.<String> = new Vector.<String>();
			processArg[0] = f.nativePath;
			processArg[1] = 256;
			dir = processArg[2] = f.nativePath.replace(f.name,"");
			processArg[3] = "map_"+(new File(dir)).name+"_";
			
//			return;
			
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			info.executable = file;
			info.arguments = processArg;
			process = new NativeProcess();
			process.addEventListener(NativeProcessExitEvent.EXIT,packageOverHandler);
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA,outputHandler);
			process.start(info);
		}
		
		protected function outputHandler(e:ProgressEvent):void
		{
			trace(process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable));
		}
		
		protected function redraw():void{
			setTimeout(function():void{
				txt.textField.scrollV = txt.textField.numLines+1;
			},55);
		}
		protected function packageOverHandler(e:NativeProcessExitEvent):void
		{
			txt.text += "\n\n切割完毕,准备转换  ATF ...\n\n\n";
			redraw();
			function converOK():void{
				convert_one_file();
			}
			function logOK(text:String):void{
				if(text=="" || text=="\n" || text=="\r\n" || text=="\r") return;
				txt.text += text;
				redraw();
			}
			function convert_one_file():void{
				if(list.length>0){
					var f:File = list.pop() as File;
					if(f.extension.toLowerCase()=="png" && f.name.indexOf("_")>=0){
						txt.text += "正在转换:"+f.nativePath+"\n";
						redraw();
						png2atfUtil.converAtf(workdir,f.nativePath,f.nativePath.replace(".png",".atf"),"d",false,false,1,converOK,logOK);
					}else{
						convert_one_file();
					}
				}else{
					txt.text += "\n\n★转换完成~~~\n\n";
					//writeMapJson(dir);
					redraw();
				}
			}
			if(e.exitCode==0){
				var list:Array;
				var d:File = new File(dir);
				var workdir:String = File.applicationDirectory.nativePath;
				list = d.getDirectoryListing();
				convert_one_file();
			}
		}
		
		private function writeMapJson(dir:String):void
		{
			var d:File = new File(dir);
			var arr:Array = [];
			var list:Array = d.getDirectoryListing();
			for (var i:int = 0; i < list.length; i++){
				var ff:File = list[i] as File;
				if(ff.name.indexOf("_")>0 && ff.name.toLowerCase().indexOf(".atf")>0){
					arr.push(ff.name);
				}
			}
			var ob:Object = {};
			ob.arr = arr;
			var resolvePath:File = d.resolvePath("map_"+d.name+".json");
			FileX.stringToFile(JSON.stringify(ob,null,"\t"),resolvePath);
		}
	}
}