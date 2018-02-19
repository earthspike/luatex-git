-- luagitsty.lua
--
-- https://github.com/earthspike/luatex-git
--
-- See luagit.sty for usage details

function print_git_commit_parameter_def(param, tex_macro)
   -- Calls git log for an individual parameter <param> and sets the <tex_macro> to the output
   local handle = io.popen("git log -1 --pretty=format:\"" .. param .. "\"")
   local result = handle:read("*a")
   local success, err = handle:close()

   if success then
      lines = {}
      result:gsub("[^\10]+", function(l)
		     lines[#lines + 1] = l
			     end)
      tex.sprint("\\def\\" .. tex_macro .. "{")
      tex.print(-2,lines)
      tex.print("}")
   else
      tex.sprint("\\def\\" .. tex_macro .. "{")
      tex.sprint(-2, err) -- Render err as catcode 12 except for spaces (catcode 10)
      tex.print("}")
   end
end


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

   print_git_commit_parameter_def("%H","gitcommithash")
   print_git_commit_parameter_def("%h","gitcommithashshort")
   print_git_commit_parameter_def("%T","gitcommittreehash")
   print_git_commit_parameter_def("%t","gitcommittreehashshort")
   print_git_commit_parameter_def("%P","gitcommitparenthashes")
   print_git_commit_parameter_def("%p","gitcommitparenthashesshort")
   print_git_commit_parameter_def("%an","gitcommitauthorname")
   print_git_commit_parameter_def("%aN","gitcommitauthornamemapped")
   print_git_commit_parameter_def("%ae","gitcommitauthoremail")
   print_git_commit_parameter_def("%aE","gitcommitauthoremailmapped")
   print_git_commit_parameter_def("%ai","gitcommitauthordate")
   print_git_commit_parameter_def("%cn","gitcommitcommittername")
   print_git_commit_parameter_def("%cN","gitcommitcomitternamemapped")
   print_git_commit_parameter_def("%ce","gitcommitcommitteremail")
   print_git_commit_parameter_def("%cE","gitcommitcommitteremailmapped")
   print_git_commit_parameter_def("%ci","gitcommitcommitterdate")
   print_git_commit_parameter_def("%d","gitcommitrefnames")
   print_git_commit_parameter_def("%e","gitcommitencoding")
   print_git_commit_parameter_def("%s","gitcommitsubject")
   print_git_commit_parameter_def("%f","gitcommitsubjectsanitised")
   print_git_commit_parameter_def("%b","gitcommitbody")
   print_git_commit_parameter_def("%B","gitcommitbodyraw")
   print_git_commit_parameter_def("%N","gitcommitnotes")
   print_git_commit_parameter_def("%G?","gitcommitsignaturestatus")
   print_git_commit_parameter_def("%GS","gitcommitsigner")
   print_git_commit_parameter_def("%GK","gitcommitkey")
   print_git_commit_parameter_def("%gD","gitcommitreflogselector")
   print_git_commit_parameter_def("%gd","gitcommitreflogselectorshort")
   print_git_commit_parameter_def("%gn","gitcommitreflogidentityname")
   print_git_commit_parameter_def("%gN","gitcommitreflogidentitynamemapped")
   print_git_commit_parameter_def("%ge","gitcommitreflogidentityemail")
   print_git_commit_parameter_def("%gE","gitcommitreflogidentityemailmapped")
   print_git_commit_parameter_def("%gs","gitcommitreflogsubject")
end
