/**
 * Implements a full node of a Huffman tree.
 */
public class HuffmanFullNode extends HuffmanNode {

	private val left:HuffmanNode;
	private val right:HuffmanNode;

	/**
	 * Create a non-leaf node.
	 * @param weight the weight.
	 * @param l the left subtree.
	 * @param r the right subtree.
	 */
	public def this(l:HuffmanNode, r:HuffmanNode) {
		weight = l.getWeight() + r.getWeight();
		left = l;
		right = r;
	}

	/**
	 * Method for recursively generating the Huffman Code.
	 * Called by HuffmanTree.generateCode().
	 * Updates the code for each node in the tree.
	 */
	public def generateCode() {
		left.codeString = codeString + "0";
		
		for ([i] in 63..1) {
			left.code(i) = code(i) << 1;
			if ( (code(i-1) & (1 as UByte) << 7) != 0)
				left.code(i) += (1 as UByte);
		}
		left.code(0) = code(0) << 1;
		
		left.length = length + 1;
		left.generateCode();
		
		
		right.codeString = codeString + "1";
		
		for ([i] in 63..1) {
			right.code(i) = code(i) << 1;
			if ( (code(i-1) & (1 as UByte) << 7) != 0)
				right.code(i) += (1 as UByte);
		}
		right.code(0) = code(0) << 1;
		right.code(0) += (1 as UByte);
		
		right.length = length + 1;
		right.generateCode();
	}

	/**
	 * Method for recursively printing the Huffman Code.
	 */
	public def printCode() {
		left.printCode();
		right.printCode();
	}

	public def toString():String = "(" + weight + ")";

}
