extends Node2D

# class member variables go here, for example:
#var width = 53
#var height = 31
#var width = 24
#var height = 11
var width = 53
var height = 31
var margin = Vector2(1.0, 1.0)
var cells = []

const cellWidth = 19.0

export(Font) var font

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

class Cell:
	var type = 0
	var discovered = 0
	var marked = 0

func populate():
	randomize()
	
	var i = 0
	while (i < self.width * self.height):
		var cell = Cell.new()
		cell.type = 1 if randf(0.0, 1.0) < 0.15 else 0
		self.cells.append(cell)
		i = i + 1

func _draw():
	populate()
	var label = Label.new()
	var font = label.get_font("")
	
	var row = 0 
	while (row < self.height):
		var col = 0	
		while (col < self.width):
			var cellIndex = row * self.width + col
			#var cellCol = getCellCol(cells[cellIndex])
			var cell = self.cells[cellIndex];
			var cellCol = getCellCol(cell)
			var pos = Vector2(self.margin.x + col * cellWidth, self.margin.y + row * cellWidth)
			var rect = Rect2(pos, Vector2(cellWidth - 1.0, cellWidth - 1.0));
			draw_rect(rect, cellCol, true)
			var count = countTouchingBombs(Vector2(col, row))
			if count > 0 and cell.discovered == 1:
				draw_string(font, pos + Vector2(4.0, font.get_height() / 2 + 7), str(count))
			col = col + 1
		row = row + 1

func getCellCol(cell):
	if not cell.discovered:
		if cell.marked:
			return Color(0.9, 0.8, 0.2)
		else: 
			return Color(0.6, 0.6, 0.6)
	if (cell.type == 0):
		return Color(0.1, 0.1, 0.1)
	if (cell.type == 1):
		return Color(1.0, 0.1, 0.2)

func _input(event):
	# Mouse in viewport coordinates
	if event is InputEventMouseButton and event.pressed:
		var gridPos = event.position - self.margin
		var cellCoords = Vector2(gridPos.x / self.cellWidth, gridPos.y / self.cellWidth)
		if event.button_index == 1:
			discoverNeighbours(cellCoords)
		if event.button_index == 2:
			var cell = getCellAt(cellCoords)
			if (cell != null):
				cell.marked = !cell.marked
	
		update()
		

func discoverNeighbours(coords):
	var cellIndex = coordsToIndex(coords)
	if cellIndex < 0:
		return # we're out of the game zone
		
	var cell = self.cells[cellIndex]
	
	if cell.discovered == 1:
		return
		
	else:
		cell.discovered = 1
		if cell.type == 0 and countTouchingBombs(coords) == 0:
			discoverNeighbours(coords + Vector2(1.0, 0.0))
			discoverNeighbours(coords + Vector2(-1.0, 0.0))
			discoverNeighbours(coords + Vector2(0.0, 1.0))
			discoverNeighbours(coords + Vector2(0.0, -1.0))
			discoverNeighbours(coords + Vector2(1.0, 1.0))
			discoverNeighbours(coords + Vector2(1.0, -1.0))
			discoverNeighbours(coords + Vector2(-1.0, 1.0))
			discoverNeighbours(coords + Vector2(-1.0, -1.0))
	

func getCellAt(coords):
	var index = coordsToIndex(coords)
	if (index < 0):
		return null
	return self.cells[index]

func coordsToIndex(coords):
	if (coords.x < 0 or coords.y < 0 or coords.x >= self.width or coords.y >= self.height):
		return -1
	return int(coords.y) * self.width + int(coords.x)

func indexToPos(i):
	return Vector2(i % self.width, i / self.width)

func countTouchingBombs(pos):
	var count = 0
	for n in getNeighbours(pos):
		if n.type == 1:
			count = count + 1
	return count
			
	return getNeighbours(pos).size()

func getNeighbours(pos):
	var neighbours = []
	var deltas = [
		Vector2(1.0, 0.0),
		Vector2(-1.0, 0.0),
		Vector2(0.0, 1.0),
		Vector2(0.0, -1.0),
		Vector2(1.0, 1.0),
		Vector2(-1.0, -1.0),
		Vector2(-1.0, 1.0),
		Vector2(1.0, -1.0),
	]
	for delta in deltas:
		var cell = getCellAt(pos + delta)
		if (cell != null):
			neighbours.append(cell)

	return neighbours
	
	
