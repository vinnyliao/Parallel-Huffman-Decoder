public class HuffmanDecoder {
		
	private var hash:Rail[String];
	private var encodedText:String;
	private var decodedText:String;
	private var c:Char;
	
	public def this(hash:Rail[String], encodedText:String) {
		this.hash = hash;
		this.encodedText = encodedText;
		decodedText = "";
	}
	
	public def decode() {
		var begin:Int = 0;
		var end:Int = 1;
		while (end <= encodedText.length()) {
			if (decodeChar(encodedText.substring(begin, end))) {
				decodedText += c;
				begin = end;
			}
			end++;
		}
	}
	
	private def decodeChar(code:String):Boolean {
		for ([i] in 0..hash.length()-1)
			if (code.equals(hash(i))) {
				c = Char.chr(i);
				return true;
			}
		return false;
	}
	
	public def getDecodedText():String = decodedText;
	
}