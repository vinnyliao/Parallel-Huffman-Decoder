/**
 * Implements a leaf node of a Huffman tree.
 */
public class HuffmanLeafNode extends HuffmanNode {

	private val character:char;

	/**
	 * Create a leaf node.
	 * @param character the character to store in the node
	 * @param weight the weight of the node.
	 */
	public def this(character:char, weight:int) {
		this.character = character;
		this.weight = weight;
	}

	/**
	 * Method for recursively generating the Huffman Code.
	 * Called by HuffmanTree.generateCode().
	 * Updates the code for each node in the tree.
	 */
	public def generateCode() {
		hash(character.ord()) = code;
	}

	/**
	 * Method for recursively printing the Huffman Code.
	 */
	public def printCode() {
		Console.OUT.println("'" + character + "' = " + code);
	}

	public def toString():String = "(" + weight + ") '" + character + "' = " + code;

}
