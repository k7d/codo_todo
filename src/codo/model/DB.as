package codo.model
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.utils.StringUtil;
	
	public class DB
	{
		private var con:SQLConnection;
		private var initCallback:Function;
		
		public function init(dbName:String, callback:Function):void
		{
			initCallback = callback;
			var dbFile:File = File.applicationStorageDirectory.resolvePath(dbName);
			con = new SQLConnection();
			
			con.addEventListener(SQLEvent.OPEN, function(event:SQLEvent): void {
				initStructures();
				callback(true);
			});
			
			con.addEventListener(SQLErrorEvent.ERROR, function(event:SQLEvent): void {
				callback(false);
			});
			
			con.open(dbFile);			
		}
		
		
		
		protected function initStructures(reset:Boolean=false): void {
			var st:SQLStatement = new SQLStatement();			
			st.sqlConnection = con;

			if (reset) {
				var resetScript: File = new File("app:/codo/model/scripts/reset.sql");
				executeScript(resetScript, st);				
			}
			
			st.text = "create table IF NOT EXISTS DBVersion (currentVersion VARCHAR(16) PRIMARY KEY)";
			st.execute();
			
			st.text = "select currentVersion from DBVersion";
			st.execute();
			
			var currentVersion: String;
			var data:Array = st.getResult().data;
			if (data && data.length > 0) {
				currentVersion = data[0].currentVersion; 
			} else {
				currentVersion = "00.00";
				st.text = "insert into DBVersion values ('00.00')";
				st.execute();
			}
			
			var newCurrentVersion:String = currentVersion;
			
			trace("current DB version:" + currentVersion);
			
			var scriptDir:File = new File("app:/codo/model/scripts/");
			
			var scripts:ArrayCollection = new ArrayCollection(scriptDir.getDirectoryListing());
			scripts.sort = new Sort();
			var sf:SortField = new SortField();
			sf.name = "name";
			scripts.sort.fields = [sf];
			scripts.refresh();

			var updateScripts:Array = new Array();
			for each (var script:File in scripts) {
				//var script:File = File(scripts.getItemAt(i));
				newCurrentVersion = script.name.substr(6,5);
				if (script.name.substr(0, 6) == 'update' && newCurrentVersion > currentVersion) {							
					updateScripts.push(script);
			 	}
			}

			for (var i:int = 0; i < updateScripts.length; i++) {
				executeScript(updateScripts[i], st);
			}						
			
			st.text = "update DBVersion set currentVersion = '" + newCurrentVersion + "'";
			st.execute();		
		}
		
		
		
		protected function executeScript(script:File, st:SQLStatement): void {
			trace("executing DB script " + script.name);
			
			var str: FileStream = new FileStream();
			str.open(script, FileMode.READ);
			
			var sql:String = str.readUTFBytes(str.bytesAvailable);
			
			var statements:Array = sql.split(";");
			
			for (var ii:uint = 0; ii < statements.length; ii++) {
				var s:String = StringUtil.trim(statements[ii]);
				if (s != '') {
					st.text = s;
					trace("executing SQL: " + s + ";");
					st.execute();						
				}
			}
			
			str.close();							
		}



		public function reset(): void {
			initStructures(true);
		}


		public function get connection(): SQLConnection
		{
			return con;
		}


		private static var _instance:DB = null;
		
		public static function get instance(): DB
		{
			if (!_instance) {
				_instance = new DB();
			}
			
			return _instance;
		}		 
	}
}