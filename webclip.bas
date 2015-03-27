global #db
global #lib
global #user

run "functionLibrary", #lib
run "userObject", #user

#user authenticateSession(UrlKeys$, #null)
if #user id() = 0 then #user loginPage("webclip", "Webclip", #null)

call createDatabase

[reload]
  call connect
  #db execute("select text, timestamp from clipboard where userid = "; #user id())
  if #db hasanswer() then
    #row = #db #nextrow()
    text$ = #row text$()
    timestamp$ = #row timestamp$()
    if message$ = "" then message$ = "Clipboard loaded."
  else
    text$ = ""
    timestamp$ = ""
    if mesage$ = "" then message$ = "Clipboard is empty."
  end if
  call disconnect

[main]
  call startPage

  if message$ <> "" then
    html "<div class=""alert alert-success"">"
    print message$
    html "</div>"
    message$ = ""
  end if

  if transformed then
    html "<div class=""alert alert-success"">"
    print "Transformation applied - clipboard has not been ";
    link #saved, "saved", [save]
    print " yet.";
    html "</div>"
    transformed = 0
  end if

  html "<div id=""clearModal"" class=""modal hide fade"" tabindex=""-1"" role=""dialog"" aria-labelledby=""clearModalLabel"" aria-hidden=""true"">"
  html "<div class=""modal-header"">"
  html "<h3>Confirm Clear Text</h3>"
  html "</div>"
  html "<div class=""modal-body"">"
  html "<p>Clear the saved text? This action cannot be undone.</p>"
  html "</div>"
  html "<div class=""modal-footer"">"
  html "<button class=""btn"" data-dismiss=""modal"" aria-hidden=""true"">Cancel</button>"
  button #clear, "Clear Text", [clear]
  #clear cssclass("btn btn-danger")
  html "</div>"
  html "</div>"

  textarea #text, text$
  #text setfocus()
  html "<p>Last Updated: "; timestamp$; "</p>"
  html "<div class=""btn-group pull-right"">"
  button #lower, "lowercase", [lower]
  #lower cssclass("btn")
  button #upper, "UPPERCASE", [upper]
  #upper cssclass("btn")
  button #rot13, "ROT-13", [rot13]
  #rot13 cssclass("btn")
  html "</div>"
  button #reload, "Reload", [reload]
  #reload cssclass("btn")
  html " "
  button #save, "Save", [save]
  #save cssclass("btn btn-success")
  html " "
  html "<a href=""#clearModal"" role=""button"" class=""btn"" data-toggle=""modal"">Clear</a>"

  call endPage
  html "<script type=""text/javascript"">$('textarea').addClass('input-block-level');</script>"
  wait

[lower]
  text$ = trim$(#text contents$())
  text$ = lower$(text$)
  transformed = 1
  goto [main]

[upper]
  text$ = trim$(#text contents$())
  text$ = upper$(text$)
  transformed = 1
  goto [main]

[rot13]
  text$ = trim$(#text contents$())
  text$ = rot13$(text$)
  transformed = 1
  goto [main]

[save]
  text$ = trim$(#text contents$())
  if text$ = "" then goto [clear]

  call connect
  #db execute("insert or replace into clipboard (userid, text, timestamp) values ("; #user id(); ","; #lib quote$(text$); ",datetime('now'))")
  call disconnect

  message$ = "Clipboard saved."
  goto [reload]

[clear]
  call connect
  #db execute("delete from clipboard where userid = "; #user id())
  call disconnect

  message$ = "Clipboard cleared."
  goto [reload]

[quit]
  expire "/"

[editProfile]
  #user profilePage("webclip", "Webclip - " + #user description$(), #null)

sub connect
  sqliteconnect #db, "databases/webclip.db"
end sub

sub disconnect
  #db disconnect()
end sub

sub createDatabase
  call connect
  #db execute("create table if not exists clipboard (userid integer primary key, text text, timestamp text)")
  call disconnect
end sub

sub startPage
  cls

  if #user id() = 0 then
    titlebar "Webclip"
  else
    titlebar "Webclip- "; #user description$()
  end if

  head "<link href=""//netdna.bootstrapcdn.com/twitter-bootstrap/2.3.2/css/bootstrap-combined.min.css"" rel=""stylesheet"">"

  html "</div>"
  html "<div class=""navbar navbar-static-top navbar-inverse"">"
  html "<div class=""navbar-inner"">"
  html "<a class=""brand"" href=""#"">"
  html "Webclip"
  if #user id() = 0 then
    html "</a>"
  else
    html " - "; #user description$(); "</a>"
    html "<ul class=""nav pull-right"">"
    html "<li class=""dropdown"">"
    html "<a href=""#"" class=""navbar-link dropdown-toggle"" data-toggle=""dropdown"">Options <b class=""caret""></b></a>"
    html "<ul class=""dropdown-menu"">"
    html "<li>"
    link #password, "Edit Profile", [editProfile]
    html "</li>"
    html "<li>"
    link #logut, "Quit", [quit]
    html "</li>"
    html "</ul>"
    html "</li>"
    html "</ul>"
  end if
  html "</div></div><br>"
  html "<div class=""container"">"
end sub

sub endPage
  html "<hr>"
  html "<p class=""muted text-right"">Powered by <a href=""http://www.runbasic.com/"">Run BASIC</a></p>"
  html "</div>"
  html "<script src=""//code.jquery.com/jquery-1.11.1.min.js""></script>"
  html "<script src=""//netdna.bootstrapcdn.com/twitter-bootstrap/2.3.2/js/bootstrap.min.js""></script>"
  html "<div>"
end sub

function rot13$(s$)
  for i = 1 to len(s$)
    c$ = mid$(s$, i, 1)
    c = instr("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", c$)
    if c = 0 then
      rot13$ = rot13$ + c$
    else
      rot13$ = rot13$ + mid$("NOPQRSTUVWXYZABCDEFGHIJKLMnopqrstuvwxyzabcdefghijklm", c, 1)
    end if
  next i  
end function
