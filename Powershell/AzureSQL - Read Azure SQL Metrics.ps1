﻿<#   
.NOTES     
    Author: Sergio Fonseca
    Twitter @FonsecaSergio
    Email: sergio.fonseca@microsoft.com
    Last Update Date: 2020-10-07

.SYNOPSIS   
   
.DESCRIPTION    
    Script to read Azure SQL DB Metrics 
    https://docs.microsoft.com/en-us/azure/azure-sql/database/scripts/monitor-and-scale-database-powershell
    https://docs.microsoft.com/en-us/azure/azure-monitor/platform/metrics-supported#microsoftsqlserversdatabases
    https://docs.microsoft.com/en-us/powershell/module/az.monitor/get-azmetric?view=azps-4.7.0
 
.PARAMETER xxxx 
       
#> 

$SubscriptionName = "Microsoft Azure Subscription"
$ResourceGroup = "ResGroup"
$ServerName = "Server"
$DBName = "DBName"
$DaysToLook = -2
$TimeGrain = [TimeSpan]::Parse("00:05:00")

#$MetricName = "dtu_consumption_percent"
$MetricName = @("dtu_used", "dtu_limit", "dtu_consumption_percent")

################################################
#CONNECT TO AZURE
Clear-Host

$Context = Get-AzContext

if ($Context -eq $null) {
    Write-Information "Need to login"
    Connect-AzAccount -Subscription $SubscriptionName
}
else
{
    Write-Host "Login was done"
    Write-Host "Current credential is $($Context.Account.Id)"
    $Subscription = Get-AzSubscription -SubscriptionName $SubscriptionName -WarningAction Ignore
    Select-AzSubscription -Subscription $Subscription.Id | Out-Null
    Write-Host "Current subscription is $($Context.Subscription.Name)"
}
################################################

$SubscriptionID = $Subscription.Id
$MonitorParameters = @{
  ResourceId = "/subscriptions/$($SubscriptionID)/resourceGroups/$($ResourceGroup)/providers/Microsoft.Sql/servers/$($ServerName)/databases/$($DBName)"
  TimeGrain = $TimeGrain
  MetricNames = $MetricName
  StartTime = (Get-Date).AddDays($DaysToLook)
}
$Metrics = Get-AzMetric @MonitorParameters -DetailedOutput

foreach ($Metric in $Metrics)
{
    $Resuts += $Metric.Data | Select TimeStamp, Average, @{Name="Metric"; Expression={$Metric.Name.Value}}
}
################################################

$Resuts | Sort-Object -Property TimeStamp, Metric | Format-Table
