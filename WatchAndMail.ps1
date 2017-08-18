### This script watches a folder.  When new file is created, it waits 45 seconds,
### make a copy of it, then email to a person
### For my purpose, I do not want to check subdirectories


### SET FOLDER TO WATCH + FILES TO WATCH + SUBFOLDERS YES/NO
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = "full path to directory you want to watch"
    $watcher.Filter = "*.*"
    $watcher.IncludeSubdirectories = $false
    $watcher.EnableRaisingEvents = $true  

### DEFINE ACTIONS AFTER AN EVENT IS DETECTED
    $action = { 
        ###copy file after 45 seconds
        $path = $Event.SourceEventArgs.FullPath
		$name = $Event.SourceEventArgs.Name		
        $changeType = $Event.SourceEventArgs.ChangeType

        ###sleep 45 seconds
        ###this is just my way of waiting for the file to finish being written to.
        ###A more safe way would be to check that there are no longer a write lock on
        ###the file.  However, in my situation, multiple applications will try to access the file right after 
        ###it has been created.  Therefore, I am not going to attemped to check the locks. 
        sleep 45
        
        ###add a date stamp
		$stamp= $(get-date -uformat "%m-%d-%y")
        $newname= "your destination directory"+$stamp.ToString()+$name.ToString()
        
        ###make a copy
		Copy-Item $path $newname

        
        ###mail
        $smtpServer = "your smtp server domain"
        $att = new-object Net.Mail.Attachment($newname)
        $msg = new-object Net.Mail.MailMessage
        $smtp = new-object Net.Mail.SmtpClient($smtpServer, 587)
        $smtp.Credentials = New-Object System.Net.NetworkCredential(“user email”, “password”);
        $msg.From = "user email"
        $msg.To.Add("destination email")
        $msg.Subject = "new file attached"
        $msg.Body = "new file attached"
        $msg.Attachments.Add($att)
        $smtp.Send($msg)
        $att.Dispose()
              }    
### DECIDE WHICH EVENTS SHOULD BE WATCHED 
    Register-ObjectEvent $watcher "Created" -Action $action
    
    while ($true) {sleep 5}