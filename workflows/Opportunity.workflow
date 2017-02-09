<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Fleet_Contract_Due</fullName>
        <description>Fleet Contract Due</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Toyota/Fleet_Contract_Due</template>
    </alerts>
    <rules>
        <fullName>Fleet Contract Due</fullName>
        <actions>
            <name>Fleet_Contract_Due</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>CloseDate =  TODAY()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
