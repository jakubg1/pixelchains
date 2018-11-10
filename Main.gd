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

func restrictValue(value, minValue, maxValue):
	return max(min(value, maxValue), minValue)

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
	
	calculateAnimations()
	
	update()

var scene = "game"
var timeAttack = true
var levelData = {
	"target":50,
	"tiles":[
		Vector2(0,3),Vector2(0,4),Vector2(0,5),
		Vector2(1,3),Vector2(1,4),Vector2(1,5),
		Vector2(2,3),Vector2(2,4),Vector2(2,5),
		Vector2(3,0),Vector2(3,1),Vector2(3,2),Vector2(3,3),Vector2(3,4),Vector2(3,5),Vector2(3,6),Vector2(3,7),Vector2(3,8),
		Vector2(4,0),Vector2(4,1),Vector2(4,2),Vector2(4,3),Vector2(4,4),Vector2(4,5),Vector2(4,6),Vector2(4,7),Vector2(4,8),
		Vector2(5,0),Vector2(5,1),Vector2(5,2),Vector2(5,3),Vector2(5,4),Vector2(5,5),Vector2(5,6),Vector2(5,7),Vector2(5,8),
		Vector2(6,3),Vector2(6,4),Vector2(6,5),
		Vector2(7,3),Vector2(7,4),Vector2(7,5),
		Vector2(8,3),Vector2(8,4),Vector2(8,5)
	],
#	"tile":[
#	[
#		Vector2(0,0),Vector2(0,1),Vector2(0,2),Vector2(0,3),Vector2(0,4),Vector2(0,5),Vector2(0,6),Vector2(0,7),Vector2(0,8),
#		Vector2(1,0),Vector2(1,1),Vector2(1,2),Vector2(1,3),Vector2(1,4),Vector2(1,5),Vector2(1,6),Vector2(1,7),Vector2(1,8),
#		Vector2(2,0),Vector2(2,1),Vector2(2,2),Vector2(2,3),Vector2(2,4),Vector2(2,5),Vector2(2,6),Vector2(2,7),Vector2(2,8),
#		Vector2(3,0),Vector2(3,1),Vector2(3,2),Vector2(3,3),Vector2(3,4),Vector2(3,5),Vector2(3,6),Vector2(3,7),Vector2(3,8),
#		Vector2(4,0),Vector2(4,1),Vector2(4,2),Vector2(4,3),Vector2(4,4),Vector2(4,5),Vector2(4,6),Vector2(4,7),Vector2(4,8),
#		Vector2(5,0),Vector2(5,1),Vector2(5,2),Vector2(5,3),Vector2(5,4),Vector2(5,5),Vector2(5,6),Vector2(5,7),Vector2(5,8),
#		Vector2(6,0),Vector2(6,1),Vector2(6,2),Vector2(6,3),Vector2(6,4),Vector2(6,5),Vector2(6,6),Vector2(6,7),Vector2(6,8),
#		Vector2(7,0),Vector2(7,1),Vector2(7,2),Vector2(7,3),Vector2(7,4),Vector2(7,5),Vector2(7,6),Vector2(7,7),Vector2(7,8),
#		Vector2(8,0),Vector2(8,1),Vector2(8,2),Vector2(8,3),Vector2(8,4),Vector2(8,5),Vector2(8,6),Vector2(8,7),Vector2(8,8)
#	],
#	[
#		Vector2(0,2),Vector2(0,3),Vector2(0,4),Vector2(0,5),Vector2(0,6),
#		Vector2(1,1),Vector2(1,2),Vector2(1,3),Vector2(1,4),Vector2(1,5),Vector2(1,6),Vector2(1,7),
#		Vector2(2,0),Vector2(2,1),Vector2(2,2),Vector2(2,3),Vector2(2,4),Vector2(2,5),Vector2(2,6),Vector2(2,7),Vector2(2,8),
#		Vector2(3,0),Vector2(3,1),Vector2(3,2),Vector2(3,6),Vector2(3,7),Vector2(3,8),
#		Vector2(4,0),Vector2(4,1),Vector2(4,2),Vector2(4,6),Vector2(4,7),Vector2(4,8),
#		Vector2(5,0),Vector2(5,1),Vector2(5,2),Vector2(5,6),Vector2(5,7),Vector2(5,8),
#		Vector2(6,0),Vector2(6,1),Vector2(6,2),Vector2(6,3),Vector2(6,4),Vector2(6,5),Vector2(6,6),Vector2(6,7),Vector2(6,8),
#		Vector2(7,1),Vector2(7,2),Vector2(7,3),Vector2(7,4),Vector2(7,5),Vector2(7,6),Vector2(7,7),
#		Vector2(8,2),Vector2(8,3),Vector2(8,4),Vector2(8,5),Vector2(8,6)
#	],
#	[
#		Vector2(0,3),Vector2(0,4),Vector2(0,5),
#		Vector2(1,3),Vector2(1,4),Vector2(1,5),
#		Vector2(2,3),Vector2(2,4),Vector2(2,5),
#		Vector2(3,0),Vector2(3,1),Vector2(3,2),Vector2(3,3),Vector2(3,4),Vector2(3,5),Vector2(3,6),Vector2(3,7),Vector2(3,8),
#		Vector2(4,0),Vector2(4,1),Vector2(4,2),Vector2(4,3),Vector2(4,4),Vector2(4,5),Vector2(4,6),Vector2(4,7),Vector2(4,8),
#		Vector2(5,0),Vector2(5,1),Vector2(5,2),Vector2(5,3),Vector2(5,4),Vector2(5,5),Vector2(5,6),Vector2(5,7),Vector2(5,8),
#		Vector2(6,3),Vector2(6,4),Vector2(6,5),
#		Vector2(7,3),Vector2(7,4),Vector2(7,5),
#		Vector2(8,3),Vector2(8,4),Vector2(8,5)
#	],
#	[
#		Vector2(0,4),
#		Vector2(1,3),Vector2(1,4),Vector2(1,5),
#		Vector2(2,2),Vector2(2,3),Vector2(2,4),Vector2(2,5),Vector2(2,6),
#		Vector2(3,1),Vector2(3,2),Vector2(3,3),Vector2(3,4),Vector2(3,5),Vector2(3,6),Vector2(3,7),
#		Vector2(4,0),Vector2(4,1),Vector2(4,2),Vector2(4,3),Vector2(4,4),Vector2(4,5),Vector2(4,6),Vector2(4,7),Vector2(4,8),
#		Vector2(5,1),Vector2(5,2),Vector2(5,3),Vector2(5,4),Vector2(5,5),Vector2(5,6),Vector2(5,7),
#		Vector2(6,2),Vector2(6,3),Vector2(6,4),Vector2(6,5),Vector2(6,6),
#		Vector2(7,3),Vector2(7,4),Vector2(7,5),
#		Vector2(8,4)
#	],
#	[
#		Vector2(1,2),Vector2(1,3),Vector2(1,4),Vector2(1,5),Vector2(1,6),
#		Vector2(2,1),Vector2(2,2),Vector2(2,3),Vector2(2,4),Vector2(2,5),Vector2(2,6),Vector2(2,7),
#		Vector2(3,0),Vector2(3,1),Vector2(3,2),Vector2(3,6),Vector2(3,7),Vector2(3,8),
#		Vector2(4,0),Vector2(4,1),Vector2(4,7),Vector2(4,8),
#		Vector2(5,0),Vector2(5,1),Vector2(5,2),Vector2(5,6),Vector2(5,7),Vector2(5,8),
#		Vector2(6,1),Vector2(6,2),Vector2(6,3),Vector2(6,4),Vector2(6,5),Vector2(6,6),Vector2(6,7),
#		Vector2(7,2),Vector2(7,3),Vector2(7,4),Vector2(7,5),Vector2(7,6)
#	],
#	[
#		Vector2(0,0),Vector2(0,1),Vector2(0,2),Vector2(0,3),Vector2(0,4),Vector2(0,5),Vector2(0,6),Vector2(0,7),Vector2(0,8),
#		Vector2(1,0),Vector2(1,1),Vector2(1,2),Vector2(1,3),Vector2(1,4),Vector2(1,5),Vector2(1,6),Vector2(1,7),Vector2(1,8),
#		Vector2(2,0),Vector2(2,1),Vector2(2,7),Vector2(2,8),
#		Vector2(3,0),Vector2(3,1),Vector2(3,7),Vector2(3,8),
#		Vector2(4,0),Vector2(4,1),Vector2(4,7),Vector2(4,8),
#		Vector2(5,0),Vector2(5,1),Vector2(5,7),Vector2(5,8),
#		Vector2(6,0),Vector2(6,1),Vector2(6,7),Vector2(6,8),
#		Vector2(7,0),Vector2(7,1),Vector2(7,2),Vector2(7,3),Vector2(7,4),Vector2(7,5),Vector2(7,6),Vector2(7,7),Vector2(7,8),
#		Vector2(8,0),Vector2(8,1),Vector2(8,2),Vector2(8,3),Vector2(8,4),Vector2(8,5),Vector2(8,6),Vector2(8,7),Vector2(8,8)
#	],
#	[
#		Vector2(0,0),Vector2(0,2),Vector2(0,3),Vector2(0,5),Vector2(0,6),Vector2(0,7),Vector2(0,8),
#		Vector2(1,1),Vector2(1,2),Vector2(1,4),Vector2(1,5),Vector2(1,6),Vector2(1,7),Vector2(1,8),
#		Vector2(2,0),Vector2(2,1),Vector2(2,3),Vector2(2,4),Vector2(2,5),Vector2(2,6),Vector2(2,7),Vector2(2,8),
#		Vector2(3,0),Vector2(3,2),Vector2(3,3),Vector2(3,4),Vector2(3,5),Vector2(3,6),Vector2(3,7),Vector2(3,8),
#		Vector2(4,1),Vector2(4,2),Vector2(4,3),Vector2(4,4),Vector2(4,5),Vector2(4,6),Vector2(4,7),
#		Vector2(5,0),Vector2(5,1),Vector2(5,2),Vector2(5,3),Vector2(5,4),Vector2(5,5),Vector2(5,6),Vector2(5,8),
#		Vector2(6,0),Vector2(6,1),Vector2(6,2),Vector2(6,3),Vector2(6,4),Vector2(6,5),Vector2(6,7),Vector2(6,8),
#		Vector2(7,0),Vector2(7,1),Vector2(7,2),Vector2(7,3),Vector2(7,4),Vector2(7,6),Vector2(7,7),
#		Vector2(8,0),Vector2(8,1),Vector2(8,2),Vector2(8,3),Vector2(8,5),Vector2(8,6),Vector2(8,8)
#	],
#	[
#		Vector2(0,0),Vector2(0,1),Vector2(0,2),Vector2(0,3),Vector2(0,4),Vector2(0,5),Vector2(0,6),Vector2(0,7),Vector2(0,8),
#		Vector2(1,0),Vector2(1,2),Vector2(1,4),Vector2(1,6),Vector2(1,8),
#		Vector2(2,0),Vector2(2,1),Vector2(2,2),Vector2(2,3),Vector2(2,4),Vector2(2,5),Vector2(2,6),Vector2(2,7),Vector2(2,8),
#		Vector2(3,0),Vector2(3,2),Vector2(3,4),Vector2(3,6),Vector2(3,8),
#		Vector2(4,0),Vector2(4,1),Vector2(4,2),Vector2(4,3),Vector2(4,4),Vector2(4,5),Vector2(4,6),Vector2(4,7),Vector2(4,8),
#		Vector2(5,0),Vector2(5,2),Vector2(5,4),Vector2(5,6),Vector2(5,8),
#		Vector2(6,0),Vector2(6,1),Vector2(6,2),Vector2(6,3),Vector2(6,4),Vector2(6,5),Vector2(6,6),Vector2(6,7),Vector2(6,8),
#		Vector2(7,0),Vector2(7,2),Vector2(7,4),Vector2(7,6),Vector2(7,8),
#		Vector2(8,0),Vector2(8,1),Vector2(8,2),Vector2(8,3),Vector2(8,4),Vector2(8,5),Vector2(8,6),Vector2(8,7),Vector2(8,8)
#	]
#	]
}

var score = 0
var scoreAnimation = 0
var brokenChains = 0
var levelProgress = 0
var levelProgressAnimation = 0
var combo = 1
var shufflesRemaining = 0
var timeLeft = 60
var gameOverActive = false
var gameOverDrop = false
var gameOverTime = 0
var gameOver = false
var levelComplete = false
var levelEndActive = false
var levelEndTime = 0

var posDirections = [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]
var tileSize = Vector2(64, 64)
var boardSize = Vector2(9, 9)

var boardTiles = {}
var droppedChains = []
var scoreTexts = []
var chainColors = {
	-2:Color(1.0, 1.0, 1.0),
	-1:Color(0.0, 0.0, 0.0),
	0:Color(1.0, 0.0, 0.0),
	1:Color(1.0, 1.0, 0.0),
	2:Color(0.0, 0.0, 1.0),
	3:Color(0.0, 1.0, 0.0),
	4:Color(1.0, 0.5, 0.0)
}
var chainShapes = {
	2:{"pattern":[true, false, true, false],"steps":2},
	3:{"pattern":[true, true, true, false],"steps":4},
	4:{"pattern":[true, true, true, true],"steps":1}
}
var chainPowers = ["2x", "3x", "5x", "s+", "t+"]

var rotatingChainsCount = 0
var fallingChainsCount = 0
var shufflingChainsCount = 0
var interactionAllowed = true

var onscreenMessage = {"type":null,"time":0,"active":false}
var onscreenMessageTypes = {
	"shuffle":{"text":"Shuffling...","color":Color(1.0, 1.0, 0.0),"maxTime":2},
	"gameOverMoves":{"text":"No more shuffles left!","color":Color(1.0, 0.0, 0.0),"maxTime":10},
	"gameOverTime":{"text":"Time's up!","color":Color(1.0, 0.0, 0.0),"maxTime":10},
	"levelComplete":{"text":"Level completed!","color":Color(0.0, 1.0, 0.0),"maxTime":6}
}

func startGame():
	startLevel()

func startLevel():
	initBoard()
	calculateVisibleChainConnections()

func endGame():
	gameOverActive = true
	interactionAllowed = false

func endLevel():
	levelEndActive = true
	interactionAllowed = false

func completeLevel():
	levelComplete = true
	interactionAllowed = false
	displayOnscreenMessage("levelComplete")
	for i in range(boardTiles.size()):
		var boardPos = boardTiles.keys()[i]
		removeChain(boardPos)

func initBoard():
	var levelTiles = levelData["tiles"]
	for i in range(levelTiles.size()):
		var boardPos = levelTiles[i]
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
	var chainColor = random(2, 4)
	#if random(1, 100) == 1:
	#	chainColor = -2
	#if random(1, 50) == 1:
	#	chainColor = -1
	var chainShape = 2
	#if random(1, 3) == 1:
	#	chainShape = 3
	if random(1, 8) == 1:
		chainShape = 4
	var chainRotation = random(0, chainShapes[chainShape]["steps"] - 1)
	var chainPower = null
	if random(1, 100) == 1:
		if timeAttack:
			chainPower = "t+"
		else:
			chainPower = "s+"
	if random(1, 100) == 1:
		chainPower = "5x"
	if random(1, 50) == 1:
		chainPower = "3x"
	if random(1, 20) == 1:
		chainPower = "2x"
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
		"shuffleActive":false,
		"gameOverTime":0,
		"gameOverOffset":Vector2(0, 0),
		"power":chainPower
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
		var chainMatchPos = Vector2(0, 0)
		var chainMatchScoreMultiplier = 1
		var chainMatchExtraShuffles = 0
		var chainMatchExtraTime = 0
		for j in range(chainMatch.size()):
			var chainPos = chainMatch[j]
			var chain = getChain(chainPos)
			if chain["power"] == "2x":
				chainMatchScoreMultiplier *= 2
			if chain["power"] == "3x":
				chainMatchScoreMultiplier *= 3
			if chain["power"] == "5x":
				chainMatchScoreMultiplier *= 5
			if chain["power"] == "s+":
				chainMatchExtraShuffles += 1
			if chain["power"] == "t+":
				chainMatchExtraTime += 5
			removeChain(chainPos)
			chainMatchPos += chainPos
		chainMatchPos /= chainMatch.size()
		var addedScore = (((chainMatch.size() - 2) * 100) * combo) * chainMatchScoreMultiplier
		scoreTexts.append({"score":addedScore,"combo":combo,"multiplier":chainMatchScoreMultiplier,"extraShuffles":chainMatchExtraShuffles,"extraTime":chainMatchExtraTime,"position":chainMatchPos,"time":0})
		score += addedScore
		combo += 1
		brokenChains += chainMatch.size()
		levelProgress = float(brokenChains) / levelData["target"]
		shufflesRemaining += chainMatchExtraShuffles
		timeLeft += chainMatchExtraTime
	if !chainMatches.empty():
		fillHoles()
		fillHolesUp()
		interactionAllowed = false
	else:
		if brokenChains >= levelData["target"]:
			completeLevel()
		elif !checkMoves():
			if !timeAttack && shufflesRemaining == 0:
				endGame()
			else:
				displayOnscreenMessage("shuffle")

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
	if chain["rotationActive"] || (chain["color"] == -1 || chainShapes[chain["shape"]]["steps"] == 1):
		return
	chain["rotationActive"] = true
	rotatingChainsCount += 1
	combo = 1

func removeChain(chainPos):
	var chain = getChain(chainPos)
	if chain == null:
		return
	boardTiles[chainPos].erase("chain")
	var chainDropped = chain.duplicate()
	chainDropped["rotationStep"] = 0
	chainDropped["rotationStepTime"] = 0
	chainDropped["rotationActive"] = false
	chainDropped["visibleConnections"] = [false, false, false, false]
	chainDropped["position"] = chainPos
	chainDropped["velocity"] = Vector2(random(-25, 25) / 10.0, random(-75, -50) / 10.0)
	chainDropped["time"] = 0
	droppedChains.append(chainDropped)

func shuffleChains():
	interactionAllowed = false
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
	if !timeAttack:
		shufflesRemaining -= 1

func calculateAnimations():
	# Chain animating
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
				rotatingChainsCount -= 1
				if rotatingChainsCount == 0:
					detectChainMatches()
				calculateVisibleChainConnection(boardPos, true)
		if chain["fallOffset"] > 0:
			if chain["fallSpeed"] == 0:
				calculateVisibleChainConnection(boardPos, true)
			chain["fallSpeed"] += dt * 20
			chain["fallOffset"] -= chain["fallSpeed"] * dt
			if chain["fallOffset"] <= 0:
				chain["fallSpeed"] = 0
				chain["fallOffset"] = 0
				fallingChainsCount -= 1
				calculateVisibleChainConnection(boardPos, true)
		if chain["shuffleActive"]:
			if chain["shuffleTime"] == 0:
				calculateVisibleChainConnection(boardPos)
			chain["shuffleTime"] += dt
			if chain["shuffleTime"] >= 1:
				chain["shuffleTime"] = 0
				chain["shufflePosition"] = Vector2(0, 0)
				chain["shuffleActive"] = false
				shufflingChainsCount -= 1
				if shufflingChainsCount == 0:
					calculateVisibleChainConnections()
		if gameOverActive:
			chain["gameOverTime"] += dt
			while chain["gameOverTime"] >= 0.02:
				chain["gameOverTime"] -= 0.02
				chain["gameOverOffset"] = Vector2(random(-2, 2) * 4, random(-2, 2) * 4)
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
	# Messages
	if onscreenMessage["active"]:
		var onscreenMessageData = onscreenMessageTypes[onscreenMessage["type"]]
		onscreenMessage["time"] += dt
		if onscreenMessage["time"] >= onscreenMessageData["maxTime"]:
			onscreenMessage["time"] = 0
			onscreenMessage["active"] = false
			if onscreenMessage["type"] == "shuffle":
				shuffleChains()
			if onscreenMessage["type"] == "gameOverMoves" || onscreenMessage["type"] == "gameOverTime" || onscreenMessage["type"] == "levelComplete":
				endLevel()
	# Score
	scoreAnimation = round(min(scoreAnimation + (((score - scoreAnimation) + 100) * dt), score))
	# Score texts
	for i in range(scoreTexts.size()):
		if i >= scoreTexts.size():
			break
		var scoreText = scoreTexts[i]
		scoreText["time"] += dt
		if scoreText["time"] >= 2:
			scoreTexts.remove(i)
			i -= 1
	# User interaction
	if (fallingChainsCount == 0 && shufflingChainsCount == 0) && (!onscreenMessage["active"] && (!gameOver && !gameOverActive && !levelComplete)):
		if !interactionAllowed:
			interactionAllowed = true
			detectChainMatches()
	elif interactionAllowed:
		interactionAllowed = false
	# Time counting
	if timeAttack && interactionAllowed:
		timeLeft -= dt
		if timeLeft <= 0:
			timeLeft = 0
			endGame()
	# Game over
	if gameOverActive && !gameOver:
		gameOverTime += dt
		if gameOverTime >= 2:
			for i in range(boardTiles.size()):
				var boardPos = boardTiles.keys()[i]
				var chain = getChain(boardPos)
				if chain == null:
					continue
				removeChain(boardPos)
			gameOverTime = 0
			gameOverActive = false
			gameOver = true
			gameOverDrop = true
	if gameOverDrop && droppedChains.empty():
		gameOverDrop = false
		if timeAttack:
			displayOnscreenMessage("gameOverTime")
		else:
			displayOnscreenMessage("gameOverMoves")
	# Level end
	if levelEndActive:
		levelEndTime += dt
		if levelEndTime >= ((boardSize[0] + boardSize[1]) * 0.05) + 1:
			levelEndTime = 0
			levelEndActive = false
			scene = "menu"

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

func displayOnscreenMessage(type):
	onscreenMessage = {"type":type,"time":0,"active":true}
	interactionAllowed = false



# These variables are necessary because dynamic loading doesn't work anymore.
var tileTexture = load("res://img/tile.png")
var chainTileSetTexture = load("res://img/chaintileset.png")
var chainPowerTileSetTexture = load("res://img/powertileset.png")

# Of course, this array will be loaded from external file.
var fonts = {
	"small":{
		"texture":load("res://font/small.png"),
		"characters":{},
		"heightOffset":0
	},
	"normal":{
		"texture":load("res://font/normal.png"),
		"characters":{},
		"heightOffset":0
	}
}
var characterPixelSize = Vector2(4, 4)

func _draw():
	if scene == "menu":
		drawText(windowSize / 2, "Pixelchains\n\nCurrent user: jakubg1   Change\nClassic mode\nTime attack\nLeaderboard\nHelp\nSettings\nExit\n\n\n\nVersion: Alpha 0.0.0\nMenu placeholder; not for use!", "normal", Color(1.0, 1.0, 0.0), {"shadow":true,"halign":0,"valign":0})
	if scene == "game":
		drawBoardTiles()
		drawBoardChains()
		drawDroppedChains()
		drawScoreTexts()
		drawOnscreenMessage()
		var barText = "Score: " + str(scoreAnimation) + "\nChains broken: " + str(brokenChains) + "\nProgress: " + str(floor(levelProgress * 100)) + "%"
		if timeAttack:
			barText += "\nTime left: " + str(ceil(timeLeft * 10) / 10.0) + "s"
		else:
			barText += "\nShuffles remaining: " + str(shufflesRemaining)
		drawText(Vector2(8, 8), barText, "normal", Color(1.0, 1.0, 0.0), {"shadow":true})

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

func chainPowerTextureRect(chainPower):
	var chainPowerSpriteSize = Vector2(8, 8)
	var chainPowerSpritePos = Vector2(chainPowers.find(chainPower), 0)
	return Rect2(chainPowerSpritePos * chainPowerSpriteSize, chainPowerSpriteSize)

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
				var tileRect = globalTileRect(boardPos)
				var tileRectSize = 1
				if levelEndActive:
					tileRectSize = restrictValue(1 - (levelEndTime - ((i + j) * 0.05)), 0.0, 1.0)
				tileRect.position += (tileSize / 2) * (1 - tileRectSize)
				tileRect.size *= tileRectSize
				draw_texture_rect(tileTexture, tileRect, false)

func drawBoardChains():
	for i in range(boardTiles.size()):
		var chainPos = boardTiles.keys()[i]
		var chain = getChain(chainPos)
		drawChain(chainPos, chain)

func drawDroppedChains():
	for i in range(droppedChains.size()):
		var droppedChain = droppedChains[i]
		var droppedChainPos = droppedChain["position"]
		drawChain(droppedChainPos, droppedChain)

func drawChain(boardPos, chain):
	if chain == null:
		return
	var chainTextureRect = chainTextureRect(chain)
	var chainColor = chainColors[chain["color"]]
	var chainOffset = Vector2(0, chain["fallOffset"] * -tileSize[1]) + chain["gameOverOffset"]
	if chain["shuffleActive"]:
		chainOffset += ((chain["shufflePosition"] - boardPos) * ((sin((chain["shuffleTime"] * PI) + (PI / 2)) + 1) / 2)) * tileSize
	var chainRect = globalTileRect(boardPos)
	var chainRectShadow = chainRect
	chainRect.position += chainOffset
	chainRectShadow.position += chainOffset + Vector2(4, 4)
	draw_texture_rect_region(chainTileSetTexture, chainRectShadow, chainTextureRect, Color(0.0, 0.0, 0.0, 0.5))
	draw_texture_rect_region(chainTileSetTexture, chainRect, chainTextureRect, chainColor)
	if chain["power"] != null:
		var chainPowerTextureRect = chainPowerTextureRect(chain["power"])
		var chainPowerRect = chainRect
		var chainPowerRectShadow = chainRectShadow
		chainPowerRect.position += Vector2(16, 16)
		chainPowerRectShadow.position += Vector2(16, 16)
		chainPowerRect.size /= 2
		chainPowerRectShadow.size /= 2
		draw_texture_rect_region(chainPowerTileSetTexture, chainPowerRectShadow, chainPowerTextureRect, Color(0.0, 0.0, 0.0, 0.5))
		draw_texture_rect_region(chainPowerTileSetTexture, chainPowerRect, chainPowerTextureRect, Color(1.0, 1.0, 1.0))

func drawScoreTexts():
	for i in range(scoreTexts.size()):
		var scoreText = scoreTexts[i]
		var scoreTextPos = globalTilePos(scoreText["position"] + Vector2(0.5, 0.5))
		scoreTextPos[1] -= scoreText["time"] * 50
		var scoreTextText = str(scoreText["score"])
		if scoreText["combo"] > 1:
			scoreTextText += "\n" + str(scoreText["combo"]) + "x combo!"
		if scoreText["multiplier"] > 1:
			scoreTextText += "\n" + str(scoreText["multiplier"]) + "x multiplier!"
		if scoreText["extraShuffles"] > 0:
			scoreTextText += "\n+" + str(scoreText["extraShuffles"]) + " extra shuffle"
			if scoreText["extraShuffles"] > 1:
				scoreTextText += "s"
			scoreTextText += "!"
		if scoreText["extraTime"] > 0:
			scoreTextText += "\n+" + str(scoreText["extraTime"]) + "s of time!"
		drawText(scoreTextPos, scoreTextText, "normal", Color(1.0, 1.0, 1.0, min((2 - scoreText["time"]) * 2, 1)), {"shadow":true,"halign":0,"valign":1})

func drawOnscreenMessage():
	if !onscreenMessage["active"]:
		return
	var onscreenMessageData = onscreenMessageTypes[onscreenMessage["type"]]
	var screenAlpha = 0.5
	var messageAlpha = 1.0
	var messageOffset = Vector2(0, 0)
	if onscreenMessage["type"] == "shuffle":
		screenAlpha = restrictValue((abs(onscreenMessage["time"] - 1) - 1) * -1, 0.0, 0.5)
		messageAlpha = restrictValue((abs(onscreenMessage["time"] - 1) - 1) * -2, 0.0, 1.0)
	if onscreenMessage["type"] == "gameOverMoves" || onscreenMessage["type"] == "gameOverTime":
		if onscreenMessage["time"] < 9:
			screenAlpha = restrictValue(onscreenMessage["time"] / 4, 0.0, 0.5)
		if onscreenMessage["time"] >= 9:
			screenAlpha = restrictValue(abs(onscreenMessage["time"] - 10) / 2, 0.0, 0.5)
		messageAlpha = restrictValue((onscreenMessage["time"] - 1) / 3, 0.0, 1.0)
		messageOffset = Vector2(0, pow(restrictValue(onscreenMessage["time"] - 8, 0, 2), 3) * (windowSize[1] / 2))
	if onscreenMessage["type"] == "levelComplete":
		screenAlpha = restrictValue((abs(onscreenMessage["time"] - 2.5) - 2.5) * -1, 0.0, 0.5)
		messageAlpha = restrictValue(5 - onscreenMessage["time"], 0.0, 1.0)
		messageOffset = Vector2((restrictValue(1 - (onscreenMessage["time"] / 0.5), 0.0, 1.0) * 1.2) * (windowSize[0] / 2), 0)
	draw_rect(Rect2(Vector2(0, 0), windowSize), Color(0.0, 0.0, 0.0, screenAlpha), true)
	drawText((windowSize / 2) + messageOffset, onscreenMessageData["text"], "normal", onscreenMessageData["color"] * Color(1.0, 1.0, 1.0, messageAlpha), {"shadow":true,"halign":0,"valign":0})

func prepareCharacterSet():
	for i in range(fonts.size()):
		var fontName = fonts.keys()[i]
		var font = fonts[fontName]
		var fontFile = File.new()
		fontFile.open("res://font/" + fontName + ".txt", fontFile.READ)
		var characterOffset = 0
		font["heightOffset"] = int(fontFile.get_line())
		while !fontFile.eof_reached():
			var character = fontFile.get_line()
			var characterWidth = int(fontFile.get_line())
			font["characters"][character] = {"offset":characterOffset,"width":characterWidth}
			characterOffset += characterWidth
		fontFile.close()

func characterTextureRect(character, characterFont):
	var font = fonts[characterFont]
	var fontCharacters = font["characters"]
	var fontTexture = font["texture"]
	if fontCharacters.has(character):
		var characterData = fontCharacters[character]
		return Rect2(Vector2(characterData["offset"], 0), Vector2(characterData["width"], fontTexture.get_size()[1]))

func drawCharacter(characterPos, character, characterFont, characterColor = Color(1.0, 1.0, 1.0), characterFlags = {}):
	if characterFlags.has("shadow") && characterFlags["shadow"]:
		characterFlags.erase("shadow")
		drawCharacter(characterPos + characterPixelSize, character, characterFont, Color(0.0, 0.0, 0.0, 0.5 * characterColor[3]), characterFlags)
	var font = fonts[characterFont]
	var fontTexture = font["texture"]
	var fontHeightOffset = font["heightOffset"]
	var characterTextureRect = characterTextureRect(character, characterFont)
	var characterRect = Rect2(characterPos, characterTextureRect.size * characterPixelSize)
	characterRect.position[1] -= fontHeightOffset
	draw_texture_rect_region(fontTexture, characterRect, characterTextureRect, characterColor)

func drawTextLine(textPos, text, textFont, textColor = Color(1.0, 1.0, 1.0), textFlags = {}):
	var font = fonts[textFont]
	var fontCharacters = font["characters"]
	var fontTexture = font["texture"]
	if textFlags.has("halign") && textFlags["halign"] != -1:
		var lineLength = 0
		for i in range(len(text)):
			var character = text[i]
			var characterData = fontCharacters[character]
			lineLength += characterData["width"] + 1
		lineLength -= 1
		lineLength *= characterPixelSize[0]
		textPos[0] -= lineLength * ((textFlags["halign"] + 1) / 2.0)
		textFlags.erase("halign")
		drawTextLine(textPos, text, textFont, textColor, textFlags)
		return
	var characterOffset = 0
	for i in range(len(text)):
		var character = text[i]
		var characterPos = textPos + Vector2(characterOffset, 0)
		var characterData = fontCharacters[character]
		drawCharacter(characterPos, character, textFont, textColor, textFlags.duplicate())
		characterOffset += (characterData["width"] + 1) * characterPixelSize[0]

func drawText(textPos, text, textFont, textColor = Color(1.0, 1.0, 1.0), textFlags = {}):
	var font = fonts[textFont]
	var fontTexture = font["texture"]
	var lineHeight = fontTexture.get_size()[1] * characterPixelSize[1]
	var textLines = text.split("\n")
	if textFlags.has("valign") && textFlags["valign"] != -1:
		textPos[1] -= (lineHeight * textLines.size()) * ((textFlags["valign"] + 1) / 2.0)
		textFlags.erase("valign")
		drawText(textPos, text, textFont, textColor, textFlags)
		return
	for i in range(textLines.size()):
		var textLine = textLines[i]
		var textLinePos = textPos + Vector2(0, lineHeight * i)
		drawTextLine(textLinePos, textLine, textFont, textColor, textFlags.duplicate())