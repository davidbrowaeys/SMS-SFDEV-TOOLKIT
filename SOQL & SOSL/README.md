<div style="text-align:right;top: 10px;position: absolute;right: 10px;" markdown="1">
    <img align="right" src="http://www.smsmt.com/hs-fs/hubfs/SMS_Logo-1.png?t=1490163156935&amp;width=300&amp;name=SMS_Logo-1.png"/>
</div>

# SOSL & SOQL #
Are you always rebuilding SQL query over and over in your code. You never thought maybe I could find an easy way to perform SQL. This section is for you and aims to provide a very dynamic way to use SOQL and SOSL.

## SOQL ##
### Retrieve map of records by id ###
```java
Map<Id,SObject> selectMapObject(String objectName, String[] selectFields, Set<Id> idSet){}
```
Example:
```java
List<Account> accList = QueryUtils.selectMapObject(
            'Account',
            new String[]{'Name','Phone'},
            new Set<Id>{'001N000001AvY5n'});
```
If ``javaselectFields`` is null, it will select ALL field of the select object
```java
Qu`eryUtils.selectMapObject('Account',new Set<Id>{'001N000001AvY5n'});
``

### Retrieve map of records by id ###
```java
Map<Id,SObject[]> selectMapChildObject(String objectName, String[] selectFields, String parentFieldName, Set<Id> idSet){}
```
Example:
```java
Map<Id,SObject[]> results = QueryUtils.selectMapChildObject(
        'Contact',
        new String[]{'FirstName','LastName'},
        'AccountId',
        new Set<Id>{'001N000001AvY5n'});
``
## SOSL ##
SOSL is a faster way to access database as it always use index field. SOSL doesn't count toward the query row, but it has it's own limit. It's good to use in the event you don't know what you are searching for and in which objects. 

```java
List<List<SObject>> find(String searchTerm, Map <String,String[]> selectObjects){}
```

Example:
```java
List<List<SObject>> results = QueryUtils.find(
                'albert', new Map<String,String[]>{
                'Account' => new String[]{'Id', 'Name'},
                'Contact' => new String[]{'Id', 'FirstName', 'LastName', 'AccountId'},
                'Lead'    => new String[]{'Id', 'FirstName', 'LastName'}});
```