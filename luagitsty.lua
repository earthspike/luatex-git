-- luagitsty.lua
--
-- https://github.com/earthspike/luatex-git
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

   -- Now get details of the last commit from `git log --pretty:format` using this format:
   local gitlogformat = "\\def\\gitcommithash{%H}\\def\\gitcommithashshort{%h}%n" ..
   	 "\\def\\gitcommittreehash{%T}\\def\\gitcommittreehashshort{%t}%n" ..
	 "\\def\\gitcommitparenthashes{%P}\\def\\gitcommitparenthashesshort{%p}%n" ..
	 "\\def\\gitcommitauthorname{%an}\\def\\gitcommitauthornamemapped{%aN}%n" ..
	 "\\def\\gitcommitauthoremail{%ae}\\def\\gitcommitauthoremailmapped{%aE}%n" ..
	 "\\def\\gitcommitauthordate{%ai}%n" ..
	 "\\def\\gitcommitcommittername{%cn}\\def\\gitcommitcomitternamemapped{%cN}%n" ..
	 "\\def\\gitcommitcommitteremail{%ce}\\def\\gitcommitcommitteremailmapped{%cE}%n" ..
	 "\\def\\gitcommitcommitterdate{%ci}%n" ..
	 "\\def\\gitcommitrefnames{%d}\\def\\gitcommitencoding{%e}%n" ..
	 "\\def\\gitcommitsubject{%s}\\def\\gitcommitsubjectsanitised{%f}%n" ..
	 "\\def\\gitcommitbody{%b}%n" ..
	 "\\def\\gitcommitbodyraw{%B}%n" ..
	 "\\def\\gitcommitnotes{%N}%n" ..
	 "\\def\\gitcommitsignaturestatus{%G?}\\def\\gitcommitsigner{%GS}\\def\\gitcommitkey{%GK}%n"

   local handle = io.popen("git log -1 --pretty=format:\"" .. gitlogformat .. "\"")
   local result = handle:read("*a")
   local success, err = handle:close()

   if success then
      -- Break into lines
      lines = {}
      result:gsub("[^\10]+", function(l)
		     lines[#lines + 1] = l
			     end)
      for i=1,#lines do tex.print(lines[i]) end
--[[
      -- Get the commit reference 
      gitcommit = lines[1]:match("commit (%x+)")
      tex.print("\\def\\lastgitcommitref{" .. gitcommit .. "}")
      -- Get the author name and email
      gitauthorname, gitauthoremail = lines[2]:match("Author: (.+) <(.+)>")
      tex.print("\\def\\lastgitcommitname{" .. gitauthorname .. "}\\def\\lastgitcommitemail{" .. gitauthoremail .. "}")
      -- Get the date
      gitcommitdate = lines[3]:match("Date:%s+(.+)")
      tex.print("\\def\\lastgitcommitdate{" .. gitcommitdate .. "}")
      --]]
   else
      -- No git log (empty repo)
      tex.print("\\def\\lastgitcommithash{(Empty repository)}")
   end
end

--[==[  From git log --help:
           The placeholders are:

           ·   %H: commit hash

           ·   %h: abbreviated commit hash

           ·   %T: tree hash

           ·   %t: abbreviated tree hash

           ·   %P: parent hashes

           ·   %p: abbreviated parent hashes

           ·   %an: author name

           ·   %aN: author name (respecting .mailmap, see git-shortlog(1) or git-blame(1))

           ·   %ae: author email

           ·   %aE: author email (respecting .mailmap, see git-shortlog(1) or git-blame(1))

           ·   %ad: author date (format respects --date= option)

           ·   %aD: author date, RFC2822 style

           ·   %ar: author date, relative

           ·   %at: author date, UNIX timestamp

           ·   %ai: author date, ISO 8601 format

           ·   %cn: committer name

           ·   %cN: committer name (respecting .mailmap, see git-shortlog(1) or git-blame(1))

           ·   %ce: committer email

           ·   %cE: committer email (respecting .mailmap, see git-shortlog(1) or git-blame(1))

           ·   %cd: committer date

           ·   %cD: committer date, RFC2822 style

           ·   %cr: committer date, relative

           ·   %ct: committer date, UNIX timestamp

           ·   %ci: committer date, ISO 8601 format

           ·   %d: ref names, like the --decorate option of git-log(1)

           ·   %e: encoding

           ·   %s: subject

           ·   %f: sanitized subject line, suitable for a filename

           ·   %b: body

           ·   %B: raw body (unwrapped subject and body)

           ·   %N: commit notes

           ·   %GG: raw verification message from GPG for a signed commit

           ·   %G?: show "G" for a Good signature, "B" for a Bad signature, "U" for a good, untrusted signature and "N" for no signature

           ·   %GS: show the name of the signer for a signed commit

           ·   %GK: show the key used to sign a signed commit

           ·   %gD: reflog selector, e.g., refs/stash@{1}

           ·   %gd: shortened reflog selector, e.g., stash@{1}

           ·   %gn: reflog identity name

           ·   %gN: reflog identity name (respecting .mailmap, see git-shortlog(1) or git-blame(1))

           ·   %ge: reflog identity email

           ·   %gE: reflog identity email (respecting .mailmap, see git-shortlog(1) or git-blame(1))

           ·   %gs: reflog subject

           ·   %Cred: switch color to red

           ·   %Cgreen: switch color to green

           ·   %Cblue: switch color to blue

           ·   %Creset: reset color

           ·   %C(...): color specification, as described in color.branch.* config option; adding auto, at the beginning will emit color only when
               colors are enabled for log output (by color.diff, color.ui, or --color, and respecting the auto settings of the former if we are
               going to a terminal).  auto alone (i.e.  %C(auto)) will turn on auto coloring on the next placeholders until the color is switched
               again.

           ·   %m: left, right or boundary mark

           ·   %n: newline

           ·   : a raw %

           ·   %x00: print a byte from a hex code

           ·   %w([<w>[,<i1>[,<i2>]]]): switch line wrapping, like the -w option of git-shortlog(1).

           ·   %<(<N>[,trunc|ltrunc|mtrunc]): make the next placeholder take at least N columns, padding spaces on the right if necessary.
               Optionally truncate at the beginning (ltrunc), the middle (mtrunc) or the end (trunc) if the output is longer than N columns. Note
               that truncating only works correctly with N >= 2.

           ·   %<|(<N>): make the next placeholder take at least until Nth columns, padding spaces on the right if necessary

           ·   %>(<N>), %>|(<N>): similar to %<(<N>), %<|(<N>) respectively, but padding spaces on the left

           ·   %>>(<N>), %>>|(<N>): similar to %>(<N>), %>|(<N>) respectively, except that if the next placeholder takes more spaces than given
               and there are spaces on its left, use those spaces

           ·   %><(<N>), %><|(<N>): similar to % <(<N>), %<|(<N>) respectively, but padding both sides (i.e. the text is centered)

           Note
           Some placeholders may depend on other options given to the revision traversal engine. For example, the %g* reflog options will insert
           an empty string unless we are traversing reflog entries (e.g., by git log -g). The %d placeholder will use the "short" decoration
           format if --decorate was not already provided on the command line.

       If you add a + (plus sign) after % of a placeholder, a line-feed is inserted immediately before the expansion if and only if the
       placeholder expands to a non-empty string.

       If you add a - (minus sign) after % of a placeholder, line-feeds that immediately precede the expansion are deleted if and only if the
       placeholder expands to an empty string.

       If you add a ` ` (space) after % of a placeholder, a space is inserted immediately before the expansion if and only if the placeholder
       expands to a non-empty string.

       ·   tformat:

           The tformat: format works exactly like format:, except that it provides "terminator" semantics instead of "separator" semantics. In
           other words, each commit has the message terminator character (usually a newline) appended, rather than a separator placed between
           entries. This means that the final entry of a single-line format will be properly terminated with a new line, just as the "oneline"
           format does. For example:

               $ git log -2 --pretty=format:%h 4da45bef \
                 | perl -pe '$_ .= " -- NO NEWLINE\n" unless /\n/'
               4da45be
                      7134973 -- NO NEWLINE

               $ git log -2 --pretty=tformat:%h 4da45bef \
                 | perl -pe '$_ .= " -- NO NEWLINE\n" unless /\n/'
               4da45be
               7134973

           In addition, any unrecognized string that has a % in it is interpreted as if it has tformat: in front of it. For example, these two are
           equivalent:

               $ git log -2 --pretty=tformat:%h 4da45bef
               $ git log -2 --pretty=%h 4da45bef
--]==]
