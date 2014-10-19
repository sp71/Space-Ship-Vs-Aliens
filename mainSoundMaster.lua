local mainSoundMaster = {}
local mySoundTable = {}
local currentSound = {}
currentSound.isPaused = false
currentSound.BGMOption = {
	channel=2,
	loops=-1,
	fadein=1000
}
function mainSoundMaster.initializeSoundMaster ()
	mySoundTable.BGM = {
		{myBGM = audio.loadSound ("pop.wav") },
		{myBGM = audio.loadSound ("laser_shot.wav") },
		{myBGM = audio.loadSound ("WOOOOW.wav") },
		{myBGM = audio.loadSound ("flight.wav") },
		{myBGM = audio.loadSound ("moveSound.wav") },
		{myBGM = audio.loadSound ("explosion.wav") }
	}
	mySoundTable.SFX = {
		{mySFX = audio.loadSound ("pop.wav"), ID = "pop"},
		{mySFX = audio.loadSound ("laser_shot.wav"), ID = "laser"},
		{mySFX = audio.loadSound ("moveSound.wav"), ID = "mov"},
		{mySFX = audio.loadSound ("flight.wav"), ID = "fly"},
		{mySFX = audio.loadSound ("WOOOOW.wav"), ID = "wow"},
		{mySFX = audio.loadSound ("explosion.wav"), ID = "exp"}

	}
end
function mainSoundMaster.playBGM ()
	currentSound.BGMChannel = audio.play(mySoundTable.BGM[1].myBGM, currentSound.BGMOption)
end
function mainSoundMaster.playButtonSound (_buttonID)
	for i=1, #mySoundTable.SFX do
		if (_buttonID == mySoundTable.SFX[i].ID) then
			audio.play (mySoundTable.SFX[i].mySFX)
		end
	end
end


function mainSoundMaster.cleanUp ()
	for i=1, #mySoundTable.BGM do
		if (_buttonID == mySoundTable.SFX[i].ID) then
			audio.dispose (mySoundTable.SFX[i].mySFX)
		end
	end
	for i=1, #mySoundTable.SFX do
		if (_buttonID == mySoundTable.SFX[i].ID) then
			audio.dispose (mySoundTable.SFX[i].mySFX)
		end
	end
end

return mainSoundMaster