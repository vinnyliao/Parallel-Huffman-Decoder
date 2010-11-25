public class HuffmanCode {

	public val code:Rail[UByte];
	public val length:Int;

	public def this(code:Rail[UByte], length:Int) {
		this.code = code;
		this.length = length;
	}

	/**
	 * Returns true if the given right-aligned code of the given length is equal to this Huffman code.
	 */
	public def equals(code:Rail[UByte], length:Int):Boolean {
		if (length != this.length)
			return false;
		for ([i] in 0..code.length-1)
			if ((code(i) ^ this.code(i)) != 0)
				return false;
		return true;
	}

}
