/**
 * Implements a binary heap for HuffmanNode objects.
 * Based on: http://users.cis.fiu.edu/~weiss/dsaajava2/code/BinaryHeap.java
 */
public class BinaryHuffmanNodeHeap {

	val DEFAULT_CAPACITY = 10;
	var currentSize:Int; // Number of elements in heap
	var array:Rail[HuffmanNode]; // The heap array

	/**
	 * Construct the binary Huffman node heap.
	 */
	public def this()
	{
		currentSize = 0;
		array = Rail.make[HuffmanNode](DEFAULT_CAPACITY);
	}

	/**
	 * Construct the binary Huffman node heap.
	 * @param capacity the capacity of the binary Huffman node heap.
	 */
	public def this( capacity:Int )
	{
		currentSize = 0;
		array = Rail.make[HuffmanNode](capacity);
	}

	/**
	* Construct the binary Huffman node heap given a Rail of Huffman nodes.
	*/
	public def this( nodes:Rail[HuffmanNode] )
	{
		currentSize = nodes.length;
		array = Rail.make[HuffmanNode]( ( currentSize + 2 ) * 11 / 10 );
		
		var i:Int = 1;
		for ( node in nodes )
			array( i++ ) = node;
		buildHeap( );
	}

	/**
	 * Insert into the priority queue, maintaining heap order.
	 * Duplicates are allowed.
	 * @param x the item to insert.
	 */
	public def insert( x:HuffmanNode )
	{
		if ( currentSize == array.length - 1 )
			enlargeArray( array.length * 2 + 1 );

		// Percolate up
		var hole:Int = ++currentSize;
		for ( ; hole > 1 && x.compareTo( array( hole / 2 ) ) < 0; hole /= 2 )
			array( hole ) = array( hole / 2 );
		array( hole ) = x;
	}

	private def enlargeArray( newSize:Int )
	{
		val old:Rail[HuffmanNode] = array;
		array = Rail.make[HuffmanNode]( newSize );
		for ( var i:Int = 0; i < old.length; i++ )
			array( i ) = old( i );
	}

	/**
	 * Find the smallest item in the priority queue.
	 * @return the smallest item, or throw an UnderflowException if empty.
	 * @throws Exception 
	 */
	public def findMin( )
	{
		if ( isEmpty( ) )
			throw new Exception( );
		return array( 1 );
	}

	/**
	 * Remove the smallest item from the priority queue.
	 * @return the smallest item, or throw an UnderflowException if empty.
	 * @throws Exception 
	 */
	public def deleteMin( )
	{
		if ( isEmpty( ) )
			throw new Exception( );

		minItem:HuffmanNode = findMin( );
		array( 1 ) = array( currentSize-- );
		percolateDown( 1 );

		return minItem;
	}

	/**
	 * Establish heap order property from an arbitrary
	 * arrangement of items. Runs in linear time.
	 */
	private def buildHeap( )
	{
		for ( var i:Int = currentSize / 2; i > 0; i-- )
			percolateDown( i );
	}

	/**
	 * Test if the priority queue is logically empty.
	 * @return true if empty, false otherwise.
	 */
	public def isEmpty( )
	{
		return currentSize == 0;
	}

	/**
	 * Make the priority queue logically empty.
	 */
	public def makeEmpty( )
	{
		currentSize = 0;
	}

	/**
	 * Internal method to percolate down in the heap.
	 * @param firstHole the index at which the percolate begins.
	 */
	private def percolateDown( firstHole:Int )
	{
		var child:Int;
		var hole:Int = firstHole;
		tmp:HuffmanNode = array( hole );

		for ( ; hole * 2 <= currentSize; hole = child )
		{
			child = hole * 2;
			if ( child != currentSize &&
					array( child + 1 ).compareTo( array( child ) ) < 0 )
				child++;
			if ( array( child ).compareTo( tmp ) < 0 )
				array( hole ) = array( child );
			else
				break;
		}
		array( hole ) = tmp;
	}

}
