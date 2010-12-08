public class CharDecoder {
	
	private val hash:Rail[HuffmanCode];
	private var c:Char;
	
	public def this(hash:Rail[HuffmanCode]) {
		this.hash = hash;
	}
	
	public def decode(code:Rail[UByte], length:Int):Boolean {
		for ([i] in 0..hash.length()-1) {
			if (hash(i) != null && hash(i).equals(code, length)) {
				c = Char.chr(i);
				return true;
			}
		}
		return false;
	}
	
	public def getChar():Char = c;
	
}
