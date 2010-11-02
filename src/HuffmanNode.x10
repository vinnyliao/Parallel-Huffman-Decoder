/**
 * Abstract class of a node of a Huffman tree.
 */
public abstract class HuffmanNode {

	private static val MAX_ASCII:int = 256;
	protected static val hash:Rail[String] = Rail.make[String](MAX_ASCII);
	protected var weight:int;

	public def getWeight():int = weight;

	public abstract def toString():String;

	public abstract def generateCode():void;

	public abstract def printCode():void;

	public var code:String = "";

	public def compareTo(var that:Object):x10.lang.Int {
		if (this.weight > (that as HuffmanNode).getWeight()) return 1;
		if (this.weight < (that as HuffmanNode).getWeight()) return -1;
		return 0;
	}

}
