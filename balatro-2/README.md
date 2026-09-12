# Balatro Web port
**DISCLAIMER: Balatro(TM) is a trademark of localthunk, this project has in no way been endorsed by localthunk. all rights reserved.**<br>
disclaimer 2: Sorry for the bad spelling, i genuinely cant figure out the differences between some words like "which","witch","wich" and "whitch" so i basicly use them interchangeably same with puncuation, i use way to many commas not enough periods, my bad :(<br>

# Features:

1.) A port of the full game using love.js.<br>
2.) A save export and importer.<br>
3.) Ports of multiple mods including but not limited to "Mikas Mod Collection", "Jank Jonklers", "Lord Minimus" and many more either not listed or on their way!<br>

# How to build:

1.) Open powershell (has to be powershell) and cd into the root of this project
2.) type "./build.ps1" and run it
3.) to play it run "python server.py" in the same directory



# Background:<br>

Balatro is a game made by Solo dev localthunk and published by playstack, made in LÖVE, a foss cross platform game engine using lua for scripting<br>

# Porting process:<br>

I started this project knowing nothing about lua or LÖVE so the first thing i did was opened the LÖVE wiki, this where i found 3 links, <br>
* [Programming in Lua (first edition)](http://lua.org/pil)<br>
* [Lua-Users Tutorials](http://lua-users.org/wiki/TutorialDirectory)<br>
* [Lua 5.1 Reference Manual](http://www.lua.org/manual/5.1/)<br>
if you want to learn lua they are a great place to start, anyway i learned up on lua and LÖVE for a few weeks and i figured i was ready to atleast get the source code out of the game<br>
so i did... the balatro executable is basicly a zip file with a built in LÖVE runner so you can just extract the code out of that using winrar or peazip,<br>
with this code the first thing i did was remove the steam dependentcy (wich turned out to not go that deep into the source code so it was just a single block of code removal and that was basicly it.<br>
i then tried to get love.js to compile, had some trouble with love.js opening as a js file not running as a script but eventually i settled on the love.js.cmd Balatro -m 134217728 command wich acually worked to compile a web port, until the errors.<br>
So in a game like balatro in order to run the game quickly you would need to use multiple cpu threads making it possible to do multiple things at the exact same time but with web browsers the closest you can get to this are wasm workers,<br>
but for this you need https and Cross-Origin Isolation wich was not going to happen, so instead i made it run on the main thread, meaning the closest you can get to multitasking are coroutines basicly telling 1 part of the program to pause while somthing is being dome then instanly resumes after finishing.<br>
To get audio to work i had to make a lua to js compatability layer via browser_fs.js (browserFs) to get audio working, after that hurdle i then found out that randomness was infact suddenly deterministic, i honestly blacked out during the making of the random fix
but in the end the only thing i can remember from it is the fact that the shop would always give you mega celectial packs no matter what, dont remember the fix though...<br>
I then basicly build the game, did some css, and released it on my website (https://dooble.lat) not touching for months it until one of my freinds said "I wish your balatro could save saves." and i thought "thats acually a good idea".<br>
so i went home and realized i forgot all my lua and LÖVE knowlege so after touching up i got to work, i first thought, "can i just use fsapi"  and set that up between lua and browserfs... turns out to use fsapi you need user input, user input that expires after miliseconds, so by the time the browser fs got the cmd to send fsapi it was too late and had already expired<br>
so for exporting i decited to just make it open a download link, just like all other ways of downloading somthing from a website, the import was a little finiky, eventually using fsapi but needing to click somewhere else on screen to activate it.<br>
to get the save data out i used emscripten's readFile module, making it possible to just get data out of the virtual file system, to get it in i used... guess what... the writeFile module, does the exact same thing as read but in reverse, instead of taking data off it puts data on.<br>
although i settled with that final version i explored using drag and drop and clipboard based methods.<br>
after that i realized part of what makes balatro so fun are mods, execept most mod loaders are made for desktop using lovely, without lovely these mod managers could not communicate with the game without needing major changes, so i decided to just port them, directly to balatro.<br>
The only real mod type that could be used is smodded because its made in lua for lua so you can easly run it in LÖVE, exept it depends on lovely, so instead i just made the eqivelant LÖVE to the mods non pure LÖVE and rinse and repeat, i will be taking a break from this project until hackclub flavor town is done :)<br>

# Conclusion:<br>
im tired<br>
go to https://dooble.lat for unblocked school games, Peace<br>
