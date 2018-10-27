extends Node2D

var dt = 0
var time = 0
var mousePos = Vector2(0, 0)
var windowSize = Vector2(0, 0)

func _ready():
	set_process_input(true)
	set_process(true)
	
	prepareCharacterSet()
	startGame()

func rotateArray(array, offset):
	var newArray = []
	for i in range(array.size()):
		newArray.append(array[(i - offset) % array.size()])
	return newArray

func random(from, to):
	from = int(from)
	to = int(to)
	randomize()
	return (randi() % ((to - from) + 1)) + from

func randomItem(array):
	var rnd = random(0, array.size() - 1)
	return array[rnd]

func randomOrder(array):
	var newArray = []
	var oldArray = array.duplicate()
	while !oldArray.empty():
		var rnd = random(0, oldArray.size() - 1)
		newArray.append(oldArray[rnd])
		oldArray.remove(rnd)
	return newArray



func _input(event):
	if event.is_action_pressed("mouseLeft"):
		rotateChain(exactBoardTilePos(mousePos))
	if event.is_action_pressed("mouseRight"):
		pass # actions done with right mouse click = currently nothing, but add them here

func _process(delta):
	dt = delta
	time += delta
	mousePos = get_global_mouse_position()
	windowSize = get_viewport().size
	
	calculateChainAnimation()
	
	update()

var score = 0
var scoreAnimation = 0
var brokenChains = 0
var combo = 1

var posDirections = [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]
var tileSize = Vector2(64, 64)
var boardSize = Vector2(9, 9)

var boardTiles = {}
var droppedChains = []
var chainColors = {
	-2:Color(1.0, 1.0, 1.0),
	-1:Color(0.0, 0.0, 0.0),
	0:Color(1.0, 0.0, 0.0),
	1:Color(1.0, 1.0, 0.0),
	2:Color(0.0, 0.0, 1.0)
}
var chainShapes = {
	2:{"pattern":[true, false, true, false],"steps":2},
	3:{"pattern":[true, true, true, false],"steps":4},
	4:{"pattern":[true, true, true, true],"steps":1}
}

var fallingChainsCount = 0
var shufflingChainsCount = 0
var interactionAllowed = true

func startGame():
	initBoard()
	calculateVisibleChainConnections()

func initBoard():
	var excludedTiles = [Vector2(0, 0), Vector2(3, 0), Vector2(4, 0), Vector2(5, 0), Vector2(8, 0), Vector2(0, 4), Vector2(1, 4), Vector2(7, 4), Vector2(8, 4), Vector2(0, 8), Vector2(3, 8), Vector2(4, 8), Vector2(5, 8), Vector2(8, 8), ]
	for i in range(boardSize[0]):
		for j in range(boardSize[1]):
			var boardPos = Vector2(i, j)
			#if !excludedTiles.has(boardPos):
			#if j < 3 || j > 5:
			#if i <= j:
			#if random(1, 8) > 1:
			#if (i >= 3 && i <= 5) || (j >= 3 && j <= 5):
			boardTiles[boardPos] = {"chain":null}
	initChains()

func initChains():
	for i in range(boardSize[0]):
		for j in range(boardSize[1]):
			var chainPos = Vector2(i, j)
			if getTile(chainPos) == null:
				continue
			while true:
				boardTiles[chainPos]["chain"] = randomChainData()
				if getChainMatches().empty():
					break

func randomChainData():
	var chainColor = random(0, 2)
	if random(1, 100) == 1:
		chainColor = -2
	if random(1, 50) == 1:
		chainColor = -1
	var chainShape = 2
	if random(1, 5) == 1:
		chainShape = 3
	if random(1, 20) == 1:
		chainShape = 4
	var chainRotation = random(0, chainShapes[chainShape]["steps"] - 1)
	var chainData = {
		"color":chainColor,
		"shape":chainShape,
		"rotation":chainRotation,
		"rotationStep":0,
		"rotationStepTime":0,
		"rotationActive":false,
		"visibleConnections":[false, false, false, false],
		"fallOffset":0,
		"fallSpeed":0,
		"shuffleTime":0,
		"shufllePosition":Vector2(0, 0),
		"shuffleActive":false
	}
	return chainData

func isPosValid(pos):
	return (pos[0] >= 0 && pos[0] < boardSize[0]) && (pos[1] >= 0 && pos[1] < boardSize[1])

func neighTile(pos, direction):
	var neighTile = pos + posDirections[direction]
	if !isPosValid(pos) || !isPosValid(neighTile):
		return
	return neighTile

func getTile(boardPos):
	if boardTiles.has(boardPos):
		return boardTiles[boardPos]

func getChain(chainPos):
	if getTile(chainPos) != null && getTile(chainPos).has("chain"):
		return boardTiles[chainPos]["chain"]

func getChainNeighbor(chainPos, direction):
	var neighTile = neighTile(chainPos, direction)
	if neighTile != null:
		return getChain(neighTile(chainPos, direction))

func getChainNeighbors(chainPos):
	var chainNeighbors = []
	for i in range(4):
		var chainNeighbor = getChainNeighbor(chainPos, i)
		if chainNeighbor == null:
			chainNeighbors.append(null)
		else:
			chainNeighbors.append(neighTile(chainPos, i))
	return chainNeighbors

func doesColorsMatch(color1, color2):
	return color1 == color2 || (color1 == -2 || color2 == -2)

func isChainConnected(chainPos, direction):
	var chain = getChain(chainPos)
	var chainNeighbor = getChainNeighbor(chainPos, direction)
	if chain == null || chainNeighbor == null:
		return false
	var chainNeighborPos = neighTile(chainPos, direction)
	var chainConnectionsAvailable = getChainConnectionsAvailable(chainPos)
	var chainNeighborConnectionsAvailable = getChainConnectionsAvailable(chainNeighborPos)
	var shapesMatch = chainConnectionsAvailable[direction] && chainNeighborConnectionsAvailable[(direction + 2) % 4]
	var colorsMatch = doesColorsMatch(chain["color"], chainNeighbor["color"])
	return shapesMatch && colorsMatch

func getChainConnections(chainPos):
	var chainConnections = []
	for i in range(4):
		chainConnections.append(isChainConnected(chainPos, i))
	return chainConnections

func getChainConnectionsCount(chainPos):
	var chainConnections = getChainConnections(chainPos)
	var chainConnectionsCount = 0
	for i in range(chainConnections.size()):
		var chainConnection = chainConnections[i]
		if chainConnection:
			chainConnectionsCount += 1
	return chainConnectionsCount

func getChainsConnected(chainPos):
	var chainsConnected = []
	var chainNeighbors = getChainNeighbors(chainPos)
	var chainConnections = getChainConnections(chainPos)
	for i in range(4):
		var chainNeighbor = chainNeighbors[i]
		if chainNeighbor == null:
			continue
		if chainConnections[i]:
			chainsConnected.append(chainNeighbors[i])
	return chainsConnected

func getChainConnectionsAvailable(chainPos):
	var chain = getChain(chainPos)
	if chain["rotationActive"] || chain["fallOffset"] > 0 || chain["shuffleActive"]:
		return [false, false, false, false]
	return rotateArray(chainShapes[chain["shape"]]["pattern"], chain["rotation"])

func getChainGroup(chainPos, chainEntries = [chainPos]):
	if chainPos == null:
		return
	var chainConnections = getChainsConnected(chainPos)
	for i in range(chainConnections.size()):
		var chainConnection = chainConnections[i]
		if chainEntries.has(chainConnection):
			continue
		chainEntries = getChainGroup(chainConnection, chainEntries + [chainConnection])
	return chainEntries

func getChainMatches():
	var chainMatches = []
	for i in range(boardTiles.size()):
		var boardPos = boardTiles.keys()[i]
		var chain = getChain(boardPos)
		if chain == null:
			continue
		var chainGroup = getChainGroup(boardPos)
		if chainGroup.size() < 3:
			continue
		var chainRepeat = false
		for j in range(chainMatches.size()):
			var chainMatch = chainMatches[j]
			if chainMatch.has(boardPos):
				chainRepeat = true
				break
		if chainRepeat:
			continue
		chainMatches.append(chainGroup)
	return chainMatches

func detectChainMatches():
	var chainMatches = getChainMatches()
	for i in range(chainMatches.size()):
		var chainMatch = chainMatches[i]
		for j in range(chainMatch.size()):
			var chainPos = chainMatch[j]
			removeChain(chainPos)
		score += ((chainMatch.size() - 2) * 100) * combo
		combo += 1
		brokenChains += chainMatch.size()
	if !chainMatches.empty():
		fillHoles()
		fillHolesUp()
		interactionAllowed = false
	elif !checkMoves():
		shuffleChains()

func fillHoles():
	for i in range(boardSize[0]):
		for j in range(boardSize[1] - 1, -1, -1): # reversed iteration
			var boardPos = Vector2(i, j)
			if getTile(boardPos) != null && getChain(boardPos) == null:
				for k in range(j - 1, -1, -1): # reversed iteration
					var seekPos = Vector2(i, k)
					if getChain(seekPos) != null:
						getTile(boardPos)["chain"] = getChain(seekPos)
						getTile(seekPos).erase("chain")
						getChain(boardPos)["fallOffset"] += j - k
						fallingChainsCount += 1
						break

func fillHolesUp():
	for i in range(boardSize[0]):
		var placedChains = 0
		for j in range(boardSize[1] - 1, -1, -1): # reversed iteration
			var boardPos = Vector2(i, j)
			if getTile(boardPos) != null && getChain(boardPos) == null:
				getTile(boardPos)["chain"] = randomChainData()
				getChain(boardPos)["fallOffset"] = (j + 3) + placedChains
				fallingChainsCount += 1
				placedChains += 1

func checkMoves():
	for i in range(boardTiles.size()):
		var boardPos = boardTiles.keys()[i]
		var chain = getChain(boardPos)
		if chain == null:
			continue
		var chainMatches = [boardPos]
		var chainNeighbors = getChainNeighbors(boardPos)
		for j in range(chainNeighbors.size()):
			var chainNeighborPos = chainNeighbors[j]
			var chainNeighbor = getChain(chainNeighborPos)
			if chainNeighbor != null && doesColorsMatch(chain["color"], chainNeighbor["color"]):
				chainMatches.append(chainNeighborPos)
		if chainMatches.size() < 3:
			continue
		var iterationData = []
		var iterationDataCurrent = []
		var iterationCount = 1
		var chainOriginalRotations = []
		for j in range(chainMatches.size()):
			var chainMatchPos = chainMatches[j]
			var chainMatch = getChain(chainMatchPos)
			var chainRotationSteps = chainShapes[chainMatch["shape"]]["steps"]
			iterationData.append(chainRotationSteps)
			iterationDataCurrent.append(0)
			iterationCount *= chainRotationSteps
			chainOriginalRotations.append(chainMatch["rotation"])
		for j in range(iterationCount):
			for k in range(iterationData.size() - 1):
				var iterationDataCurrentMax = iterationData[k]
				if iterationDataCurrent[k] >= iterationDataCurrentMax:
					iterationDataCurrent[k] -= iterationDataCurrentMax
					iterationDataCurrent[k + 1] += 1
			for k in range(chainMatches.size()):
				var chainMatchPos = chainMatches[k]
				var chainMatch = getChain(chainMatchPos)
				if chainMatch["color"] == -1:
					continue
				chainMatch["rotation"] = iterationDataCurrent[k]
			var chainConnectionsCount = getChainConnectionsCount(boardPos)
			if chainConnectionsCount >= 2:
				for k in range(chainMatches.size()):
					var chainMatchPos = chainMatches[k]
					var chainMatch = getChain(chainMatchPos)
					chainMatch["rotation"] = chainOriginalRotations[k]
				return true
			iterationDataCurrent[0] += 1
		for j in range(chainMatches.size()):
			var chainMatchPos = chainMatches[j]
			var chainMatch = getChain(chainMatchPos)
			chainMatch["rotation"] = chainOriginalRotations[j]
	return false

func rotateChain(chainPos):
	if !interactionAllowed:
		return
	var chain = getChain(chainPos)
	if chain == null:
		return
	if chain["color"] == -1 || chainShapes[chain["shape"]]["steps"] == 1:
		return
	chain["rotationActive"] = true
	combo = 1

func removeChain(chainPos):
	var chain = getChain(chainPos)
	boardTiles[chainPos].erase("chain")
	var chainDropped = chain.duplicate()
	chainDropped.erase("rotationStep")
	chainDropped.erase("rotationStepTime")
	chainDropped.erase("rotationActive")
	chainDropped.erase("fallOffset")
	chainDropped["position"] = chainPos
	chainDropped["velocity"] = Vector2(random(-25, 25) / 10.0, random(-75, -50) / 10.0)
	chainDropped["time"] = 0
	droppedChains.append(chainDropped)

func shuffleChains():
	var chainsList = {}
	for i in range(boardTiles.size()):
		var boardPos = boardTiles.keys()[i]
		var chain = getChain(boardPos)
		if chain != null:
			chainsList[boardPos] = chain
	var newChainsList = []
	var chainsListTemp = chainsList.duplicate()
	for i in range(chainsListTemp.size()):
		var rnd = random(0, chainsListTemp.size() - 1)
		var chainPos = chainsList.keys()[i]
		var chain = chainsListTemp[chainPos]
		chain["shufflePosition"] = chainPos
		chain["shuffleActive"] = true
		shufflingChainsCount += 1
		newChainsList.append(chain)
		chainsListTemp.erase(chainPos)
	newChainsList = randomOrder(newChainsList)
	for i in range(chainsList.size()):
		var chainPos = chainsList.keys()[i]
		var newChain = newChainsList[i]
		boardTiles[chainPos]["chain"] = newChain
	combo = 1

func calculateChainAnimation():
	for i in range(boardTiles.size()):
		var boardPos = boardTiles.keys()[i]
		var chain = getChain(boardPos)
		if chain == null:
			continue
		if chain["rotationActive"]:
			chain["rotationStepTime"] += dt
			while chain["rotationStepTime"] >= 0.05:
				chain["rotationStepTime"] -= 0.05
				chain["rotationStep"] += 1
				if chain["rotationStep"] == 1:
					calculateVisibleChainConnection(boardPos, true) # Detaching the chain from its connected neighbors
			if chain["rotationStep"] >= 4:
				chain["rotationStepTime"] = 0
				chain["rotationStep"] = 0
				chain["rotation"] = (chain["rotation"] + 1) % chainShapes[chain["shape"]]["steps"]
				chain["rotationActive"] = false
				detectChainMatches()
				calculateVisibleChainConnection(boardPos, true)
		if chain["fallOffset"] > 0:
			chain["fallSpeed"] += dt * 20
			chain["fallOffset"] -= chain["fallSpeed"] * dt
			if chain["fallOffset"] <= 0:
				chain["fallSpeed"] = 0
				chain["fallOffset"] = 0
				fallingChainsCount -= 1
				calculateVisibleChainConnection(boardPos, true)
		if chain["shuffleActive"]:
			chain["shuffleTime"] += dt
			if chain["shuffleTime"] >= 1:
				chain["shuffleTime"] = 0
				chain["shufflePosition"] = Vector2(0, 0)
				chain["shuffleActive"] = false
				shufflingChainsCount -= 1
				if shufflingChainsCount == 0:
					calculateVisibleChainConnections()
	for i in range(droppedChains.size()):
		if i >= droppedChains.size():
			break
		var droppedChain = droppedChains[i]
		droppedChain["time"] += dt
		droppedChain["velocity"][1] += droppedChain["time"] / 2
		droppedChain["position"] += droppedChain["velocity"] * dt
		if droppedChain["position"][1] >= tileSize[1]:
			droppedChains.remove(i)
			i -= 1
	if fallingChainsCount == 0 && shufflingChainsCount == 0:
		if !interactionAllowed:
			interactionAllowed = true
			detectChainMatches()
	elif interactionAllowed:
		interactionAllowed = false

func calculateVisibleChainConnection(chainPos, includeChainNeighbors = false):
	var chain = getChain(chainPos)
	if chain == null:
		return
	chain["visibleConnections"] = getChainConnections(chainPos)
	if includeChainNeighbors:
		var chainNeighbors = getChainNeighbors(chainPos)
		for i in range(chainNeighbors.size()):
			var chainNeighbor = chainNeighbors[i]
			calculateVisibleChainConnection(chainNeighbor)

func calculateVisibleChainConnections():
	for i in range(boardTiles.size()):
		var boardPos = boardTiles.keys()[i]
		calculateVisibleChainConnection(boardPos)



# These variables are necessary because dynamic loading doesn't work anymore.
var tileTexture = load("res://img/tile.png")
var chainTileSetTexture = load("res://img/chaintileset.png")

# Of course, this array will be loaded from external file.
var characterSet = {}
var characterSetTexture = load("res://font/small.png")
var characterPixelSize = Vector2(8, 8)

func _draw():
	drawBoardTiles()
	drawBoardChains()
	drawDroppedChains()
	
	scoreAnimation = round(min(scoreAnimation + (((score - scoreAnimation) + 100) * dt), score))
	drawText(Vector2(8, 8), "Score: " + str(scoreAnimation) + "\nChains broken: " + str(brokenChains), Color(1.0, 1.0, 0.0), {"shadow":true})

func chainTextureRect(chainData):
	var chain = chainData
	if typeof(chainData) == TYPE_VECTOR2:
		chain = getChain(chainData)
	var chainSpriteSize = Vector2(16, 16)
	var chainSpritePos = Vector2(0, 0)
	if chain["rotationStep"] == 0:
		var chainConnections = chain["visibleConnections"]
		for i in range(chainConnections.size()):
			var chainConnection = chainConnections[i]
			if chainConnection:
				chainSpritePos[0] += pow(2, i)
	else:
		chainSpritePos[0] = 15 + chain["rotationStep"]
	chainSpritePos[1] = (4 * (chain["shape"] - 1)) + chain["rotation"]
	return Rect2(chainSpritePos * chainSpriteSize, chainSpriteSize)

func globalTilePos(boardPos):
	return (boardPos * tileSize) + ((windowSize - (boardSize * tileSize)) / 2)

func globalTileRect(boardPos):
	return Rect2(globalTilePos(boardPos), tileSize)

func boardTilePos(globalPos):
	return ((globalPos - ((windowSize - (boardSize * tileSize)) / 2)) / tileSize)

func exactBoardTilePos(globalPos):
	var boardPos = boardTilePos(globalPos).floor()
	if getTile(boardPos) != null:
		return boardPos

func drawBoardTiles():
	for i in range(boardSize[0]):
		for j in range(boardSize[1]):
			var boardPos = Vector2(i, j)
			if getTile(boardPos) != null:
				draw_texture_rect(tileTexture, globalTileRect(boardPos), false)

func drawBoardChains():
	for i in range(boardTiles.size()):
		var chainPos = boardTiles.keys()[i]
		var chain = getChain(chainPos)
		if chain != null:
			var chainTextureRect = chainTextureRect(chainPos)
			var chainColor = chainColors[chain["color"]]
			var chainOffset = Vector2(0, chain["fallOffset"] * -tileSize[1])
			if chain["shuffleActive"]:
				chainOffset += ((chain["shufflePosition"] - chainPos) * ((sin((chain["shuffleTime"] * PI) + (PI / 2)) + 1) / 2)) * tileSize
			var chainRect = globalTileRect(chainPos)
			var chainRectShadow = chainRect
			chainRect.position += chainOffset
			chainRectShadow.position += chainOffset + Vector2(4, 4)
			draw_texture_rect_region(chainTileSetTexture, chainRectShadow, chainTextureRect, Color(0.0, 0.0, 0.0, 0.5))
			draw_texture_rect_region(chainTileSetTexture, chainRect, chainTextureRect, chainColor)

func drawDroppedChains():
	for i in range(droppedChains.size()):
		var droppedChain = droppedChains[i]
		var droppedChainPos = droppedChain["position"]
		var droppedChainTextureRect = chainTextureRect({"shape":droppedChain["shape"],"rotation":droppedChain["rotation"],"rotationStep":0,"visibleConnections":[false, false, false, false]})
		var droppedChainColor = chainColors[droppedChain["color"]]
		var droppedChainRect = globalTileRect(droppedChainPos)
		var droppedChainRectShadow = droppedChainRect
		droppedChainRectShadow.position += Vector2(4, 4)
		draw_texture_rect_region(chainTileSetTexture, droppedChainRectShadow, droppedChainTextureRect, Color(0.0, 0.0, 0.0, 0.5))
		draw_texture_rect_region(chainTileSetTexture, droppedChainRect, droppedChainTextureRect, droppedChainColor)

func prepareCharacterSet():
	var characterSetFile = File.new()
	characterSetFile.open("res://font/small.txt", characterSetFile.READ)
	var characterSetOffset = 0
	while !characterSetFile.eof_reached():
		var character = characterSetFile.get_line()
		var characterWidth = int(characterSetFile.get_line())
		characterSet[character] = {"offset":characterSetOffset,"width":characterWidth}
		characterSetOffset += characterWidth
	characterSetFile.close()

func characterTextureRect(character):
	if characterSet.has(character):
		var characterData = characterSet[character]
		return Rect2(Vector2(characterData["offset"], 0), Vector2(characterData["width"], characterSetTexture.get_size()[1]))

func drawCharacter(characterPos, character, characterColor = Color(1.0, 1.0, 1.0), characterFlags = {}):
	if characterFlags.has("shadow") && characterFlags["shadow"]:
		characterFlags.erase("shadow")
		drawCharacter(characterPos + characterPixelSize, character, Color(0.0, 0.0, 0.0, 0.5), characterFlags)
	var characterTextureRect = characterTextureRect(character)
	var characterRect = Rect2(characterPos, characterTextureRect.size * characterPixelSize)
	draw_texture_rect_region(characterSetTexture, characterRect, characterTextureRect, characterColor)

func drawText(textPos, text, textColor = Color(1.0, 1.0, 1.0), textFlags = {}):
	var characterOffset = Vector2(0, 0)
	for i in range(len(text)):
		var character = text[i]
		if character == "\n":
			characterOffset[0] = 0
			characterOffset[1] += 8 * characterPixelSize[1]
		else:
			drawCharacter(textPos + characterOffset, character, textColor, textFlags.duplicate())
			characterOffset[0] += (characterSet[character]["width"] + 1) * characterPixelSize[0]