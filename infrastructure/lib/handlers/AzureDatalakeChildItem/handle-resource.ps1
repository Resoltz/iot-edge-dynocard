Param(
    [parameter(Mandatory=$true)]
    [ValidateSet('deploy', 'destroy', 'info')]
    [string] $action,

    [parameter(Mandatory=$true)]
    [string] $name,

    [parameter(Mandatory=$true)]
    [hashtable] $resource
)

## build path to the base project folder
$BASE_PATH = resolve-path (join-path (split-path -parent $MyInvocation.MyCommand.path) "../../..")

## figure out some info about ourself
$SELF_TYPE = $resource.type
$SELF_PATH = split-path -parent $MyInvocation.MyCommand.Path
$SELF_NAME = split-path -leaf $MyInvocation.PSCommandPath

## add utilty_scripts to our path
$SCRIPTS_PATH = (join-path $BASE_PATH "lib/utility_scripts")
if($ENV:PATH -notcontains $SCRIPTS_PATH) {
    $ENV:PATH  = ("{0}{1}{2}" -f $ENV:PATH,[IO.Path]::PathSeparator,$SCRIPTS_PATH)
}

function deploy {
    Param(
        [parameter(Mandatory=$true)]
        [string] $name,

        [parameter(Mandatory=$true)]
        [hashtable] $resource
    )

    foreach($item in $resource.items) {
        switch($item.type) {
            "folder" {
                $item.path | %{
                    New-AzureRmDataLakeStoreItem -Folder -AccountName $resource.datalake -Path $_
                    #$newItem = Get-AzureRmDataLakeStoreItem -AccountName $resource.datalake -Path $_
                    write-info "Created data lake folder '$_' in '$resource.datalake'"
                }
            }
            default {
                write-error "$SELF_TYPE - Unknown item type '$item.type'"
            }
        }
    }
}

function destroy {
    Param(
        [parameter(Mandatory=$true)]
        [string] $name,

        [parameter(Mandatory=$true)]
        [hashtable] $resource
    )
    write-warning "$SELF_PATH does not implement the 'destroy' action."
}

function info {
    Param(
        [parameter(Mandatory=$true)]
        [string] $name,

        [parameter(Mandatory=$true)]
        [hashtable] $resource
    )
    write-warning "$SELF_PATH does not implement the 'info' action." 
}

switch($action) {
    'deploy' {
        deploy -name $name -resource $resource
    }
    'destroy' {
        destroy -name $name -resource $resource
    }
    'info' {
        info -name $name -resource $resource
    }
}
