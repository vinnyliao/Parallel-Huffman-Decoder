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
		left.code = code + "0";
		left.generateCode();
		right.code = code + "1";
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
