import Data.Char

-- 1
normalize :: String -> String
normalize message = 
	if [digit | digit <- message , isDigit digit] == []
		then [toUpper ch | ch <- message , isLetter ch]
		else "error digits not allowed"


--2a
encode :: String -> Char -> Int -> String
encode alphabet ch offset = 
	if ch `elem` alphabet
		then alphabet !! ((findPos ch alphabet + offset) `mod` (length alphabet)) : []
		else  "error unsupported symbol: " ++ [ch] 
	where findPos x arr = head [b | (a,b) <- zip arr [0..length arr-1], a==x]

--2b
encrypt :: String -> Int -> String -> String 
encrypt alphabet offset normalized =
	concat (map (\ x -> encode alphabet x offset) normalized)

--2c
decrypt :: String -> Int -> String -> String 
decrypt alphabet offset encrypted =
	encrypt alphabet (-offset) encrypted

--3a
crackall :: String -> String -> [String]
crackall alphabet encrypted =
	helpCrack alphabet 1 encrypted 
	where helpCrack alphabet offset encrypted 
		|offset == length alphabet           = []
		|otherwise                           = decrypt alphabet offset encrypted : helpCrack alphabet (offset+1) encrypted 

--3b
substring :: String -> String -> Bool
substring sub str 
	|null str  = False
	|otherwise = isPrefix sub str || substring sub (tail str) 
	where isPrefix p str 
		|null p    = True
		|null str  = False
		|otherwise = (head p == head str) && isPrefix (tail p) (tail str)

--3c
crackcandidates :: String -> [String] -> String -> [String]
crackcandidates alphabet commonwords encrypted = 
	[str | str <- crackall alphabet encrypted, isPotential commonwords str]
	where isPotential commonwords str
		| null commonwords = False
		| otherwise        = substring (head commonwords) str || isPotential (tail commonwords) str 

--4а
polyencrypt :: String -> Int -> Int -> Int -> String -> String
polyencrypt alphabet offset step blockSize normalized =
	helpPolyencrypt alphabet offset step blockSize normalized 0
	where helpPolyencrypt alphabet offset step blockSize normalized i
		|null normalized = []
		|otherwise       = encrypt alphabet (offset + i*step) (take blockSize normalized) ++ 
					  	 helpPolyencrypt alphabet offset step blockSize (drop blockSize normalized) (i+1)

--4b 
polydecrypt :: String -> Int -> Int -> Int -> String -> String
polydecrypt alphabet offset step blockSize encrypted = 
	helpPolydecrypt alphabet offset step blockSize encrypted 0
	where helpPolydecrypt alphabet offset step blockSize encrypted i
		|null encrypted = []
		|otherwise      = decrypt alphabet (offset + i*step) (take blockSize encrypted) ++ 
					  	helpPolydecrypt alphabet offset step blockSize (drop blockSize encrypted) (i+1)
	
--5а 
enigmaencrypt :: String -> [(Int,Int,Int)] -> String -> String 
enigmaencrypt alphabet rotors normalized = 
	if null rotors
		then normalized
		else enigmaencrypt alphabet (tail rotors) (polyencrypt alphabet (get1 (head rotors)) (get2 (head rotors)) (get3 (head rotors)) normalized)

--5b 
enigmadecrypt :: String -> [(Int,Int,Int)] -> String -> String 
enigmadecrypt alphabet rotors normalized =
	if null rotors
		then normalized
		else enigmadecrypt alphabet (init rotors) (polydecrypt alphabet (get1 (last rotors)) (get2 (last rotors)) (get3 (last rotors)) normalized)


get1 :: (a, b, c) -> a
get1 (a, _, _) = a

get2 :: (a, b, c) -> b
get2 (_, b, _) = b

get3 :: (a, b, c) -> c
get3 (_, _, c) = c


