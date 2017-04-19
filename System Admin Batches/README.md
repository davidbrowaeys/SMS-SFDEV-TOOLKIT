<div style="text-align:right;top: 10px;position: absolute;right: 10px;" markdown="1">
	<img align="right" src="http://www.smsmt.com/hs-fs/hubfs/SMS_Logo-1.png?t=1490163156935&amp;width=300&amp;name=SMS_Logo-1.png"/>
</div>

# System Admin Batches #
Some cool apex batches that can be used by system administrator to facilitate some admin tasks. This can be execute in the Developer Console through the Execute Anonymous features.

## Mass Update Records ##
```java
Database.executeBatch(new SystemMassUpdateRecordsBatch(
			'SELECT Id, Status__c, Account WHERE Status__c = \'Inactive'\',
			new Map<String, Object>{'Status__c' => 'Active'}));
```
## Mass Delete Records ##
```java
Database.executeBatch(new SystemMassDeleteRecordsBatch(
			'SELECT Id, Status__c, Account WHERE Status__c = \'Inactive'\',
			true));
```
