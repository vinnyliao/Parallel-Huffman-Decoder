/**
 * Abstract class of a node of a Huffman tree.
 */
public abstract class HuffmanNode {

	private static val MAX_ASCII:Int = 256;
	protected static val stringHash:Rail[String] = Rail.make[String](MAX_ASCII);
	protected static val hash:Rail[HuffmanCode] = Rail.make[HuffmanCode](MAX_ASCII);
	protected var weight:Int;
	protected var code:Rail[UByte] = Rail.make(64, (0 as UByte));
	protected var length:Int = 0;
	protected var codeString:String = "";

	public def getWeight():Int = weight;

	public abstract def toString():String;

	public abstract def generateCode():Void;

	public abstract def printCode():Void;

	public def compareTo(var that:Object):x10.lang.Int {
		if (this.weight > (that as HuffmanNode).getWeight()) return 1;
		if (this.weight < (that as HuffmanNode).getWeight()) return -1;
		return 0;
	}

}
