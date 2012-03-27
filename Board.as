package  
{
	import org.flixel.*;
	
	public class Board
	{
		public var columns:int;
		public var rows:int;
		public var tiles:FlxGroup;
		public var toggle:Tile;
		
		private var doneBoard:Array = new Array(9);
		private var tempBoard:Array = new Array(9);
		private static var MINIMUM_MATCHES:int = 4;
		private static var CLEAR_BOARD:int = -1;
		private static var BOARD_SIZE_BORDER:int = 9;
		private static var BULLET:int = 0;
		
		private var matches:int = 0;
		private var initialBoardCheck:int = 1;
		public var score:int = 0;
		private var bowl:int = -1;
		private var bullets:int = 0;
		private var maxBullets:int = 3;
		
		public function Board() 
		{
			
			//Initialize the game board, done board, and temp board
			for (var row:int = 0; row < BOARD_SIZE_BORDER; row++)
			{
				//Create the second dimensions for each array
				//board[row] = new Array(BOARD_SIZE_BORDER);
				doneBoard[row] = new Array(BOARD_SIZE_BORDER);
				tempBoard[row] = new Array(BOARD_SIZE_BORDER);
				
				//Initialize each array
				for (var col:int = 0; col < BOARD_SIZE_BORDER; col++)
				{
					//board[row][col] = CLEAR_BOARD;
					doneBoard[row][col] = CLEAR_BOARD;
					tempBoard[row][col] = CLEAR_BOARD;
				}
			}
			
			//This section adds random tiles to the flxGroup of tiles
			columns = 7;
			rows = 7;
			tiles = new FlxGroup();
			
			var n:int = columns;
			for (var i:int = 0; i < n; i++)
			{
				var m:int = rows;
				for (var j:int = 0; j < m; j++)
				{
					var tile:Tile = new Tile(this, i, j);
					
					tile.y = (tile.height + 2) * i + 30;
					tile.x = (tile.width + 2) * j;
					tiles.add(tile);
				}
			}
			/*
			tiles.members[0].setType(0);
			tiles.members[1].setType(5);
			tiles.members[2].setType(5);
			tiles.members[3].setType(1);
			tiles.members[4].setType(2);
			tiles.members[5].setType(4);
			tiles.members[6].setType(4);
			
			tiles.members[7].setType(3);
			tiles.members[8].setType(5);
			tiles.members[9].setType(3);
			tiles.members[10].setType(0);
			tiles.members[11].setType(3);
			tiles.members[12].setType(0);
			tiles.members[13].setType(2);
			
			tiles.members[14].setType(3);
			tiles.members[15].setType(0);
			tiles.members[16].setType(5);
			tiles.members[17].setType(3);
			tiles.members[18].setType(5);
			tiles.members[19].setType(4);
			tiles.members[20].setType(0);
			
			tiles.members[21].setType(0);
			tiles.members[22].setType(2);
			tiles.members[23].setType(2);
			tiles.members[24].setType(4);
			tiles.members[25].setType(0);
			tiles.members[26].setType(2);
			tiles.members[27].setType(5);
			
			tiles.members[28].setType(2);
			tiles.members[29].setType(2);
			tiles.members[30].setType(0);
			tiles.members[31].setType(4);
			tiles.members[32].setType(2);
			tiles.members[33].setType(0);
			tiles.members[34].setType(4);
		
			tiles.members[35].setType(2);
			tiles.members[36].setType(3);
			tiles.members[37].setType(0);
			tiles.members[38].setType(2);
			tiles.members[39].setType(3);
			tiles.members[40].setType(4);
			tiles.members[41].setType(3);
			
			tiles.members[42].setType(1);
			tiles.members[43].setType(0);
			tiles.members[44].setType(2);
			tiles.members[45].setType(0);
			tiles.members[46].setType(4);
			tiles.members[47].setType(5);
			tiles.members[48].setType(3);
			*/
		}
		
		public function swap(tile:Tile):void
		{
			tile.on = toggle.on = false;
			
			if (!toggle)
				return;
			
			// Works because replace the Tile that appears later in the array first
			if (tiles.members.indexOf(toggle) < tiles.members.indexOf(tile))
			{
				tiles.replace(tile, toggle);
				tiles.replace(toggle, tile);
			}
			else
			{
				tiles.replace(toggle, tile);
				tiles.replace(tile, toggle);
			}
			
			// untoggle
			toggle.on = tile.on = false;
			// swap column (XOR Swap Algorithm)
			tile.column ^= toggle.column;
			toggle.column ^= tile.column;
			tile.column ^= toggle.column;
			// swap row (XOR Swap Algorithm)
			tile.row ^= toggle.row;
			toggle.row ^= tile.row;
			tile.row ^= toggle.row;
			
			//match();
			
			var scoreBefore:int = score;
			checkBoard();
			if (scoreBefore < score)
			bowl = 1;
			toggle = null;
		}
		
		public function tileAt(column:int, row:int):Tile
		{
			/*
			 members is a one dimensional array within the FlxGroup
			 to find a tile at (3,3) would be at index 24 in the array
			 (0,0) is 0 and (6,6) is 48
			 */
			return tiles.members[(row + 1) * rows - (columns - (column))];
		}
		
		/**
		 * Function which handles the board checking. First there is an initial check to see
		 * if the call is to initialize the board for a new game. This creates a loop which replaces
		 * chains until no chains exist on the board.
		 * 
		 * There is then a loop to see if any tiles are currently fading from a previous chain creation.
		 * If any tiles are fading, no chain checking is done. As each tile finishes its fade, it sets
		 * its fade value to false and calls this function. Only once the last tile which is fading calls 
		 * this function will it actually recheck the board for chains, possibly causing a cascading effect
		 * where more chains are created and fade away.
		 */
		public function checkBoard():void
		{
			//Initial loop to create a chain free board
			if (initialBoardCheck)
			{
				while (checkForChains()) { } //loops until first board has no chains
				initialBoardCheck = 0;
				score = 0;
				bullets = 0;
			}
			//Called once a swap has been made, or new tiles have been randomized on the board
			else
			{
				var fading:Boolean = false;
				//If any tiles are still fading, the 'fading' boolean will be set to true
				for (var index:int = 0; index < tiles.length; index++)
				{
					if (tiles.members[index].fade == true)
						fading = true;
				}
				
				//Prevents chain checking when tiles are fading
				if(!fading)
					checkForChains();
			}
		}
		
		/**
		 * Function to check the entire board for chains
		 */
		public function checkForChains():int
		{
			clearBoard(doneBoard);
			
			//First pass through checks every location if that location is part of a chain.
			//**The result of this section will be to have the done board display -1 in every
			//location not in a chain(as well as the border), and a number in the location of
			//a chain (number corresponding to tile type:brain, leg, ect)
			for (var row:int = 0; row < rows; row++)
			{
				for (var col:int = 0; col < columns; col++)
				{
					if(doneBoard[row+1][col+1]==CLEAR_BOARD)//plus 1 to account for border
						checkLocation(row, col);
				}
			}
			
			var match:int = 0;

			//This pass goes through the done board and does something to each tile which contains
			//a chain
			for (row = 0; row < rows; row++)
			{
				for (col = 0; col < columns; col++)
				{
					if (doneBoard[row + 1][col + 1] > -1)
					{
						//tileAt(col, row).alpha = 0.5;
						if (initialBoardCheck)
							tileAt(col, row).randomizeNoCheck();
						else
							tileAt(col, row).fadeOut();
						match++;
					}
					else
						tileAt(col, row).alpha = 1;
				}
			}
			
			return match;
		}
		
		
		/**
		 * function to check if a specific board tile is part of a chain. First a check is
		 * done to see if this tile has already been declared to be in a chain. This function
		 * takes as parameters the row and col of the tile board, and therefore adjustments need
		 * to be made to account for the border in tempBoard and resultBoard
		 * @param	row
		 * @param	col
		 */
		public function checkLocation(row:int, col:int):void
		{
			//Reset the temp board and chain length count
			clearBoard(tempBoard);
			matches = 0;
			
			//Get the current tile type
			var type:int = tileAt(col, row).type;
			
			//Perform the recursive check. The result will store any chains
			//larger than minimum chain length in tempBoard
			checkChain(row, col, type);
			
			//If the chain created is long enough, the chain will be copied from tempBoard to doneBoard
			if (matches >= MINIMUM_MATCHES)
			{
				calcScore(matches);
				copyTempBoard();
			}
			
		}
		
		/**
		 * Recursive function to determine if there are matching tiles around the current one.
		 * @param	row
		 * @param	col
		 * @param	type
		 */
		private function checkChain(row:int, col:int, type:int):void
		{
			//This is a check to see if this tile is already in the current chain
			//(stops infinite loop when comparing to parent tile)
			if (tempBoard[row + 1][col + 1] == 1)
				return;
			
			//Sets a flag to show this tile has been included
			tempBoard[row + 1][col + 1] = 1;
			matches += 1;
			
			//Check all surrounding tiles
			if (row - 1 >= 0 && (type == tileAt(col, row - 1).type || tileAt(col, row - 1).type == BULLET))
			checkChain(row - 1, col, type);
			if (col - 1 >= 0 && (type == tileAt(col - 1, row).type || tileAt(col - 1, row).type == BULLET))
			checkChain(row, col - 1, type);
			if (row + 1 < rows && (type == tileAt(col, row + 1).type || tileAt(col, row + 1).type == BULLET))
			checkChain(row + 1, col, type);
			if (col + 1 < columns && (type == tileAt(col + 1, row).type || tileAt(col + 1, row).type == BULLET))
			checkChain(row, col + 1, type);
				
		}
		
		/**
		 * This function is used to copy long enough matches to the doneBoard.
		 */
		private function copyTempBoard():void
		{
			for (var row:int = 1; row < 8; row++)
				for (var col:int = 1; col < 8; col++)
					if (tempBoard[row][col] >= 0)
					{
						doneBoard[row][col] = tileAt(col - 1, row - 1).type;
						if (tileAt(col - 1, row - 1).type == BULLET)
							addBullet();
					}
		}
		
		/**
		 * This function will clear a board to all values of -1.
		 * @param	clearBoard
		 */
		private function clearBoard(clearBoard:Array):void
		{
			for (var row:int = 1; row < 8; row++)
				for (var col:int = 1; col < 8; col++)
					clearBoard[row][col] = CLEAR_BOARD;
		}
		
		/**
		 * Function to check what the score will be for this length of chain
		 */
		public function calcScore(chainLength:int):void
		{
			var tempScore:int = chainLength;
			score += 4;
			tempScore -= 4;
			while (tempScore > 0)
			{
				score += 2;
				tempScore--;
			}
			
		}
		
		/**
		 * This is a function to check if a bowl needs to be thrown
		 */
		public function checkBowl():int 
		{
				//If a bowl is lined up, return it
				if (bowl >= 0)
				{
					var temp:int = bowl;
					bowl = -1;
					return temp;
				}
				//If no bowl is lined up, return -1;
				else
					return -1;
		}
		
		/**
		 * Function to get score
		 */
		public function getScore():int
		{
			return score;
		}
		
		public function shootBullet():void
		{
			bullets--;
		}
		
		public function addBullet():void
		{
			if(bullets < maxBullets)
				bullets++;
		}
		
		/**
		 * Function to get bullets
		 */
		public function getBullets():int
		{
			return bullets;
		}
		
		public function match():void
		{
			var n:int = columns;
			for (var i:int = 0; i < n; i++)
			{
				var m:int = rows;
				for (var j:int = 0; j < m; j++)
				{
					// There has to be a cleaner was to do this!
					
					/*
					 checks the three tiles horizontally and vertically
					 to see if they have the same type and if they do
					 sets their transparency to 50%
					 */
					var horizontal1:Tile = tileAt(i, j);
					var horizontal2:Tile;
					var horizontal3:Tile;
					if (i + 1 < columns)
						horizontal2 = tileAt(i + 1, j);
					else
						horizontal2 = null;
					if (i + 2 < columns)
						horizontal3 = tileAt(i + 2, j);
					else
						horizontal3 = null;
					
					var vertical1:Tile = tileAt(i, j);
					var vertical2:Tile;
					var vertical3:Tile;
					if (j + 1 < rows)
						vertical2= tileAt(i, j + 1);
					else
						vertical2 = null;
					if (j + 2 < rows)
						vertical3 = tileAt(i, j + 2);
					else
						vertical3 = null;
					
					if (horizontal1 && horizontal2 && horizontal3)
					{
						if (horizontal1.type == horizontal2.type && horizontal2.type == horizontal3.type)
						{
							horizontal1.randomize();
							horizontal2.randomize();
							horizontal3.randomize();
						}
					}
					
					if (vertical1 && vertical2 && vertical3)
					{
						if (vertical1.type == vertical2.type && vertical2.type == vertical3.type)
						{
							vertical1.randomize();
							vertical2.randomize();
							vertical3.randomize();
						}
					}
				}
			}
		}
	}
}