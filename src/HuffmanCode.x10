public class HuffmanCode {
	
	public val code:Byte;
	public val length:Int;
	
	public def this(code:UByte, length:Int) {
		this.code = code;
		this.length = length;
	}
	
	/**
	 * Returns true if the given substring of a byte is equal to this Huffman code.
	 */
	public def equals(byte:UByte, leftOffset:Int, rightOffset:Int):Boolean {
		val newByte:UByte = (byte << leftOffset) >> (rightOffset + leftOffset);
		if (8 - leftOffset - rightOffset == length)
			if ((newByte ^ code) == 0)
				return true;
		return false;
	}
	
	/**
	 * Returns true if the given right-aligned code of the given length is equal to this Huffman code.
	 */
	public def equals(code:UByte, length:Int):Boolean {
		if (length == this.length)
			if ((code ^ this.code) == 0)
				return true;
		return false;
	}
	
}
