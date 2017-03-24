package classes.utils
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class ObjectUtils
	{
		/**
         *  @private
         *  Char codes for 0123456789ABCDEF
         */
        private static const ALPHA_CHAR_CODES:Array = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70];
        /**
		 *  Code from http://blog.byteface.com/?p=57
		 *
         *  <p>Generates a UID (unique identifier) based on ActionScript's
         *  pseudo-random number generator and the current time.</p>
         *
         *  <p>The UID has the form
         *  <code>"XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"</code>
         *  where X is a hexadecimal digit (0-9, A-F).</p>
         *
         *  <p>This UID will not be truly globally unique; but it is the best
         *  we can do without player support for UID generation.</p>
         *
         *  @return The newly-generated UID.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public static function createUID():String
        {
            var uid:Array = new Array(36);
            var index:int = 0;
           
            var i:int;
            var j:int;
           
            for (i = 0; i < 8; i++)
            {
                uid[index++] = ALPHA_CHAR_CODES[Math.floor(Math.random() *  16)];
            }
   
            for (i = 0; i < 3; i++)
            {
                uid[index++] = 45; // charCode for "-"
               
                for (j = 0; j < 4; j++)
                {
                    uid[index++] = ALPHA_CHAR_CODES[Math.floor(Math.random() *  16)];
                }
            }
           
            uid[index++] = 45; // charCode for "-"
   
            var time:Number = new Date().getTime();
            // Note: time is the number of milliseconds since 1970,
            // which is currently more than one trillion.
            // We use the low 8 hex digits of this number in the UID.
            // Just in case the system clock has been reset to
            // Jan 1-4, 1970 (in which case this number could have only
            // 1-7 hex digits), we pad on the left with 7 zeros
            // before taking the low digits.
            var timeString:String = ("0000000" + time.toString(16).toUpperCase()).substr(-8);
           
            for (i = 0; i < 8; i++)
            {
                uid[index++] = timeString.charCodeAt(i);
            }
           
            for (i = 0; i < 4; i++)
            {
                uid[index++] = ALPHA_CHAR_CODES[Math.floor(Math.random() *  16)];
            }
			//trace("unique id", String.fromCharCode.apply(null, uid));
            return String.fromCharCode.apply(null, uid);
        }
		
		public static function getClassName(obj:*) : String
		{
			var s : String = getQualifiedClassName(obj)
			var idx : int = s.indexOf("::")
			if ( idx >= 0)
				s = s.substr(idx+2)
			return s
		}
		
		public static function dump(obj:*) : Object
		{
			var xml : XML = describeType(obj)
			var variables : XMLList = xml..variable
			var newObj:Object = {}
			for each (var variable:XML in variables)
			{
				var attr:String = variable.@name
				var value : Object = obj[attr]
				newObj[attr] = value
			}
			var accessors : XMLList = xml..accessor
			for each (var accessor:XML in accessors)
			{
				attr = accessor.@name
				value = obj[attr]
				newObj[attr] = value
			}
			return newObj
		}

		/**
		 * Transpose an sealed object into an array of name:value pairs object
		 * to be displayed in an 'inspector' datagrid 
		 */
		public static function getObjectProperties(source:Object) : Array
		{
			var result : Array = []
			var classz : Class = ObjectUtils.getClass(source)
			var xml:XML =  describeType(classz).typeDescription
			
			for each (var node:XML in xml.factory..accessor)
			{
				result.push({name:node.@name,value:source[node.@name]})
			}
			for each (node in xml.factory..variable)
			{
				result.push({name:node.@name,value:source[node.@name]})
			}	
			for (var attr:String in source)
			{
				result.push({name:attr,value:source[attr]})
			}
			
			return result
		}
		
		public static function getProperties(classz:Class, readWriteOnly:Boolean=true) : Array
		{
			var result : Array = []
			var xml:XML =  describeType(classz).typeDescription
			
			for each (var node:XML in xml.factory..accessor)
			{
				if ( !readWriteOnly || (readWriteOnly && node.@access == "readwrite"))
				result.push(node.@name.toString())
			}
			for each (node in xml.factory..variable)
			{
				result.push(node.@name.toString())
			}	
			return result			
		}
		

		public static function getSerializableProperties(classz:Class) : Array
		{
			var result : Array = []
			var xml:XML =  describeType(classz).typeDescription
			
			for each (var node:XML in xml.factory..accessor)
			{
				if ( node.@access == "readwrite" && 
					 (node.@type == "int" || node.@type == "String" || node.@type == "Boolean" || 
					  node.@type == "Number")
					)
				result.push(node.@name.toString())
			}
			for each (node in xml.factory..variable)
			{
				if ( (node.@type == "int" || node.@type == "String" || node.@type == "Boolean" || 
					  node.@type == "Number")
					)				
				result.push(node.@name.toString())
			}	
			return result						
		}
		
		
		public static function toString(obj:*) : String
		{
			var dump : * = ObjectUtils.dump(obj)
			var s:String = ""
			for (var attr:String in dump)
				s += attr + ": " + dump[attr] + ", "
			for (attr in obj)
				s += attr + ": " + obj[attr] + ", "				
			return s
		}
		
		public static function hasInterface(source:Object, interfaceName:String) : Boolean
		{
			var result:Boolean = false 
			var xml:XML =  describeType(source).typeDescription//describeType(source)
			for each (var node:XML in xml..implementsInterface)
			{
				if ( node.@type == interfaceName )
				{
					result = true
					break
				}
			}
			return result 
		}
		
		public static function getClass(obj:Object) : Class
		{
			return getDefinitionByName(getQualifiedClassName(obj)) as Class		
		}
		
		
		public static function isDerivedClass(derivedClass:Class,baseClass:Class) : Boolean
		{
			var ok : Boolean = false			
			var xml:XML = describeType(derivedClass).typeDescription
			var baseClassName : String = getQualifiedClassName(baseClass)
			for each (var extendsNode : XML in xml.factory..extendsClass)
			{
				var parentClass:String = extendsNode.@type
				if ( parentClass == baseClassName )
				{
					ok = true
					break
				}
			}
			if ( !ok )
			{
				for each (extendsNode in xml..extendsClass)
				{
					parentClass = extendsNode.@type
					if ( parentClass == baseClassName )
					{
						ok = true
						break
					}
				}				
			}
			return ok
		}
		
		public static function isObjectCompatible(object:Object,baseClass:Class) : Boolean
		{
			var ok : Boolean = false			
			var objectClassName : String = getQualifiedClassName(object)
			var baseClassName : String = getQualifiedClassName(baseClass)
			if ( baseClassName == objectClassName )
			{
				ok = true
			}
			else
			{
				var objectClass : Class = ObjectUtils.getClass(object)				
				ok = ObjectUtils.isDerivedClass(objectClass,baseClass)
			}
			return ok
		}		
		
		public static function hasAttribute(voClass:Class, attribute:String) : Boolean
		{
			var xml:XML = describeType(voClass).typeDescription//describeType(voClass)
			for each (var node:XML in xml.factory..accessor)
			{
				if ( node.@name == attribute )
					return true
			}
			for each (node in xml.factory..variable)
			{
				if ( node.@name == attribute )
					return true
			}			
			return false
		}
		
		/**
		 * copy all properties of the given source object in the given destination object
		 */
		public static function copyProperties(src:Object, dst:Object):void {
			for (var prop:String in src) {
				dst[prop] = src[prop]
			}
		}
		
		public static function getBaseParentClass(target:Object) : Class {
			
			var xml:XML = describeType(target);
			var parentClassName:String
			if ( target == null )
				return null			
			var classz : Class = getClass(target)
			trace("getBaseParentClass:", classz);
			if ( classz == Object )
				return null
			if ( target is Class)
				parentClassName = xml.factory..extendsClass[0].@type
			else
				parentClassName = xml..extendsClass[0].@type
			
			var parentClass:Class
			if ( parentClassName != null && parentClassName.length != 0 ) 
				parentClass = getDefinitionByName(parentClassName) as Class
				
			trace("parentClass " + parentClass);
			return parentClass
		}
		
		//air  flash
		/*public static function hineritFromClass(target:Object, klass:Class) : Boolean 
		{
			trace(getClass(target));
			trace(getQualifiedSuperclassName(target))	
			trace(getQualifiedSuperclassName(getClass(target)))	
			return true;
		}*/
		
		public static function hineritFromClass(target:Object, klass:Class) : Boolean 
		{
			var xml:XML = describeType(target);
			var parentClassName:String
			if ( target == null )
				return false			
			var classz : Class = getClass(target)
			//trace(classz);
			if ( classz == Object )
				return false;
			if (classz == klass) return true;
			if ( target is Class)
				parentClassName = xml.factory..extendsClass[0].@type
			else
				parentClassName = xml..extendsClass[0].@type
			
			var parentClass:Class
			if ( parentClassName != null && parentClassName.length != 0 ) 
				parentClass = getDefinitionByName(parentClassName) as Class
			return  (parentClass == klass);	
		}
		
		public static function getParentClass(target:Object) : Class 
		{
			var parentObj:DisplayObjectContainer = target.parent;
			if (parentObj) return (getDefinitionByName(getQualifiedClassName(parentObj)) as Class);
			return null;
		}
		
		public static function getParentClassName(target:Object) : String 
		{
			var parentObj:DisplayObjectContainer = target.parent;
			if (parentObj) return getClassName(parentObj);
			return null;
		}
		
		public static function hasAncestorClass(target:DisplayObject, classz:Class):Boolean
		{
			if (getParentClass(target) == classz) return true;
			var parentObj:DisplayObjectContainer = target.parent;
			if (parentObj) return hasAncestorClass(parentObj, classz);
			return false;
		}
		
		public static function hasAncestorClassName(target:DisplayObject, className:String):Boolean
		{
			if (getParentClassName(target) == className) return true;
			var parentObj:DisplayObjectContainer = target.parent;
			if (parentObj) return hasAncestorClassName(parentObj, className);
			return false;
		}
		
		public static function isChildOf(target:DisplayObject, container:DisplayObjectContainer):Boolean
		{
			if (!target.parent) return false;
			if (target.parent == container) return true;
			return isChildOf(target.parent, container);			
		}
		
	}
}
