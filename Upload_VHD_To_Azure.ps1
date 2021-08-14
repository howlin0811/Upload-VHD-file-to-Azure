### PS Steps to Create New OS Disk in Azure and Upload VHD to OS Disk ###
#Set Subscription ID, VHD file name, resource group, disk name, location, disk size and configuration //Standard_LRS
$SubsctiptionID = 'Subscription ID'
$VHDName = 'C:\Users\user\Downloads\xxx.vhd'
$ResourceGroupName = 'Resource Group Name'
$DiskName = 'Disk-Name-OS'
$Location = 'Location'
$vhdSizeBytes = (Get-Item $VHDName).length
$diskconfig = New-AzDiskConfig -SkuName 'Premium_LRS' -OsType 'Linux' -UploadSizeInBytes $vhdSizeBytes -Location $Location -HyperVGeneration 'V2' -CreateOption 'Upload'

#Connect to Azure
Connect-AzAccount

#Change subscription
Select-AzSubscription -SubscriptionID $SubsctiptionID

#Get disk size

#Create new disk
New-AzDisk -ResourceGroupName $ResourceGroupName -DiskName $DiskName -Disk $diskconfig

#Grant access to disk for upload
$diskSas = Grant-AzDiskAccess -ResourceGroupName $ResourceGroupName -DiskName $DiskName -DurationInSecond 86400 -Access 'Write'

#Set disk parameter and check status of disk
$disk = Get-AzDisk -ResourceGroupName $ResourceGroupName -DiskName $DiskName

#Ready to upload
#Copy VHD to disk **Note run from folder where AzCopy exe is located**
#Note: upload is dependent on your internet connection and host machine. It took me about 20 min on a 40Mbps network connection and Surface Book 3**
./AzCopy.exe copy $VHDName $diskSas.AccessSAS --blob-type PageBlob

#Revoke access to disk
Revoke-AzDiskAccess -ResourceGroupName $ResourceGroupName -DiskName $DiskName