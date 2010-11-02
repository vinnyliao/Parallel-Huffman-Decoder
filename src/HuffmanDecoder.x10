public class HuffmanDecoder {
	
	private static val testText:String = "abracadabra";
	
	private var hash:Rail[String];
	private var encodedText:String;
	private var decodedText:String;
	private var c:char;
	
	public def this(hash:Rail[String], encodedText:String) {
		this.hash = hash;
		this.encodedText = encodedText;
		decodedText = "";
	}
	
	public def decode() {
		var begin:int = 0;
		var end:int = 1;
		while (end <= encodedText.length()) {
			if (decodeChar(encodedText.substring(begin, end))) {
				decodedText += c;
				begin = end;
			}
			end++;
		}
	}
	
	private def decodeChar(code:String):boolean {
		for ([i] in 0..hash.length()-1)
			if (code.equals(hash(i))) {
				c = Char.chr(i);
				return true;
			}
		return false;
	}
	
	public def getDecodedText():String = decodedText;
	
    public static def main(args:Array[String](1)): Void {
    	val he:HuffmanEncoder = new HuffmanEncoder();
		Console.OUT.println("Input Text:");
		Console.OUT.println(testText);
		he.setText(testText);
		he.countFreq();
		he.countChars();
		Console.OUT.println("Character Frequencies:");
		he.printFreq();
		he.makeHuffmanTree();
		he.generateCode();
		Console.OUT.println("Huffman Code:");
		he.printCode();
		he.encodeText();
		Console.OUT.println("Encoded Message:");
		he.printText();
		
		val hd:HuffmanDecoder = new HuffmanDecoder(he.getHash(), he.getEncodedText());
		hd.decode();
		Console.OUT.println("Decoded Message:");
		Console.OUT.println(hd.getDecodedText());
    }
}