-- luagit.lua
--
--[[
 Sets the following TeX variables:
  \ifingit = true if in a git repository
  \gitbranch = name of (local) git branch
  \lastgitcommitref = git commit reference
  \lastgitcommitdate = git commit date
  \lastgitcommitname = Author name
  \lastgitcommitemail = Author email
  \ifchangedsincegitcommit = true if changed files in working area since commit

Example git commands
-------------------
$ git log -s
commit 7c750c507d6c68c2360335c23f41346586032a41
Author: Earthspike <nospam@nowhere.net>
Date:   Sat Feb 17 17:46:29 2018 +0000

    Initial commit
--
$ git status
On branch master
Untracked files:
  (use "git add <file>..." to include in what will be committed)

        luagit.aux
        luagit.log
        luagit.lua
        luagit.lua~
        luagit.pdf
        luagit.tex
        luagit.tex~

nothing added to commit but untracked files present (use "git add" to track)
--
$ git status
On branch master
Your branch is up-to-date with 'origin/master'.

nothing to commit, working directory clean
--
On branch master
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

        new file:   luagit.tex

Untracked files:
  (use "git add <file>..." to include in what will be committed)

        luagit.aux
        luagit.log
        luagit.lua
        luagit.lua~
        luagit.pdf
        luagit.tex~
--
$ git status
On branch master
nothing to commit, working directory clean
--]]

-- Define and default all TeX variables as if not in a git repo
tex.print("\\newif\\ifingit\\ingitfalse")
tex.print("\\def\\gitbranch{}\\def\\lastgitcommitref{}\\def\\lastgitcommitdate{}")
tex.print("\\def\\lastgitcommitname{}\\def\\lastgitcommitemail{}")
tex.print("\\newif\\ifchangedsincegitcommit\\changedsincegitcommittrue")

local handle = io.popen("git status")
local result = handle:read("*a")
local success, err = handle:close()

local gitrepo = success
local gitbranch = ""
local gitcommit = ""
local gitauthorname = ""
local gitauthoremail = ""
local gitcommitdate = ""
local gitchanged = false

-- local result=lua.version
-- tex.print(result)
if success then
   -- We're in a git repository
   tex.print("\\ingittrue")
   -- Break result into lines
   local lines = {}
   result:gsub("[^\10]+", function(l)
		  lines[#lines + 1] = l
			  end)
   -- Extract the git branch name
   gitbranch = lines[1]:match("On branch (.+)")
   tex.print("\\def\\gitbranch{" .. gitbranch .. "}")

   -- Check that working area is still clean
   local test_phrase = "nothing to commit, working directory clean"
   if lines[#lines]:sub(1,string.len(test_phrase)) == test_phrase then
      tex.print("\\changedsincegitcommitfalse")
   end

   -- Now get details of the last commit from `git log -s`
   local handle = io.popen("git log -s")
   local result = handle:read("*a")
   local success, err = handle:close()

   if success then
      -- Break into lines
      lines = {}
      result:gsub("[^\10]+", function(l)
		     lines[#lines + 1] = l
			     end)
      -- Get the commit reference 
      gitcommit = lines[1]:match("commit (%x+)")
      tex.print("\\def\\lastgitcommitref{" .. gitcommit .. "}")
      -- Get the author name and email
      gitauthorname, gitauthoremail = lines[2]:match("Author: (.+) <(.+)>")
      tex.print("\\def\\lastgitcommitname{" .. gitauthorname .. "}\\def\\lastgitcommitemail{" .. gitauthoremail .. "}")
      -- Get the date
      gitcommitdate = lines[3]:match("Date:%s+(.+)")
      tex.print("\\def\\lastgitcommitdate{" .. gitcommitdate .. "}")
   else
      -- No git log (empty repo)
      tex.print("\\def\\lastgitcommitref{(Empty repository)}")
   end
end
