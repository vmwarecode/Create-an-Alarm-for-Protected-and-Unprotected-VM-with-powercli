$mailto = "vcenter-alarms@example.org"

$alarmMgr = Get-View AlarmManager


# Create AlarmSpec object

$alarm = New-Object VMware.Vim.AlarmSpec

$alarm.Name = "ProtectedVmRemovedEvent"

$alarm.Description = "Virtual machine in group is no longer configured for protection."

$alarm.Enabled = $TRUE



# Event expression 1 - "Virtual machine in group is no longer configured for protection."

# will change state to "Red"

$expression1 = New-Object VMware.Vim.EventAlarmExpression

$expression1.EventType = "EventEx"

$expression1.eventTypeId = "ProtectedVmRemovedEvent"

$expression1.objectType = "VirtualMachine"

$expression1.status = "red"



 Attribute comparison for expression 1

$comparison1 = New-Object VMware.Vim.EventAlarmExpressionComparison

$comparison1.AttributeName = "ProtectedVmRemovedEvent"

$comparison1.Operator = "notEqualTo"

$comparison1.Value = "1"

$expression1.Comparisons += $comparison1


# Event expression 2 - ProtectedVmRemovedEvent restored

# will change state back to "Green"

$expression2 = New-Object VMware.Vim.EventAlarmExpression

$expression2.EventType = "EventEx"

$expression2.eventTypeId = "ProtectedVmCreatedEvent"

$expression2.objectType = "VirtualMachine"

$expression2.status = "green"


# Add event expressions to alarm

$alarm.expression = New-Object VMware.Vim.OrAlarmExpression

$alarm.expression.expression += $expression1

$alarm.expression.expression += $expression2

 

# Create alarm in vCenter root

$alarmMgr.CreateAlarm("Folder-group-d1",$alarm)

  

# Add action (send mail) to the newly created alarm

Get-AlarmDefinition $alarm.Name | New-AlarmAction -Email -Subject "ProtectedVmRemovedEvent" -To $mailTo

# New-AlarmAction will automatically add the trigger Yellow->Red (!)

 

# Add a second trigger for Yellow->Green

Get-AlarmDefinition $alarm.Name | Get-AlarmAction | New-AlarmActionTrigger -StartStatus "Yellow" -EndStatus "Green"