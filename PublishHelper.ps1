
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$title = 'NuGetApiKey'
$msg   = 'Enter you powershell gallery NuGetApiKey:'
$text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
Publish-Module -Path "C:\base\github.com\NaitWatch\SetUpBasic\SetUpBasic" -NuGetApiKey "$text" -Repository "PSGallery"